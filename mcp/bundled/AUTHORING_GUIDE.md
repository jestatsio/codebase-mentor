# ONBOARDING.md Authoring Guide

This guide walks you through each of the seven sections in `template/ONBOARDING.md`. For every section it explains what to write, how detailed to be, and gives worked examples from two different codebase archetypes:

- **Stargate Data API** — a request/response Java service with 39 concrete command resolvers, a five-layer pipeline, and no prior ONBOARDING.md. *Use this if your codebase handles discrete user requests: REST APIs, gRPC services, command processors.*
- **ibm-data-sync** (illustrative) — a batch ETL pipeline that extracts records from source systems, transforms them through a stage graph, and loads them into a target store on a schedule. *Use this if your codebase runs as a job, pipeline, daemon, or library: ETL, stream processors, ML training, data exporters, shared utility libraries.*

Both examples use symbol anchors and follow the same seven-section structure. Pick whichever is closer to your codebase and adapt from there.

**Time budget:** most teams complete a first draft in 2–4 hours. See the break-even framing below.

---

## Why This Is Worth Your Time

A new engineer's first real architecture question typically costs **30–60 minutes of senior-engineer interrupt time**. On most teams this happens 3–5 times per onboarding. That's 90–300 minutes of senior time per hire — just for orientation, before the new engineer has committed a single line.

Writing this document takes **2–4 hours, once**. That breaks even within one to two new hires. After that it compounds: every subsequent hire, every cross-team contributor, every on-call engineer debugging something unfamiliar at midnight.

The document does not replace the senior engineer. It answers the low-complexity orientation questions ("where does X live?", "what's the word for Y?") so the senior engineer is interrupted only for questions that genuinely need them.

---

## A Critical Rule Before You Start: Symbol Anchors, Not Line Numbers

Throughout `template/ONBOARDING.md` you will see the instruction: **use symbol anchors (class names, method names), not line numbers**.

**Why this matters:** line numbers rot. Every refactor, every added import, every javadoc block shifts every line number in the file. A document that says "see line 72 of `FindOneCommandResolver.java`" is wrong within weeks. A document that says "see `FindOneCommandResolver.resolveCollectionCommand()`" survives any edit that doesn't rename the method — and if the method is renamed, the rename itself is the architectural change worth updating the document for.

**The rule in practice:**
- ✅ `FindOneCommandResolver.resolveCollectionCommand()` branches across four sort paths
- ❌ `FindOneCommandResolver.java`, line 72 branches across four sort paths
- ✅ `SortClauseUtil` is the entry point for sort dispatch detection
- ❌ `service/resolver/query/collection/find/FindOneCommandResolver.java`

You do not need to include file paths. Class names are globally unique in a well-structured codebase and are searchable in any IDE. If a class name is ambiguous, add the package fragment: `sgv2.jsonapi.service.resolver.FindOneCommandResolver`.

---

## Document Owner Block

**What it is:** a named person responsible for this document's accuracy, plus a review cadence.

**Why it matters:** documents without owners drift silently. When an architectural change lands and nobody updates the ONBOARDING.md, the document becomes a trap. A named owner with a scheduled review turns maintenance into a calendar event, not a hope.

**How to fill it in:** name a specific person, not a team. Teams do not review documents; people do. The review cadence should be either time-based ("every 6 months") or event-based ("after any major architectural change") — ideally both. Err toward more frequent than you think necessary; you can always push a review if nothing changed.

**Worked example (Stargate Data API):**

```
Owner: Jane Smith (Data Platform)
Review cadence: every 6 months, or after any major architectural change
Last reviewed: 2025-01
```

---

## Section 1 — Codebase Purpose

**What it is:** one to three sentences describing what this service or library does, who calls it, and what it produces.

**Why it matters:** this is the first thing a new engineer reads. If they misunderstand the codebase's scope at this point, every subsequent section reinforces the wrong mental model.

**How detailed to be:** one good paragraph is enough. Define no jargon here — if you need jargon, it goes in Section 4. Assume the reader has general software engineering knowledge but no prior context on this project.

**Worked example (Stargate Data API):**

