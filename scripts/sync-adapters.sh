#!/usr/bin/env bash
#
# Regenerate every distribution artifact from its canonical source:
#
#   core/mentor-protocol.md          -> skills/codebase-mentor/SKILL.md (protocol body)
#   core/mentor-protocol-compact.md  -> adapters/agents-md/AGENTS-snippet.md
#                                       adapters/cursor/codebase-mentor.mdc
#                                       adapters/copilot/copilot-instructions-snippet.md
#   template/ONBOARDING.md           -> skills/codebase-mentor/ONBOARDING.template.md
#   template/AUTHORING_GUIDE.md      -> skills/codebase-mentor/AUTHORING_GUIDE.md
#   template/*.md, mentor-protocol  -> skills/onboard/ (standalone skill references)
#   core/*.md, template/*.md         -> mcp/bundled/ (byte-identical copies the
#                                       MCP server ships inside its npm package)
#
# Edit the sources, never the generated files. Usage:
#   scripts/sync-adapters.sh          regenerate in place
#   scripts/sync-adapters.sh --check  exit 1 if any generated file is out of date (CI gate)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE="${ROOT}/core/mentor-protocol.md"
COMPACT="${ROOT}/core/mentor-protocol-compact.md"

MODE="write"
[[ "${1:-}" == "--check" ]] && MODE="check"

OUT="${ROOT}"
if [[ "${MODE}" == "check" ]]; then
  OUT="$(mktemp -d)"
  trap 'rm -rf "${OUT}"' EXIT
  mkdir -p "${OUT}/skills/codebase-mentor" "${OUT}/skills/onboard" "${OUT}/adapters/agents-md" \
    "${OUT}/adapters/cursor" "${OUT}/adapters/copilot" "${OUT}/mcp/bundled"
fi

# Protocol body shared by SKILL.md: everything from "## Accuracy Contract" down.
core_body() { sed -n '/^## Accuracy Contract$/,$p' "${CORE}"; }

# --- skills/codebase-mentor/SKILL.md -----------------------------------------
{
cat <<'EOF'
---
name: codebase-mentor
description: Source-grounded codebase mentor for any repo with an ONBOARDING.md. Answers architecture questions, guides change tasks, reconciles doc claims against live source, and runs proactive freshness scans — every claim backed by a symbol or file read in that session.
---

# Source-Grounded Codebase Mentor

<!-- GENERATED FILE — do not edit the protocol body by hand.
     Canonical source: core/mentor-protocol.md. Regenerate with scripts/sync-adapters.sh. -->

Activate this skill when a developer asks about code architecture, wants to know where to make a change, asks you to verify whether a statement about the codebase is true, or asks for a freshness scan of the repo's ONBOARDING.md. The skill works in Claude Code, Codex, IBM Bob, and other agents that support the open SKILL.md format.

This skill applies to any repo that has an `ONBOARDING.md` at its root. The document is the map; live source is the truth.

**Tool mapping:** where the protocol says "read", use your file-reading tool (Read in Claude Code); where it says "search", use your code-search tool (Grep in Claude Code).

**Companions:** generate a missing ONBOARDING.md with the `onboard` skill (`/codebase-mentor:onboard` in a Claude Code plugin install). The authoring template and guide sit alongside this SKILL.md in any install: `ONBOARDING.template.md` and `AUTHORING_GUIDE.md`. Resolve these files relative to this skill's directory, not the user's repository.

---

EOF
core_body
} > "${OUT}/skills/codebase-mentor/SKILL.md"

