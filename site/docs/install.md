# Install Codebase Mentor

Pick the agent you already use. Both skills are included: **codebase-mentor** for questions, change guidance, and scans, and **onboard** for drafting a repo map. You do not need an `ONBOARDING.md` to get started.

| Agent | Recommended setup | Where it lives |
| --- | --- | --- |
| Claude Code | Native plugin | Managed by Claude Code |
| Codex | Native plugin | Managed by Codex |
| IBM Bob | Project skills | `.bob/skills/` |
| Cursor | Project rule | `.cursor/rules/codebase-mentor.mdc` |
| Copilot | Repo instructions | `.github/copilot-instructions.md` |
| Other compatible agents | Open skills or AGENTS.md | Agent-specific |

## Claude Code

In Claude Code:

```text
/plugin marketplace add jestatsio/codebase-mentor
/plugin install codebase-mentor@codebase-mentor
```

Or from a terminal:

```bash
claude plugin marketplace add jestatsio/codebase-mentor
claude plugin install codebase-mentor@codebase-mentor
```

Start a new session if the skills do not appear. Ask an architecture question with `/codebase-mentor:codebase-mentor`, or draft a map with `/codebase-mentor:onboard`.

For older clients or a vendored copy, use the installer below with `--agent claude --project`. This writes `.claude/skills/`. Without `--project`, it uses `~/.claude/skills/`.

Update the marketplace and installed plugin through Claude's plugin manager. Automatic updates depend on your marketplace settings.

## Codex

With a Codex CLI that supports plugins:

```bash
codex plugin marketplace add jestatsio/codebase-mentor
codex plugin add codebase-mentor@codebase-mentor
```

The Codex app also supports adding the GitHub marketplace from its plugin interface. Add `jestatsio/codebase-mentor`, then install **Codebase Mentor**.

Open a new session and select the Codebase Mentor skill, or ask “Use Codebase Mentor to explain this repository.” Ask for the **onboard** skill to draft a map.

### Skills fallback

If `codex plugin` is unavailable, install the same skills directly:

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent codex --project
```

This uses `.agents/skills/` in your current repo. Omit `--project` for `~/.agents/skills/`. Invoke `$codebase-mentor` or `$onboard` in clients that support skill mentions.

Earlier Codebase Mentor installers wrote to `.codex/skills/` or `~/.codex/skills/`. If switching from those to a native plugin, remove only the old `codebase-mentor` and `onboard` directories you previously installed to avoid duplicate entries. The installer leaves old locations untouched.

## IBM Bob

Bob supports native `SKILL.md` skills. From your target repository:

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent bob --project
```

The result is:

```text
.bob/skills/
  codebase-mentor/
    SKILL.md
    ...bundled references
  onboard/
    SKILL.md
    ...bundled references
```

Reopen your workspace if necessary. Ask Bob:

```text
Use the codebase-mentor skill to explain the main execution path in this repo.
Read the relevant source and cite the files and symbols you used.
```

To draft a map: “Use the onboard skill to create an ONBOARDING.md. Ask me about our team's gotchas before finishing.”

For a user-level install shared across repositories, omit `--project`. It writes to `~/.bob/skills/`. Bob does not need Claude's plugin commands. See [IBM's skill documentation](https://bob.ibm.com/docs/ide/features/skills).

## Download and review the installer

If you prefer inspecting the code before running it:

```bash
git clone https://github.com/jestatsio/codebase-mentor.git
cd codebase-mentor
less install.sh
```

Then, from the repository you want to equip, run the checked-out script by its absolute path:

```bash
bash /absolute/path/to/codebase-mentor/install.sh --agent bob --project
```

A local checkout supplies the bundled files without a download. For a reproducible install, check out a reviewed commit or release before running it. `--help` lists all options.

## Other agents

### Open skills

The [`skills` CLI](https://github.com/vercel-labs/skills) can install the two skills into supported agents:

```bash
npx skills add jestatsio/codebase-mentor
```

Select the agents and skills you need. This requires Node.js and network access. It is a skills installation, separate from native plugin management.

### Cursor

From your target repo:

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent cursor
```

This adds `.cursor/rules/codebase-mentor.mdc`. The rule supplies mentor instructions. For the **onboard** generator too, install the open skills using the skills CLI.

### GitHub Copilot

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent copilot
```

This adds or replaces the Codebase Mentor block in `.github/copilot-instructions.md`, preserving text outside the marked block.

### AGENTS.md

For agents that read repo-level `AGENTS.md` instructions:

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent agents-md
```

This adds or replaces a marked compact mentor block in `AGENTS.md`. Existing instructions outside the block are preserved. Commit it to share with your team. Like the Copilot adapter, this supplies the mentor protocol, not a separate onboard skill command.

## Optional MCP server

You do not need MCP for the native plugins or skills. For another MCP client, see the [local build and configuration guide](https://github.com/jestatsio/codebase-mentor/tree/main/mcp). The npm package is not currently published, so `npx codebase-mentor-mcp` is not a supported install path.

## Confirm it works

1. Open your target repository and start a fresh agent session.
2. Ask it to use Codebase Mentor to trace a concrete feature.
3. Check that it actually reads source and cites files plus symbols. A confident answer without reads is not evidence that the skill ran.
4. If a map exists, ask it to verify one specific claim against source. If no map exists, it should proceed from source and explain the missing context.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Skill does not appear | Restart the session. Verify the install directory for your agent and that it contains `SKILL.md`. For project installs, run from the target repo. |
| `plugin` command is unknown | Update your agent, or use its direct skills fallback. |
| Two copies of the same skill appear | Keep one installation method. Remove only the old copies you installed, or uninstall the duplicate plugin. |
| Agent cannot verify a claim | Give it access to the relevant source. Runtime or deployment facts may still be unverifiable from code. |
| `ONBOARDING.md` is not found | Supported locations are the repo root, `docs/`, then `doc/`. The agent can still answer from source. |
| Download fails | Check GitHub access. Use a local checkout and run its installer. |

## Update or remove

For plugins, use your agent's plugin manager to update or uninstall **Codebase Mentor**. For direct skills, rerun the same installer to update. To remove, delete only its `codebase-mentor` and `onboard` directories from the chosen skills location.

For Cursor, remove `codebase-mentor.mdc`. For Copilot or AGENTS.md, remove the block from `<!-- codebase-mentor:begin -->` through `<!-- codebase-mentor:end -->`, leaving your other instructions intact. Your `ONBOARDING.md` remains yours.
