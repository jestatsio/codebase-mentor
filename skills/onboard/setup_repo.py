#!/usr/bin/env python3
"""Configure small, removable project instructions using Python 3.9+ only."""

import argparse
import json
import os
from pathlib import Path, PurePosixPath, PureWindowsPath
import re
import stat
import tempfile


BEGIN = b"<!-- codebase-mentor:setup:begin -->"
END = b"<!-- codebase-mentor:setup:end -->"
AGENT_PATHS = {
    "codex": ("AGENTS.md", "AGENTS.override.md"),
    "claude": (".claude/rules/codebase-mentor.md",),
    "bob": (".bob/rules/codebase-mentor.md",),
}
MAP_PATHS = ("ONBOARDING.md", "docs/ONBOARDING.md", "doc/ONBOARDING.md")


def _map_name(value):
    """Accept repository-relative document paths safe in Markdown instructions."""
    if not isinstance(value, str) or not value or value in (".", ".."):
        raise ValueError("The map must be a nonempty repository-relative file path.")
    if any(ord(char) < 32 or ord(char) == 127 or char in "`<>\\:" for char in value):
        raise ValueError("The map path contains unsupported control, Markdown, or portable path characters.")
    path = PurePosixPath(value)
    if path.is_absolute() or PureWindowsPath(value).drive or ".." in path.parts or value.endswith("/"):
        raise ValueError("The map must stay inside the repository.")
    return path.as_posix()


def _file_path(root, name):
    """Reject links and nonregular files without following repository symlinks."""
    path = root
    parts = PurePosixPath(name).parts
    for index, part in enumerate(parts):
        path = path / part
        try:
            info = path.lstat()
        except FileNotFoundError:
            continue
        mode = info.st_mode
        if stat.S_ISLNK(mode):
            raise ValueError("Refusing symlink: " + name)
        if getattr(info, "st_file_attributes", 0) & stat.FILE_ATTRIBUTE_REPARSE_POINT:
            raise ValueError("Refusing Windows reparse point: " + name)
        if index < len(parts) - 1 and not stat.S_ISDIR(mode):
            raise ValueError("Expected a directory in: " + name)
        if index == len(parts) - 1 and not stat.S_ISREG(mode):
            raise ValueError("Expected a regular file: " + name)
    return path


def _is_instruction_map(root, name):
    """Use file identity to catch native aliases, including case and hard links."""
    path = _file_path(root, name)
    for names in AGENT_PATHS.values():
        for native_name in names:
            target = root / native_name
            if path == target or (target.exists() and path.samefile(target)):
                return True
    return False


def _managed_block(data):
    """Return exact managed byte offsets and its selected map, if present."""
    begins = list(re.finditer(rb"(?m)^" + re.escape(BEGIN) + rb"(?=\r?$)", data))
    ends = list(re.finditer(rb"(?m)^" + re.escape(END) + rb"(?=\r?$)", data))
    # Also detect misspelled, inline, nested, or duplicated managed markers.
    tokens = data.count(b"<!-- codebase-mentor:setup:")
    if not tokens:
        return None, None
    if len(begins) != 1 or len(ends) != 1 or tokens != 2:
        raise ValueError("Malformed or duplicate Mentor setup markers; existing content preserved.")
    start, stop = begins[0].start(), ends[0].end()
    if stop < start:
        raise ValueError("Reversed Mentor setup markers; existing content preserved.")
    block = data[start:stop]
    metadata = re.findall(rb"(?m)^<!-- codebase-mentor:map (.+) -->\r?$", block)
    if len(metadata) != 1 or block.count(b"<!-- codebase-mentor:map") != 1:
        raise ValueError("Missing or duplicate Mentor map metadata; existing content preserved.")
    try:
        name = _map_name(json.loads(metadata[0]))
    except (ValueError, UnicodeDecodeError) as exc:
        raise ValueError("Invalid Mentor map metadata: " + str(exc)) from exc
    return (start, stop), name


