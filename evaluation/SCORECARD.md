# Evaluation Scorecard — Source-Grounded Codebase Mentor

> **Scope:** historical Stargate Data API case study · **Evaluation window:** Week 2–3 of challenge period · **Status:** author-scored, not independently reproduced

---

## Preamble

### Three-Arm Structure

The evaluation runs every task question under three conditions:

| Arm | Condition |
|-----|-----------|
| **Arm 1** | Generic Bob — skill not active, no source, no ONBOARDING.md |
| **Arm 2** | Bob + codebase-mentor skill active + live source readable, **no** ONBOARDING.md provided |
| **Arm 3** | Bob + codebase-mentor skill active + live source readable + `data-api/ONBOARDING.md` in scope |

The conditions support two different comparisons:

- **Arm 1 → Arm 2** changes both source access and the skill. It does not isolate the skill's contribution. A source-capable agent without the skill would be needed for that comparison.
- **Arm 2 → Arm 3** adds the ONBOARDING.md map while retaining the skill and source access. This is the intended comparison, with the limitations below.

The arm (2) → arm (3) delta was the **primary claim under test**. The recorded author scores are preserved for historical context, not presented as a general performance estimate.

### Either Outcome Is Credible

If arm (2) ≈ arm (3) — the ONBOARDING.md produces little or no score lift — that is a valid and publishable result. In that case, the doc's value shifts to rationale and gotchas: non-obvious design decisions, cross-cutting invariants, and negative-space rules (things Bob cannot infer from structure alone). The submission will say so explicitly.

This was the intended evaluation framing. The limitations of the recorded run prevent a causal or general effectiveness claim from these scores alone.

### Success Criteria

Success is defined as:

1. **Positive delta:** arm (3) average score > arm (2) average score on correctness + usefulness across T1–T5.
2. **Absolute threshold:** arm (3) average ≥ 4.0 / 5.0 across all tasks.

Both numbers are reported. The delta is the headline claim; the absolute score is the secondary check that arm (3) is genuinely useful, not merely better than a weak baseline.

> **Provenance note:** scores were assigned by the submission author, not independent judges. The published response excerpts include symbol-name corrections disclosed in the Arm 2 and Arm 3 capture notes. They are not verbatim transcripts or complete tool traces. The response text and historical scores are preserved below. The "How to Run" section describes an independent-judging protocol that has not yet been executed with external judges.

### Limits of the record

- Five tasks on one codebase do not establish effectiveness across projects, agents, or models. No repeated trials or uncertainty estimates are recorded.
- The record does not pin the model version, source commit, full prompts, complete tool reads, or per-run timing. A reader can critique the excerpts and rubric, but cannot reproduce the original sessions from this file alone or verify that the evidence protocol was followed.
- Symbol-name normalization changes material that the file-coverage criterion scores. Preserve original transcripts in any future evaluation and score those separately from edited presentation copies.
- The T5 rubric and scores were revised after the run. Other scoring judgments also merit review: the T3 notes treat source-edit order as mandatory without demonstrating it, and the T1 Arm 3 note claims table-path coverage absent from the published excerpt. These scores have not been retroactively recomputed.
- The original positive-delta criterion names correctness and usefulness, while the reported table averages all three criteria. The table is retained with its stated calculation rather than represented as a preregistered analysis.
- Timing and authoring-effort observations were informal. No measured speedup or universal authoring-time estimate is supported by this record.

---

## Scoring Key

### Scale (1–5)

| Score | Meaning |
|-------|---------|
| **1** | No useful signal. Answer is wrong, irrelevant, or entirely generic. |
| **2** | Partial signal. Some correct elements but missing key facts; a developer could not act on this. |
| **3** | Adequate. Correct overall but lacks specificity; a mid-level developer could proceed with effort. |
| **4** | Good. Correct and specific; a junior developer could act on this with minimal follow-up. |
| **5** | Excellent. Correct, specific, and complete; a junior developer could execute without asking anyone. |

### Three Criteria per Task

Each task is scored on three independent criteria. The **overall task score** is the arithmetic mean of the three.

#### File Coverage
> Did Bob cite the right source artifacts — the specific classes and methods that matter for this task?

Scores 1–2: no citations, or citations to generic/wrong files.  
Scores 3: citations to the right layer but not the specific entry points.  
Scores 4–5: the critical classes and methods are named explicitly.

#### Correctness
> Was the answer factually accurate? Did checklists reflect the actual code path? Did explanations match source behaviour?

Scores 1–2: factually wrong or directly contradicted by source.  
Scores 3: correct in intent but missing a required step or conflating concepts.  
Scores 4–5: all steps correct, collection/table distinctions preserved where relevant, no false claims.

#### Usefulness
> Could a junior developer act on this answer without further help?

Scores 1–2: too vague or too wrong to act on.  
Scores 3: actionable only for someone who already knows the codebase.  
Scores 4–5: self-contained enough for a developer new to this codebase to execute.

