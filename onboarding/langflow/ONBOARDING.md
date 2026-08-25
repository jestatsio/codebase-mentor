# ONBOARDING.md — Langflow

---

## Document Owner

**Owner:** Eric Hare (Langflow team)
**Review cadence:** Every 6 months, or after any major architectural change.
**Last reviewed:** 2026-06

---

## 1 — Codebase Purpose

Langflow is a visual workflow builder for AI agents and LLM-powered pipelines. The
repository is a Python + TypeScript monorepo with a FastAPI backend, a React/Vite
frontend, and the `lfx` executor/CLI sub-package that owns the graph runtime. Users
design flows as JSON graphs in the UI; the backend loads those flow definitions,
executes them through the `lfx` graph engine, and returns structured outputs or
streaming events. Flows can also be authored as plain Python scripts (`.py`) or loaded
from JSON files and run via the `lfx` CLI without a running server.

---

## 2 — Layer Map

The backend is organized into five layers, outermost first:

| Layer | Responsibility | Key symbol |
|---|---|---|
| HTTP (FastAPI) | Deserialize the request, authenticate, route to the right handler | `simplified_run_flow()` in `api/v1/endpoints.py` |
| Service layer | Cross-cutting concerns: auth, database (SQLAlchemy), cache, storage, tracing, job queue | `src/backend/base/langflow/services/` sub-packages; each service has a `base.py` interface |
| Flow executor | Orchestrate graph loading, graph execution, and event streaming | `execute_flow_file()` in `agentic/services/flow_executor.py` |
| Graph engine (`lfx`) | Build the `Graph` from a flow definition; topologically execute `Vertex` objects | `Graph` in `lfx/graph/graph/base.py`; `Vertex` in `lfx/graph/vertex/base.py` |
| Component | User-defined or built-in unit of logic; executes inside a vertex | `Component` in `lfx/custom/custom_component/component.py` |

---

## 3 — Execution Lifecycle

**Representative request:** `POST /api/v1/run/{flow_id_or_name}` (non-streaming)

1. **HTTP entry:** `simplified_run_flow()` in `src/backend/base/langflow/api/v1/endpoints.py`
   receives the request, authenticates the user, resolves the flow by ID or endpoint name,
   and delegates to `execute_flow_file()` or `execute_flow_file_streaming()` in
   `agentic/services/flow_executor.py`.

2. **Graph load:** `execute_flow_file()` calls `load_graph_for_execution()` (in
   `agentic/services/helpers/flow_loader.py`), which resolves the flow path and instantiates
   a `Graph` object from the flow's JSON definition.

3. **Graph preparation:** `Graph.prepare()` is called, which builds the internal vertex map,
   edge list, adjacency structures, and run-order map via `Graph.build_graph_maps()` and
   `Graph.build_run_map()`. This step validates the graph topology and resolves
   `start_component_id` / `stop_component_id` if provided.

4. **Event setup:** An `EventManager` (from `lfx/events/event_manager.py`) and an
   `asyncio.Queue` are created. The event manager routes typed events (token chunks, vertex
   results, errors) to the queue for downstream consumption.

5. **Execution:** `_run_graph_with_events()` (in `flow_executor.py`) calls
   `graph.prepare()` to build the run map and vertex structures, then calls
   `Graph.async_start()` with the `EventManager`. `Graph.async_start()` iterates
   vertices in dependency order, calling `Graph.build_vertex()` for each. Each vertex
   instantiates its `Component` subclass, injects resolved input values, and calls the
   component's output method.

6. **Output and events:** Each vertex's result is stored via `Vertex.set_result()`. The
   `EventManager.send_event()` method fires events (e.g. `token`, `vertex_build`,
   `end_vertex`) that are consumed by `consume_streaming_events()` in
   `agentic/services/helpers/event_consumer.py`.

7. **Response:** For non-streaming runs, `execute_flow_file()` returns a `FlowExecutionResult`
   that `simplified_run_flow()` serializes to JSON. For streaming runs,
   `execute_flow_file_streaming()` returns a `StreamingResponse` that flushes SSE events as
   the queue receives them.

---

## 4 — Domain Vocabulary

