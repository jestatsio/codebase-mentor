# Example ONBOARDING.md Files

Example maps captured at authoring time. Use the closest shape as a model, then verify all anchors against the source version you actually use. The Stargate example includes a deliberately stale claim for the demo, labeled in that document.

| Example | Codebase shape | File |
|---|---|---|
| **Stargate Data API** | Java request/response service: 39 command resolvers, five-layer pipeline, custom task-retry framework. The original reference implementation. | [`onboarding/stargate-jsonapi/ONBOARDING.md`](https://github.com/jestatsio/codebase-mentor/blob/main/onboarding/stargate-jsonapi/ONBOARDING.md) |
| **AstraPy** | Python client library: layered client objects, sync/async duality, API options resolution. | [`onboarding/astrapy/ONBOARDING.md`](https://github.com/jestatsio/codebase-mentor/blob/main/onboarding/astrapy/ONBOARDING.md) |
| **Langflow** | Python/React visual workflow builder: component graph execution, frontend/backend split. | [`onboarding/langflow/ONBOARDING.md`](https://github.com/jestatsio/codebase-mentor/blob/main/onboarding/langflow/ONBOARDING.md) |
| **Docling** | Python document-conversion library with format-specific pipelines. | [`onboarding/docling/ONBOARDING.md`](https://github.com/jestatsio/codebase-mentor/blob/main/onboarding/docling/ONBOARDING.md) |
| **This repo** | Skills, distribution scripts, and an optional TypeScript MCP server. | [`ONBOARDING.md`](https://github.com/jestatsio/codebase-mentor/blob/main/ONBOARDING.md) |

Every example follows the same seven sections: purpose, layer map, execution lifecycle, domain vocabulary, change recipes, high-signal files, known gotchas — all anchored to class and method names, never line numbers.

**Have one to share?** Submit it via the [example submission issue form](https://github.com/jestatsio/codebase-mentor/issues/new/choose).
