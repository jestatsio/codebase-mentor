#!/usr/bin/env bash
# Exercise real installs in temporary projects without touching user settings.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/mentor-install-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT
PROJECT_DIR="$TEST_ROOT/project with spaces"
mkdir -p "$PROJECT_DIR/.github" "$TEST_ROOT/bin"
cd "$PROJECT_DIR"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
expect_failure() {
  if "$@" > "$TEST_ROOT/failure.log" 2>&1; then fail "Expected failure: $*"; fi
}
assert_mode() {
  local expected="$1" file="$2" actual
  actual="$(stat -c '%a' "$file" 2>/dev/null)" || actual="$(stat -f '%Lp' "$file")"
  [[ "$actual" == "$expected" ]] || fail "$file mode was $actual, expected $expected"
}

printf '# Team instructions\n\nKeep this text.\n' > AGENTS.md
printf '# Copilot instructions\n\nKeep these too.\n' > .github/copilot-instructions.md
chmod 600 AGENTS.md
chmod 640 .github/copilot-instructions.md
(umask 022; bash "$ROOT/install.sh" --agent all --project > "$TEST_ROOT/install.log")
grep -q 'Use Codebase Mentor to trace one important execution path' "$TEST_ROOT/install.log"
grep -q 'Use onboard to draft ONBOARDING.md' "$TEST_ROOT/install.log"
assert_mode 600 AGENTS.md
assert_mode 640 .github/copilot-instructions.md
assert_mode 644 .bob/skills/onboard/SKILL.md
for agent_dir in .claude .agents .bob; do
  for skill in codebase-mentor onboard; do
    diff -r "$ROOT/skills/$skill" "$agent_dir/skills/$skill"
  done
done
cmp "$ROOT/adapters/cursor/codebase-mentor.mdc" .cursor/rules/codebase-mentor.mdc
grep -q 'Keep this text.' AGENTS.md
grep -q 'Keep these too.' .github/copilot-instructions.md

# Updating must be byte-idempotent, keep the block at its original position,
# preserve text after the block, and leave user-added skill files alone.
printf '\n# After mentor\nPreserve this suffix.\n' >> AGENTS.md
printf 'Custom reference\n' > .bob/skills/onboard/custom.md
cp -R "$PROJECT_DIR" "$TEST_ROOT/expected"
(umask 077; bash "$ROOT/install.sh" --agent all --project > "$TEST_ROOT/install.log")
assert_mode 600 AGENTS.md
assert_mode 640 .github/copilot-instructions.md
assert_mode 644 .bob/skills/onboard/SKILL.md
diff -ru "$TEST_ROOT/expected" "$PROJECT_DIR"
printf 'PASS: all six targets, bundled references, paths with spaces, repeat installs\n'

