#!/usr/bin/env bash
# Direct skills and adapter installer. Native Claude/Codex plugins are also
# available from the JEStats marketplace (see README.md).
# Requires Bash 3.2+ and standard POSIX utilities. Remote installs need curl.
set -euo pipefail

REPO="jestatsio/codebase-mentor"
REF="main"
REF_SET=0
PROJECT=0
AGENT="claude"
SKILL_FILES=(
  skills/codebase-mentor/SKILL.md
  skills/codebase-mentor/ONBOARDING.template.md
  skills/codebase-mentor/AUTHORING_GUIDE.md
  skills/onboard/SKILL.md
  skills/onboard/ONBOARDING.template.md
  skills/onboard/AUTHORING_GUIDE.md
  skills/onboard/mentor-protocol.md
)

usage() {
  cat <<'HELP'
Codebase Mentor by JEStats

Usage: bash install.sh [--agent AGENT] [--project] [--ref REF]

  --agent AGENT  claude (default), codex, bob, cursor, copilot, agents-md, all
  --project      Install skills for this project instead of your user account
  --ref REF      Download a branch, tag, or commit from GitHub (default: main)
  --help, -h     Show this help

Skill locations (global / --project):
  claude     ~/.claude/skills / .claude/skills
  codex      ~/.agents/skills / .agents/skills
  bob        ~/.bob/skills / .bob/skills

Cursor, Copilot, and AGENTS.md adapters always install in the current directory.
Both codebase-mentor and onboard skills are included. Rerunning updates only
bundled files or the marked instruction block, preserving unrelated content.
From a checkout, files are copied locally unless --ref explicitly selects GitHub.

Examples:
  bash install.sh --agent bob
  bash install.sh --agent codex --project
  curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent bob
HELP
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --project) PROJECT=1; shift ;;
    --ref|--agent)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$1 requires a value. See --help."
      if [[ "$1" == --ref ]]; then REF="$2"; REF_SET=1; else AGENT="$2"; fi
      shift 2 ;;
    *) die "Unknown option: $1. See --help." ;;
  esac
done

case "$AGENT" in
  claude|codex|bob|cursor|copilot|agents-md|all) ;;
  *) die "Unknown agent: $AGENT. Choose claude, codex, bob, cursor, copilot, agents-md, or all." ;;
esac
[[ "$REF" =~ ^[a-zA-Z0-9._/-]+$ && "$REF" != -* ]] || die "Invalid git ref: $REF"

LOCAL_SRC=""
if [[ "$REF_SET" -eq 0 && -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -f "$SCRIPT_DIR/skills/codebase-mentor/SKILL.md" ]]; then LOCAL_SRC="$SCRIPT_DIR"; fi
fi
if [[ -z "$LOCAL_SRC" ]]; then command -v curl >/dev/null || die "Remote installation requires curl."; fi

# Fetch every required file before touching an existing installation. A failed
# download must never truncate a working skill or remove an instruction block.
STAGING="$(mktemp -d "${TMPDIR:-/tmp}/codebase-mentor.XXXXXX")"
PENDING_FILE=""
cleanup() {
  [[ -z "$PENDING_FILE" ]] || rm -f "$PENDING_FILE"
  rm -rf "$STAGING"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

stage_file() {
  local file="$1"
  [[ ! -f "$STAGING/$file" ]] || return 0
  mkdir -p "$STAGING/$(dirname "$file")"
  if [[ -n "$LOCAL_SRC" ]]; then
    cp "$LOCAL_SRC/$file" "$STAGING/$file"
  else
    curl --fail --silent --show-error --location --retry 2 \
      --connect-timeout 15 --max-time 120 \
      "https://raw.githubusercontent.com/$REPO/$REF/$file" -o "$STAGING/$file"
  fi
  [[ -s "$STAGING/$file" ]] || die "Empty source file: $file"
}

stage_agent() {
  local file
  case "$1" in
    claude|codex|bob) for file in "${SKILL_FILES[@]}"; do stage_file "$file"; done ;;
    cursor) stage_file adapters/cursor/codebase-mentor.mdc ;;
    copilot) stage_file adapters/copilot/copilot-instructions-snippet.md ;;
    agents-md) stage_file adapters/agents-md/AGENTS-snippet.md ;;
  esac
}

