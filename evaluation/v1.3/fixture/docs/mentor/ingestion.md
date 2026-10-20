# Ingestion design

**Scope:** `ingestion.py`; store, retrieve, count, or remove events.

**Observed source:** `store_event` writes the original key; `get_event` looks it up
without transformation. `PipelineTests.test_identifiers_are_opaque` verifies that
case and surrounding whitespace distinguish keys.

**Documented fixture decision:** Upstream systems own identity. Applying
`normalize_label` from delivery could merge separate events. Preserve case,
whitespace, and other characters exactly for all identity operations.

**Bulk contract:** Retrieval preserves the caller's order and repeated IDs.
Missing IDs occupy their original positions with `None`. Deduplicating a request
would destroy its alignment with the upstream batch.

**Valid example:** Follow `get_event` for key lookup. Delivery's normalization
helper is appropriate only for presentation and is not an ingestion example.

**Verification:** Run `python3 -m unittest discover -s tests -v` from the fixture
root with Python 3.9+. Add checks for new behavior, including distinct mixed-case
and whitespace-bearing keys, misses, and empty input. No model-specific execution
or production behavior is asserted here.
