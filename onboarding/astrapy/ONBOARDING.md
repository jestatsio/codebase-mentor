# ONBOARDING.md — astrapy

---

## Document Owner

**Owner:** Eric Hare (DataStax Data Platform team)
**Review cadence:** Every 6 months, or after any major architectural change.
**Last reviewed:** 2025-07

---

## 1 — Codebase Purpose

`astrapy` is the official Python client library for the DataStax Astra DB Data API.
It translates Python method calls into JSON HTTP POST requests sent to a Data API
endpoint, returning structured Python objects to the caller. The library supports
two data models: **collections** (schemaless document storage) and **tables**
(schema-enforced row storage), each with synchronous and asynchronous interfaces.
Callers are Python applications, notebooks, or frameworks; the library never owns
storage — it is a thin, HTTP-driven façade over a running Data API server.

---

## 2 — Layer Map

The codebase is organized into five layers, outermost first:

| Layer | Responsibility | Key symbol |
|---|---|---|
| Client | Entry point; holds token + environment; spawns `Database` objects | `DataAPIClient` |
| Database | Keyspace-scoped gateway; creates and retrieves collections and tables | `Database` / `AsyncDatabase` |
| Collection / Table | Collection or table handle; exposes all DML commands | `Collection` / `Table` (and their `Async*` counterparts) |
| Serdes + Request bridge | Serializes the Python payload, delegates to `APICommander`, deserializes the response | `Collection._converted_request()` via `preprocess_collection_payload` and `postprocess_collection_response` |
| HTTP | Encodes and transmits the JSON body over HTTPS via httpx; handles Decimal precision, timeouts, errors, and event observers | `APICommander` |

---

## 3 — Execution Lifecycle

**Representative execution:** `find_one()` against a collection

1. **Client construction:** `DataAPIClient.__init__()` merges the caller's token,
   environment, and `APIOptions` into `self.api_options` via a
   `defaultAPIOptions(_environment).with_override(...)` chain.

2. **Database handle:** `DataAPIClient.get_database()` validates the API endpoint
   against the environment, constructs a `Database` instance carrying the merged
   `FullAPIOptions`, and creates an `APICommander` keyed to the keyspace path via
   `Database._get_api_commander()`.

3. **Collection handle:** `Database.get_collection()` returns a `Collection` instance
   whose `__init__` builds its own `APICommander` (path extended to the collection
   name) via `Collection._get_api_commander()`. Embedding and reranking API keys are
   baked into `self._commander_headers` at this point.

4. **find_one invocation:** `Collection.find_one()` resolves the effective timeout via
   `_select_singlereq_timeout_gm()`, builds the `findOne` JSON payload dict, and calls
   `Collection._converted_request()` with a `_TimeoutContext`.

5. **Serdes preprocessing:** Inside `Collection._converted_request()`,
   `preprocess_collection_payload()` transforms the Python payload dict according to
   `SerdesOptions` (encoding `DataAPIVector` values, unrolling iterables, etc.).
   The result is passed to `APICommander.request()`.

6. **HTTP dispatch:** `APICommander.request()` calls `APICommander.raw_request()`,
   which Decimal-encodes the payload (if `handle_decimals_writes` is set), fires the
   httpx POST, converts `httpx.TimeoutException` into `DataAPITimeoutException`, then
   notifies any registered response event observers *before* calling
   `raise_for_status()` on HTTP 4xx/5xx — so observers see error responses before the
   exception is raised.

7. **Response parsing + error surfacing:** `APICommander._raw_response_to_json()`
   parses the response JSON (Decimal-aware if `handle_decimals_reads` is set), fires
   warning and error events to any registered observers, and raises
   `DataAPIResponseException` if the `"errors"` key is present in the response body.

8. **Serdes postprocessing:** Back in `Collection._converted_request()`,
   `postprocess_collection_response()` converts raw API types (e.g., UUIDs,
   timestamps) into Python objects according to `SerdesOptions`. The final dict is
   returned to `Collection.find_one()`.

