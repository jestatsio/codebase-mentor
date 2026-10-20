# Codebase Mentor privacy policy

Last updated: October 20, 2026

This policy describes the Codebase Mentor skills-only plugin published by
JEStats. The plugin contains the **codebase-mentor** and **onboard** instructions,
reference documents, an optional local setup helper, and listing assets. It does not include the optional MCP
server available separately in the source repository.

## Project files and generated documents

When you use a skill, it asks your chosen coding agent to read relevant files in
the project you make available. These can include source code, configuration,
and onboarding documentation. Project files and your conversation may contain
personal data, such as contributor names and email addresses. You choose the
project and control access through your agent's permissions.

When requested, the onboard skill asks the agent to write or update an
ONBOARDING.md and focused subsystem guides in your project. Repo setup can also
add or remove marked context entries in the selected agents' project instruction
files. The optional Python setup helper reads local setup files and performs those
file edits; it makes no network requests or model calls. Other skill workflows may propose or apply
documentation corrections that you authorize. Those files remain in the project
until you change or delete them. The plugin does not maintain a separate index,
database, account, or background storage service.

## Your coding agent's processing

Codebase Mentor runs as instructions within the agent you selected. That agent
and its configured model provider determine how conversation content and file
contents are processed, transmitted, logged, or retained. Using this plugin does
not change those settings or policies. A local project file may therefore be
processed by your agent's remote model service. Review the host's privacy
settings and policies before giving it access to confidential or personal data.

## JEStats services and credentials

The packaged skills have no JEStats backend, analytics, telemetry, or remote
storage. They do not send project files or conversations to a JEStats service.
The plugin does not ask for credentials, API keys, or a JEStats account. Any
account or authentication needed to use your coding agent belongs to that host.

## Installation and support

Downloading the plugin from GitHub or installing it through a marketplace uses
those platforms and is subject to their own data-handling policies. These
services may process information about the download or installation.

You can report problems or ask questions through the public
[GitHub issue tracker](https://github.com/jestatsio/codebase-mentor/issues).
Content you post there, including account information shown by GitHub, is handled
through GitHub and can be visible to maintainers and other visitors. Do not post
secrets, personal information, or confidential source code in an issue. Share a
minimal example with sensitive details removed.
