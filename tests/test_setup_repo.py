"""Behavioral checks for the optional repository setup helper."""

import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock


HELPER = Path(__file__).resolve().parents[1] / "skills/onboard/setup_repo.py"
SPEC = importlib.util.spec_from_file_location("setup_repo", HELPER)
assert SPEC is not None and SPEC.loader is not None
setup_repo = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(setup_repo)

BEGIN = b"<!-- codebase-mentor:setup:begin -->"
END = b"<!-- codebase-mentor:setup:end -->"
TARGETS = {
    "codex": "AGENTS.md",
    "claude": ".claude/rules/codebase-mentor.md",
    "bob": ".bob/rules/codebase-mentor.md",
}


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "repo with spaces"
        self.root.mkdir()

    def write(self, name, data=b"# Repository map\n"):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        return path

    def run_helper(self, command="status", agents=(), map_path=None, root=None):
        argv = [command, "--root", str(root or self.root)]
        for agent in agents:
            argv.extend(["--agent", agent])
        if map_path is not None:
            argv.extend(["--map", map_path])
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            code = setup_repo.main(argv)
        return code, json.loads(output.getvalue())

    def snapshot(self):
        return {
            str(path.relative_to(self.root)): (
                path.read_bytes(), stat.S_IMODE(path.stat().st_mode), path.stat().st_mtime_ns
            )
            for path in self.root.rglob("*")
            if path.is_file()
        }

    def test_status_empty_repository_is_read_only(self):
        code, result = self.run_helper()
        self.assertEqual(code, 0)
        self.assertEqual(result["map"]["state"], "missing")
        self.assertEqual(result["changed"], [])
        self.assertEqual(list(self.root.iterdir()), [])
        for value in result["agents"].values():
            self.assertFalse(value["configured"])
            self.assertEqual(value["activation"], "unverified")

    def test_all_clients_repeat_and_remove_preserve_map(self):
        self.write("ONBOARDING.md")
        for agent, target in TARGETS.items():
            with self.subTest(agent=agent):
                code, result = self.run_helper("setup", [agent])
                self.assertEqual(code, 0, result)
                self.assertEqual(result["changed"], [target])
                self.assertTrue(result["agents"][agent]["configured"])
                self.assertEqual(result["agents"][agent]["activation"], "unverified")
                data = (self.root / target).read_bytes()
                self.assertEqual(data.count(BEGIN), 1)
                self.assertEqual(data.count(END), 1)
                self.assertIn(b'<!-- codebase-mentor:map "ONBOARDING.md" -->', data)
                before = self.snapshot()
                self.assertEqual(self.run_helper("setup", [agent])[1]["changed"], [])
                self.assertEqual(before, self.snapshot())
                code, result = self.run_helper("remove", [agent])
                self.assertEqual(code, 0, result)
                self.assertFalse(result["agents"][agent]["configured"])
                self.assertNotIn(BEGIN, (self.root / target).read_bytes())
                self.assertEqual(self.run_helper("remove", [agent])[1]["changed"], [])
        self.assertEqual((self.root / "ONBOARDING.md").read_bytes(), b"# Repository map\n")

    def test_all_clients_preflight_then_write(self):
        self.write("ONBOARDING.md")
        code, result = self.run_helper("setup", list(TARGETS))
        self.assertEqual(code, 0, result)
        self.assertEqual(set(result["changed"]), set(TARGETS.values()))
        self.assertTrue(all(item["configured"] for item in result["agents"].values()))

    def test_nonroot_map_discovery(self):
        for name in ("docs/ONBOARDING.md", "doc/ONBOARDING.md"):
            with self.subTest(name=name):
                path = self.write(name)
                code, result = self.run_helper("setup", ["codex"])
                self.assertEqual(code, 0, result)
                self.assertEqual(result["map"]["path"], name)
                self.run_helper("remove", ["codex"])
                path.unlink()

    def test_custom_map_is_rediscovered_without_metadata_file(self):
        name = 'design notes/日本語 "guide" 🐇.md'
        self.write(name)
        code, result = self.run_helper("setup", ["claude"], name)
        self.assertEqual(code, 0, result)
        code, result = self.run_helper("status")
        self.assertEqual(code, 0, result)
        self.assertEqual(result["map"]["path"], name)
        self.assertTrue(result["agents"]["claude"]["configured"])
        self.assertEqual(set(self.snapshot()), {name, TARGETS["claude"]})
        self.assertEqual(self.run_helper("setup", ["claude"])[1]["changed"], [])

    def test_ambiguous_map_requires_choice(self):
        self.write("ONBOARDING.md")
        self.write("docs/ONBOARDING.md")
        code, result = self.run_helper()
        self.assertEqual(code, 0)
        self.assertEqual(result["map"]["state"], "ambiguous")
        before = self.snapshot()
        self.assertNotEqual(self.run_helper("setup", ["codex"])[0], 0)
        self.assertEqual(before, self.snapshot())
        code, result = self.run_helper("setup", ["codex"], "docs/ONBOARDING.md")
        self.assertEqual(code, 0, result)
        self.assertEqual(result["agents"]["codex"]["map"], "docs/ONBOARDING.md")

    def test_existing_managed_custom_map_participates_in_ambiguity(self):
        self.write("custom.md")
        self.run_helper("setup", ["bob"], "custom.md")
        self.write("ONBOARDING.md")
        result = self.run_helper()[1]
        self.assertEqual(result["map"]["state"], "ambiguous")
        self.assertEqual(set(result["map"]["candidates"]), {"custom.md", "ONBOARDING.md"})

    def test_codex_prefers_nonempty_override(self):
        self.write("ONBOARDING.md")
        normal = self.write("AGENTS.md", b"Normal instructions\n")
        override = self.write("AGENTS.override.md", b"Override instructions\n")
        code, result = self.run_helper("setup", ["codex"])
        self.assertEqual(code, 0, result)
        self.assertEqual(result["agents"]["codex"]["path"], "AGENTS.override.md")
        self.assertEqual(normal.read_bytes(), b"Normal instructions\n")
        self.assertIn(BEGIN, override.read_bytes())

    def test_empty_override_uses_agents_md(self):
        self.write("ONBOARDING.md")
        override = self.write("AGENTS.override.md", b"")
        self.assertEqual(self.run_helper("setup", ["codex"])[0], 0)
        self.assertEqual(override.read_bytes(), b"")
        self.assertIn(BEGIN, (self.root / "AGENTS.md").read_bytes())

    def test_remove_codex_cleans_managed_entries_in_both_instruction_files(self):
        self.write("ONBOARDING.md")
        self.run_helper("setup", ["codex"])
        self.write("AGENTS.override.md", b"Human override\n")
        self.run_helper("setup", ["codex"])
        code, result = self.run_helper("remove", ["codex"])
        self.assertEqual(code, 0, result)
        for name in ("AGENTS.md", "AGENTS.override.md"):
            self.assertNotIn(BEGIN, (self.root / name).read_bytes())
        self.assertIn(b"Human override", (self.root / "AGENTS.override.md").read_bytes())

    def test_byte_and_mode_preservation_for_update_and_removal(self):
        self.write("ONBOARDING.md")
        target = self.write("AGENTS.md", b"Prefix\xff\r\n")
        target.chmod(0o640)
        self.run_helper("setup", ["codex"])
        data = target.read_bytes() + b"\r\nSuffix\xfe\r\n"
        target.write_bytes(data)
        before_prefix, before_suffix = data.split(BEGIN)[0], data.split(END)[1]
        self.write("new map.md")
        code, result = self.run_helper("setup", ["codex"], "new map.md")
        self.assertEqual(code, 0, result)
        data = target.read_bytes()
        self.assertEqual(data.split(BEGIN)[0], before_prefix)
        self.assertEqual(data.split(END)[1], before_suffix)
        self.assertEqual(stat.S_IMODE(target.stat().st_mode), 0o640)
        self.run_helper("remove", ["codex"])
        self.assertEqual(target.read_bytes(), before_prefix + before_suffix)
        self.assertEqual(stat.S_IMODE(target.stat().st_mode), 0o640)

    def test_new_files_respect_restrictive_umask(self):
        self.write("ONBOARDING.md")
        previous = os.umask(0o077)
        try:
            self.assertEqual(self.run_helper("setup", ["bob"])[0], 0)
        finally:
            os.umask(previous)
        self.assertEqual(stat.S_IMODE((self.root / TARGETS["bob"]).stat().st_mode), 0o600)

    def test_legacy_and_manual_instructions_are_preserved_and_reported(self):
        self.write("ONBOARDING.md")
        legacy = b"<!-- codebase-mentor:begin -->\nOld rule\n<!-- codebase-mentor:end -->\n"
        self.write("AGENTS.md", legacy)
        claude = self.write("CLAUDE.md", b"Read ONBOARDING.md before editing.\n")
        code, result = self.run_helper("setup", ["codex", "claude"])
        self.assertEqual(code, 0, result)
        self.assertTrue(result["warnings"])
        self.assertTrue((self.root / "AGENTS.md").read_bytes().startswith(legacy))
        self.assertEqual(claude.read_bytes(), b"Read ONBOARDING.md before editing.\n")

    def test_mutations_require_explicit_agents(self):
        self.write("ONBOARDING.md")
        for command in ("setup", "remove"):
            with self.subTest(command=command):
                code, result = self.run_helper(command)
                self.assertNotEqual(code, 0)
                self.assertTrue(result["errors"])
        self.assertEqual(set(self.snapshot()), {"ONBOARDING.md"})

    def test_duplicate_agent_arguments_do_not_duplicate_entries(self):
        self.write("ONBOARDING.md")
        code, result = self.run_helper("setup", ["codex", "codex"])
        self.assertEqual(code, 0, result)
        self.assertEqual(result["changed"], ["AGENTS.md"])

    def test_missing_map_blocks_setup_but_does_not_block_removal(self):
        code, result = self.run_helper("setup", ["codex"])
        self.assertNotEqual(code, 0)
        self.assertTrue(result["errors"])
        self.write("ONBOARDING.md")
        self.run_helper("setup", ["codex"])
        (self.root / "ONBOARDING.md").unlink()
        code, result = self.run_helper()
        self.assertEqual(code, 0, result)
        self.assertFalse(result["agents"]["codex"]["configured"])
        self.assertTrue(result["agents"]["codex"]["issues"])
        self.assertEqual(self.run_helper("remove", ["codex"])[0], 0)

    def test_unsafe_map_paths_are_rejected_without_writes(self):
        for name in ("", "../outside.md", "/tmp/outside.md", "a/../map.md",
                     "new\nrule.md", "bad`map.md", "<!--evil-->.md", "a\\b.md", "."):
            with self.subTest(name=name):
                code, result = self.run_helper("setup", ["codex"], name)
                self.assertNotEqual(code, 0)
                self.assertTrue(result["errors"])
                self.assertEqual(result["changed"], [])
        self.assertEqual(list(self.root.iterdir()), [])

    def test_map_cannot_be_instruction_target(self):
        self.write("AGENTS.md")
        before = self.snapshot()
        self.assertNotEqual(self.run_helper("setup", ["codex"], "AGENTS.md")[0], 0)
        self.assertEqual(before, self.snapshot())

    def test_map_cannot_alias_instruction_target(self):
        target = self.write("AGENTS.md")
        alias = self.root / "agents.md"
        if not alias.exists():
            os.link(target, alias)
        before = self.snapshot()
        code, result = self.run_helper("setup", ["codex"], "agents.md")
        self.assertNotEqual(code, 0)
        self.assertTrue(result["errors"])
        self.assertEqual(before, self.snapshot())

    def test_map_cannot_be_unselected_instruction_target(self):
        for name in ("AGENTS.md", "AGENTS.override.md", TARGETS["claude"], TARGETS["bob"]):
            with self.subTest(name=name):
                self.write(name)
                before = self.snapshot()
                code, result = self.run_helper("setup", ["codex"], name)
                self.assertNotEqual(code, 0, result)
                self.assertEqual(before, self.snapshot())

    def test_windows_drive_paths_are_rejected_on_every_platform(self):
        for name in ("C:/outside/map.md", "C:outside.md", "C:", "//server/share/map.md",
                     "safe/C:/outside/map.md", "safe/C:outside.md"):
            with self.subTest(name=name):
                with self.assertRaises(ValueError):
                    setup_repo._map_name(name)

    def test_malformed_markers_block_all_selected_writes(self):
        self.write("ONBOARDING.md")
        malformed = (
            BEGIN + b"\nHuman text",
            END,
            END + b"\n" + BEGIN,
            BEGIN + b"\n" + BEGIN + b"\n" + END,
            BEGIN + b"\n" + END + b"\n" + BEGIN + b"\n" + END,
            b"<!-- codebase-mentor:setup:begin ->\n",
            b"prefix " + BEGIN + b"\n" + END,
        )
        for data in malformed:
            for command in ("setup", "remove"):
                with self.subTest(data=data, command=command):
                    self.write(TARGETS["bob"], data)
                    before = self.snapshot()
                    code, result = self.run_helper(command, ["codex", "bob"])
                    self.assertNotEqual(code, 0)
                    self.assertTrue(result["errors"])
                    self.assertEqual(before, self.snapshot())

    def test_bad_metadata_is_reported_and_never_rewritten(self):
        self.write("ONBOARDING.md")
        for metadata in (b"", b'<!-- codebase-mentor:map "../bad.md" -->',
                         b"<!-- codebase-mentor:map null -->",
                         b'<!-- codebase-mentor:map "ONBOARDING.md" -->\n' * 2):
            self.write("AGENTS.md", BEGIN + b"\n" + metadata + b"\n" + END)
            before = self.snapshot()
            self.assertNotEqual(self.run_helper("setup", ["codex"])[0], 0)
            self.assertEqual(before, self.snapshot())

    def test_symlink_targets_and_ancestors_are_rejected(self):
        self.write("ONBOARDING.md")
        outside = Path(self.temp.name) / "outside"
        outside.mkdir()
        original = outside / "rules"
        original.write_bytes(b"Keep me")
        (self.root / "AGENTS.md").symlink_to(original)
        self.assertNotEqual(self.run_helper("setup", ["codex"])[0], 0)
        self.assertNotEqual(self.run_helper("remove", ["codex"])[0], 0)
        self.assertEqual(original.read_bytes(), b"Keep me")
        (self.root / ".bob").symlink_to(outside, target_is_directory=True)
        self.assertNotEqual(self.run_helper("setup", ["claude", "bob"])[0], 0)
        self.assertFalse((self.root / ".claude").exists())

    def test_symlink_map_is_rejected_even_when_inside_root(self):
        self.write("real.md")
        (self.root / "ONBOARDING.md").symlink_to(self.root / "real.md")
        self.assertNotEqual(self.run_helper("setup", ["codex"])[0], 0)
        self.assertFalse((self.root / "AGENTS.md").exists())

    def test_windows_reparse_ancestors_and_targets_are_rejected(self):
        self.write("ONBOARDING.md")
        self.write(TARGETS["bob"], b"Human rule\n")
        lstat = Path.lstat
        for name in (".bob", TARGETS["bob"]):
            with self.subTest(name=name):
                reparse_path = (self.root / name).resolve()

                def reparse_stat(path, *args, **kwargs):
                    actual = lstat(path, *args, **kwargs)
                    if path == reparse_path:
                        return SimpleNamespace(
                            st_mode=actual.st_mode,
                            st_file_attributes=stat.FILE_ATTRIBUTE_REPARSE_POINT,
                        )
                    return actual

                before = self.snapshot()
                with mock.patch.object(Path, "lstat", reparse_stat):
                    code, result = self.run_helper("setup", ["claude", "bob"])
                self.assertNotEqual(code, 0)
                self.assertTrue(result["errors"])
                self.assertEqual(before, self.snapshot())
                self.assertFalse((self.root / ".claude").exists())

    def test_nonfiles_and_bad_roots_are_rejected(self):
        (self.root / "ONBOARDING.md").mkdir()
        self.assertNotEqual(self.run_helper("setup", ["codex"])[0], 0)
        (self.root / "ONBOARDING.md").rmdir()
        self.write("ONBOARDING.md")
        (self.root / ".bob").write_bytes(b"not a directory")
        self.assertNotEqual(self.run_helper("setup", ["claude", "bob"])[0], 0)
        self.assertFalse((self.root / ".claude").exists())
        self.assertNotEqual(self.run_helper(root=self.root / "missing")[0], 0)
        self.assertNotEqual(self.run_helper(root=self.root / "ONBOARDING.md")[0], 0)

    def test_atomic_replace_failure_preserves_original_and_cleans_temporary(self):
        self.write("ONBOARDING.md")
        self.write("AGENTS.md", b"Human instructions\n")
        before = self.snapshot()
        with mock.patch.object(setup_repo.os, "replace", side_effect=OSError("disk error")):
            code, result = self.run_helper("setup", ["codex"])
        self.assertNotEqual(code, 0)
        self.assertTrue(result["errors"])
        self.assertEqual(before, self.snapshot())

    def test_partial_write_failure_reports_actual_configuration(self):
        self.write("ONBOARDING.md")
        replace = setup_repo.os.replace

        def fail_second_replace(source, destination):
            if Path(destination).name == "codebase-mentor.md":
                raise OSError("second write failed")
            return replace(source, destination)

        with mock.patch.object(setup_repo.os, "replace", side_effect=fail_second_replace):
            code, result = self.run_helper("setup", ["codex", "claude"])
        self.assertNotEqual(code, 0)
        self.assertEqual(result["changed"], ["AGENTS.md"])
        self.assertTrue(result["agents"]["codex"]["configured"])
        self.assertFalse(result["agents"]["claude"]["configured"])
        self.assertIn(BEGIN, (self.root / "AGENTS.md").read_bytes())
        self.assertFalse((self.root / TARGETS["claude"]).exists())
        self.assertEqual(set(self.snapshot()), {"ONBOARDING.md", "AGENTS.md"})

    def test_concurrent_edit_after_preflight_is_not_overwritten(self):
        self.write("ONBOARDING.md")
        target = self.write("AGENTS.md", b"Original instructions\n")
        replacement = setup_repo._replacement

        def edit_during_preparation(*args):
            content = replacement(*args)
            target.write_bytes(b"Concurrent human edit\n")
            return content

        with mock.patch.object(setup_repo, "_replacement", side_effect=edit_during_preparation):
            code, result = self.run_helper("setup", ["codex"])
        self.assertNotEqual(code, 0)
        self.assertEqual(result["changed"], [])
        self.assertEqual(target.read_bytes(), b"Concurrent human edit\n")

    def test_concurrent_edit_during_write_is_not_overwritten(self):
        self.write("ONBOARDING.md")
        target = self.write("AGENTS.md", b"Original instructions\n")
        mkstemp = setup_repo.tempfile.mkstemp

        def edit_during_write(*args, **kwargs):
            pending = mkstemp(*args, **kwargs)
            target.write_bytes(b"Concurrent human edit\n")
            return pending

        with mock.patch.object(setup_repo.tempfile, "mkstemp", side_effect=edit_during_write):
            code, result = self.run_helper("setup", ["codex"])
        self.assertNotEqual(code, 0)
        self.assertEqual(result["changed"], [])
        self.assertEqual(target.read_bytes(), b"Concurrent human edit\n")
        self.assertEqual(set(self.snapshot()), {"ONBOARDING.md", "AGENTS.md"})

    def test_existing_map_replaced_with_symlink_is_not_configured(self):
        original = self.write("ONBOARDING.md")
        self.run_helper("setup", ["codex"])
        original.unlink()
        self.write("real-map.md")
        original.symlink_to(self.root / "real-map.md")
        before = (self.root / "AGENTS.md").read_bytes()
        code, result = self.run_helper()
        self.assertNotEqual(code, 0)
        self.assertFalse(result["agents"]["codex"]["configured"])
        self.assertTrue(result["agents"]["codex"]["issues"])
        self.assertEqual((self.root / "AGENTS.md").read_bytes(), before)

    def test_large_human_instructions_preserved(self):
        self.write("ONBOARDING.md")
        content = b"Human rule\n" * 10001
        self.write("AGENTS.md", content)
        self.assertEqual(self.run_helper("setup", ["codex"])[0], 0)
        self.assertTrue((self.root / "AGENTS.md").read_bytes().startswith(content))

    def test_cli_emits_json_and_argument_errors(self):
        result = subprocess.run(
            [sys.executable, str(HELPER), "status", "--root", str(self.root)],
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["map"]["state"], "missing")
        for arguments in (["setup", "--agent", "unknown"], ["status", "--unexpected"]):
            result = subprocess.run(
                [sys.executable, str(HELPER)] + arguments,
                capture_output=True, text=True, check=False,
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn("usage:", result.stderr)


if __name__ == "__main__":
    unittest.main()
