# Authoring repo context

An `ONBOARDING.md` is a short entry map for your codebase, with seven sections and a 400–800 word target. It points to current source and focused guides that explain the design constraints for particular subsystems. Existing longer maps and custom paths remain valid.

## Draft from source, then add rationale

After [installation](install.md), ask:

```text
Set up Codebase Mentor for this repo.
```

The **onboard** skill reads existing instructions and docs, traces representative source, and prepares a draft before asking up to three targeted questions about consequential gaps. Source can establish behavior and failure modes; historical rationale needs attribution to a decision document or the developer. Unanswered questions remain explicit.

Setup reuses the established map and useful existing guides. Where important subsystems lack useful context, it drafts up to three focused guides and lists uncovered areas. It then adds or reuses small native instruction entries for the selected agents.

For documents only, ask **“Use onboard to draft ONBOARDING.md only.”** This does not change agent instructions. In Claude Code, you can use `/codebase-mentor:onboard` with that request.

## The manual path: the template

Start from the [root template](https://github.com/jestatsio/codebase-mentor/blob/main/template/ONBOARDING.md), [authoring guide](https://github.com/jestatsio/codebase-mentor/blob/main/template/AUTHORING_GUIDE.md), and optional [subsystem guide template](https://github.com/jestatsio/codebase-mentor/blob/main/template/SUBSYSTEM_GUIDE.md). The authoring guide includes historical service examples and an illustrative batch pipeline; verify any borrowed source anchors against your project.

The seven sections:

| # | Section | What it answers |
|---|---|---|
| — | Document owner | Who keeps this accurate, on what cadence |
| 1 | Codebase purpose | What is this, who calls it, what does it return |
| 2 | Layer map | Responsibilities, source anchors, and scoped links to subsystem guides |
| 3 | Execution lifecycle | One representative path, entry to response, named at every hop |
| 4 | Domain vocabulary | 5–10 terms with project-specific meaning |
| 5 | Common change recipes | Valid examples, constraints, relevant tests, and verification prerequisites |
| 6 | High-signal files | The right entry point per common question |
| 7 | Known gotchas | Constraints, consequences, attributed rationale, and unresolved questions |

## Focus each subsystem guide

Reuse an existing guide where it already captures useful design context. For new guides, `docs/mentor/<subsystem>.md` is the suggested location. Link each from the map with relevant paths and kinds of changes so an agent can select only the context it needs.

Cover responsibilities, boundaries, design constraints, valid implementation examples and their limits, tests, commands and prerequisites, and known traps. Include contracts with other subsystems when a local change can affect them. Avoid repeating the root overview or generating a document for every directory.

Use symbols with file paths, or headings and configuration keys where code symbols do not apply. Record the source revision and what was checked when available. Separate source observations, documented decisions, developer-confirmed rationale, and open questions. A source inspection does not prove a command passed, and a date does not prove every claim was checked.

## Keep it alive

During ordinary work, Mentor checks relevant claims and proposes focused corrections for review. When a boundary or path moves, the update should include the affected guide and root routing entry. Human rationale and unrelated content remain intact.

A full freshness scan covers the map and explicitly listed guides by default; a document-only request stays limited to that document. Reports distinguish checked, skipped, and unverifiable claims. The [scheduled scan](ci.md) remains optional.
