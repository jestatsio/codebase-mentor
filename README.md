<h1 align="center">Codebase Mentor</h1>

<p align="center"><strong>Find your way through unfamiliar code.</strong><br>
Architecture answers, change plans, and onboarding docs grounded in the source your agent actually reads.</p>

<p align="center">
  <a href="https://github.com/jestatsio/codebase-mentor/actions/workflows/validate.yml"><img src="https://github.com/jestatsio/codebase-mentor/actions/workflows/validate.yml/badge.svg" alt="Validation"></a>
  <a href="https://jestatsio.github.io/codebase-mentor/"><img src="https://img.shields.io/badge/docs-get_started-087f8c" alt="Documentation"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-64748b" alt="MIT license"></a>
  <a href="https://jestats.io"><img src="https://img.shields.io/badge/by-JEStats-087f8c" alt="By JEStats"></a>
</p>

<p align="center"><a href="#install">Install</a> · <a href="#try-it">Try it</a> · <a href="docs/INSTALL.md">Setup help</a> · <a href="https://jestatsio.github.io/codebase-mentor/">Docs</a></p>

Give your coding agent a repeatable way to answer **“How does this work?”** and **“Where do I make this change?”** Codebase Mentor asks it to read current source, cite the relevant files and symbols, and call out missing evidence. A short `ONBOARDING.md` adds the rationale and gotchas your team knows.

**Start in any repo.** An onboarding doc is optional. The skills need no API key, database, background service, or separate runtime beyond your coding agent.

## Install

Install directly from [Codebase Mentor’s repository](https://github.com/jestatsio/codebase-mentor). It includes the `codebase-mentor` marketplace for both Claude Code and Codex.

### Claude Code

Run in Claude Code:

```text
/plugin marketplace add jestatsio/codebase-mentor
/plugin install codebase-mentor@codebase-mentor
```

### Codex

Run in your terminal with a current Codex CLI:

```bash
codex plugin marketplace add jestatsio/codebase-mentor
codex plugin add codebase-mentor@codebase-mentor
```

In the Codex app, add `jestatsio/codebase-mentor` as a plugin marketplace and install **Codebase Mentor**. If your version does not support plugins, use the [skills fallback](docs/INSTALL.md#codex).

Already installed from `jestats-plugins` or as direct skills? Keep one copy per agent. See [switching installation methods](docs/INSTALL.md#switching-installation-methods) before changing sources.

### IBM Bob

From the repository you want to understand:

```bash
curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent bob --project
```

This installs both skills in `.bob/skills/`. Reopen your workspace if they do not appear, then ask Bob to use Codebase Mentor. See [Bob setup and troubleshooting](docs/INSTALL.md#ibm-bob) for a download-and-review alternative.

**Other agents:** `npx skills add jestatsio/codebase-mentor` installs the open skills format. [Cursor, Copilot, AGENTS.md, and all installation options →](docs/INSTALL.md)

## Try it

Open a repo in your agent and paste:

```text
Use Codebase Mentor to trace one important execution path in this repo.
Explain it to a new contributor. Cite the files and symbols you read,
and flag anything you cannot verify.
```

Then put it to work:

| You want to… | Ask your agent |
| --- | --- |
| Understand an unfamiliar feature | “Use Codebase Mentor: how does authentication work here?” |
| Plan a change | “Where would I add a new API endpoint? Find the closest existing example and the tests to run.” |
| Check an assumption | “Our docs say validation happens before dispatch. Is that still true?” |
| Catch stale documentation | “Scan ONBOARDING.md against current source. Show what changed and what you could not verify.” |
| Create a map for your team | “Use the onboard skill to draft ONBOARDING.md. Ask me about the gotchas source cannot explain.” |

In Claude Code, invoke the generator directly with `/codebase-mentor:onboard`. In other agents, select **onboard** from their skills menu or ask for it by name.

An answer should make its evidence inspectable. For example, in **this repository**:

> **Where do I change the mentor’s behavior?** Edit `core/mentor-protocol.md`, then run `scripts/sync-adapters.sh` to regenerate the distributed copies. Update `core/mentor-protocol-compact.md` when the rule also applies to compact adapters. Run `scripts/sync-adapters.sh --check` to check for drift.
>
> **Evidence:** the full and compact protocol files, plus the generation and check paths in `scripts/sync-adapters.sh`.

The protocol is an instruction set, not a correctness guarantee. Results depend on your agent and its source access. Review its evidence before acting.

## A map your team can maintain

`ONBOARDING.md` is a short, human-owned guide: purpose, layers, execution path, vocabulary, change recipes, useful files, and known gotchas. The agent uses it to find the code, then checks what the code actually does.

1. **Draft:** use the onboard skill, or start with the [template](template/ONBOARDING.md).
2. **Review:** add the design decisions and pitfalls only your team knows.
3. **Share:** commit it alongside your code. Follow the [team setup guide](docs/TEAM_SETUP.md).
4. **Maintain:** ask for a freshness scan after refactors, or opt into the [scheduled scan](examples/github-actions/onboarding-freshness.yml).

Browse [real example maps](onboarding/) for Python libraries, Java services, and a Python/React application. Examples are snapshots, so verify their anchors against the version you use.

## Evidence and limitations

The project began with a five-task, author-scored case study on the Stargate Data API:

| Setup | Average score (1–5) |
| --- | --- |
| No skill, no source access, no onboarding doc | 1.3 |
| Skill + live source, no onboarding doc | 3.5 |
| Skill + live source + onboarding doc | 4.7 |

This is an exploratory case study, not an independent benchmark. The first comparison changes both source access and instructions. Published responses include normalized excerpts, and independent judging has not been completed. [Read the design, rubrics, responses, and limitations](evaluation/SCORECARD.md).

## Go further

| Guide | What you’ll find |
| --- | --- |
| [Install and troubleshoot](docs/INSTALL.md) | Native plugins, Bob skills, other agents, updates, and removal |
| [Roll out to a team](docs/TEAM_SETUP.md) | Share skills and a reviewed repo map |
| [Write a useful map](template/AUTHORING_GUIDE.md) | Seven sections with worked examples |
| [Optional MCP server](mcp/) | A local stdio bridge for MCP clients, built from this checkout |
| [Privacy](PRIVACY.md) | Project-file access, generated docs, and your agent's data handling |
| [Contribute](CONTRIBUTING.md) | Protocol changes, new adapters, examples, and checks |

The MCP package is not currently published to npm. Use its documented local build. Native plugin and skill installs do not need it.

<details>
<summary><strong>Repository layout</strong></summary>

| Path | Purpose |
| --- | --- |
| `core/` | Canonical full and compact mentor protocols |
| `skills/` | Mentor skill, onboard generator, and bundled reference files |
| `adapters/` | Generated AGENTS.md, Cursor, and Copilot instructions |
| `template/` | Canonical onboarding template and authoring guide |
| `scripts/` | Artifact generation and validation |
| `mcp/` | Optional TypeScript MCP server |
| `site/` | Documentation site and brand assets |
| `onboarding/`, `evaluation/` | Example maps and the original case study |

</details>

---

<p align="center">Built by <a href="https://jestats.io">JEStats</a> · Created by <a href="https://github.com/erichare">Eric Hare</a> · <a href="LICENSE">MIT licensed</a></p>
