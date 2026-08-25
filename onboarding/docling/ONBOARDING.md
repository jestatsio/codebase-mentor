# ONBOARDING.md — docling

---

## Document Owner

**Owner:** Eric Hare
**Review cadence:** Every 6 months, or after any major architectural change.
**Last reviewed:** 2026-08

---

## 1 — Codebase Purpose

Docling is a Python SDK and CLI (`docling`, a typer app in `docling/cli/main.py`)
that converts documents — PDF, DOCX, PPTX, XLSX, HTML, Markdown, images, audio,
LaTeX, and several XML schemas — into a unified `DoclingDocument` representation
(from the external `docling-core` package) for downstream gen-AI workflows.
Callers are Python applications, notebooks, or framework integrations; the CLI
wraps the same public API. The library never owns the input files or the model
weights — it detects the input format, routes it to a backend + pipeline pair,
and returns a `ConversionResult` whose `document` can be exported to Markdown,
HTML, JSON, or DocTags.

---

## 2 — Layer Map

The codebase is organized into six layers, outermost first:

| Layer | Responsibility | Key symbol |
|---|---|---|
| Converter | Public API; maps each `InputFormat` to a pipeline + backend; caches initialized pipelines | `DocumentConverter` |
| Format detection & input | Guesses the `InputFormat`; builds an `InputDocument` with its backend attached | `_DocumentConversionInput` / `InputDocument` |
| Backend | Parses raw bytes — either straight into a `DoclingDocument` (declarative) or into per-page handles (paginated PDF) | `AbstractDocumentBackend` (`DeclarativeDocumentBackend`, `PdfDocumentBackend`) |
| Pipeline | Orchestrates build → assemble → enrich stages for a format family | `BasePipeline` (`StandardPdfPipeline`, `SimplePipeline`, `VlmPipeline`, `AsrPipeline`) |
| Models | OCR, layout, table structure, reading order, and enrichment models, created through plugin factories | `GenericEnrichmentModel`, `BaseFactory` (`OcrFactory`, `LayoutFactory`, `TableStructureFactory`) |
| docling-core | Output document schema and exporters (separate package) | `DoclingDocument` |

---

## 3 — Execution Lifecycle

**Representative execution:** `DocumentConverter().convert("paper.pdf")`

1. **Entry:** `DocumentConverter.convert()` wraps the source in
   `DocumentLimits` and delegates to `DocumentConverter.convert_all()`.
2. **Format detection:** `_DocumentConversionInput.docs()` resolves URL inputs
   via `resolve_source_to_stream()`, then guesses the `InputFormat` in
   `_DocumentConversionInput._guess_format()` — mime via `filetype`, extension
   fallback via `_mime_from_extension()`, content sniffing via
   `_guess_from_content()` — and selects the backend from
   `DocumentConverter.format_to_options`.
3. **Input construction:** `InputDocument.__init__()` instantiates the backend
   through `InputDocument._init_doc()` (for PDF, `DoclingParseDocumentBackend`),
   enforces `max_file_size` / `max_num_pages`, and computes a document hash.
4. **Batch dispatch:** `DocumentConverter._convert()` chunks inputs with
   `chunkify()` (`settings.perf.doc_batch_size`) and runs
   `_process_document()` per document — serially by default, or via a
   `ThreadPoolExecutor` when `settings.perf.doc_batch_concurrency > 1`.
5. **Pipeline selection:** `DocumentConverter._execute_pipeline()` fetches the
   pipeline from `_get_pipeline()`, cached by
   `(pipeline class, md5 of pipeline_options.model_dump())`. For PDF this is
   `StandardPdfPipeline` with `ThreadedPdfPipelineOptions`.
6. **Build:** `BasePipeline.execute()` calls
   `StandardPdfPipeline._build_document()`: a producer thread loads
   `PdfPageBackend`s via `PdfDocumentBackend.load_page()`, and pages flow
   through `ThreadedPipelineStage`s wired by bounded `ThreadedQueue`s:
   preprocess (`PagePreprocessingModel`) → OCR → layout (default Heron model)
   → table structure (TableFormer) → assemble (`PageAssembleModel`).
7. **Assemble:** `StandardPdfPipeline._assemble_document()` concatenates the
   per-page elements, then `ReadingOrderModel.__call__()` establishes reading
   order and produces the `DoclingDocument`; page/picture images and confidence
   scores are attached here.
8. **Enrich:** `BasePipeline._enrich_document()` runs each model in
   `enrichment_pipe` (picture classification, picture description, chart
   extraction, code/formula) over `conv_res.document.iterate_items()`.
9. **Result:** a `ConversionResult` is yielded to the caller;
   `result.document` is the `DoclingDocument`, typically exported with
   `result.document.export_to_markdown()`.

---

