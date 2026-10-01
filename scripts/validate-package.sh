#!/usr/bin/env bash
# Check local distribution contracts. No downloads or user configuration writes.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
command -v jq >/dev/null || { echo 'Package validation requires jq.' >&2; exit 1; }

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
bash scripts/sync-adapters.sh --check
printf 'Package manifests, catalogs, assets, versions, and bundled skills are valid (%s).\n' "$version"
