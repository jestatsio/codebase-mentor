# Security Policy

## What counts as a security issue here

This project ships **instructions that AI coding agents execute** (skills, rules, AGENTS.md snippets) plus an install script, an optional local MCP server, and GitHub Actions workflows. In-scope reports include:

- **Prompt-injection vectors**: any way the protocol text, templates, or generated adapters could be abused to make an agent exfiltrate data, run unintended commands, or ignore its user's instructions.
- **Install-path issues**: `install.sh` writing outside its documented destinations, unsafe handling of fetched content, or marker-block upserts corrupting user files.
- **MCP server issues**: unsafe filesystem reads, unbounded resource use, or protocol handling that exposes data unexpectedly.
- **Workflow issues**: the example/CI GitHub Actions workflows requesting broader permissions than documented or leaking secrets.

## Reporting

Please report privately via **GitHub Security Advisories**: [Security tab → Report a vulnerability](https://github.com/jestatsio/codebase-mentor/security/advisories/new). Do not open a public issue for exploitable problems.

You can expect an acknowledgment within a week. Fixes ship as a new release with the advisory credited to you (unless you prefer otherwise).

## Supported versions

Only the latest release is supported. Plugin updates depend on marketplace settings; script installs should re-run `install.sh` (or `npx skills add jestatsio/codebase-mentor`) to pick up fixes.