# --- adapters/agents-md/AGENTS-snippet.md ------------------------------------
{
cat <<'EOF'
<!-- codebase-mentor:begin — generated from core/mentor-protocol-compact.md
     (https://github.com/jestatsio/codebase-mentor); do not edit by hand.
     Append this block to your repo's AGENTS.md. Re-running install.sh
     replaces everything between the begin/end markers. -->
EOF
cat "${COMPACT}"
cat <<'EOF'
<!-- codebase-mentor:end -->
EOF
} > "${OUT}/adapters/agents-md/AGENTS-snippet.md"

# --- adapters/cursor/codebase-mentor.mdc --------------------------------------
{
cat <<'EOF'
---
description: Source-grounded codebase mentor — answers architecture questions and guides change tasks from ONBOARDING.md plus live source, with symbol-anchored evidence for every claim
alwaysApply: false
---

<!-- GENERATED from core/mentor-protocol-compact.md
     (https://github.com/jestatsio/codebase-mentor); do not edit by hand. -->

EOF
cat "${COMPACT}"
} > "${OUT}/adapters/cursor/codebase-mentor.mdc"

# --- adapters/copilot/copilot-instructions-snippet.md --------------------------
{
cat <<'EOF'
<!-- codebase-mentor:begin — generated from core/mentor-protocol-compact.md
     (https://github.com/jestatsio/codebase-mentor); do not edit by hand.
     Paste into (or create) .github/copilot-instructions.md; install.sh
     replaces everything between the begin/end markers on re-run. The
     Copilot coding agent also reads AGENTS.md — see adapters/agents-md/. -->
EOF
cat "${COMPACT}"
cat <<'EOF'
<!-- codebase-mentor:end -->
EOF
} > "${OUT}/adapters/copilot/copilot-instructions-snippet.md"

# --- bundled template copies ---------------------------------------------------
cp "${ROOT}/template/ONBOARDING.md" "${OUT}/skills/codebase-mentor/ONBOARDING.template.md"
cp "${ROOT}/template/AUTHORING_GUIDE.md" "${OUT}/skills/codebase-mentor/AUTHORING_GUIDE.md"
cp "${ROOT}/template/ONBOARDING.md" "${OUT}/skills/onboard/ONBOARDING.template.md"
cp "${ROOT}/template/AUTHORING_GUIDE.md" "${OUT}/skills/onboard/AUTHORING_GUIDE.md"
cp "${ROOT}/core/mentor-protocol.md" "${OUT}/skills/onboard/mentor-protocol.md"

# --- mcp/bundled: canonical copies shipped inside the npm package ---------------
cp "${ROOT}/core/mentor-protocol.md" "${OUT}/mcp/bundled/mentor-protocol.md"
cp "${ROOT}/core/mentor-protocol-compact.md" "${OUT}/mcp/bundled/mentor-protocol-compact.md"
cp "${ROOT}/template/ONBOARDING.md" "${OUT}/mcp/bundled/ONBOARDING.template.md"
cp "${ROOT}/template/AUTHORING_GUIDE.md" "${OUT}/mcp/bundled/AUTHORING_GUIDE.md"

# --- check mode ----------------------------------------------------------------
GENERATED=(
  skills/codebase-mentor/SKILL.md
  skills/codebase-mentor/ONBOARDING.template.md
  skills/codebase-mentor/AUTHORING_GUIDE.md
  skills/onboard/ONBOARDING.template.md
  skills/onboard/AUTHORING_GUIDE.md
  skills/onboard/mentor-protocol.md
  adapters/agents-md/AGENTS-snippet.md
  adapters/cursor/codebase-mentor.mdc
  adapters/copilot/copilot-instructions-snippet.md
  mcp/bundled/mentor-protocol.md
  mcp/bundled/mentor-protocol-compact.md
  mcp/bundled/ONBOARDING.template.md
  mcp/bundled/AUTHORING_GUIDE.md
)

if [[ "${MODE}" == "check" ]]; then
  stale=0
  for f in "${GENERATED[@]}"; do
    if ! diff -u "${ROOT}/${f}" "${OUT}/${f}" >/dev/null 2>&1; then
      echo "STALE: ${f} (regenerate with scripts/sync-adapters.sh)" >&2
      diff -u "${ROOT}/${f}" "${OUT}/${f}" >&2 || true
      stale=1
    fi
  done
  [[ ${stale} -eq 0 ]] && echo "sync-adapters: all generated files up to date."
  exit ${stale}
fi

for f in "${GENERATED[@]}"; do echo "regenerated ${f}"; done
