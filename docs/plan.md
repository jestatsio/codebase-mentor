# Bob Challenge 2026 — Implementation Plan

> **Historical document.** This was the build plan for the original IBM Bob Challenge 2026
> submission, kept for provenance. It is not a live roadmap — some paths it references
> (e.g. `data-api/ONBOARDING.md`, now at `onboarding/stargate-jsonapi/ONBOARDING.md`) have
> moved, and its checkboxes were never the tracking mechanism. For current state, see the
> [changelog](../CHANGELOG.md).

## Overview

Build a reusable Bob skill called the **Source-Grounded Codebase Mentor** and demonstrate it on the Stargate Data API. The submission consists of five deliverables, all living in this repo:

1. `skills/codebase-mentor/SKILL.md` — the installable Bob skill
2. `template/ONBOARDING.md` + `template/AUTHORING_GUIDE.md` — the per-team authoring kit
3. `data-api/ONBOARDING.md` — reference implementation for the Stargate Data API
4. Freshness check mode — built into the skill itself
5. `evaluation/SCORECARD.md` — three-arm evaluation results (run in Week 2–3)

The approach: author the skill and template first (they are independent of any specific codebase), then author the Data API reference ONBOARDING.md from live source, then run the evaluation, then record the demo.

---

## Sub-Task 1 — Skill Authoring (`skills/codebase-mentor/SKILL.md`)

**Status:** `[x] done`

### Intent
Write the Bob skill file that any IBM team installs once. It contains the reasoning strategy Bob follows when the skill is active: how to locate an ONBOARDING.md, how to trace a request path through live source, how to produce evidence-cited answers, how to perform reactive reconciliation (check one claim on demand), and how to perform the proactive freshness scan (compare the whole ONBOARDING.md against current source structure). The skill must also define the accuracy contract: every architecture or change-guidance claim backed by a symbol or file read in that session, or Bob says evidence is missing.

### Expected Outcomes
- `skills/codebase-mentor/SKILL.md` exists and is complete
- The skill has a clear frontmatter section (name, description, trigger conditions)
- The skill describes four operating modes: **mentor** (answer architecture questions), **change-guide** (produce ordered checklists for a task), **reconcile** (check one claim against source), **scan** (proactive freshness check across the whole doc)
- The accuracy contract is stated in the skill instructions, not just in the proposal
- The skill explains symbol-anchored citation format (method names, class names — not line numbers)

### Todo List
- [ ] Create `skill/` directory
- [ ] Write skill frontmatter: name, description, when to activate
- [ ] Write the **mentor** mode instructions: read ONBOARDING.md, locate relevant source, answer with symbol citations
- [ ] Write the **change-guide** mode instructions: find the nearest existing example in source, produce an ordered checklist of files/methods to touch
- [ ] Write the **reconcile** mode instructions: when a dev asks "is X true?", read the relevant source and compare against the doc's claim
- [ ] Write the **scan** mode instructions: walk every structural claim in ONBOARDING.md, verify each against current source, report divergences
- [ ] Write the accuracy contract section
- [ ] Write the "evidence missing" response protocol

### Relevant Context
- Proposal section: "What Gets Built — Bob skill"
- Proposal accuracy contract: "Every architecture or change-guidance claim must be supported by a symbol or file read in that session"
- The skill is modeled on the Bob skill format at `~/.agents/skills/`

---

## Sub-Task 2 — Template and Authoring Guide

**Status:** `[x] done`

### Intent
Write the `ONBOARDING.md` template and a companion authoring guide that any IBM team can use to produce their own ONBOARDING.md in 2–4 hours. The template uses symbol anchors (method names, class names) not line numbers, so it resists drift with routine edits. The authoring guide explains each section and gives examples drawn from the Data API.

### Expected Outcomes
- `template/ONBOARDING.md` exists with clearly labeled fill-in-the-blanks sections
- `template/AUTHORING_GUIDE.md` exists explaining each section with examples
- Template sections include: codebase purpose, layer map, request lifecycle, domain vocabulary, common change recipes, high-signal files per question type, known gotchas
- Template explicitly instructs authors to use symbol anchors, not line numbers
- Authoring guide includes the break-even framing (30–60 min interrupt × 3–5 events vs. 2–4 hr authoring cost)

### Todo List
- [ ] Create `template/` directory
- [ ] Write `template/ONBOARDING.md` with the seven standard sections, each marked as fill-in
- [ ] Write `template/AUTHORING_GUIDE.md` explaining each section, with a worked example per section drawn from the Data API
- [ ] Add a "known gotchas" section guidance: invariants and negative-space rules not visible in source
- [ ] Add a "named owner and cadence" block at the top of the template
- [ ] Verify the template is self-contained: a team with no prior context should be able to complete it

### Relevant Context
- Proposal section: "What Gets Built — ONBOARDING.md template"
- Symbol-anchor requirement: confirmed in accuracy contract and reviewer feedback
- The Data API examples to draw from: resolver naming convention, shredding vocabulary, task retry gotchas

---

## Sub-Task 3 — Data API Reference ONBOARDING.md

**Status:** `[x] done`

### Intent
Author the reference ONBOARDING.md for the Stargate Data API, populated entirely from live source in the `data-api` repo. This is both the demo artifact and the worked example of the template. It must cover the five-layer pipeline, the collection/table split rationale, shredding, the error template system, and the TaskRetryPolicy framework. All references use symbol anchors. A known-wrong stale claim is planted deliberately for the refusal demo clip.

