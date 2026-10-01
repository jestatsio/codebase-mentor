# The original case study

Codebase Mentor began as Eric Hare's submission to IBM's Bob Challenge 2026. The testbed was the [Stargate Data API](https://github.com/stargate/jsonapi), a Java service with a layered request pipeline. The [original plan](https://github.com/jestatsio/codebase-mentor/blob/main/docs/plan.md) and [demo script](https://github.com/jestatsio/codebase-mentor/tree/main/demo) remain available as historical material.

## What was compared

Five tasks covered adding a sort type, explaining a resolver, adding an error code, a design-intent gotcha, and a task-versus-operation architecture question.

| Arm | Condition | Average score (1–5) |
| --- | --- | --- |
| 1 | No skill, no source access, no onboarding doc | 1.3 |
| 2 | Skill + live source, no onboarding doc | 3.5 |
| 3 | Skill + live source + onboarding doc | 4.7 |

The author assigned scores for file coverage, correctness, and usefulness using task-specific rubrics. Read the [scorecard and published response excerpts](https://github.com/jestatsio/codebase-mentor/blob/main/evaluation/SCORECARD.md).

## How to interpret it

This is a small exploratory case study, not a controlled or independently validated benchmark. The first comparison changes both source access and instructions, so it cannot isolate the protocol's effect. The second comparison explores the added value of an authored map in this particular setting.

Published responses include normalization of symbol names. They are not complete unmodified execution traces. The repository does not provide a fully reproducible benchmark with pinned model and source versions, repeated trials, independent judging, or measured time savings. Treat the scores as historical observations and try the workflow on your own codebase.

## What motivated the product

One task asked whether collection and table operation logic should be shared. The response without the map recommended sharing. The response with the map cited a documented distinction between collection and table storage semantics and argued against that change. The example illustrates the value of recording rationale that is hard to recover from structure alone.

A separate demonstration deliberately planted a stale validation-order claim. The agent was asked to read the relevant resolver, compare the claim with its implementation, and report the mismatch. The desired behavior is an evidence-backed correction when the map and code disagree.

## Try a small evaluation in your own repo

Pick three real questions: one execution path, one upcoming change, and one known gotcha. Record the agent and model, source commit, prompts, source reads, and complete responses. Have a teammate score correctness without knowing which setup produced each answer. Report failures as well as successes, and keep source access equal when measuring the protocol itself.
