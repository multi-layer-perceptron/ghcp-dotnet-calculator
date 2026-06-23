---
title: Doc-Ops Work Plan Research
status: complete
date: 2026-06-22
---

## Research Topic

Create a prioritized work plan from discovered Markdown and documentation issues for `.github/**/*.md` and top-level repository Markdown files.

## Evidence Reviewed

* `.copilot-tracking/doc-ops/2026-06-22-session.md`
* Markdown conventions from `markdown.instructions.md`
* Writing style conventions from `writing-style.instructions.md`

## Key Discoveries

* Accuracy discrepancies are highest priority because active `.github` guidance and root docs describe repository paths and folders that do not exist in the current flattened workspace.
* The main stale path pattern is the old `programming/dotnet/csharp/workspace/calculator-xunit-testing/` hierarchy, which should be reconciled with `src/workspace/calculator-xunit-testing/`.
* Frontmatter and structure fixes are safe for existing files when they add required metadata or normalize headings without renaming files or inventing missing docs.
* Mechanical Markdown formatting issues are numerous but lower risk after accuracy and metadata fixes, especially for active `.github/instructions`, `.github/prompts`, `.github/agents`, and `.github/skills`.
* `.github/proposed/**` remains in formatting scope but should be lower priority than active guidance.

## Output

The complete numbered work plan was written to the `Work Plan` section of `.copilot-tracking/doc-ops/2026-06-22-session.md`.

## Clarifying Questions

None for this planning phase.