---
# Shared component: OpenTelemetry observability guidance for agentic workflows.
# Imported by workflows via `imports:`. Markdown below is appended to the
# importing workflow's agent instructions at compile time.
# Authoring reference: https://github.github.io/gh-aw/reference/imports/
# Example shared components: https://github.com/githubnext/agentics
# OpenTelemetry guide for gh-aw: https://github.github.io/gh-aw/guides/open-telemetry/
---

## Observability Conventions

When reporting diagnostic results, include enough context for tracing:

* Reference the triggering workflow run ID and run URL in every output.
* Name the failed job and step exactly as they appear in the run logs.
* Include timestamps (`started_at`, `completed_at`) for failed steps when available.
