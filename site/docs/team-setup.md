# Share Codebase Mentor with your team

Start with one repository and the installation method your team already uses. Pick one method per agent to avoid duplicate skills. Then ask **“Set up Codebase Mentor for this repo for Codex, Claude Code, and IBM Bob”**, naming only the agents your team uses.

Setup drafts from source, asks up to three targeted questions, and connects the selected agents to a shared repo map and relevant subsystem guides. Installation alone does not change project instructions.

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

These settings use the `codebase-mentor` marketplace in Codebase Mentor’s own repository. If your team used `codebase-mentor@jestats-plugins` or committed skill copies, follow [switching installation methods](install.md#switching-installation-methods) so each teammate loads one copy. Remove the old `codebase-mentor@jestats-plugins` entry from `enabledPlugins`, while keeping the `jestats-plugins` marketplace and any other plugin settings your team uses.

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

Review and commit the generated skill directories for the agent you chose. Teammates may need a fresh session to discover them. A vendored copy stays fixed until you rerun the installer. For reproducibility, use a reviewed checkout as described in the [install guide](install.md#download-and-review-the-installer).

For mixed agents that read `AGENTS.md`, use the compact shared protocol:

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent agents-md
```

This preserves other instructions outside the Codebase Mentor markers. The snippet supplies mentoring behavior. Install the skills separately if you want the onboard generator.

## Set up shared context

1. Ask for repo setup and name the team's agents. Mentor reuses existing docs, drafts a short map, and creates up to three focused subsystem guides where deeper context is missing. Important uncovered areas remain visible.
2. Review the cited source, design constraints, valid examples, and verification commands. Answer up to three questions about consequential gaps; unanswered questions stay marked. Confirm a document owner when appropriate.
3. Review and commit the map, guides, and small native instruction entries. The default surfaces are effective Codex project instructions, `.claude/rules/codebase-mentor.md`, and `.bob/rules/codebase-mentor.md`. Setup inspects existing instructions before adding entries.
4. Start a fresh session in each client your team uses. Request an ordinary change without mentioning Mentor. Confirm that the agent reads the relevant context, checks current source, preserves the original project instructions, and respects the design constraint.
5. Ask **“Is Mentor set up correctly here?”** for a read-only status report. Configured files and observed fresh-session use are separate evidence; client versions, settings, and nested instruction files can affect loading.

To draft documents without changing project instructions, ask **“Use onboard to draft ONBOARDING.md only.”** The entry map keeps its seven-section format and established location. Existing maps need no migration.

## Maintain and remove setup

During ordinary work, Mentor checks the claims relevant to the task and proposes a small update for review when those claims drift. The proposal includes affected guide links when subsystem boundaries change. A focused check does not certify the rest of the map.

Ask for a full freshness scan after significant refactors. By default it covers the entry map and explicitly listed subsystem guides, reporting any skipped or unverifiable claims. The [optional scheduled workflow](https://github.com/jestatsio/codebase-mentor/blob/main/examples/github-actions/onboarding-freshness.yml) requires an Anthropic API key and may incur model usage charges.

Rerun repo setup to update the selected managed entries, preserving existing documents and unrelated instructions. Ask **“Remove Codebase Mentor's setup entries for this repo”** to remove those entries for selected clients while retaining the map and guides. Manual pointers and legacy adapters remain until explicitly removed. Uninstalling skills alone does not remove project instruction entries.

## Containers and offline use

Copy the reviewed skill directories into the image or checkout before going offline. The skills use local instructions and bundled references; setup can use an optional Python 3.9+ helper, with native agent file editing as a fallback. No background service or runtime network fetch is required by Mentor. Your coding agent may still require its own network connection. The [local installer](install.md#download-and-review-the-installer) can copy from a complete checkout without downloading the artifacts.