| Term | Definition |
|---|---|
| **Component** | The base class for all user-defined and built-in Langflow components. Defined in `lfx.custom.custom_component.component.Component`. A component declares typed `inputs` and `outputs` and exposes one method per output. `langflow.custom.Component` is a re-export shim — the real class lives in `lfx`. |
| **Graph** | The runtime representation of a flow. Loaded from a flow's JSON definition, it holds the vertex and edge structures and drives execution order. Class: `Graph` in `lfx/graph/graph/base.py`. |
| **Vertex** | A node in the graph. Wraps one `Component` instance (when it is a `ComponentVertex`) and manages its state transitions (`INACTIVE → ACTIVE → BUILT`). Class: `Vertex` in `lfx/graph/vertex/base.py`; `ComponentVertex` in `lfx/graph/vertex/vertex_types.py`. |
| **Edge** | A directed connection between two vertices representing data flow between component outputs and inputs. Represented as `CycleEdge` or `Edge` in `lfx/graph/`. |
| **Flow** | A JSON document describing a graph — the serialized set of vertices (components with their config), edges, and metadata. Stored in the database by the `flow` service and loaded from disk by the CLI. |
| **`lfx`** | The standalone CLI sub-package at `src/lfx/`. It owns the graph engine (`Graph`, `Vertex`), the `Component` base class, the event system, extension discovery, and the `lfx serve` / `lfx run` entry points. `langflow-base` imports from it; `lfx` does not import from `langflow`. |
| **`langflow-base`** | The core backend framework package at `src/backend/base/`. Provides the FastAPI app, services (auth, database, cache, etc.), API routes, and the agentic layer. Depends on `lfx` for graph execution. |
| **`EventManager`** | The event routing hub used during graph execution. Registered callbacks receive typed events (e.g. token streams, vertex build results). Created via `create_default_event_manager()` or `create_stream_tokens_event_manager()`. Defined in `lfx/events/event_manager.py`. |
| **`InputValueRequest`** | The schema object that carries user input into a flow run (`input_value`, `input_type`, `output_type`, etc.). Defined in `lfx/schema/schema.py`. |
| **Service** | A singleton object registered with `ServiceManager` that provides a cross-cutting capability (auth, database, cache, storage, tracing). Each service has a `base.py` abstract interface and at minimum one concrete implementation. Defined under `services/` in `langflow-base`. |

---

## 5 — Common Change Recipes

### Recipe A — Add a new built-in component

1. Create a Python class in `src/backend/base/langflow/components/<category>/` (or
   `src/lfx/src/lfx/components/<category>/` for lfx-owned components) that inherits from
   `Component` (imported from `langflow.custom` or `lfx.custom`).
2. Define `display_name`, `description`, `icon` (Lucide icon name), `inputs` (list of
   `Input` subclass instances), and `outputs` (list of `Output` instances).
3. Implement one method per `Output` entry; the method name must match the `method` field
   of the corresponding `Output`.
4. Add the class to the `__init__.py` of its component category in alphabetical order.
5. Run the backend with `LFX_DEV=1 make backend` to hot-reload and verify the component
   appears in the UI without a full restart.
6. Add tests under `src/backend/tests/unit/components/` using `ComponentTestBaseWithClient`
   or `ComponentTestBaseWithoutClient` as the base class.

> ⚠️ **Never rename the component class after first release.** The class name is the
> stable identifier used in saved flow JSON and in the UI upgrade system. See Gotcha §1.

### Recipe B — Add a new backend service

1. Create a new directory under `src/backend/base/langflow/services/<service_name>/`.
2. Define an abstract interface class inheriting from `Service` (in `services/base.py`) in
   `base.py`.
3. Implement the concrete class in `service.py` (or similarly named file).
4. Register the service factory in `services/factory.py` by adding an entry to the service
   factory map.
5. Inject the service in route handlers or other services via `get_<service_name>_service()`
   dependency functions following the pattern in `services/deps.py`.

### Recipe C — Add a new API endpoint

1. Identify the correct router file under `src/backend/base/langflow/api/v1/` or `api/v2/`.
2. Add the route handler function, decorating with `@router.get` / `@router.post` / etc.
3. Add any required auth guards using the `get_current_active_user` dependency or an
   `ensure_*_permission()` guard from `services/authorization/guards.py`.
4. If the endpoint reads or writes flows or other DB entities, inject the relevant service
   via `Depends()` following existing patterns in the same router file.

### Recipe D — Add an authz guard to an existing route

1. Import the appropriate guard from `langflow.services.authorization.guards` (e.g.
   `ensure_flow_permission`).
2. Add the guard as an awaited call inside the route handler:
   ```python
   await ensure_flow_permission(current_user, FlowAction.read, flow_id=flow_id)
   ```
3. Verify behavior under `LANGFLOW_AUTHZ_ENABLED=false` (OSS default): the OSS
   pass-through returns allow for every check, so guarded routes remain accessible — no
   test regressions are expected in OSS mode.

---

## 6 — High-Signal Files by Question Type