---

## Tasks

---

### T1 — Add a New Sort Type

**Question:**
> "I need to add a new sort type to the Data API. Where do I start?"

#### Per-Criterion Judging Notes

**File Coverage**  
Award 4–5 if Bob explicitly cites:
- `SortClauseUtil` (detection / validation of sort type)
- A `*CqlClause` class for tables (e.g. `TableOrderByANNCqlClause` or a sibling clause class)
- `FindCollectionOperation` (sort dispatch on the collection path)
- `FindOneCommandResolver` (entry point where sort options are resolved)

Award 3 if Bob reaches the right layer (sort clause, operation layer) but names only one or two of the above.  
Award 1–2 if Bob cites generic API framework files or no files at all.

**Correctness**  
Award 4–5 if the answer produces an ordered checklist covering all three required steps:
1. Detect/validate the new sort type in `SortClauseUtil`
2. Create (or extend) the appropriate `*CqlClause` class for the table path
3. Mirror the dispatch case in `FindCollectionOperation` for the collection path

Also award full marks if the answer correctly explains the **collection/table split**: collection sorts run through in-memory or index-backed dispatch in `FindCollectionOperation`; table sorts produce CQL `ORDER BY` clauses via the `*CqlClause` hierarchy.

Award 3 if the checklist is present but missing the collection/table distinction or one step.  
Award 1–2 if the answer omits the checklist or gets the split wrong.

**Usefulness**  
Award 4–5 if a junior developer reading the answer could open the correct files, understand what to add, and follow the steps without a senior-engineer walkthrough.  
Award 3 if the answer requires the developer to already know roughly where sort handling lives.  
Award 1–2 if the answer is too abstract to act on.

---

### T2 — Why Does findOne Have Four Code Paths?

**Question:**
> "Why does findOne have four different code paths in the collection resolver?"

#### Per-Criterion Judging Notes

**File Coverage**  
Award 4–5 if Bob explicitly cites:
- `FindOneCommandResolver.resolveCollectionCommand()` (the method that dispatches the four paths)
- `FindCollectionOperation` and at least two of its four internal path identifiers: `vsearchSingle`, `bm25Single`, `sortedSingle`, `unsortedSingle`

Award 3 if Bob reaches `FindOneCommandResolver` but does not name `resolveCollectionCommand()` or does not name the four path variants.  
Award 1–2 if Bob does not reach the resolver or operation layer.

**Correctness**  
Award 4–5 if the answer correctly identifies all four paths and explains *why* each exists:
- **vsearch** — vector ANN index is present; uses approximate nearest-neighbour search
- **BM25** — BM25 text index is present; uses full-text search
- **sorted** — no vector/BM25 index but a sort clause is present; requires in-memory sort
- **unsorted** — simple read, no sort or index needed; most efficient path

The explanation must connect each path to the underlying Cassandra capability (or its absence) that forced the split, not just enumerate the names.

Award 3 if the answer names the paths but does not explain the Cassandra capability rationale.  
Award 1–2 if the answer is wrong about the number of paths or conflates the split reasons.

**Usefulness**  
Award 4–5 if the answer explains the *design intent* — why Cassandra's index model forces this branching — such that a developer understands when to add a fifth path vs. modify an existing one.  
Award 3 if the answer enumerates the paths without design-intent explanation.  
Award 1–2 if the answer would leave a developer confused about when the split applies.

---

### T3 — Add a New Error Code

**Question:**
> "How do I add a new error code to the Data API?"

#### Per-Criterion Judging Notes

**File Coverage**  
Award 4–5 if Bob explicitly cites:
- The `exception/` package directory (or a concrete exception class from it, e.g. `JsonApiException`)
- A `*Exception.Code` enum (e.g. `JsonApiException.Code`) as the place to add the new constant
- The YAML resources directory where error message templates live (e.g. `src/main/resources/` or the `errors/` subdirectory within it)

Award 3 if Bob mentions exceptions generically or finds one of the three artifacts without the others.  
Award 1–2 if Bob suggests adding error handling in a command handler or resolver without reaching the error-code infrastructure.

**Correctness**  
Award 4–5 if the answer produces the **three-step pattern** in order:
1. Add a new constant to the relevant `*Exception.Code` enum
2. Add a matching YAML error-message template (with the correct key format) in the resources directory
3. Throw the error using the `ErrorCode.get(errVars(...))` pattern at the call site

Award 3 if two of the three steps are present and correctly ordered but one is missing or wrong.  
Award 1–2 if the answer suggests a different pattern (e.g. constructing the exception directly without the enum/YAML pair) that contradicts the actual infrastructure.

**Usefulness**  
Award 4–5 if the answer includes enough detail — enum class name, YAML key format, throw-site example — that a developer can execute all three steps without asking a senior engineer.  
Award 3 if the answer is correct in intent but requires the developer to discover the YAML format or enum location independently.  
Award 1–2 if the answer is too abstract to execute.

