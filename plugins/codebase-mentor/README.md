# Codebase Mentor

![Codebase Mentor](site/docs/assets/logo.png)

Version 1.3.0 by [JEStats](https://jestats.io). Understand unfamiliar code,
plan a change, and maintain onboarding documentation with source-backed answers.
The plugin contains two skills: **codebase-mentor** and **onboard**. It requires
no API key, database, background service, or separate MCP runtime.

## Set up your repository

Ask: **Set up Codebase Mentor for this repo.**

Onboard drafts or reuses a short repo map, asks up to three targeted questions,
and creates focused guides for important subsystems. It configures small project
instruction entries for your selected agents so future sessions can find that
context. Source claims are verified during use; drift corrections are proposed
for review. Ask **Is Mentor set up correctly here?** for a read-only status check.

Setup can use an optional Python 3.9+ helper for safe file edits. When Python is
unavailable, the skill describes the same workflow using the agent's file tools.
No helper runs automatically during plugin installation.

## Or start with a question

Open the repository you want to understand in your coding agent. Ask:

> Use codebase-mentor to trace one important execution path in this repository.
> Read the source, cite the relevant files and symbols, and flag what you cannot verify.

An ONBOARDING.md is optional. In Claude Code, invoke
`/codebase-mentor:codebase-mentor` to ask a question or
`/codebase-mentor:onboard` to draft a map. In Codex, select the skill by name or
ask to use **codebase-mentor** or **onboard** in a new session.

The skills guide your agent to inspect source. They do not guarantee correctness.
Review the cited evidence and any generated document before acting.

## Install and get help

- [Installation and troubleshooting](https://github.com/jestatsio/codebase-mentor/blob/main/docs/INSTALL.md)
- [Documentation](https://jestatsio.github.io/codebase-mentor/)
- [Source and releases](https://github.com/jestatsio/codebase-mentor)
- [Report an issue](https://github.com/jestatsio/codebase-mentor/issues)
- [Privacy policy](PRIVACY.md)

MIT licensed. See the bundled [LICENSE](LICENSE).