| Question type | Where to start |
|---|---|
| "How does a flow run end-to-end?" | `simplified_run_flow()` in `api/v1/endpoints.py` → `execute_flow_file()` in `agentic/services/flow_executor.py` → `Graph.async_start()` in `lfx/graph/graph/base.py` |
| "Where is the Component base class really defined?" | `lfx/custom/custom_component/component.py` (`Component`). The `langflow.custom` path is a re-export shim. |
| "How does the graph execute vertices in order?" | `Graph.async_start()` → `Graph.build_vertex()` in `lfx/graph/graph/base.py`; topological order is built by `Graph.build_run_map()` |
| "How does authentication work?" | `services/auth/` — `AuthService`; route guards via `get_current_active_user` in `services/auth/utils.py` |
| "How does RBAC / authorization work?" | `services/authorization/guards.py` — `ensure_flow_permission()` etc.; plugin registration via `lfx.services` entry point `authorization_service` |
| "How do I add a component?" | `src/backend/base/langflow/components/` for built-in components; Recipe A above |
| "How does streaming work?" | `execute_flow_file_streaming()` in `flow_executor.py`; `EventManager.send_event()` in `lfx/events/event_manager.py`; `consume_streaming_events()` in `agentic/services/helpers/event_consumer.py` |
| "How is a flow stored and retrieved?" | `services/flow/` — flow CRUD; `services/database/` — SQLAlchemy models |
| "How does the lfx CLI run a flow without a server?" | `src/lfx/src/lfx/cli/` — `lfx run` and `lfx serve` entry points; `script_loader.py` for `.py` flow loading |

---

## 7 — Known Gotchas

### Component class rename is a breaking change

**Rule:** Never rename a `Component` subclass after it has been shipped in a release.
**Why:** The component's class name is used as the stable type identifier serialized into
saved flow JSON. When a user opens a flow that references the old class name, Langflow's
upgrade system marks the component as needing an update. If no migration is provided, the
component appears as missing and the flow is broken.
**What breaks:** Any saved flow — in the database or in exported JSON files — that
references the old class name will fail to load the component correctly. Metrics, logs,
and integration tests keyed on the class name also go dark.

---

### `Component` lives in `lfx`, not `langflow`

**Rule:** When reading or editing the `Component` base class, always work from
`lfx/custom/custom_component/component.py`, not from the `langflow` package.
**Why:** `langflow.custom.custom_component.component` is a thin re-export shim:

```python
from lfx.custom.custom_component.component import Component
```

Grepping for `class Component` inside `src/backend/` finds the shim. The real
implementation — including `__init__`, all config attributes, `get_component_toolkit()`,
and `PlaceholderGraph` — lives in `src/lfx/src/lfx/custom/custom_component/component.py`.
**What breaks:** Editing the shim file has no effect. The mentor's reconcile mode will flag the
shim path as stale if pointed there for a behavior question.

---

### `LFX_DEV=1` is required for hot reload during component development

**Rule:** Start the backend with `LFX_DEV=1 make backend` when actively developing
components. Use `LFX_DEV=mistral,openai` to load only specific modules.
**Why:** Without `LFX_DEV=1`, the component registry is populated at startup from the
installed package. New or modified component files are not picked up until the server
restarts.
**What breaks:** Without the flag, component edits appear to have no effect, leading to
confusing debugging sessions where the old version is running.

---

### blockbuster will fail tests that do sync I/O

**Rule:** Never make synchronous filesystem or network calls in async test paths. Check
`tests/conftest.py` for the explicit exemptions list before adding a new exception.
**Why:** All tests use the `blockbuster` fixture (autouse=True from `conftest.py`) which
detects blocking I/O in the async event loop. Any sync `open()`, `requests.get()`, or
similar call will fail the test even if the code is logically correct.
**What breaks:** Tests fail with a blockbuster error rather than a meaningful assertion
failure, making the root cause non-obvious. Mark tests with `@pytest.mark.no_blockbuster`
only as a last resort.

---

### `uv run` is required for pre-commit hooks

**Rule:** Run `uv run git commit` (not bare `git commit`) when committing in this repo.
**Why:** Pre-commit hooks (ruff for Python, biome for TypeScript) are installed in the
`uv` virtual environment. A bare `git commit` invokes them outside of `uv`, causing
`pre-commit` to fail to find the right Python interpreter.
**What breaks:** The commit aborts with a `command not found` or Python version error
from the pre-commit hook runner, even when your code is correctly formatted.

---

### Sub-package dev deps must be synced separately

**Rule:** Before running tests for `langflow-base` or `lfx`, run
`uv sync --group dev --package langflow-base` (or `--package lfx` as appropriate) in
addition to the top-level `uv sync`.
**Why:** `uv sync` at the workspace root resolves the top-level workspace dependencies but
does not install dev-only dependency groups declared inside sub-packages. Test-only deps
such as `fakeredis` may be absent.
**What breaks:** Tests fail at import time with `ModuleNotFoundError` for a dev-only
dependency that is not listed in the top-level workspace deps.