> This service accepts JSON API requests from the Stargate coordinator and executes them against an Apache Cassandra cluster, returning JSON responses. It is the sole path for both document-model ("collection") and table-model operations on the cluster. It does not own the cluster or the schema — it translates incoming commands into CQL and hands execution off to the Cassandra driver.

---

## Section 2 — Layer Map

**What it is:** a table of the major architectural layers or stages, in execution order, with a key class or interface name at each layer.

**Why it matters:** without a layer map, a new engineer opens the codebase and sees a flat wall of files. The layer map gives them the first organizing principle: "I'm looking at layer N, which means the contract I need to satisfy is defined by `[ClassName]`."

**How detailed to be:** one row per layer. Name the class or interface that defines that layer's contract. Do not list every class in the layer — just the one that best describes what the layer does. For a pipeline codebase, "outermost first" means "what runs first in the execution graph" — use whichever ordering makes the execution flow obvious.

**Worked example (Stargate Data API — request/response service):**

| Layer | Responsibility | Key symbol |
|---|---|---|
| Command | Dumb POJO representing the parsed incoming request | `FindOneCommand` |
| CommandResolver | Picks the right Operation for this Command | `CommandResolver<C>` |
| Operation | Describes how to execute the command | `Operation` |
| Task / DBTask | Builds and issues the CQL statement | `DBTask` |
| Cassandra driver | Executes CQL against the cluster | (driver boundary) |

Note that `CommandResolver` is an interface; `FindOneCommandResolver` is one of 39 concrete `*CommandResolver` implementations. The layer map names the interface because that's the contract — implementations are details.

**Worked example (ibm-data-sync — batch ETL pipeline):**

| Stage | Responsibility | Key symbol |
|---|---|---|
| Source | Read raw records from the upstream system | `SourceConnector` (interface); e.g. `JdbcSourceConnector` |
| Extract | Parse and validate each raw record into a typed `SyncRecord` | `RecordExtractor` |
| Transform | Apply field mappings, enrichments, and filtering rules | `TransformChain`, `TransformStage` (interface) |
| Load | Write the final records to the target store in batches | `TargetWriter` (interface); e.g. `CosTargetWriter` |
| Coordinator | Manage job state, checkpointing, and error recovery across stages | `SyncJobCoordinator` |

Note that for a pipeline, the "layers" are execution stages rather than request-handling tiers — the table still names one key symbol per stage.

---

## Section 3 — Execution Lifecycle

**What it is:** a numbered walkthrough of one representative execution path — a request, a job run, an event, a batch — naming the class and method at each hop.

**Why it matters:** a layer map shows structure; the execution lifecycle shows motion. Together they answer "what is this system made of?" and "how does it actually run?". New engineers cannot contribute confidently until they can trace a unit of work from entry to completion.

**How detailed to be:** trace one representative case end to end. Name the method at each hop — not "the resolver" but "`FindOneCommandResolver.resolveCollectionCommand()`". A reader should be able to follow the trace in their IDE using nothing but the names you provide. For a pipeline codebase, "entry" is the job trigger or the first method that runs when a record is consumed. For a **library**, there is no job entry point — trace a typical caller's use of the primary public API instead (e.g., "caller constructs `Client`, calls `Client.submit()`, which invokes `RequestQueue.enqueue()`, which…").

**Worked example (Stargate Data API — `findOne` request):**

1. **Entry:** `MeteredCommandProcessor.processCommand()` receives the incoming `FindOneCommand` and delegates to the processing pipeline.
2. **Resolver selection:** `FindOneCommandResolver.resolveCollectionCommand()` inspects the request and branches across four sort paths: vector search, BM25, sorted (with `ChainedComparator`), and unsorted. Sort dispatch detection uses `SortClauseUtil`.
3. **Operation construction:** the selected resolver method returns an `Operation` instance describing how to execute the command.
4. **Task execution:** the `Operation` builds a `DBTask` (or `DBTask` subtype) that constructs the CQL statement.
5. **Driver hand-off:** the task passes the CQL to the Cassandra driver, which executes against the cluster and returns a result set.
6. **Response:** the result set is mapped back to JSON and returned to the coordinator.