### Expected Outcomes
- `data-api/ONBOARDING.md` exists, fully populated (no fill-in-the-blanks remaining)
- All seven template sections are present
- Every structural claim is anchored to a real class or method name verified against live source
- The planted stale claim is clearly marked with a `<!-- PLANTED_STALE_CLAIM -->` HTML comment so it can be found and confirmed before recording
- A "named owner" block appears at the top
- The document is self-consistent: no references to classes or paths that don't exist in current source

### Todo List
- [ ] Create `data-api/` directory
- [ ] Write the **codebase purpose** section
- [ ] Write the **layer map** section: Command → Resolver → Operation → Task/DBTask → CQL, with the key class name at each layer
- [ ] Write the **request lifecycle** section: trace a `findOne` request end-to-end through the layers, using method and class names
- [ ] Write the **domain vocabulary** section: shredding, resolver, schema object, task, deferred, LWT, vectorize
- [ ] Write the **common change recipes** section: (a) add a new command, (b) add a new sort type, (c) add a new error code — each as an ordered symbol-anchored checklist
- [ ] Write the **high-signal files** section: one entry per common question type pointing to the right class
- [ ] Write the **known gotchas** section: resolver class rename breaks saved flows; collection/table split; task-level vs driver-level retry; shredding is collection-only
- [ ] Plant the stale claim in the request lifecycle section (validation order) and mark with `<!-- PLANTED_STALE_CLAIM -->`
- [ ] Verify every class and method name against live source in the `data-api` repo

### Relevant Context
- Live source root: `io/stargate/sgv2/jsonapi/` (standard Stargate package layout)
- Key files already read: `FindOneCommandResolver.java`, `CommandResolver.java`, `MeteredCommandProcessor.java`, `TaskRetryPolicy.java`, `BaseTask.java`, `CollectionCommandTools.java` (MCP), `DocumentShredder.java` (shredding)
- Verified facts: `sortClause.validate()` is at line 72 of `FindOneCommandResolver`; sort dispatch is inside `resolveCollectionCommand()`; there are 39 concrete `*CommandResolver` implementations; there is no AGENTS.md in the data-api repo
- Planted stale claim: "sort options are validated in `SortClause.validate()` before the resolver runs" — truth is it runs inside `resolveCollectionCommand()` at line 72

---

## Sub-Task 4 — Evaluation Scorecard Setup

**Status:** `[x] done`

### Intent
Create the evaluation scorecard file with the three pre-specified tasks (T1–T3) fully written up, and placeholder rows for judge-selected T4–T5. The scorecard tracks all three arms (generic Bob, Bob+skill+source, Bob+skill+ONBOARDING.md) and is structured to report the arm (2)→(3) delta explicitly. This file is committed now so the structure is visible on GitHub before results are filled in.

### Expected Outcomes
- `evaluation/SCORECARD.md` exists with the full three-arm table structure
- T1–T3 rows are fully specified (question text, judging criteria for file coverage, correctness, usefulness)
- T4–T5 rows are placeholder rows marked "judge-selected after doc freeze"
- A scoring key explains the 1–5 scale and the three criteria
- A results section exists with empty cells, ready to fill after evaluation runs
- The "either outcome is credible" framing is present in the scorecard preamble

### Todo List
- [ ] Create `evaluation/` directory
- [ ] Write the scorecard preamble: three-arm rationale, delta-reporting framing, "either outcome is credible" statement
- [ ] Write the scoring key: 1–5 scale, definitions of file coverage / correctness / usefulness
- [ ] Write T1–T3 rows with full question text and per-criterion judging notes
- [ ] Write T4–T5 placeholder rows
- [ ] Write the results table with empty cells for each arm × task × criterion
- [ ] Add a "how to run" section: instructions for running each arm and recording scores

### Relevant Context
- Proposal section: "Evaluation Plan"
- The three pre-specified tasks: (T1) add a sort type, (T2) why does findOne have 4 paths, (T3) add a new error code
- The held-out tasks test transfer of general orientation, not specific recipes

---

## Sub-Task 5 — README as Live Status Dashboard

**Status:** `[x] done`

### Intent
Replace the minimal README.md with a submission-quality README that serves as both the public face of the repo and a live progress dashboard. It links to the proposal artifact, summarizes the submission, and shows current task status updated after each sub-task completes.

### Expected Outcomes
- `README.md` is fully rewritten with a project summary, links to all deliverables, and a status table
- The status table reflects real completion state (updated after each sub-task)
- The README is readable standalone: a judge who only reads it understands the submission
- The proposal summary in the README matches the final HTML artifact

### Todo List
- [x] Write the project title, one-paragraph pitch, and break-even framing
- [x] Write the "what's in this repo" section with links to each deliverable file
- [x] Write the status table with one row per sub-task, checkboxes updated as work completes
- [x] Add the before/after demo description (three-arm structure, refusal clip)
- [x] Add a "how to install the skill" quick-start section for IBM teams who want to adopt it
- [x] Add a "evaluation" section summarizing the plan and linking to the scorecard

---

## Deliverable Map

| File | Sub-Task | Status |
|---|---|---|
| `skills/codebase-mentor/SKILL.md` | 1 | `[x] done` |
| `template/ONBOARDING.md` | 2 | `[x] done` |
| `template/AUTHORING_GUIDE.md` | 2 | `[x] done` |
| `data-api/ONBOARDING.md` | 3 | `[x] done` |
| `evaluation/SCORECARD.md` | 4 | `[x] done` |
| `README.md` | 5 | `[x] done` |