---

### T4 — Design Intent / Cross-Cutting Invariant

**Question:**
> "I want to share some logic between a collection operation and a table operation to avoid duplication. Is that a good idea?"

**What this task tests:**
T4 probes whether Bob can surface the *why* behind a cross-cutting architectural rule — not just that the two packages are separate (findable from source) but the specific reason (shredded-column schema vs CQL columns) and the concrete failure mode (`ClassCastException` from passing the wrong `SchemaObject`). The ONBOARDING.md gotcha section contains this explicitly; source alone requires reading multiple files and inferring the design intent.

#### Per-Criterion Judging Notes

**File Coverage**
Award 4–5 if Bob cites:
- The two separate packages: `service/operation/collections/` and `service/operation/tables/`
- `CollectionSchemaObject` and `TableSchemaObject` as the incompatible types that make sharing dangerous
- `DocumentShredder` or the shredded column names (`doc_json`, `exist_keys`, `array_size`) as evidence of why collections can't share table code

Award 3 if Bob identifies the packages are separate but doesn't reach the schema incompatibility.
Award 1–2 if Bob recommends sharing without surfacing the risk.

**Correctness**
Award 4–5 if the answer:
1. States the rule clearly: do not share concrete operation classes across the two paths
2. Explains *why*: collections use a shredded denormalized schema with fixed Cassandra columns; tables map one-to-one to CQL columns — the `SchemaObject` types are incompatible
3. Names the concrete failure mode: a `ClassCastException` when the wrong `SchemaObject` is passed, or silent no-op because shredded columns don't exist in the table

Award 3 if the answer recommends against sharing but only gives a vague "the paths are different" reason.
Award 1–2 if the answer recommends sharing or gets the failure mode wrong.

**Usefulness**
Award 4–5 if a developer reading the answer would know definitively not to share logic and understand exactly what would break if they tried.
Award 3 if the answer discourages sharing but leaves the developer uncertain about what exactly would fail.
Award 1–2 if the answer is inconclusive or wrong.

---

### T5 — Vocabulary / Orientation

**Question:**
> "What's the difference between an Operation and a Task in this codebase? When would I use one vs. the other?"

**What this task tests:**
T5 probes vocabulary disambiguation — a question that requires understanding the design intent behind two similar-sounding concepts. Source shows both classes exist and their structure, but the clean answer (Operation = collection path one-shot unit of work; Task = table path with explicit state machine and retry loop) requires either reading many files or having the domain vocabulary section of the ONBOARDING.md. A developer who gets this wrong will put new code in the wrong layer.

#### Per-Criterion Judging Notes

**File Coverage**
Award 4–5 if Bob cites:
- `FindCollectionOperation` or `InsertCollectionOperation` as the canonical Operation example (collection path)
- `BaseTask` and its state transition enum (`UNINITIALIZED → READY → IN_PROGRESS → COMPLETED/ERROR/SKIPPED`)
- `TaskRetryPolicy` as the retry mechanism attached to Tasks
- The package split: `service/operation/collections/` (Operations) vs. `service/operation/tasks/` (Tasks)

Award 3 if Bob finds both `BaseTask` and an Operation class but doesn't articulate the primary collection/table alignment.
Award 1–2 if Bob conflates the two or gives a purely structural description with no guidance on when to use each.

**Correctness**
Award 4–5 if the answer gives the *primary* alignment (Operations → collection path dominant, Tasks → table path dominant) **and** acknowledges either the migration context (`TaskOperation`) or that Tasks also appear in some collection paths (e.g. `IntermediateCollectionReadTask` for reranking). Penalize answers that state "Tasks are table-only" as a hard rule.

Award 3 if the answer gives the primary alignment correctly but misses the state machine, retry dimension, or migration caveat.
Award 1–2 if the answer treats them as interchangeable or describes only structural differences without guidance.

**Usefulness**
Award 4–5 if a developer new to the codebase would know which abstraction to reach for when adding new behavior, and would not be surprised to encounter Tasks in collection code.
Award 3 if the answer gives a correct but incomplete picture that would require follow-up.
Award 1–2 if the answer would leave a developer unsure which to use.

---

## Published Response Excerpts

Historical response excerpts, including the normalization disclosed below. These are available for inspection, but they cannot replace the original transcripts and tool traces for independent judging.

---

### Arm 1 Response Excerpts (Generic Bob — no skill, no source, no ONBOARDING.md)

> Captured: initial evaluation run. Answers reflect pre-training knowledge only — no source reads performed.

**T1-A1:** *"I need to add a new sort type to the Data API. Where do I start?"*

> Look for sort-related classes in the query or filter layer. You'll likely want to add an enum value or a new sort clause class, update the parser to recognize the new sort keyword, and then handle it in whatever operation executes the query. Check existing sort types to understand the pattern.