**Worked example (ibm-data-sync — one full sync run):**

1. **Job trigger:** `SyncJobCoordinator.runJob()` is invoked by the scheduler (or the CLI entry point `SyncRunner.main()`). It loads the job config from `JobConfigLoader.load()` and initialises the stage graph.
2. **Source read:** `JdbcSourceConnector.fetchBatch()` queries the upstream database for records changed since the last checkpoint cursor. Returns an `Iterator<RawRecord>`.
3. **Extraction:** `RecordExtractor.extract()` parses each `RawRecord` into a typed `SyncRecord`, applying schema validation. Invalid records are routed to `DeadLetterQueue.enqueue()`.
4. **Transform chain:** `TransformChain.apply()` runs each `TransformStage` in order (field mapping, enrichment, filter). Each stage returns a `SyncRecord` or `null` (drop).
5. **Load:** `CosTargetWriter.writeBatch()` accumulates records into `batchConfig.maxBatchSize()` chunks and issues PUT requests to COS. Failures are retried via `RetryPolicy.shouldRetry()`.
6. **Checkpoint:** on success, `CheckpointStore.advance()` persists the new cursor so the next run resumes from the correct offset.

---

## Section 4 — Domain Vocabulary

**What it is:** a short glossary of terms that have a project-specific meaning, or that a new engineer needs to know to read the source.

**Why it matters:** every codebase develops its own dialect. "Command", "resolver", "shredding", "deferred" — these mean specific things in this codebase that do not match their dictionary definitions. A new engineer who reads `DocumentShredder` without knowing what "shredding" means in this context will misread the code.

**How detailed to be:** 5–10 terms, one or two sentences each. If you find yourself writing 15+ terms, you are building a glossary. Cut the terms a new engineer will look up themselves (standard Java, standard Cassandra concepts) and keep only the project-specific dialect.

**Worked example (Stargate Data API):**

| Term | Definition |
|---|---|
| **Shredding** | The process of decomposing an incoming JSON document into a flat row structure for Cassandra storage. Runs only on insert, collection-only. Key classes: `DocumentShredder`, `WritableShreddedDocument`. |
| **Resolver** | A class implementing `CommandResolver<C>` that maps an incoming `Command` to an `Operation`. There are 39 concrete `*CommandResolver` implementations; naming convention is `[CommandName]Resolver`. |
| **Collection** | A document-model namespace. Predates tables in this codebase; uses in-memory sorting via `ChainedComparator` rather than CQL `ORDER BY`. |
| **Table** | A table-model namespace introduced later. Uses real CQL `ORDER BY` via `*CqlClause` classes. |
| **Task / DBTask** | A unit of CQL work. Has its own retry policy (`TaskRetryPolicy`) separate from the driver-level retry policy. |
| **LWT** | Lightweight Transaction — a Cassandra feature used for conditional writes. Calls that use LWT require special handling in the task layer. |

**Worked example (ibm-data-sync — batch ETL pipeline):**

| Term | Definition |
|---|---|
| **SyncRecord** | A typed, validated record that has passed extraction and is ready for transformation. Carries both data fields and metadata (source timestamp, record ID, partition key). Key class: `SyncRecord`. |
| **Checkpoint** | A persisted cursor that tracks the last successfully processed record offset, allowing jobs to resume from the correct position after a failure. Managed by `CheckpointStore`. |
| **Dead letter queue** | A holding area for records that fail validation or transformation. Allows the job to proceed without blocking on individual bad records. Key class: `DeadLetterQueue`. |
| **TransformStage** | A single atomic unit in the transform pipeline. Each stage receives a `SyncRecord` and returns a modified `SyncRecord` or `null` (drop). Stages run in `@Order` sequence. |
| **WriteBatch** | The unit of writes to the target store. Records are accumulated into `batchConfig.maxBatchSize()` chunks before issuing a bulk write. |
| **Idempotency token** | A unique per-record identifier used by `TargetWriter` to deduplicate retried writes. Prevents double-write on job restart. |

---

## Section 5 — Common Change Recipes

**What it is:** ordered checklists for 3–5 common change tasks, naming the classes and methods to touch in order.

