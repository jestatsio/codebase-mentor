# Delivery design

**Scope:** `delivery.py`; human-facing labels only.

**Observed source:** `display_label` delegates to `normalize_label`, which strips
surrounding whitespace and lowercases presentation text.

**Documented fixture decision:** Display labels are deliberately normalized for
consistent presentation. They are not event IDs. Ingestion owns identity and does
not share this transformation.

**Valid example:** Use `normalize_label` for new display-label operations. Never
export this rule as a repository-wide instruction for all strings.

**Verification:** `PipelineTests.test_display_labels_are_normalized` in
`tests/test_pipeline.py`, run with `python3 -m unittest discover -s tests -v`.