**T2-A1:** *"Why does findOne have four different code paths in the collection resolver?"*

> Probably to handle different index types or query strategies — for example, a vector similarity search takes a different path than a regular field filter, which takes a different path than a sorted scan. The branches likely reflect what Cassandra can do natively vs. what has to be handled in application memory.

**T3-A1:** *"How do I add a new error code to the Data API?"*

> Find where existing error codes are defined — probably an enum or constants class. Add your new code there. Then find where errors are constructed and returned, and add a case for your new code. Make sure any error message strings are in the right place, possibly a messages file or resource bundle.


**T4-A1:** *"I want to share some logic between a collection operation and a table operation to avoid code duplication. Is that a good idea?"*

> Yes, sharing logic can be a good idea. Look for a common abstraction or base class that both collection and table operations extend. Extract the shared logic into that base class or a utility class. Be mindful of type differences between the two contexts, but in general DRY principles apply here and shared logic reduces maintenance burden.

**T5-A1:** *"What's the difference between an Operation and a Task in this codebase? When would I use one vs. the other?"*

> An Operation typically represents a high-level request-handling unit — the thing that processes an incoming API command and produces a result. A Task is usually a smaller, lower-level unit of work, possibly one of several steps within an Operation. You'd use an Operation when implementing a new command, and a Task when you need to break the work into discrete, possibly retriable steps. Check any base classes or interfaces for both to understand the contract.


---

### Arm 2 Response Excerpts (Bob + skill + live source, no ONBOARDING.md)

> Captured: live session with `skills/codebase-mentor/SKILL.md` active, workspace = `data-api` source root. No `ONBOARDING.md` provided. *Outputs lightly normalized for symbol-name accuracy (state-machine names corrected to match source); content and scores unchanged.*

**T1-A2:** *"I need to add a new sort type to the Data API. Where do I start?"*

> Key files to modify: (1) `SortExpression.java` — add new field, factory method, `isYourSort()` helper; (2) `CollectionSortClauseBuilder.java` — update `buildClauseFromDefinition()` to detect and parse new sort syntax; (3) `TableSortClauseBuilder.java` — update `buildClauseFromDefinition()` and add new build method; (4) `TableCqlSortClauseResolver.java` (CQL-based) or `TableMemorySortClauseResolver.java` (in-memory) — add new resolution branch; (5) `SortClause.java` — update `validate()` if needed.
>
> Existing sort types to copy from: vector (`$vector`), vectorize (`$vectorize`), lexical (`$lexical`), regular (field + direction). Typical flow: JSON → Builder parses → `SortExpression` → `SortClause` → Resolver → CQL or in-memory operation.

**T2-A2:** *"Why does findOne have four different code paths in the collection resolver?"*

> In `FindOneCommandResolver.resolveCollectionCommand`: (1) Vector search path (lines 95–102) — triggered when `vector != null`, uses `FindCollectionOperation.vsearchSingle()`, performs ANN similarity search; (2) BM25 search path (lines 105–112) — triggered when `bm25Expr != null`, uses `FindCollectionOperation.bm25Single()`, performs full-text search; (3) Sorted path (lines 114–128) — triggered when `orderBy != null`, uses `FindCollectionOperation.sortedSingle()`, retrieves and sorts in-memory; (4) Unsorted path (lines 129–135) — no sorting, uses `FindCollectionOperation.unsortedSingle()`, simplest retrieval.
>
> Each path is optimized for its specific use case with different performance characteristics. Vector and BM25 use specialized indexes; sorted path does in-memory sorting with pagination; unsorted is the most straightforward retrieval.

**T3-A2:** *"How do I add a new error code to the Data API?"*

> (1) Edit `src/main/resources/errors.yaml` — choose REQUEST error (4xx) or SERVER error (5xx), define with `scope`, `code` (UPPER_SNAKE_CASE), optional `http-status-override`, required `title` and `body` (can use `${vars}` and `${SNIPPET.NAME}`). (2) Create or update the corresponding Java exception class in `src/main/java/io/stargate/sgv2/jsonapi/exception/` — the exception class reads from `errors.yaml` to populate error details. Keep entries sorted alphabetically by scope, then code.

**T4-A2:** *"I want to share some logic between a collection operation and a table operation to avoid duplication. Is that a good idea?"*

> Yes, sharing logic can be a good idea, but with important considerations. The codebase already has a foundation: both `CollectionOperation` and `TableOperation` extend the base `Operation<SchemaT>` interface; the generic `SchemaT` parameter allows type-safe sharing. Good candidates for sharing: common validation logic, shared utility methods, generic algorithms, exception handling patterns (`exceptionHandlerFactory()`), metrics/logging. Avoid sharing: schema-specific operations (collections use documents, tables use rows), type-specific business logic, operations requiring complex conditionals or type checking. Recommended: use the base `Operation` interface for generic logic, create utility classes for shared algorithms, prefer composition over inheritance. Note: `TableOperation.java` indicates migration to `OperationAttempt` pattern is planned — verify before adding shared logic.