AGENTS=("$AGENT")
if [[ "$AGENT" == all ]]; then AGENTS=(claude codex bob cursor copilot agents-md); fi
for agent in "${AGENTS[@]}"; do stage_agent "$agent"; done

write_file() {
  local source="$1" target="$2" directory mode
  [[ ! -L "$target" ]] || die "Refusing to replace symlink: $target"
  [[ ! -d "$target" ]] || die "Expected a file, found directory: $target"
  directory="$(dirname "$target")"
  mkdir -p "$directory"
  if [[ -f "$target" ]]; then
    # Preserve a developer's existing permissions, including private documents.
    # GNU and BSD stat use different flags for the numeric permission bits.
    mode="$(stat -c '%a' "$target" 2>/dev/null)" || mode="$(stat -f '%Lp' "$target")"
  else
    # mktemp starts at 0600. Set the normal file mode filtered by the caller's
    # umask instead of copying the source file's permissions into the install.
    mode="$(umask)"
    printf -v mode '%o' "$((0666 & ~8#$mode))"
  fi
  PENDING_FILE="$(mktemp "$directory/.codebase-mentor.XXXXXX")"
  cp "$source" "$PENDING_FILE"
  chmod "$mode" "$PENDING_FILE"
  mv -f "$PENDING_FILE" "$target"
  PENDING_FILE=""
  printf 'Installed %s\n' "$target"
}

install_skills() {
  local destination="$1" file
  for file in "${SKILL_FILES[@]}"; do
    write_file "$STAGING/$file" "$destination/${file#skills/}"
  done
}

upsert_block() {
  local target="$1" snippet="$2" existing="$STAGING/existing" output="$STAGING/updated"
  [[ ! -L "$target" ]] || die "Refusing to replace symlink: $target"
  [[ ! -d "$target" ]] || die "Expected a file, found directory: $target"
  : > "$existing"
  if [[ -f "$target" ]]; then cp "$target" "$existing"; fi

  # Reject malformed or duplicate markers instead of silently deleting text.
  if ! awk '
    /^<!-- codebase-mentor:begin([[:space:]]|$)/ { if (inside || count++) exit 1; inside=1 }
    /^<!-- codebase-mentor:end[[:space:]]*-->/ { if (!inside) exit 1; inside=0; ends++ }
    END { if (inside || count != ends) exit 1 }
  ' "$existing"; then die "Malformed codebase-mentor markers in $target. Existing file preserved."; fi

  awk -v snippet="$snippet" '
    function insert( line) { while ((getline line < snippet) > 0) print line; close(snippet) }
    /^<!-- codebase-mentor:begin([[:space:]]|$)/ { insert(); inside=1; replaced=1; next }
    /^<!-- codebase-mentor:end[[:space:]]*-->/ { inside=0; next }
    !inside { print }
    END { if (!replaced) { if (NR) print ""; insert() } }
  ' "$existing" > "$output"
  write_file "$output" "$target"
}

for agent in "${AGENTS[@]}"; do
  case "$agent" in
    claude|codex|bob)
      case "$agent" in claude) base=.claude ;; codex) base=.agents ;; bob) base=.bob ;; esac
      if [[ "$PROJECT" -eq 1 ]]; then install_skills "$base/skills"
      else install_skills "${HOME:?HOME must be set for global installation}/$base/skills"; fi ;;
    cursor) write_file "$STAGING/adapters/cursor/codebase-mentor.mdc" .cursor/rules/codebase-mentor.mdc ;;
    copilot) upsert_block .github/copilot-instructions.md "$STAGING/adapters/copilot/copilot-instructions-snippet.md" ;;
    agents-md) upsert_block AGENTS.md "$STAGING/adapters/agents-md/AGENTS-snippet.md" ;;
  esac
done

printf '\nCodebase Mentor is ready. Start a new agent session, then ask:\n'
printf '  "Use Codebase Mentor to trace one important execution path in this repo.\n'
printf '   Cite the files and symbols you read, and flag anything you cannot verify."\n'
case "$AGENT" in
  claude|codex|bob|all)
    printf '\nWhen you want an onboarding map, ask:\n'
    printf '  "Use onboard to draft ONBOARDING.md. Ask me about the gotchas source cannot explain."\n' ;;
esac
printf '\nInstall guide: https://github.com/%s#install\n' "$REPO"