9. **Result:** `Collection.find_one()` extracts `response["data"]["document"]`,
   returning it to the caller as a plain `dict` (or typed `DOC`), or `None` if no
   document matched.

---

## 4 — Domain Vocabulary

| Term | Definition |
|---|---|
| **Collection** | A schemaless, document-oriented container in the Data API. Each collection belongs to a keyspace. The Python handle is `Collection` (sync) or `AsyncCollection` (async); both live in `astrapy/data/collection.py`. |
| **Table** | A schema-enforced, row-oriented container in the Data API, analogous to a CQL table. The Python handle is `Table` / `AsyncTable` in `astrapy/data/table.py`. |
| **DataAPIClient** | The top-level entry point in `astrapy/client.py`. Holds the token and environment; spawns `Database` and `AstraDBAdmin` objects. |
| **APICommander** | The HTTP layer in `astrapy/utils/api_commander.py`. Each `Collection`, `Table`, and `Database` instance owns one. It wraps an `httpx.Client` + `httpx.AsyncClient`, handles Decimal encoding/decoding, and converts `httpx` errors into astrapy exceptions. |
| **_UNSET** | A singleton sentinel (`UnsetType`) in `astrapy/utils/unset.py`. Used as the default for optional parameters to distinguish "caller did not provide this argument" from "caller explicitly passed `None`". Passing `None` when `_UNSET` is expected changes the outgoing API payload. |
| **FilterType** | A `dict[str, Any]` type alias (in `astrapy.constants`) representing a Data API filter expression, e.g. `{"price": {"$lt": 100}}`. |
| **SortType** | A `dict[str, Any]` type alias representing a sort specification; `{"$vector": [...]}` triggers ANN vector search. |
| **SerdesOptions / `serdes_options`** | A group of settings (class `SerdesOptions`, full form `FullSerdesOptions`, in `astrapy/utils/api_options.py`) controlling how Python values are serialized to and deserialized from the Data API, including Decimal precision, custom data types, and vector binary encoding. Accessible via `api_options.serdes_options`. |
| **CollectionFindCursor / TableFindCursor** | Lazy iterators returned by `Collection.find()` / `Table.find()`, defined in `astrapy/data/cursors/find_cursor.py`. The cursor has three states (`CursorState.IDLE`, `CursorState.STARTED`, `CursorState.CLOSED`) and pages through results by calling `_try_ensure_fill_buffer()` on demand. |
| **DOC / ROW** | `TypeVar` generics (in `astrapy.constants`) that flow through the `Collection[DOC]` and `Table[ROW]` generic classes to give callers typed document/row access. Default concrete types are `DefaultDocumentType = dict[str, Any]` and `DefaultRowType = dict[str, Any]`. |
| **EmbeddingHeadersProvider** | An abstract class in `astrapy/authentication.py` that supplies embedding-service authentication headers per request. Passed as `embedding_api_key` when acquiring a `Collection`; its `get_headers()` output is merged into every `APICommander` request for that collection. |
| **_TimeoutContext** | A dataclass in `astrapy/exceptions/__init__.py` that carries `request_ms`, `nominal_ms`, and a human-readable `label` string through the call stack into `APICommander`, so that a `DataAPITimeoutException` can report exactly which timeout setting fired. |

---

## 5 — Common Change Recipes

### Recipe A — Add a new collection command (sync + async)

1. Add the method to `Collection` in `astrapy/data/collection.py`: accept `FilterType`,
   `SortType`, timeout parameters, and any command-specific arguments; resolve the
   timeout via the appropriate `_select_singlereq_timeout_*` helper imported from
   `astrapy.exceptions.utils`; build the JSON payload dict; call
   `Collection._converted_request()`.