## 4 — Domain Vocabulary

| Term | Definition |
|---|---|
| **DoclingDocument** | The unified output schema, defined in the external `docling-core` package. Backends and pipelines build it; exporters (Markdown, HTML, JSON, DocTags) consume it. |
| **Backend** | An `AbstractDocumentBackend` subclass that parses raw bytes. Declarative backends (`DeclarativeDocumentBackend.convert()`, e.g. `MsWordDocumentBackend`) emit a `DoclingDocument` directly; PDF backends (`PdfDocumentBackend`) yield `PdfPageBackend` handles. |
| **Pipeline** | A `BasePipeline` subclass that turns backend output into a finished document. `SimplePipeline` serves declarative formats; `StandardPdfPipeline` is the threaded PDF/image pipeline; `VlmPipeline` and `AsrPipeline` cover VLM and audio. |
| **FormatOption** | A per-`InputFormat` binding of `pipeline_cls` + `backend` (+ options), e.g. `PdfFormatOption`. Registered in `_get_default_option()` in `docling/document_converter.py`. |
| **Page** | The working unit of the PDF pipeline (`Page` in `docling/datamodel/base_models.py`). Carries size, `parsed_page`, predictions, `_backend`, and `_image_cache` through the threaded stages. |
| **ConversionResult / ConversionStatus** | The wrapper returned per document: `document`, `pages`, `errors`, and a status of `SUCCESS`, `PARTIAL_SUCCESS`, `FAILURE`, or `SKIPPED`. |
| **Enrichment model** | A `GenericEnrichmentModel` subclass in `enrichment_pipe` that annotates the assembled document (picture classification/description, chart extraction, code/formula). |
| **TableFormer** | The table-structure model. Configured via `TableStructureOptions` with `TableFormerMode.ACCURATE` and `do_cell_matching=True` as defaults. |
| **artifacts_path** | A local directory of pre-downloaded model weights. If unset, models are fetched on first use; if set, `BasePipeline.__init__()` requires it to be an existing directory. Pre-fetch with `docling-tools models download`. |

---

## 5 — Common Change Recipes

### Recipe A — Add support for a new input format

1. Add a member to the `InputFormat` enum and map its MIME type(s) in
   `MimeTypeToFormat` (both in `docling/datamodel/base_models.py`); add a
   `_detect_*` helper on `_DocumentConversionInput` if content sniffing is
   needed.
2. Implement a backend subclassing `DeclarativeDocumentBackend` (implement
   `convert()`) or `PdfDocumentBackend` (implement `load_page()` and
   `page_count()`); declare `supported_formats()` and `supports_pagination()`.
3. Define a `*FormatOption` class in `docling/document_converter.py` with the
   `pipeline_cls` and `backend`, and register it in `_get_default_option()`.
4. Optionally add a backend options class in `docling/datamodel/backend_options.py`.
5. Add tests under `tests/`; regenerate reference data with
   `DOCLING_GEN_TEST_DATA=1 uv run pytest` only if conversion outputs change.

### Recipe B — Add a new OCR engine

1. Subclass `OcrOptions` with a unique `kind` ClassVar (pattern:
   `EasyOcrOptions`, `RapidOcrOptions`, `TesseractCliOcrOptions` in
   `docling/datamodel/pipeline_options.py`).
2. Implement `BaseOcrModel` for the engine under `docling/models/`.
3. Register the model class with `OcrFactory` — `BaseFactory.register()` keys
   the model by its options type and loads registrations via the
   `ocr_engines` pluggy entry point.
4. Users select the engine through `PdfPipelineOptions.ocr_options`.

### Recipe C — Add a new enrichment model

1. Subclass `BaseEnrichmentModel` or `BaseItemAndImageEnrichmentModel`
   (both derive from `GenericEnrichmentModel` in `docling/models/base_model.py`);
   implement `is_processable()`, `prepare_element()`, and `__call__()`.
2. Add an options class and a `do_*` enable flag on `ConvertPipelineOptions`
   (or `PdfPipelineOptions` for PDF-only features).
3. Append the instance to `enrichment_pipe` in `ConvertPipeline.__init__()` or
   `StandardPdfPipeline._init_models()`, gated on the enable flag.

### Recipe D — Add a new pipeline

1. Subclass `ConvertPipeline` (or `PaginatedPipeline` for page-based formats);
   implement `_build_document()`, `_determine_status()`,
   `get_default_options()`, and `is_backend_supported()`.
2. Define an options class in the `PipelineOptions` hierarchy with a `kind`
   ClassVar (the discriminator pattern from `BaseOptions`).
3. Point a `FormatOption.pipeline_cls` at the new pipeline in
   `docling/document_converter.py`.

---

## 6 — High-Signal Files by Question Type

