#!/usr/bin/env bash
# Build a deterministic skills-only plugin archive using Python's standard library.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ $# -le 1 ]] || { echo 'Usage: scripts/package-plugin.sh [output-directory]' >&2; exit 1; }
command -v python3 >/dev/null || { echo 'Plugin packaging requires python3.' >&2; exit 1; }
OUTPUT_DIR="${1:-$ROOT/dist}"
bash "$ROOT/scripts/validate-package.sh"

python3 - "$ROOT" "$OUTPUT_DIR" <<'PY'
import hashlib
import json
import pathlib
import tempfile
import zipfile
import sys

root = pathlib.Path(sys.argv[1])
output = pathlib.Path(sys.argv[2]).resolve()
version = json.loads((root / "plugin.json").read_text())["version"]
output.mkdir(parents=True, exist_ok=True)
archive = output / f"codebase-mentor-{version}.zip"

# Explicit files keep source-only development tools, caches, credentials, and the
# separately distributed optional MCP package out of the plugin release.
paths = [
    "plugin.json",
    ".codex-plugin/plugin.json",
    ".claude-plugin/plugin.json",
    "LICENSE",
    "PRIVACY.md",
    "site/docs/assets/logo.png",
    "skills/codebase-mentor/SKILL.md",
    "skills/codebase-mentor/ONBOARDING.template.md",
    "skills/codebase-mentor/AUTHORING_GUIDE.md",
    "skills/onboard/SKILL.md",
    "skills/onboard/ONBOARDING.template.md",
    "skills/onboard/AUTHORING_GUIDE.md",
    "skills/onboard/mentor-protocol.md",
]
files = {}
for name in paths:
    path = root / name
    if path.is_symlink() or not path.is_file():
        raise SystemExit(f"Expected a regular package file: {name}")
    files[name] = path.read_bytes()

# The repository README links to development files omitted from the ZIP. Give
# installed users a short guide with public URLs and no missing local links.
files["README.md"] = f"""# Codebase Mentor

![Codebase Mentor](site/docs/assets/logo.png)

Version {version} by [JEStats](https://jestats.io). Understand unfamiliar code,
plan a change, and maintain onboarding documentation with source-backed answers.
The plugin contains two skills: **codebase-mentor** and **onboard**. It requires
no API key, database, background service, or separate MCP runtime.

## Start with a question

Open the repository you want to understand in your coding agent. Ask:

> Use codebase-mentor to trace one important execution path in this repository.
> Read the source, cite the relevant files and symbols, and flag what you cannot verify.

An ONBOARDING.md is optional. In Claude Code, invoke
`/codebase-mentor:codebase-mentor` to ask a question or
`/codebase-mentor:onboard` to draft a map. In Codex, select the skill by name or
ask to use **codebase-mentor** or **onboard** in a new session.

The skills guide your agent to inspect source. They do not guarantee correctness.
Review the cited evidence and any generated document before acting.

## Install and get help

- [Installation and troubleshooting](https://github.com/jestatsio/codebase-mentor/blob/main/docs/INSTALL.md)
- [Documentation](https://jestatsio.github.io/codebase-mentor/)
- [Source and releases](https://github.com/jestatsio/codebase-mentor)
- [Report an issue](https://github.com/jestatsio/codebase-mentor/issues)
- [Privacy policy](PRIVACY.md)

MIT licensed. See the bundled [LICENSE](LICENSE).
""".encode()

# Fixed timestamps, permissions, ordering, and compression make identical inputs
# produce identical bytes on the same Python/zlib toolchain.
with tempfile.NamedTemporaryFile(dir=output, suffix=".zip", delete=False) as temp:
    temporary = pathlib.Path(temp.name)
try:
    with zipfile.ZipFile(temporary, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as bundle:
        for name, data in sorted(files.items()):
            info = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            bundle.writestr(info, data, compresslevel=9)
    temporary.replace(archive)
finally:
    temporary.unlink(missing_ok=True)

digest = hashlib.sha256(archive.read_bytes()).hexdigest()
checksum = archive.with_suffix(".zip.sha256")
checksum.write_text(f"{digest}  {archive.name}\n")
print(archive)
print(checksum)
PY

VERSION="$(jq -er .version "$ROOT/plugin.json")"
bash "$ROOT/scripts/validate-package.sh" "$OUTPUT_DIR/codebase-mentor-$VERSION.zip"