**Why it matters:** this section is where the document earns most of its value. A new engineer assigned "add a new command" or "add a new transform stage" does not need to understand the entire codebase — they need to know which files to touch, in what order, and what interface to implement. This section answers that.

**How detailed to be:** imperative steps only. "Create a `[CommandName]` class implementing `[InterfaceName]`" is enough. Do not explain the implementation — point to where it goes. If a step has a non-obvious constraint, add a one-clause note.

**Worked example (Stargate Data API — adding a new command):**

1. Create a new `[CommandName]Command` class as a POJO implementing the `Command` interface.
2. Create a `[CommandName]CommandResolver` class implementing `CommandResolver<[CommandName]Command>`.
3. Implement `resolveCollectionCommand()` and `resolveTableCommand()` in the resolver; branch for the collection and table paths separately.
4. Register the command and resolver in the dependency injection configuration.
5. Add error code constants for any new failure modes to the appropriate `RequestException` subclass.

**Worked example (Stargate Data API — adding a new error code):**

1. Identify the correct exception class for the error category (`RequestException` for client errors, `ServerException` for server errors).
2. Add a new `Code` enum constant inside that exception class.
3. Create a corresponding error message template in the YAML error resources.
4. Throw using the pattern: `ExceptionClass.Code.YOUR_CODE.get(errVars(...))`.

**Worked example (ibm-data-sync — adding a new transform stage):**

1. Create a new class implementing `TransformStage` — implement `apply(SyncRecord): SyncRecord` (return `null` to drop the record).
2. Annotate with `@TransformStage.Order(n)` to set its position in the `TransformChain`. Check existing stage annotations to avoid collisions.
3. Register the new stage in `TransformChainFactory.buildChain()` — it reads stage order from annotations, so registration is the only wiring required.
4. Add a config key to `SyncJobConfig` if the stage needs a tunable parameter; bind it in `JobConfigLoader.load()`.
5. Add a unit test extending `AbstractTransformStageTest` — the base class handles setup and provides a `SyncRecord` factory.

**Worked example (ibm-data-sync — swapping in a new target writer):**

1. Implement `TargetWriter` — `writeBatch(List<SyncRecord>)` and `close()` are the required methods.
2. Add a new `WriterType` enum constant to `WriterConfig.WriterType`.
3. Add a case to `TargetWriterFactory.create()` that instantiates the new writer from the job config.
4. Update `SyncJobConfig` with any new config keys the writer needs (connection string, bucket name, etc.).

---

## Section 6 — High-Signal Files by Question Type

**What it is:** a lookup table mapping common questions to the one or two classes that best answer them.

**Why it matters:** large codebases have hundreds of classes. A new engineer running a text search for "sort" in the Data API will get dozens of hits across the resolver files. This section cuts the noise: "for questions about sort dispatch, start at `SortClauseUtil`."

**How detailed to be:** one entry per question type. Name only the best entry point — not every class that touches the concept. If you feel the need to list five classes for one question, that is a sign the answer is "it's complicated" and belongs in Section 7 (Known Gotchas) instead.

**Worked example (Stargate Data API):**

| Question type | Where to start |
|---|---|
| "How does findOne work?" | `FindOneCommandResolver.resolveCollectionCommand()` |
| "Where does sort dispatch happen?" | `SortClauseUtil` |
| "How does document storage work?" | `DocumentShredder` |
| "How do I add retry behavior?" | `TaskRetryPolicy.shouldRetry()` |
| "Where do error codes live?" | `RequestException`, `ServerException` |

**Worked example (ibm-data-sync — batch ETL pipeline):**

| Question type | Where to start |
|---|---|
| "How does a sync job run end-to-end?" | `SyncJobCoordinator.runJob()` |
| "Where does record validation happen?" | `RecordExtractor.extract()` |
| "How do I add a new transform?" | `TransformStage` (interface), `TransformChainFactory` |
| "What happens when a record fails?" | `DeadLetterQueue.enqueue()`, `FailureHandler` |
| "How does checkpointing work?" | `CheckpointStore.advance()`, `CheckpointStore.restore()` |

---