def _inspect(root, name):
    info = {"path": name, "data": b"", "span": None, "map": None, "error": None}
    try:
        path = _file_path(root, name)
        info["data"] = path.read_bytes() if path.exists() else b""
        info["span"], info["map"] = _managed_block(info["data"])
    except (ValueError, OSError) as exc:
        info["error"] = name + ": " + str(exc)
    return info


def _instruction(map_path, newline):
    text = [
        BEGIN.decode(),
        "<!-- codebase-mentor:map " + json.dumps(map_path, ensure_ascii=True) + " -->",
        "Before substantive repository work, read the repo map at `" + map_path + "`",
        "(relative to the repository root), then read the subsystem guides whose scope",
        "matches the task before editing. If a relevant guide link is broken, search",
        "for the moved guide before editing. If recovery fails, state the context gap",
        "and continue from current source. Verify relevant guide claims and source",
        "anchors against current source and tests. Use applicable design constraints,",
        "examples, and verification commands. Keep context gathering proportional to",
        "the change; small edits do not need a full scan. When relevant drift is found,",
        "propose focused corrections to affected routing links and guide claims or",
        "source anchors together for review. Preserve human rationale and unrelated",
        "text. Do not rewrite context without authorization.",
        END.decode(),
    ]
    return newline.join(line.encode("utf-8") for line in text)


def _replacement(info, map_path, remove):
    data, span = info["data"], info["span"]
    if remove:
        return data[:span[0]] + data[span[1]:] if span else data
    newline = b"\r\n" if b"\r\n" in data else b"\n"
    block = _instruction(map_path, newline)
    if span:
        return data[:span[0]] + block + data[span[1]:]
    separator = b"" if not data else (newline if data.endswith(b"\n") else newline * 2)
    return data + separator + block + newline


def _atomic_write(root, info, content):
    """Replace only changed files; keep the existing permission bits."""
    path = _file_path(root, info["path"])
    exists = path.exists()
    current = path.read_bytes() if exists else b""
    if current != info["data"]:
        raise ValueError("Instructions changed during setup; rerun before editing: " + info["path"])
    if current == content:
        return False
    mode = stat.S_IMODE(path.stat().st_mode) if exists else None
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, pending = tempfile.mkstemp(prefix=".codebase-mentor-", dir=str(path.parent))
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(content)
        if mode is None:
            mask = os.umask(0)
            os.umask(mask)
            mode = 0o666 & ~mask
        os.chmod(pending, mode)
        # Revalidate immediately before replacing an existing path.
        _file_path(root, info["path"])
        if (path.read_bytes() if path.exists() else b"") != current:
            raise ValueError("Instructions changed during setup; rerun: " + info["path"])
        os.replace(pending, path)
    finally:
        if os.path.exists(pending):
            os.unlink(pending)
    return True


def _discover_map(root, instructions, explicit):
    result = {"path": None, "candidates": [], "state": "missing", "errors": []}
    if explicit is not None:
        try:
            name = _map_name(explicit)
            path = _file_path(root, name)
            result["path"] = name
            result["state"] = "selected" if path.is_file() else "missing"
            if path.is_file():
                result["candidates"] = [name]
        except (ValueError, OSError) as exc:
            result["state"] = "invalid"
            result["errors"].append(str(exc))
        return result
    names = list(MAP_PATHS)
    names.extend(info["map"] for info in instructions.values() if info["map"])
    for name in dict.fromkeys(names):
        try:
            if _file_path(root, name).is_file():
                result["candidates"].append(name)
        except (ValueError, OSError) as exc:
            result["errors"].append(str(exc))
    if len(result["candidates"]) == 1:
        result["path"] = result["candidates"][0]
        result["state"] = "selected"
    elif len(result["candidates"]) > 1:
        result["state"] = "ambiguous"
    return result