| Question type | Where to start |
|---|---|
| "How does conversion work end-to-end?" | `DocumentConverter.convert()` → `_convert()` → `_execute_pipeline()` in `docling/document_converter.py` |
| "How is the input format decided?" | `_DocumentConversionInput._guess_format()` in `docling/datamodel/document.py` |
| "How does PDF parsing work?" | `StandardPdfPipeline._build_document()` in `docling/pipeline/standard_pdf_pipeline.py`; backend contract in `PdfDocumentBackend` (`docling/backend/pdf_backend.py`) |
| "Where are models selected and configured?" | `StandardPdfPipeline._init_models()`; factories `get_ocr_factory()` / `get_layout_factory()` / `get_table_structure_factory()` in `docling/models/factories/__init__.py` |
| "How do I tune OCR, layout, or tables?" | `PdfPipelineOptions` and `TableStructureOptions` in `docling/datamodel/pipeline_options.py` |
| "Where does the output schema live?" | `DoclingDocument` in the `docling-core` package (external); exports like `export_to_markdown()` live there |

---

## 7 — Known Gotchas

### Pipeline options are cache keys — never mutate them in place

**Rule:** Treat `pipeline_options` as immutable once a `DocumentConverter` is
constructed. Pipeline code that needs a variant must copy first — see
`StandardPdfPipeline._init_models()`, which `model_copy()`s the code/formula
options "to avoid mutating pipeline_options in-place, which would change its
hash and break pipeline caching (#3109)".
**Why:** `DocumentConverter._get_pipeline()` keys its pipeline cache on
`_get_pipeline_options_hash()`, an MD5 of `pipeline_options.model_dump()`.
**What breaks:** Mutating options either silently reuses a stale cached
pipeline (new settings ignored) or changes the hash of a live pipeline's
options, corrupting cache lookups.

### `StandardPdfPipeline` *is* the threaded pipeline

**Rule:** Do not look for a serialized "standard" PDF pipeline in current
source. `pipeline/threaded_standard_pdf_pipeline.py` is a five-line
backwards-compat subclass; the old serialized implementation lives on as
`LegacyStandardPdfPipeline` in `pipeline/legacy_standard_pdf_pipeline.py`.
**Why:** `StandardPdfPipeline._build_document()` runs preprocess/OCR/layout/
table/assemble as `ThreadedPipelineStage` workers connected by bounded
`ThreadedQueue`s, with per-`execute` run isolation.
**What breaks:** Models and backends added to the PDF path must be safe to
invoke from worker threads; assuming serial stage execution leads to races
and heisenbugs.

### pypdfium2 is not thread-safe — all access goes through a global lock

**Rule:** Any code that calls into pdfium must hold `pypdfium2_lock` from
`docling.utils.locks`. Both `PyPdfiumDocumentBackend` and
`DoclingParseDocumentBackend` wrap every pdfium call in
`with pypdfium2_lock:`.
**Why:** The native pdfium library cannot be used concurrently.
**What breaks:** Calling pdfium APIs outside the lock under the threaded
pipeline causes crashes or corrupted page parsing.

### OCR and TableFormer are ON by default

**Rule:** `PdfPipelineOptions` defaults to `do_ocr=True`,
`do_table_structure=True`, `TableStructureOptions.mode=TableFormerMode.ACCURATE`,
`do_cell_matching=True`, and `ocr_options=OcrAutoOptions()` (auto-selects
whatever engine is installed). Disable features you don't need rather than
discovering the cost later.
**Why:** Defaults optimize for output quality, not speed.
**What breaks:** First conversions are unexpectedly slow and trigger large
model downloads. Separately, the comment on
`TableStructureV2Options.do_cell_matching` warns that cell matching "can break
table output if PDF cells are merged across table columns" — a silent quality
regression, not an exception.

### Page resources are released after the build stage unless explicitly kept

**Rule:** After conversion, `Page.parsed_page`, `Page._backend`, and
`Page._image_cache` are cleared unless `generate_parsed_pages`,
`generate_page_images`, or an enrichment flag keeps them alive — see
`StandardPdfPipeline._release_page_resources()` and `_integrate_results()`.
**Why:** Backends hold open native documents and page images are large; the
pipeline frees them to bound memory.
**What breaks:** Post-conversion code that reaches into `conv_res.pages` for
backends, images, or parsed pages gets `None` instead of data.

### Cross-document threading is experimental — don't raise it blindly

**Rule:** `settings.perf.doc_batch_concurrency` defaults to 1; its own comment
warns "No benefit expected without free-threaded python."
**Why:** The GIL plus native model contention means threads don't parallelize
on standard CPython.
**What breaks:** Raising `doc_batch_concurrency` (and `doc_batch_size`) on
regular CPython adds thread overhead and multiplies model memory usage with no
throughput gain.