## Section 7 — Known Gotchas

**What it is:** invariants and negative-space rules that are NOT visible from reading the source — things a senior engineer mentions in code review but that are not captured in a comment or test.

**Why it matters:** this is the section that most directly replaces the senior-engineer interrupt. "Renaming a resolver class breaks saved client flows" is not in the code. It is in the senior engineer's head. Moving it here is the highest-value thing you can do in this document.

**How detailed to be:** state the rule, explain why it exists, name the consequence of violating it. One to three sentences per gotcha. If there is a key class that enforces or embodies the rule, name it.

**Finding material:** if you cannot think of any gotchas, interview a senior engineer who reviews PRs on this codebase. Ask: "What mistakes do you keep catching in review?" That answer is this section.

**Worked example (Stargate Data API):**

---

**Renaming a resolver class breaks saved client flows**

Rule: do not rename a `*CommandResolver` class without a migration plan.
Why: some client tooling and saved Stargate configurations reference resolver names as strings. A rename silently breaks these without compile-time warning.
What breaks: runtime routing failures that appear as unexpected errors, not "class not found" errors.

---

**Collection and table paths are intentionally separate codepaths**

Rule: do not unify the collection and table sort implementations.
Why: collections predate tables and use in-memory sorting via `ChainedComparator`; tables use real CQL `ORDER BY` via `*CqlClause` classes. The semantic contracts are different.
What breaks: if you route collection sort through the table CQL path, the sort semantics change silently — no exception, wrong results.

---

**Task-level retry and driver-level retry are independent — do not confuse them**

Rule: `TaskRetryPolicy` (with its `NO_RETRY` constant and `shouldRetry()` override point) controls retries at the task layer. The Cassandra driver has its own separate retry policy.
Why: they operate at different abstraction levels and handle different failure classes.
What breaks: adding retry logic at the wrong level results in either under-retry (errors that should retry are surfaced immediately) or double-retry (errors that retry once at each level are retried twice, causing unexpected behavior under load).

---

**Worked example (ibm-data-sync — batch ETL pipeline):**

**Checkpoint offsets must be advanced only after target write succeeds**

Rule: `CheckpointStore.advance()` must be called *after* `TargetWriter.writeBatch()` returns success, not before. The checkpoint update and the write are not transactional.
Why: if the job crashes after advancing the checkpoint but before completing the write, the next run resumes past those records and they are permanently lost.
What breaks: data loss. The source sees those records as processed (cursor advanced), but they never landed in the target store.

---

**Transform stages cannot be reordered without reviewing order-dependency invariants**

Rule: when changing a `TransformStage`'s `@Order` annotation, review whether other stages depend on its output. The codebase does not enforce stage dependencies at compile time.
Why: some stages assume earlier stages have already run — for example, `EnrichmentStage` expects `ValidationStage` to have already set the `recordType` field.
What breaks: if enrichment runs before validation, `recordType` is null and the enrichment lookup silently fails, producing incomplete records.

---

## Ready to Test Checklist

Before committing your completed `ONBOARDING.md`, run through this checklist:

- [ ] **No line numbers.** Search the document for any reference to a line number (e.g., "line 72", ":72"). Replace every one with a symbol anchor.
- [ ] **No file paths without a symbol.** Every file path reference should name a class or method, not just a path.
- [ ] **Every class name is real.** Open your IDE and verify every class name you wrote actually exists in current source. Fix any that don't.
- [ ] **Every method name is real.** Same check for method names.
- [ ] **A new engineer can follow Section 3 in an IDE.** Hand the request lifecycle trace to someone unfamiliar with the codebase and ask them to find each step. If they can't, the trace is missing a class or method name.
- [ ] **Section 7 has at least three gotchas.** If it doesn't, interview a senior engineer before committing.
- [ ] **The owner block names a person, not a team.** "Data Platform" is not an owner. "Jane Smith (Data Platform)" is.
- [ ] **The review cadence is scheduled.** Add a calendar reminder now. The document is worth nothing if it drifts.
- [ ] **No TODO markers remain.** Search for `[PLACEHOLDER]` and `<!-- TODO:`. Every one must be replaced with real content.