**T5-A2:** *"What's the difference between an Operation and a Task in this codebase? When would I use one vs. the other?"*

> **Operation** is the high-level interface representing a complete database operation (`Operation<SchemaT>`). Takes a `CommandContext`, returns `Uni<Supplier<CommandResult>>`. Represents entire user-facing command execution. Types: `GenericOperation` (legacy, being phased out), `TaskOperation` (modern).
>
> **Task** is a lower-level unit of work within an Operation: implements `Task<SchemaT>`, represents a single atomic piece of work (one CQL statement), has lifecycle states `UNINITIALIZED → READY → IN_PROGRESS → COMPLETED/ERROR/SKIPPED`, can be retried via `TaskRetryPolicy`, grouped into `TaskGroup`. Results aggregated by `TaskAccumulator`.
>
> Use Operation when implementing a new command handler or defining overall execution flow. Use Task when implementing actual database interaction, needing fine-grained CQL control, or wanting retry logic. Architecture: Command → `TaskOperation` → `TaskGroup` → [Task, Task, Task] → CQL. Note: codebase is transitioning from `OperationAttempt` (legacy) to Task (modern).

---

### Arm 3 Response Excerpts (Bob + skill + ONBOARDING.md)

> Captured: live session with `skills/codebase-mentor/SKILL.md` active, workspace = `bob-challenge-2026`, `data-api/ONBOARDING.md` in scope, `data-api` source accessible. *Outputs lightly normalized for symbol-name accuracy; content and scores unchanged.*

**T1-A3:** *"I need to add a new sort type to the Data API. Where do I start?"*

> Following Recipe B from ONBOARDING.md: (1) Add a new `SortExpression` sub-type or extend `SortClauseUtil` with a new resolution method, following the pattern of `resolveVsearch()` and `resolveBM25Search()`; (2) Add a new branch in `FindOneCommandResolver.resolveCollectionCommand()` and in `FindCommandResolver.resolveCollectionCommand()` if the sort applies to multi-document find; (3) Add a factory method on `FindCollectionOperation` following the pattern of `vsearchSingle()`, `bm25Single()`, `sortedSingle()`; (4) Update `SortClause.validate()` to accept or reject the new sort expression; (5) Update `MeteredCommandProcessor.getVectorTypeTag()` to emit the correct `JsonApiMetricsConfig.SortType` tag for the new sort path.
>
> Key files: sort dispatch in `FindOneCommandResolver.resolveCollectionCommand()` and `FindCommandResolver`; validation in `SortClause.validate()` (called inside `resolveCollectionCommand`); operation execution in `FindCollectionOperation` factory methods.

**T2-A3:** *"Why does findOne have four different code paths in the collection resolver?"*

> In `FindOneCommandResolver.resolveCollectionCommand()`: (1) Vector search path — triggered when `vector != null`, uses `FindCollectionOperation.vsearchSingle()`, ANN similarity search; (2) BM25 search path — triggered when `bm25Expr != null`, uses `FindCollectionOperation.bm25Single()`, full-text search; (3) Sorted path — triggered when `orderBy != null`, uses `FindCollectionOperation.sortedSingle()`, retrieves and sorts in-memory; (4) Unsorted path — no special conditions, uses `FindCollectionOperation.unsortedSingle()`, simplest retrieval. Each path leverages different Cassandra capabilities (vector search, full-text indexing, in-memory sorting, or simple retrieval).

**T3-A3:** *"How do I add a new error code to the Data API?"*

> (1) Add enum constant: add a SNAKE_CASE constant to the appropriate `Code` enum (e.g. `RequestException.Code`, `DocumentException.Code`, `SortException.Code`); (2) Create YAML template: create/update the YAML error-template file in the resources directory following the `family/scope/CODE_NAME` naming convention, include HTTP status override if needed; (3) Throw the error: use `ErrorCode.get(errVars(...))` at the call site (e.g. `RequestException.Code.UNSUPPORTED_COLLECTION_COMMAND.get(...)`).
>
> Critical: every enum constant MUST have a corresponding YAML file. Missing YAML causes an `ExceptionInInitializerError` at first use (not startup), resulting in a 500 with no useful error body.

**T4-A3:** *"I want to share some logic between a collection operation and a table operation to avoid duplication. Is that a good idea?"*

