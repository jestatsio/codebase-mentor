#!/usr/bin/env bash
# Check local distribution contracts. No downloads or user configuration writes.
set -euo pipefail
[[ $# -le 1 ]] || { echo 'Usage: scripts/validate-package.sh [plugin.zip]' >&2; exit 1; }
# Resolve an optional archive before changing to the repository root.
ARCHIVE="${1:-}"
if [[ -n "$ARCHIVE" && "$ARCHIVE" != /* ]]; then ARCHIVE="$PWD/$ARCHIVE"; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v jq >/dev/null || { echo 'Package validation requires jq.' >&2; exit 1; }
command -v python3 >/dev/null || { echo 'Package validation requires python3.' >&2; exit 1; }

fail() { printf 'Package validation: %s\n' "$*" >&2; exit 1; }
version="$(jq -er '.version' plugin.json)"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail 'Expected a release semver.'
for manifest in plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json; do
  jq -e --arg version "$version" '
    .name == "codebase-mentor" and .version == $version and
    .repository == "https://github.com/jestatsio/codebase-mentor" and
    .author.name == "JEStats" and .license == "MIT" and
    (.description | type == "string" and length > 0)
  ' "$manifest" >/dev/null || fail "Invalid identity or version in $manifest"
done
jq -e 'all(.[];
  (has("mcpServers") or has("apps") or has("hooks") | not) and
  ((.extensions["com.openai"] // {}) | has("mcpServers") or has("apps") or has("hooks") | not)
)' --slurp plugin.json .codex-plugin/plugin.json .claude-plugin/plugin.json >/dev/null \
  || fail 'Skills-only plugin manifests must not declare MCP, apps, or hooks.'
jq -e '.[0].extensions["com.openai"].interface == .[1].interface and
  .[0].extensions["com.openai"].publication == .[1].extensions["com.openai"].publication' \
  --slurp plugin.json .codex-plugin/plugin.json >/dev/null || fail 'Portable and Codex metadata differ.'
jq -e '
  ."$schema" == "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json" and
  (.extensions["com.openai"].interface |
    (.displayName | type == "string" and length > 0 and length <= 30) and
    (.shortDescription | type == "string" and length > 0 and length <= 30) and
    (.longDescription | type == "string" and length > 0 and length <= 4000) and
    .developerName == "JEStats" and .category == "Developer Tools" and
    .privacyPolicyURL == "https://github.com/jestatsio/codebase-mentor/blob/main/PRIVACY.md" and
    (.capabilities | type == "array" and length <= 20) and
    (.defaultPrompt | type == "array" and length > 0 and length <= 3) and
    (all(.defaultPrompt[]; type == "string" and length > 0 and length <= 128))
  )
' plugin.json >/dev/null || fail 'OpenAI listing metadata does not meet submission limits.'
jq -e '
  .displayName == "Codebase Mentor" and .icon == "./site/docs/assets/logo.png" and
  .documentationUrl == "https://jestatsio.github.io/codebase-mentor/" and
  .supportUrl == "https://github.com/jestatsio/codebase-mentor/issues" and
  .privacyPolicyUrl == "https://github.com/jestatsio/codebase-mentor/blob/main/PRIVACY.md"
' .claude-plugin/plugin.json >/dev/null || fail 'Claude listing metadata is incomplete.'
[[ -s PRIVACY.md ]] || fail 'Missing bundled privacy policy.'
jq -e --arg version "$version" '
  .name == "codebase-mentor" and (.plugins | length == 1) and
  .plugins[0].name == "codebase-mentor" and .plugins[0].source == "./" and
  .plugins[0].version == $version
' .claude-plugin/marketplace.json >/dev/null || fail 'Claude catalog is out of sync.'
jq -e '
  .name == "codebase-mentor" and (.plugins | length == 1) and
  .plugins[0].name == "codebase-mentor" and
  .plugins[0].source == {"source":"local","path":"./"} and
  .plugins[0].policy.installation == "AVAILABLE" and
  .plugins[0].policy.authentication == "ON_USE" and
  .plugins[0].category == "Developer Tools"
' .agents/plugins/marketplace.json >/dev/null || fail 'Codex catalog is invalid.'
jq -e '.skills == "./skills/" and .interface.developerName == "JEStats"' .codex-plugin/plugin.json >/dev/null
while IFS= read -r asset; do
  [[ "$asset" == ./* && "$asset" != *..* && -s "$asset" ]] || fail "Missing or invalid plugin asset: $asset"
done < <(jq -er '.interface | .logo, .composerIcon' .codex-plugin/plugin.json)
for skill in codebase-mentor onboard; do
  grep -q "^name: $skill$" "skills/$skill/SKILL.md" || fail "Missing skill name: $skill"
  grep -q '^description: .' "skills/$skill/SKILL.md" || fail "Missing skill description: $skill"
  for file in ONBOARDING.template.md AUTHORING_GUIDE.md; do
    [[ -s "skills/$skill/$file" ]] || fail "Missing bundled reference: $skill/$file"
  done
done
[[ -s skills/onboard/mentor-protocol.md ]] || fail 'Missing standalone onboard protocol.'
python3 - <<'PY'
from pathlib import Path

skills = {path.parent.name for path in Path("skills").glob("*/SKILL.md")}
if skills != {"codebase-mentor", "onboard"}:
    raise SystemExit(f"Package validation: unexpected skill inventory: {skills}")
PY
bash scripts/sync-adapters.sh --check
printf 'Package manifests, catalogs, assets, versions, and bundled skills are valid (%s).\n' "$version"

if [[ -n "$ARCHIVE" ]]; then
  python3 - "$ROOT" "$ARCHIVE" <<'PY'
import hashlib
import json
import pathlib
import stat
import sys
import zipfile

root, archive = map(pathlib.Path, sys.argv[1:])
expected = {
    "plugin.json", ".codex-plugin/plugin.json", ".claude-plugin/plugin.json",
    "README.md", "LICENSE", "PRIVACY.md", "site/docs/assets/logo.png",
    "skills/codebase-mentor/SKILL.md", "skills/codebase-mentor/ONBOARDING.template.md",
    "skills/codebase-mentor/AUTHORING_GUIDE.md", "skills/onboard/SKILL.md",
    "skills/onboard/ONBOARDING.template.md", "skills/onboard/AUTHORING_GUIDE.md",
    "skills/onboard/mentor-protocol.md",
}

def require(condition, message):
    if not condition:
        raise SystemExit(f"Archive validation: {message}")

with zipfile.ZipFile(archive) as bundle:
    names = bundle.namelist()
    require(len(names) == len(set(names)), "duplicate archive entries")
    require(set(names) == expected, f"unexpected inventory: {set(names) ^ expected}")
    require(bundle.testzip() is None, "corrupt archive data")
    for item in bundle.infolist():
        require(stat.S_ISREG(item.external_attr >> 16), f"not a regular file: {item.filename}")
        require(0 < item.file_size <= 5 * 1024 * 1024, f"invalid file size: {item.filename}")
        if item.filename != "README.md":
            require(bundle.read(item) == (root / item.filename).read_bytes(),
                    f"archive differs from validated source: {item.filename}")
    portable = json.loads(bundle.read("plugin.json"))
    codex = json.loads(bundle.read(".codex-plugin/plugin.json"))
    claude = json.loads(bundle.read(".claude-plugin/plugin.json"))
    require(all("mcpServers" not in manifest for manifest in (portable, codex, claude)),
            "skills-only release declares an MCP server")
    for manifest in (portable["extensions"]["com.openai"]["interface"], codex["interface"]):
        for key in ("logo", "composerIcon"):
            require(manifest[key].startswith("./") and manifest[key][2:] in expected,
                    f"missing bundled {key}")
    require(claude["icon"][2:] in expected, "missing Claude icon")
    require(codex["skills"] == "./skills/", "unexpected skill discovery path")
    require(f"Version {portable['version']}" in bundle.read("README.md").decode(),
            "bundled README version differs")
    require("[Privacy policy](PRIVACY.md)" in bundle.read("README.md").decode(),
            "bundled README does not link the privacy policy")

checksum = archive.with_suffix(".zip.sha256")
actual = hashlib.sha256(archive.read_bytes()).hexdigest()
require(checksum.read_text() == f"{actual}  {archive.name}\n", "checksum file differs")
print(f"Archive inventory, source bytes, skill paths, assets, and checksum are valid: {archive.name}")
PY
fi
