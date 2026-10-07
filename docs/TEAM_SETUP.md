# Share Codebase Mentor with your team

Start with one repository and the installation method your team already uses. Add a reviewed `ONBOARDING.md` when you want to capture team context. Pick one method per agent to avoid duplicate skills.

## Claude Code: recommend the plugin in repo settings

Merge these keys into `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "codebase-mentor": {
      "source": {
        "source": "github",
        "repo": "jestatsio/codebase-mentor"
      }
    }
  },
  "enabledPlugins": {
    "codebase-mentor@codebase-mentor": true
  }
}
```

Claude may prompt teammates to trust the workspace and install the plugin. Organization policy and client settings can affect availability and updates. Do not replace existing settings with this example.

These settings use the `codebase-mentor` marketplace in Codebase Mentor’s own repository. If your team used `codebase-mentor@jestats-plugins` or committed skill copies, follow [switching installation methods](INSTALL.md#switching-installation-methods) so each teammate loads one copy. Remove the old `codebase-mentor@jestats-plugins` entry from `enabledPlugins`, while keeping the `jestats-plugins` marketplace and any other plugin settings your team uses.

## Codex: use the native plugin

Each teammate can install once:

```bash
codex plugin marketplace add jestatsio/codebase-mentor
codex plugin add codebase-mentor@codebase-mentor
```

For teams that prefer committed skills, use `--agent codex --project` below. That writes `.agents/skills/`, which supported Codex clients discover in the project.

## Bob and other agents: commit project skills

Run from the repo you want to equip. Pick the appropriate command:

```bash
# IBM Bob → .bob/skills/
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent bob --project

# Codex → .agents/skills/
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent codex --project

# Claude Code → .claude/skills/
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent claude --project
```

Review and commit the generated skill directories for the agent you chose. Teammates may need a fresh session to discover them. A vendored copy stays fixed until you rerun the installer. For reproducibility, use a reviewed checkout as described in the [install guide](INSTALL.md#download-and-review-the-installer).

For mixed agents that read `AGENTS.md`, use the compact shared protocol:

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent agents-md
```

This preserves other instructions outside the Codebase Mentor markers. The snippet supplies mentoring behavior. Install the skills separately if you want the onboard generator.

## Make the first session useful

1. Ask the mentor to trace a real feature or plan an upcoming change.
2. Review the cited source together. Confirm the explanation includes the relevant tests and existing example.
3. Generate or author an `ONBOARDING.md`, capturing team rationale and known pitfalls. Name a document owner.
4. Add a short contributor note explaining how to ask for the mentor and how to maintain the map.
5. Run a freshness scan after significant refactors. The [optional scheduled workflow](../examples/github-actions/onboarding-freshness.yml) requires an Anthropic API key and may incur model usage charges.

## Containers and offline use

Copy the reviewed skill directories into the image or checkout before going offline. Direct skills are plain Markdown and do not require a network fetch at runtime. Your coding agent may still require its own network connection. The [local installer](INSTALL.md#download-and-review-the-installer) can copy from a complete checkout without downloading the artifacts.
