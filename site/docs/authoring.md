# Authoring an ONBOARDING.md

The ONBOARDING.md is a 400–800-word map of your codebase: seven sections, every claim anchored to a class or method name. Use the generator for a draft, then review the evidence and add the context your team knows.

## The fast path: generate it

Ask your agent to use the **onboard** skill. In Claude Code with the plugin installed, run in your repo:

```
/codebase-mentor:onboard
```

The skill scans your source, traces a representative execution path, drafts six of the seven sections with verified symbol anchors, then interviews you for the seventh — the **known gotchas** only humans can supply — plus the document owner block. It finishes by freshness-scanning its own draft.

## The manual path: the template

Start from [`template/ONBOARDING.md`](https://github.com/jestatsio/codebase-mentor/blob/main/template/ONBOARDING.md) with [`template/AUTHORING_GUIDE.md`](https://github.com/jestatsio/codebase-mentor/blob/main/template/AUTHORING_GUIDE.md) beside it — the guide has worked examples for two codebase archetypes (request/response service, batch pipeline) for every section.

The seven sections:

| # | Section | What it answers |
|---|---|---|
| — | Document owner | Who keeps this accurate, on what cadence |
| 1 | Codebase purpose | What is this, who calls it, what does it return |
| 2 | Layer map | The organizing principle — one key symbol per layer |
| 3 | Execution lifecycle | One representative path, entry to response, named at every hop |
| 4 | Domain vocabulary | 5–10 terms with project-specific meaning |
| 5 | Common change recipes | Ordered symbol checklists for 3–5 frequent tasks |
| 6 | High-signal files | The right entry point per common question |
| 7 | Known gotchas | Invariants invisible in source — what breaks, and why |

## The two rules that matter

**Symbol anchors, not line numbers.** "See `FindOneCommandResolver.resolveCollectionCommand()`" survives every edit that doesn't rename the method. "See line 72" is wrong within weeks.

**Section 7 is the payload.** Interview your senior reviewer: *"what mistakes do you keep catching in review?"* That answer is the section — context that source alone may not explain.

## Keep it alive

Name an owner, set a review cadence, and wire up the [scheduled freshness scan](ci.md) so drift files an issue instead of misleading the next engineer.