2. Add the exact async counterpart to `AsyncCollection` (further down in the same
   file). The signature must mirror the sync version; call
   `AsyncCollection._converted_request()`, which invokes `APICommander.async_request()`
   internally.
3. If the command returns a cursor (multi-document read), return a new
   `CollectionFindCursor` (or `AsyncCollectionFindCursor`) following the
   `Collection.find()` pattern rather than calling `_converted_request()` directly.
4. Add unit tests in `tests/base/unit/` and integration tests in
   `tests/base/integration/`, following the `_sync` / `_async` test name convention.

### Recipe B — Add a new admin operation

1. Identify the target admin class: `AstraDBAdmin` (Astra DB account-level operations)
   or `AstraDBDatabaseAdmin` / `DataAPIDatabaseAdmin` (per-database operations) in
   `astrapy/admin/admin.py`.
2. Add the sync method; resolve timeouts; build the payload; call
   `self._dev_ops_api_commander.request()` for DevOps API calls or
   `self._api_commander.request()` for Data API calls.
3. Add the async counterpart (`async_<method_name>`) to the same class.
4. If the abstract base `DatabaseAdmin` declares the operation as `@abstractmethod`,
   implement it in every concrete subclass (`AstraDBDatabaseAdmin`,
   `DataAPIDatabaseAdmin`).
5. Export the method from the relevant `__all__` list if public.

### Recipe C — Add a new exception type

1. Choose the correct module under `astrapy/exceptions/`:
   `data_api_exceptions.py` for Data API errors, `devops_api_exceptions.py` for
   DevOps API errors, `collection_exceptions.py` for collection-specific bulk errors,
   `table_exceptions.py` for table-specific bulk errors.
2. Define the new exception class, subclassing the appropriate base
   (`DataAPIException`, `DevOpsAPIException`, etc.).
3. Export the new class from `astrapy/exceptions/__init__.py`.
4. Raise it from the relevant layer (collection method, `APICommander`, or admin
   method) at the point where the error condition is detected.

---

## 6 — High-Signal Files by Question Type

| Question type | Where to start |
|---|---|
| "How does a read work end-to-end?" | `Collection.find_one()` → `Collection._converted_request()` → `APICommander.request()` in `astrapy/data/collection.py` and `astrapy/utils/api_commander.py` |
| "How does pagination / cursor work?" | `CollectionFindCursor._try_ensure_fill_buffer()` in `astrapy/data/cursors/find_cursor.py`; cursor state machine in `AbstractCursor` in `astrapy/data/cursors/cursor.py` |
| "How are API errors surfaced?" | `APICommander._raw_response_to_json()` (error detection and raise) → `DataAPIResponseException` in `astrapy/exceptions/data_api_exceptions.py` |
| "How does sync/async parity work?" | `Collection` and `AsyncCollection` in `astrapy/data/collection.py` — sync calls `APICommander.request()`, async calls `APICommander.async_request()`; payload construction is identical |
| "How are timeouts handled?" | `_TimeoutContext` and `MultiCallTimeoutManager` in `astrapy/exceptions/__init__.py`; `_select_singlereq_timeout_gm()` in `astrapy/exceptions/utils.py`; `APICommander.raw_request()` converts `httpx.TimeoutException` → `DataAPITimeoutException` |
| "How does vectorize / embedding work?" | `EmbeddingHeadersProvider` in `astrapy/authentication.py` (header injection per request); `AstraDBDatabaseAdmin.find_embedding_providers()` in `astrapy/admin/admin.py` (provider discovery); pass `$vectorize` as a document field or in `SortType` to trigger server-side embedding |

---

## 7 — Known Gotchas

### `_UNSET` vs `None`: they produce different API payloads

