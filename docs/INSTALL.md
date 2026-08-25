# Installing Codebase Mentor — Every Agent

The mentor protocol ships in three forms, all generated from one canonical source (`core/mentor-protocol.md`):

1. **SKILL.md skills** — for agents with native skill support (Claude Code, Codex CLI, and the `skills` CLI's ~70 supported agents).
2. **AGENTS.md snippet** — for the many agents that read the open [AGENTS.md](https://agents.md) standard.
3. **Per-agent adapters** — Cursor rule file, GitHub Copilot instructions block.

## The universal one-liner (recommended)

If you have Node.js, the [`skills` CLI](https://github.com/vercel-labs/skills) detects your installed agents and installs the skills into each:

```bash
npx skills add erichare/codebase-mentor
```

Useful flags: `-g` (install user-level instead of project-level), `-a claude-code` / `-a codex` / `-a cursor` (target one agent), `-y` (skip prompts).

## Claude Code (and IBM Bob)

Plugin install (preferred — gets you `/codebase-mentor:onboard` and auto-updates):

```
/plugin marketplace add erichare/codebase-mentor
/plugin install codebase-mentor@codebase-mentor
```

No plugin support (older versions, IBM Bob):

```bash
curl -fsSL https://raw.githubusercontent.com/erichare/codebase-mentor/main/install.sh | bash
```

Add `-s -- --project` to vendor the skills into the current repo's `.claude/skills/` instead. Team-wide rollout options are in [TEAM_SETUP.md](TEAM_SETUP.md).

## OpenAI Codex CLI

Codex supports the same open SKILL.md format:

```bash
curl -fsSL https://raw.githubusercontent.com/erichare/codebase-mentor/main/install.sh | bash -s -- --agent codex
```

Skills land in `~/.codex/skills/` (or `.codex/skills/` with `--project`). Invoke with `$codebase-mentor`, or let Codex pick it up implicitly from the description. Codex also reads `AGENTS.md` — see the snippet option below if you prefer repo-level instructions.

## Cursor

Two options:

- **AGENTS.md** (simplest — Cursor reads it natively): see the snippet section below.
- **Project rule** (richer: agent-requested by description):

```bash
curl -fsSL https://raw.githubusercontent.com/erichare/codebase-mentor/main/install.sh | bash -s -- --agent cursor
```

This drops `codebase-mentor.mdc` into `.cursor/rules/`. Commit it to share with the team.

## GitHub Copilot

- **Copilot coding agent**: reads `AGENTS.md` natively — use the snippet below.
- **Copilot Chat / repo-wide custom instructions**:

```bash
curl -fsSL https://raw.githubusercontent.com/erichare/codebase-mentor/main/install.sh | bash -s -- --agent copilot
```

This upserts a marked block into `.github/copilot-instructions.md` (created if missing; re-runs replace the block, never duplicate it).

## Everything that reads AGENTS.md

Codex, Cursor, Copilot coding agent, OpenCode, Amp, Zed, Windsurf, Gemini CLI, Jules, and more all read the [AGENTS.md](https://agents.md) standard:

```bash
curl -fsSL https://raw.githubusercontent.com/erichare/codebase-mentor/main/install.sh | bash -s -- --agent agents-md
```

This upserts the compact mentor protocol (~2 KB — well within Codex's 32 KiB combined-AGENTS.md budget) into your repo's `AGENTS.md` between `codebase-mentor:begin/end` markers. Commit it and every AGENTS.md-aware agent on the team follows the protocol.

## Everything at once

```bash
curl -fsSL https://raw.githubusercontent.com/erichare/codebase-mentor/main/install.sh | bash -s -- --agent all
```

## MCP clients

Any MCP-capable client can instead run the stdio server from [`mcp/`](../mcp/) (published as `codebase-mentor-mcp`). It exposes the protocol, ONBOARDING.md discovery, and the mentor/change_guide/reconcile/scan/onboard prompts as MCP tools, prompts, and resources — the client model does the reasoning:

```json
{
  "mcpServers": {
    "codebase-mentor": {
      "command": "npx",
      "args": ["-y", "codebase-mentor-mcp"]
    }
  }
}
```

## After installing — same three steps everywhere

1. If the repo has no `ONBOARDING.md`, author one from the [template](../template/ONBOARDING.md) ([authoring guide](../template/AUTHORING_GUIDE.md)) — Claude Code users can generate a draft with `/codebase-mentor:onboard`.
2. Ask an architecture question: *"Where do I add X?"* — answers come with symbol-anchored citations from current source.
3. Keep the doc fresh: ask *"has anything drifted?"*, or automate it with the [freshness-scan GitHub Action](../examples/github-actions/onboarding-freshness.yml).