> No, sharing logic between collection and table operations is NOT recommended. From ONBOARDING.md Section 7 (Known Gotchas): "Do not add collection logic to `service/operation/tables/` or vice versa." The two paths share no concrete operation classes. Technical reasons: (1) Collections use a shredded, denormalized storage schema with fixed Cassandra columns; tables map one-to-one to CQL columns — sharing would require constant null-checks and type-switching, making both paths fragile. (2) Silent failures: collection-specific behavior placed in table operations will silently have no effect, or throw `ClassCastException` when the wrong `SchemaObject` type is passed.
>
> Concrete example: if `DocumentShredder.shred()` (collection-only) is accidentally invoked for a table write, it builds without error but the CQL INSERT targets non-existent columns, causing a confusing schema mismatch. Recommendation: keep operations separate; extract shared utility logic into a utility class both paths call independently.

**T5-A3:** *"What's the difference between an Operation and a Task in this codebase? When would I use one vs. the other?"*

> **Operation** — a one-shot, executable unit of work that builds and dispatches CQL statements and returns a `CommandResult`. The dominant abstraction for collection operations (document-model). Location: `service/operation/collections/`. Examples: `FindCollectionOperation`, `InsertCollectionOperation`. Simpler execution model, direct CQL building and execution.
>
> **Task / DBTask** — the primary abstraction for table operations, with built-in state management and retry. Base class: `BaseTask`. Location: `service/operation/tasks/`. State transitions: `UNINITIALIZED → READY → IN_PROGRESS → COMPLETED/ERROR/SKIPPED`. Built-in retry loops via `TaskRetryPolicy`. Note: Tasks also appear in some collection paths (e.g. reranking via `IntermediateCollectionReadTask`); codebase is mid-migration to `TaskOperation`-based execution.
>
> Use Operation when working with collection-based (document-model) operations or adding collection behavior. Use Task when working with table-based operations, needing state tracking and retry logic, or implementing table-path functionality. Key gotcha: do not mix collection logic into `service/operation/tables/` or vice versa — they use fundamentally different storage schemas.

---

## Results Table

> Historical author scores for all three arms. Independent judging and a reproducible rerun remain outstanding.

Scoring: each cell is a score from 1–5 on that criterion. Task average = mean of three criteria. Arm average = mean of T1–T5 task averages.

| Task | Arm 1 (File) | Arm 1 (Correct) | Arm 1 (Useful) | Arm 1 Avg | Arm 2 (File) | Arm 2 (Correct) | Arm 2 (Useful) | Arm 2 Avg | Arm 3 (File) | Arm 3 (Correct) | Arm 3 (Useful) | Arm 3 Avg |
|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| T1 | 1 | 2 | 1 | **1.3** | 5 | 5 | 5 | **5.0** | 5 | 5 | 5 | **5.0** |
| T2 | 1 | 2 | 2 | **1.7** | 4 | 4 | 4 | **4.0** | 4 | 4 | 4 | **4.0** |
| T3 | 1 | 2 | 1 | **1.3** | 4 | 3 | 3 | **3.3** | 5 | 5 | 5 | **5.0** |
| T4 | 1 | 1 | 1 | **1.0** | 2 | 1 | 1 | **1.3** | 5 | 5 | 5 | **5.0** |
| T5 | 1 | 2 | 1 | **1.3** | 4 | 4 | 4 | **4.0** | 4 | 4 | 5 | **4.3** |
| **Arm avg** | | | | **1.3** | | | | **3.5** | | | | **4.7** |
| **Delta (Arm 3 − Arm 2)** | | | | | | | | | | | | **+1.2** |

> **Delta** = Arm 3 average − Arm 2 average. This is the primary claim under test.
> Target: delta > 0 AND Arm 3 avg ≥ 4.0 / 5.0.
> **Recorded result: delta = +1.2 · Arm 3 avg = 4.7 / 5.0**, using the three-criterion averages above. These are historical author scores subject to the provenance and analysis limitations in the Preamble.
> *Note: T5 scores revised after rubric correction — the original criterion incorrectly penalized the more source-accurate Arm 2 answer and rewarded the oversimplified Arm 3 answer. See T5 scoring notes below.*

### Arm 2 Scoring Notes (T1–T5)

**T1:** File coverage 5 — cites `SortExpression`, `CollectionSortClauseBuilder`, `TableSortClauseBuilder`, `TableCqlSortClauseResolver`, `TableMemorySortClauseResolver`, `SortClause`. Correctness 5 — ordered steps, collection/table split explicit, in-memory vs CQL distinction clear, existing sort types named as examples. Usefulness 5 — actionable for a junior developer.

**T2:** File coverage 4 — cites `FindOneCommandResolver.resolveCollectionCommand` and all four factory methods, but uses line numbers rather than symbol anchors and doesn't name `SortClauseUtil`. Correctness 4 — all four paths identified with correct triggers, but explanation is mechanical ("optimized for its use case") without connecting each to the Cassandra capability that forces the split; missing "when to add a fifth path" guidance. Usefulness 4 — developer understands the paths but lacks design-intent framing for future changes.

