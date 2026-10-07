#!/usr/bin/env bash
# Generate the GitHub directory-submission folder from the release package.
# plugins/codebase-mentor/ is generated: edit the root manifests, skills, or
# package script instead, then run this script. Write mode replaces its contents.
# --check builds in a temporary directory and compares without changing the copy.
# Keep this check outside validate-package.sh: package-plugin.sh already calls it.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="write"
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--check" ) ]]; then
  echo 'Usage: scripts/sync-plugin-directory.sh [--check]' >&2
  exit 1
fi
[[ "${1:-}" == "--check" ]] && MODE="check"
PACKAGE_TMP="$(mktemp -d)"
trap 'rm -rf "$PACKAGE_TMP"' EXIT
if ! bash "$ROOT/scripts/package-plugin.sh" "$PACKAGE_TMP" >"$PACKAGE_TMP/build.log" 2>&1; then
  cat "$PACKAGE_TMP/build.log" >&2
  exit 1
fi

python3 - "$ROOT" "$PACKAGE_TMP" "$MODE" <<'PY'
import json
import pathlib
import shutil
import sys
import zipfile

root = pathlib.Path(sys.argv[1])
package_dir = pathlib.Path(sys.argv[2])
mode = sys.argv[3]
version = json.loads((root / "plugin.json").read_text())["version"]
target = root / "plugins" / "codebase-mentor"
archive = package_dir / f"codebase-mentor-{version}.zip"

# A generated copy must never replace an external folder through a symlink.
if target.parent.is_symlink() or target.is_symlink():
    raise SystemExit("sync-plugin-directory: generated directory must not be a symlink")

# package-plugin.sh validates this archive's exact allowlist and source bytes.
with zipfile.ZipFile(archive) as bundle:
    expected = {name: bundle.read(name) for name in bundle.namelist()}

if mode == "check":
    actual = {
        path.relative_to(target).as_posix(): path
        for path in target.rglob("*")
        if path.is_file() or path.is_symlink()
    }
    differences = []
    for name in sorted(expected.keys() - actual.keys()):
        differences.append(f"missing: {name}")
    for name in sorted(actual.keys() - expected.keys()):
        differences.append(f"unexpected: {name}")
    for name in sorted(expected.keys() & actual.keys()):
        if actual[name].is_symlink() or actual[name].read_bytes() != expected[name]:
            differences.append(f"changed: {name}")
    if differences:
        print("sync-plugin-directory: generated directory is out of date:", file=sys.stderr)
        print("\n".join(differences), file=sys.stderr)
        raise SystemExit("Run bash scripts/sync-plugin-directory.sh and commit the generated files.")
    print(f"sync-plugin-directory: {len(expected)} files match the release package ({version}).")
else:
    if target.exists():
        shutil.rmtree(target)
    for name, content in expected.items():
        destination = target / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
    print(f"sync-plugin-directory: generated {len(expected)} files in {target.relative_to(root)} ({version}).")
PY