def _report(root, agents, explicit):
    instructions = {
        name: _inspect(root, name)
        for paths in AGENT_PATHS.values()
        for name in paths
    }
    report = {
        "root": str(root),
        "map": _discover_map(root, instructions, explicit),
        "agents": {},
        "changed": [],
        "errors": [],
        "warnings": [],
    }
    for agent in agents:
        names = AGENT_PATHS[agent]
        name = names[-1] if agent == "codex" and instructions[names[-1]]["data"] else names[0]
        info = instructions[name]
        issues = [instructions[item]["error"] for item in names if instructions[item]["error"]]
        report["errors"].extend(issues)
        configured = bool(info["span"])
        if info["map"]:
            try:
                if not _file_path(root, info["map"]).is_file():
                    issues.append("The managed map is missing: " + info["map"])
                    configured = False
            except (ValueError, OSError) as exc:
                issues.append(str(exc))
                configured = False
            if explicit is not None and info["map"] != report["map"]["path"]:
                issues.append("The instruction entry points to a different map.")
                configured = False
        if agent == "codex" and name == names[-1] and instructions[names[0]]["span"]:
            report["warnings"].append("AGENTS.md also contains a managed entry; AGENTS.override.md takes precedence.")
        report["agents"][agent] = {
            "path": name, "map": info["map"], "configured": configured and not info["error"],
            "activation": "unverified", "issues": issues,
        }
    # Existing adapter and manual entries are never silently migrated or removed.
    manual_names = set(instructions) | {"CLAUDE.md", ".claude/CLAUDE.md"}
    for name in sorted(manual_names):
        info = instructions.get(name) or _inspect(root, name)
        data = info["data"]
        if info["span"]:
            start, end = info["span"]
            data = data[:start] + data[end:]
        if re.search(rb"codebase[- ]mentor|ONBOARDING\.md", data, re.IGNORECASE):
            report["warnings"].append("Possible manual or legacy Mentor instructions in " + name + "; review for duplication.")
    return report, instructions


def main(argv=None):
    """Run setup/status/removal and print a machine-readable result."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("status", "setup", "remove"))
    parser.add_argument("--root", default=".", help="Repository root (default: current directory).")
    parser.add_argument("--agent", action="append", choices=tuple(AGENT_PATHS))
    parser.add_argument("--map", dest="map_path", help="Repository-relative map path when selection is needed.")
    args = parser.parse_args(argv)
    result = {"command": args.command, "changed": [], "errors": []}
    try:
        root = Path(args.root).expanduser().resolve(strict=True)
        if not root.is_dir():
            raise ValueError("The repository root must be a directory.")
        if args.command != "status" and not args.agent:
            raise ValueError("Select at least one --agent for setup or removal.")
        agents = list(dict.fromkeys(args.agent or AGENT_PATHS))
        report, instructions = _report(root, agents, args.map_path)
        result.update(report)
        if args.command == "status":
            result["errors"].extend(result["map"]["errors"])
        else:
            if args.command == "setup":
                result["errors"].extend(result["map"]["errors"])
                if result["map"]["state"] != "selected":
                    result["errors"].append("Select one existing map with --map; current state: " + result["map"]["state"])
            targets = [
                instructions[name]
                for agent in agents
                for name in (AGENT_PATHS[agent] if args.command == "remove"
                             else (result["agents"][agent]["path"],))
            ]
            if (args.command == "setup" and result["map"]["state"] == "selected"
                    and _is_instruction_map(root, result["map"]["path"])):
                result["errors"].append("The map cannot also be a managed instruction target.")
            if not result["errors"]:
                changes = [
                    (info, _replacement(info, result["map"]["path"], args.command == "remove"))
                    for info in targets
                ]
                try:
                    for info, content in changes:
                        if _atomic_write(root, info, content):
                            result["changed"].append(info["path"])
                finally:
                    # A later disk failure must still report earlier completed writes.
                    refreshed, _ = _report(root, agents, args.map_path)
                    result["map"] = refreshed["map"]
                    result["agents"] = refreshed["agents"]
                    result["warnings"] = refreshed["warnings"]
    except (ValueError, OSError) as exc:
        result["errors"].append(str(exc))
    print(json.dumps(result, indent=2, ensure_ascii=True))
    return 1 if result["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