# A restrictive umask applies to every newly created file, including adapters
# and skill references. Existing files retain their chosen mode on updates.
mkdir "$TEST_ROOT/private-project"
(
  cd "$TEST_ROOT/private-project"
  umask 077
  bash "$ROOT/install.sh" --agent all --project > "$TEST_ROOT/private-install.log"
  for file in AGENTS.md .github/copilot-instructions.md .cursor/rules/codebase-mentor.mdc \
    .claude/skills/*/* .agents/skills/*/* .bob/skills/*/*; do
    assert_mode 600 "$file"
  done
)
printf 'PASS: existing permissions preserved, new files honor umask 022 and 077\n'

# Adapter-only installs must not advertise an onboard skill they do not install.
for agent in cursor copilot agents-md; do
  mkdir "$TEST_ROOT/next-action-$agent"
  (
    cd "$TEST_ROOT/next-action-$agent"
    bash "$ROOT/install.sh" --agent "$agent" > "$TEST_ROOT/next-action-$agent.log"
  )
  grep -q 'Use Codebase Mentor to trace one important execution path' "$TEST_ROOT/next-action-$agent.log"
  if grep -q 'Use onboard' "$TEST_ROOT/next-action-$agent.log"; then
    fail "$agent advertised an unavailable onboard skill"
  fi
done
printf 'PASS: source-trace starter prompt, adapter-only guidance matches installed tools\n'

for option in --agent --ref; do
  expect_failure bash "$ROOT/install.sh" "$option"
  grep -q 'requires a value' "$TEST_ROOT/failure.log"
done
expect_failure bash "$ROOT/install.sh" --agent nonsense
expect_failure bash "$ROOT/install.sh" --ref 'main?bad=true'
expect_failure bash "$ROOT/install.sh" --unknown
bash "$ROOT/install.sh" --help > "$TEST_ROOT/help.log"
grep -q 'bob' "$TEST_ROOT/help.log"
diff -ru "$TEST_ROOT/expected" "$PROJECT_DIR"
printf 'PASS: helpful argument errors, help, no writes on invalid input\n'

# An incomplete marker must not eat the remainder of a developer's document.
printf '# Existing\n<!-- codebase-mentor:begin -->\nKeep all of this.\n' > AGENTS.md
cp AGENTS.md "$TEST_ROOT/malformed"
expect_failure bash "$ROOT/install.sh" --agent agents-md
cmp AGENTS.md "$TEST_ROOT/malformed"
printf '<!-- codebase-mentor:end -->\n' > AGENTS.md
cp AGENTS.md "$TEST_ROOT/malformed"
expect_failure bash "$ROOT/install.sh" --agent agents-md
cmp AGENTS.md "$TEST_ROOT/malformed"
cat "$ROOT/adapters/agents-md/AGENTS-snippet.md" "$ROOT/adapters/agents-md/AGENTS-snippet.md" > AGENTS.md
cp AGENTS.md "$TEST_ROOT/malformed"
expect_failure bash "$ROOT/install.sh" --agent agents-md
cmp AGENTS.md "$TEST_ROOT/malformed"
cp "$TEST_ROOT/expected/AGENTS.md" AGENTS.md
printf 'PASS: unbalanced and duplicate markers preserve existing files\n'

mv .bob/skills/codebase-mentor/SKILL.md "$TEST_ROOT/symlink-original"
ln -s "$TEST_ROOT/symlink-original" .bob/skills/codebase-mentor/SKILL.md
expect_failure bash "$ROOT/install.sh" --agent bob --project
grep -q 'Refusing to replace symlink' "$TEST_ROOT/failure.log"
cmp "$ROOT/skills/codebase-mentor/SKILL.md" "$TEST_ROOT/symlink-original"
rm .bob/skills/codebase-mentor/SKILL.md
mv "$TEST_ROOT/symlink-original" .bob/skills/codebase-mentor/SKILL.md
printf 'PASS: symlink targets preserved\n'

# The fake remote exercises the network path deterministically, including
# --ref from a local checkout and a failed download after earlier successes.
cat > "$TEST_ROOT/bin/curl" <<'CURL'
#!/usr/bin/env bash
set -euo pipefail
url="" output=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) output="$2"; shift 2 ;;
    https://*) url="$1"; shift ;;
    *) shift ;;
  esac
done
printf '%s\n' "$url" >> "$MENTOR_TEST_URL_LOG"
file="${url#https://raw.githubusercontent.com/jestatsio/codebase-mentor/test-ref/}"
[[ "$file" != "$url" ]] || exit 22
if [[ -n "${MENTOR_TEST_FAIL_FILE:-}" && "$file" == "$MENTOR_TEST_FAIL_FILE" ]]; then exit 22; fi
cp "$MENTOR_TEST_SOURCE_ROOT/$file" "$output"
CURL
chmod +x "$TEST_ROOT/bin/curl"
export MENTOR_TEST_SOURCE_ROOT="$ROOT"
export MENTOR_TEST_URL_LOG="$TEST_ROOT/urls.log"
export MENTOR_TEST_FAIL_FILE=skills/onboard/AUTHORING_GUIDE.md
expect_failure env PATH="$TEST_ROOT/bin:$PATH" bash "$ROOT/install.sh" --agent bob --project --ref test-ref
diff -ru "$TEST_ROOT/expected" "$PROJECT_DIR"
unset MENTOR_TEST_FAIL_FILE
env PATH="$TEST_ROOT/bin:$PATH" bash "$ROOT/install.sh" --agent bob --project --ref test-ref > "$TEST_ROOT/install.log"
diff -ru "$TEST_ROOT/expected" "$PROJECT_DIR"
# Exercise a real pipeline, matching the documented curl | bash installation.
# shellcheck disable=SC2002
cat "$ROOT/install.sh" | env PATH="$TEST_ROOT/bin:$PATH" bash -s -- --agent bob --project --ref test-ref > "$TEST_ROOT/install.log"
diff -ru "$TEST_ROOT/expected" "$PROJECT_DIR"
printf 'PASS: explicit refs, piped installs, failed downloads preserve working installs\n'

printf 'Installer checks passed.\n'