**Rule:** Use `_UNSET` (from `astrapy.utils.unset`) as the default for optional
parameters that should be omitted from the API payload when not provided. Never
substitute `None` as a stand-in for "not provided".
**Why:** The payload-building code in every DML method explicitly filters out keys
whose value is `None` (e.g., `{k: v for k, v in {...}.items() if v is not None}`).
A parameter that is `_UNSET` is never inserted into that dict in the first place.
However, if a caller or developer mistakenly passes `None` meaning "omit this field",
and the method passes it through unchecked, the field will appear as a JSON `null`
in the payload, changing the semantics of the API request.
**What breaks:** The API may interpret an explicit `null` differently from an absent
field (e.g., `"filter": null` vs. no `filter` key), leading to unexpected query
results or API validation errors that are difficult to diagnose.

---

### Sync/async parity: every public Collection method needs an AsyncCollection counterpart

**Rule:** Every public method added to `Collection` must have an exact async
counterpart on `AsyncCollection`, and vice versa. The same rule applies to `Table`
and `AsyncTable`. The parallel classes are maintained by hand in the same file
(`astrapy/data/collection.py` and `astrapy/data/table.py` respectively).
**Why:** astrapy's public contract is that all functionality is available in both
sync and async usage. There is no code-generation or decorator-based approach —
the parallel methods are written and kept in sync manually.
**What breaks:** Adding a method to one class without the other silently creates a
feature gap. An async caller hits `AttributeError` at runtime; no static type check
catches the omission before release.

---

### Decimal serialization: bypassing `APICommander`'s custom encode/parse loses precision

**Rule:** All JSON serialization and deserialization of API payloads must go through
`APICommander.request()` (or `async_request()`). Never call `json.dumps` / `json.loads`
directly on the payload dict. The `handle_decimals_writes` and `handle_decimals_reads`
flags on `APICommander` control whether the Decimal-aware path is taken.
**Why:** Standard `json.dumps` converts `decimal.Decimal` to a float string, silently
losing significant digits. `APICommander._decimal_aware_encode_payload()` uses
`_MarkedDecimalEncoder` to embed Decimal values with special Unicode markers and then
strips the surrounding quotes, emitting bare decimal literals. On the read path,
`_decimal_aware_parse_json_response()` calls `json.loads(text, parse_float=Decimal)`
to restore precision losslessly.
**What breaks:** Bypassing `APICommander` on the write path silently truncates Decimal
values in the outgoing payload. On the read path, all numbers arrive as Python `float`
with the same silent precision loss — no exception is raised.

---

### Python 3.13+ integration test skips are expected — the package itself is fine

**Rule:** Do not interpret skipped integration tests on Python 3.13+ as a library
defect or attempt to "fix" them by modifying library dependencies.
**Why:** The `cassandra-driver` package used in the integration test harness depends on
`libev` / `asyncore`, which are unavailable or broken on Python 3.13+. The library
itself has no direct runtime dependency on `cassandra-driver`.
**What breaks:** Pinning or removing `cassandra-driver` from `pyproject.toml` to
eliminate the skips would break the test infrastructure on older Python versions
without improving the library code itself.

---

### `StrEnum` pattern: use `astrapy.utils.str_enum.StrEnum`, not stdlib `enum.Enum`

**Rule:** All string-valued enums in astrapy must subclass
`astrapy.utils.str_enum.StrEnum` (backed by `StrEnumMeta`), not the stdlib
`enum.Enum` or `enum.StrEnum`.
**Why:** `StrEnumMeta` provides `_name_lookup()`, which performs case-insensitive
matching on both enum keys *and* values, so `"dot_product"` and `"DOT_PRODUCT"` are
both valid. The stdlib `Enum.__contains__` checks only values with exact case.
`StrEnum.coerce()` allows callers to pass either the string key or value,
case-insensitively — this convenience is part of the public API contract.
**What breaks:** A new enum subclassing stdlib `Enum` will make `value in MyEnum`
return `False` for case-mismatched strings that should be valid, and `coerce()` is
unavailable. This surfaces as a `ValueError` from callers who rely on
case-insensitive string coercion at the usage sites of those enums.
