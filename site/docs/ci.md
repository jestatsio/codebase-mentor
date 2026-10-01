# CI Freshness Scanning

Drift is the failure mode of every onboarding doc — and a stale doc that an agent confidently repeats is worse than no doc. Automate the defense.

## The scheduled scan

Copy [`examples/github-actions/onboarding-freshness.yml`](https://github.com/jestatsio/codebase-mentor/blob/main/examples/github-actions/onboarding-freshness.yml) into your repo's `.github/workflows/`. Weekly (and on demand), it:

1. Installs the codebase-mentor plugin inside [`anthropics/claude-code-action`](https://github.com/anthropics/claude-code-action).
2. Runs the Mode 4 scan: every structural claim in `ONBOARDING.md` verified against current source.
3. Files (or updates) a GitHub issue titled *"ONBOARDING.md freshness scan: drift detected"* containing the report table when anything is ⚠️ Stale — and closes it with a comment when a later scan comes back clean.

## Setup

1. Add an `ANTHROPIC_API_KEY` secret (repo Settings → Secrets and variables → Actions).
2. Commit the workflow. It needs only:

```yaml
permissions:
  contents: read
  issues: write
```

## What a report looks like

| Section | Claim summary | Status | Evidence |
|---|---|---|---|
| Execution Lifecycle | "sort validation runs in `SortClause.validate()` before the resolver" | ⚠️ Stale | `FindOneCommandResolver.resolveCollectionCommand()` calls `sortClause.validate()` inside the resolver |
| Layer Map | 5 claims | ✅ Current | — |

Each Stale row comes with a one-sentence recommended correction. The scan never edits your ONBOARDING.md itself — corrections are proposed, humans (or a follow-up agent session you supervise) apply them.

## Tuning

- **Cadence**: the example runs Mondays 09:00 UTC; adjust the cron.
- **Cost control**: the scan reads your ONBOARDING.md and the files it references — small docs (the recommended 400–800 words) keep runs cheap. `--max-turns` caps runaway sessions.
- **On-demand**: the `workflow_dispatch` trigger lets you run it from the Actions tab after any large refactor.
