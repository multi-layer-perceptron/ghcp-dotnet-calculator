---
name: match-source-repo-readme-structure
description: "Update a repository README to match a source repository README structure while preserving target-specific values. Use when: match README structure, mirror source repo README, update README from source repo, sourceRepo README template, align README format."
---

# Match Source Repo README Structure

## Purpose

Use this skill to update the current repository's `README.md` so it follows the
intent, section order, formatting patterns, and reader journey of another
repository's README while keeping every factual value tailored to the current
repository.

This is a structured documentation workflow. No bundled script is required by
default because the work depends on reading, comparing, editing, and validating
repository-specific content.

## Inputs

* `sourceRepo`: Required GitHub repository name in `OWNER/REPO` format.
* `targetReadme`: Optional target README path. Defaults to `README.md` in the
  current repository root.

## Required Workflow

### Step 1 - Fetch The Source README

Retrieve the source repository README with GitHub tooling or GitHub CLI. Use the
authenticated user's available access.

Example command when GitHub CLI is available:

```powershell
gh api repos/OWNER/REPO/readme --jq '.content' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

If the source repository has no README or access is denied, stop and report the
specific blocker.

### Step 2 - Extract The Source Structure

Identify the source README's reusable structure:

* Top-level reader promise and opening summary
* Badge, link, or metadata pattern
* Section order and heading hierarchy
* Setup and prerequisites model
* Getting-started flow
* Tutorial or walkthrough shape
* Command table style
* Project layout block style
* Diagram usage and diagram intent
* Documentation, facilitator, and license sections

Do not copy source-only values such as product names, API endpoints, ports,
domain examples, package versions, paths, images, or business data.

### Step 3 - Inventory Target Values

Read enough current repository files to replace the source values with accurate
target values. Prefer live source files over stale docs.

Check, when present:

* `README.md`
* Solution, project, package, or manifest files
* `src/`, `tests/`, `docs/`, `.github/prompts/`, `.github/skills/`, and
  `.github/workflows/`
* Setup, cleanup, validation, deployment, or migration scripts
* Repository metadata such as name, owner, license, and default branch

### Step 4 - Rewrite The Target README

Update the target README to mirror the source README's structure and reader
journey while replacing every value with target-specific content.

The updated README must:

* Keep required YAML frontmatter for this repository.
* Use valid Markdown heading order.
* Link only to files that exist in the target repository.
* Include copy-pasteable commands for this repository.
* Include diagrams only when they describe the target repository accurately.
* Preserve the target repository's actual technologies, frameworks, ports,
  paths, package names, docs, prompts, and skills.
* Avoid broad claims about incomplete or missing project surfaces.

### Step 5 - Validate

Run focused validation before completing:

1. Check editor diagnostics for `README.md`.
2. Search for source-only names or values that should not have been copied.
3. Confirm important linked local files exist.
4. Review the final diff for unintended code or configuration changes.

For .NET repositories, run build or tests only when the README change includes
new or changed commands that need verification and the environment supports it.

## Quality Bar

The work is complete when:

* The README reads like the source repo's companion document in structure and
  style.
* The README's facts are all true for the target repository.
* No source-specific values remain unless they are intentionally named as the
  source reference.
* Markdown diagnostics are clean.
* The final response lists the source repo, target README path, and validation
  performed.

## Common Mistakes

### Copying Source Values

Do not copy source app names, endpoint names, launch URLs, test project names,
or domain examples into the target README.

### Advertising Missing Features

If the target repository does not currently include an API, UI, database,
deployment path, or workflow, do not describe it as implemented.

### Overwriting Repository-Specific Frontmatter

Keep target frontmatter valid for this repository even when the source README
does not use frontmatter.

### Treating Generated Files As Source

Avoid deriving target facts from `bin/`, `obj/`, build output, cache folders, or
other generated artifacts unless no source file exists and you label the fact as
generated evidence.