**T3:** File coverage 4 — cites `errors.yaml` with full path and `exception/` directory, but inverts the order (YAML first, enum second) and omits `AllErrorCodesLoadTest`. Correctness 3 — both required artifacts present but ordering is wrong (enum constructor calls `ErrorTemplate.load()` at class-init, so enum must exist first); no mention of strict variable substitution or the safety-net test. Usefulness 3 — a developer could produce a working error code but may be confused by the inverted order and miss the CI safety net.

**T4:** File coverage 2 — cites `Operation<SchemaT>` interface and base classes, but misses `CollectionSchemaObject`/`TableSchemaObject` incompatibility and `DocumentShredder`/shredded column names entirely. Correctness 1 — **actively recommends sharing**, directly contradicting the architectural rule. Never surfaces the shredded-column failure mode, the `ClassCastException` risk, or the explicit prohibition. Usefulness 1 — a developer following this advice would create exactly the bug the ONBOARDING.md's gotcha section exists to prevent.

**T5:** File coverage 4 — cites `BaseTask`, state transitions, `TaskRetryPolicy`, `TaskOperation`, `TaskGroup`. Correctness 4 *(revised from 3)* — "Task is a lower-level unit within any Operation" is actually more source-accurate than "Task = table path only": `IntermediateCollectionReadTask extends BaseTask<CollectionSchemaObject>` exists in `service/operation/reranking/`, and `TaskOperation implements Operation<SchemaT>` confirms Tasks wrap inside Operations. The original rubric penalized this correct framing. The vague "when to use each" guidance is the real weakness. Usefulness 4 *(revised from 3)* — a developer familiar with the source would not be misled; the framing is imprecise rather than wrong.

### Arm 3 Scoring Notes (T1–T5)

**T1:** File coverage 5 — cites `SortClauseUtil`, `FindOneCommandResolver.resolveCollectionCommand()`, `FindCommandResolver`, `FindCollectionOperation` factory methods (`vsearchSingle`, `bm25Single`, `sortedSingle`), and `SortClause.validate()`. Explicitly follows Recipe B from ONBOARDING.md, naming `MeteredCommandProcessor.getVectorTypeTag()` as a metrics step not present in Arm 2. Correctness 5 — ordered five-step checklist, both collection and table paths covered. Usefulness 5 — junior developer could execute without a walkthrough.

**T2:** File coverage 4 — cites `FindOneCommandResolver.resolveCollectionCommand()` and all four `FindCollectionOperation` factory methods. Same quality as Arm 2 on this task — T2 was already well-served by live source, and the ONBOARDING.md does not add substantially new material here. Correctness 4 — all four paths with correct triggers; still lacks explicit Cassandra-capability framing ("in-memory sort with pagination" but no "why Cassandra cannot do this natively"). Usefulness 4 — same as Arm 2.

**T3:** File coverage 5 — cites specific enum class names (`RequestException.Code`, `DocumentException.Code`, `SortException.Code`), resources directory with `family/scope/CODE_NAME` convention, and throw-site pattern. Correctness 5 — correct three-step order (enum first, YAML second, throw-site third), plus the critical failure mode: missing YAML causes `ExceptionInInitializerError` at first use, not startup. Usefulness 5 — includes enough specificity (key format, throw pattern, failure mode) to execute without follow-up.

**T4:** File coverage 5 — cites both operation packages (`service/operation/collections/`, `service/operation/tables/`), `CollectionSchemaObject`/`TableSchemaObject` incompatibility, shredded column schema, and `DocumentShredder.shred()` as a concrete counter-example. Correctness 5 — clear "NO" recommendation with both failure modes stated (silent no-op/wrong CQL, `ClassCastException`), exactly per ONBOARDING.md Section 7. This is the sharpest Arm 2 → Arm 3 contrast: Arm 2 actively recommended sharing (score 1); Arm 3 correctly refused with the precise technical rationale (score 5). Usefulness 5 — developer would immediately know not to proceed and understand exactly what would break.

**T5:** File coverage 4 — cites `FindCollectionOperation`, `InsertCollectionOperation` as canonical Operation examples, `BaseTask` with state-transition enum (`UNINITIALIZED → READY → IN_PROGRESS → COMPLETED/ERROR/SKIPPED`), `TaskRetryPolicy`, and the package split. Correctness 4 *(revised from 5)* — cleanly aligns Operations with the collection path and Tasks with the table path, includes retry and state-machine dimensions; however, the "Tasks = table-path" framing is an oversimplification contradicted by `IntermediateCollectionReadTask` and the mid-migration `TaskOperation` pattern. The doc's own vocabulary entry has now been corrected to reflect this nuance. Usefulness 5 — a developer adding new collection or table behavior would still land in the right place following this guidance.

**Informal speed observation:** the author perceived Arm 3 sessions as faster on T3–T5. No timings or complete tool-read counts were recorded, so this is an anecdote, not a measured speedup. A map may narrow the search, but the protocol still requires reading the source behind behavioral claims.

---

### Arm 1 Scoring Notes (T1–T5)

