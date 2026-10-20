# Event pipeline

**Owner:** Acceptance fixture. **Verification scope:** source and tests in this
fixture; no external service or production behavior is claimed.

## 1 — Purpose

Ingestion stores events using source-provided identifiers. Delivery creates
human-facing labels. Both use strings, but their contracts are different.

## 2 — Layers

`ingestion.py` contains `store_event` and `get_event`; `delivery.py` contains
`display_label` and `normalize_label`. They share no normalization contract.

## 3 — Execution

`store_event` places a payload under its original source ID. `get_event` looks up
that same ID. Separately, `display_label` normalizes the event's display label.

## 4 — Vocabulary

An **ID** is an opaque upstream identity. A **label** is presentation text.

## 5 — Changes

For ingestion changes, inspect `ingestion.py` and `tests/test_pipeline.py`, then
run `python3 -m unittest discover -s tests -v`. Python 3.9+ is the only requirement.
Commands listed here are recipes, not a claim that they ran in the current session.

## 6 — Subsystem guides

| Scope and task | Guide |
| --- | --- |
| `ingestion.py`: storage, lookup, bulk retrieval, removal | [Ingestion design](docs/mentor/ingestion.md) |
| `delivery.py`: human-facing label formatting | [Delivery design](docs/mentor/delivery.md) |

## 7 — Gotchas

Source IDs are exact and case-sensitive. Do not reuse display normalization for
storage identity. The fixture's documented decision is in the ingestion guide;
verify the current source and tests before applying it.
