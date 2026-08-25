# Evaluation & Origin Story

## Origin: the IBM Bob Challenge

Codebase Mentor began as Eric Hare's submission to IBM's **Bob Challenge 2026** (Bob is IBM's distribution of Claude Code). The brief: build a reusable skill and prove it on a hard, real codebase. The testbed was the [Stargate Data API](https://github.com/stargate/jsonapi) — 39 concrete command resolvers, a five-layer request pipeline, a custom task-retry framework, and no pre-existing agent documentation. The full demo script, planted-stale-claim setup, and original implementation plan remain in the repo ([`demo/`](https://github.com/erichare/codebase-mentor/tree/main/demo), [`docs/plan.md`](https://github.com/erichare/codebase-mentor/blob/main/docs/plan.md)).

## The three-arm evaluation

Five tasks (add a sort type, explain a four-path resolver, add an error code, a design-intent gotcha, a task-vs-operation architecture question) were run under three conditions:

| Arm | Condition | Avg score |
|---|---|---|
| 1 | Bare agent — no skill, no source access | **1.3 / 5** |
| 2 | Agent + skill + live source, no ONBOARDING.md | **3.5 / 5** |
| 3 | Agent + skill + live source + ONBOARDING.md | **4.7 / 5** |

Each response was scored 1–5 on file coverage, correctness, and usefulness against pre-written per-task rubrics. Full rubrics, scores, and **all raw outputs** are committed in [`evaluation/SCORECARD.md`](https://github.com/erichare/codebase-mentor/blob/main/evaluation/SCORECARD.md).

!!! warning "Provenance"
    Scores were assigned by the submission author against pre-written rubric criteria, not by independent judges. The raw outputs are published precisely so anyone can re-score them blind. Treat the deltas, not the absolute numbers, as the signal.

## The two results worth knowing

**The design-intent gotcha (T4).** Asked whether collection and table operation logic should be shared, the source-only arm *recommended sharing it* — the code structure makes it look safe. The ONBOARDING.md arm refused, citing the doc's gotcha section: collections use a shredded denormalized schema, tables map one-to-one to CQL, and sharing concrete operation code breaks both. This is the class of knowledge only an authored doc can carry — source alone actively misleads.

**The evidenced refusal.** A stale claim was deliberately planted in the ONBOARDING.md (a validation-order statement contradicted by the source). Asked to verify it, the agent read `FindOneCommandResolver.resolveCollectionCommand()`, declared the doc claim **Stale**, and cited the contradicting method. A doc that an agent confidently *corrects* is safer than a doc it confidently repeats.

## Secondary observation

Arm 3 sessions were also faster: the domain-vocabulary section and gotcha map let the agent skip exploratory reads and answer design-intent questions directly. The map pays for itself in read operations, not just accuracy.