**T1:** File coverage 1 — no class or method names cited; "sort clause class" and "query layer" are generic. Correctness 2 — correctly identifies that a new class and parser change are needed, but misses the collection/table split entirely. Usefulness 1 — not actionable without already knowing the codebase.

**T2:** File coverage 1 — no class names. Correctness 2 — correctly identifies that different index types drive the split and notes the in-memory sort case, but does not name the four paths or connect them to specific Cassandra capabilities. Usefulness 2 — a mid-level developer could confirm this is the right area but couldn't act without more.

**T3:** File coverage 1 — "enum or constants class" and "messages file" are generic; no specific class named. Correctness 2 — identifies the enum + message pattern but misses the YAML template infrastructure entirely. Usefulness 1 — cannot execute without discovering the YAML format independently.

**T4:** File coverage 1 — no class names cited; no mention of `CollectionSchemaObject`/`TableSchemaObject` incompatibility, `DocumentShredder`, or the shredded column schema. Correctness 1 — **actively recommends sharing**, citing DRY principles without any awareness of the architectural constraint. This is the worst possible answer. Usefulness 1 — a developer following this advice would create the exact failure mode the ONBOARDING.md gotcha exists to prevent.

**T5:** File coverage 1 — "base class or interfaces for both" is generic; no class names. Correctness 2 — correctly intuits that Operations are higher-level and Tasks are lower-level steps, but provides no collection/table alignment, no state machine, no retry dimension. Usefulness 1 — a developer could not act on this without already knowing the codebase structure.

---

## How to Run

For a new evaluation, save the exact source commit, model and agent versions, skill version, prompts, configuration, and unedited response/tool transcripts. Use fresh sessions, repeat the tasks, record duration and source reads, and score blind against a frozen rubric. Include a source-capable no-skill condition if evaluating the protocol's contribution. Keep new results separate from the historical table above.

### Prerequisites

- Two senior Stargate Data API engineers available as independent judges
- Bob session access
- The codebase-mentor skill installed (see [`skills/codebase-mentor/SKILL.md`](../skills/codebase-mentor/SKILL.md))
- Local clone of `data-api` repo (or equivalent source access from within the session)
- `data-api/ONBOARDING.md` committed and frozen before T4/T5 questions are selected

### Running Arm 1 — Generic Bob (no skill, no doc)

1. Open a **fresh** Bob session with no skill active. Confirm the codebase-mentor skill is not loaded.
2. To reproduce the historical Arm 1 condition, provide neither source access nor `data-api/ONBOARDING.md` nor a codebase summary. Label this condition explicitly as a no-source baseline.
3. Ask the task question verbatim (do not rephrase).
4. Record the full response.
5. Score independently on all three criteria using the judging notes above.
6. Enter scores in the Arm 1 columns of the results table.

### Running Arm 2 — Bob + Skill + Live Source (no ONBOARDING.md)

1. Open a **fresh** Bob session.
2. Activate the codebase-mentor skill (copy `skills/codebase-mentor/SKILL.md` to your skills directory if not already installed).
3. **Do not** provide `data-api/ONBOARDING.md` or mention that it exists.
4. Ensure Bob has access to the `data-api` source (local repo path or equivalent).
5. Ask the task question verbatim.
6. Record the full response including any source reads Bob performs.
7. Score independently on all three criteria.
8. Enter scores in the Arm 2 columns of the results table.

### Running Arm 3 — Bob + Skill + ONBOARDING.md

1. Open a **fresh** Bob session.
2. Activate the codebase-mentor skill.
3. Ensure `data-api/ONBOARDING.md` is accessible in the session (place it at repo root or point Bob to it explicitly).
4. Ensure Bob has access to the `data-api` source.
5. Ask the task question verbatim.
6. Record the full response including any ONBOARDING.md and source reads Bob performs.
7. Score independently on all three criteria.
8. Enter scores in the Arm 3 columns of the results table.

### Judging Protocol

- **Two judges** score each response independently without seeing the other's scores.
- After both judges complete a task-arm pair, compare scores. If any criterion differs by more than 1 point, discuss and reconcile to a single agreed score before entering it in the table.
- Score all five tasks under one arm before moving to the next arm, to reduce contamination across conditions.
- Do not discuss scores between judges until both have finished a given task-arm pair.

### T4 and T5 Question Selection

1. Both judges read `data-api/ONBOARDING.md` independently after it is committed and frozen.
2. Each judge proposes two candidate questions: one that is **not** covered by a specific change recipe in the doc (T4 candidate), and one that targets a **different layer** of the codebase (T5 candidate).
3. Judges agree on final T4 and T5 questions, then each defines expected file citations, the correct answer, and the minimum bar for usefulness *before* running any arm.
4. Write the agreed questions and judging criteria into this file (replacing the placeholder rows above) before scoring begins.
5. Run T4 and T5 under all three arms using the same protocol as T1–T3.
