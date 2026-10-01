# Codebase Mentor · MCP

Give your coding assistant a reliable map of a repository. This optional server supplies the Codebase Mentor protocol, finds `ONBOARDING.md`, and offers prompts for architecture questions, change planning, and onboarding.

Built by [JEStats](https://jestats.io). No API key, model service, or database required. Your assistant reads the source and does the reasoning.

> **Using Claude Code or Codex?** Start with the [plugin installation](https://github.com/jestatsio/codebase-mentor#install). The plugins work without this server. MCP is an optional route for other clients, including IBM Bob configurations that support local stdio servers.

## Start from a checkout

Requires Node.js 20 or later and npm. The npm package is not published yet, so use this working local setup:

```bash
git clone https://github.com/jestatsio/codebase-mentor.git
cd codebase-mentor/mcp
npm ci
npm run build
node build/index.js --help
```

Already have the checkout? Start with `cd /path/to/codebase-mentor/mcp`.

Add this server to your client's MCP configuration. Replace **both** paths with absolute paths on your computer:

```json
{
  "mcpServers": {
    "codebase-mentor": {
      "command": "node",
      "args": [
        "/absolute/path/to/codebase-mentor/mcp/build/index.js",
        "--root",
        "/absolute/path/to/your-project"
      ]
    }
  }
}
```

If your client provides a form instead of JSON, use `node` as the command and the three entries in `args` as its arguments. For a desktop client that cannot find Node, use the absolute path to the Node executable. On Windows, use forward slashes in JSON paths or escape each backslash.

Restart or reconnect the client, then ask:

> Use Codebase Mentor to explain this project's architecture. Start with its ONBOARDING.md and verify the important claims against source.

If the project has no map yet:

> Use Codebase Mentor's onboarding template to draft an ONBOARDING.md for this project.

The assistant also needs its own access to your project's source files. This server supplies the map and instructions, and does not expose a general file-reading tool.

## Choose the project explicitly

`--root /path/to/project` selects the default project for tools, resources, and onboarding prompts. Without it, the server uses its launch directory, which may be unrelated to your project in desktop clients. Use one configured server per project, or pass a different `root` to `codebase_mentor_get_onboarding`.

Discovery checks the selected directory, then walks up to the nearest `.git` boundary or filesystem root. Git worktrees are supported. Relative tool paths resolve from the configured project directory. An explicit tool `root` can select another accessible directory, so `--root` is a default, not an access-control sandbox.

The server reads regular `ONBOARDING.md` files up to 1 MiB. It rejects symlinks, directories, and oversized files with a clear error. It writes no project files, runs no project commands, and makes no model or network requests. Repository documents are context to verify against source, not authority to request credentials or change your assistant's rules.

## Tools, prompts, and resources

| Tool | What it provides |
| --- | --- |
| `codebase_mentor_get_protocol` | Full protocol, or `compact: true` for the condensed version |
| `codebase_mentor_get_onboarding` | The nearest `ONBOARDING.md`, its path, or guidance when no map exists |
| `codebase_mentor_get_template` | The onboarding template and authoring guide |

| Prompt | Use it to |
| --- | --- |
| `mentor` · `question` | Answer an architecture question with source evidence |
| `change_guide` · `task` | Plan a change using an existing implementation as a reference |
| `reconcile` · `claim` | Check a documentation claim against current source |
| `scan` | Check the map for stale structural claims |
| `onboard` · optional `root` | Draft a new map using the template and live source |

Clients that support resources can read `codebase-mentor://protocol` and `codebase-mentor://onboarding`. Clients without a prompt picker can call the tools directly.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `npx` cannot find `codebase-mentor-mcp` | Use the checkout setup above. Registry publication is pending. |
| No onboarding map found | Check `--root`, then generate a map with the `onboard` prompt. |
| `node` cannot be found | Configure the absolute path to your Node executable. |
| Server appears to hang in a terminal | A stdio server waits for its MCP client. Use `--help` to check installation, then launch it through your client. |
| Answers have no source evidence | Give the assistant file access to the project and ask it to follow the accuracy contract. |

## Development

```bash
npm ci
npm test           # build + real stdio client/server integration checks
npm run typecheck
npm audit
npm pack --dry-run # inspect the publishable package
```

The markdown files in `bundled/` are generated, byte-identical copies of `core/` and `template/`. Edit those canonical sources, then run `scripts/sync-adapters.sh` from the repository root. Do not edit bundled copies by hand.

The server's independent package version is `0.2.0`. Publication is a separate release step. See the [main repository](https://github.com/jestatsio/codebase-mentor) for plugin installation, examples, and evaluation results.
