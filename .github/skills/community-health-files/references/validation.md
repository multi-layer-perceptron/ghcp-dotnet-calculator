---
title: Community Health Validation
description: Structural, policy, content, and GitHub integration checks for generated community health artifacts.
---

## Required Checks

1. Confirm every approved file exists at a GitHub-supported location.
2. Parse YAML frontmatter and every issue form or configuration file.
3. Search generated files for unresolved markers such as `TODO`, `TBD`,
   `INSERT`, `REPLACE`, `example.com`, and template notes.
4. Confirm conduct and security contacts match approved monitored private channels.
5. Confirm the code of conduct identifies its source, version, steward, and license.
6. Confirm support guidance routes questions, defects, vulnerabilities, and
   conduct reports to distinct appropriate channels.
7. Confirm contribution guidance matches the issue forms, pull request template,
   repository commands, branch policy, and license.
8. Confirm issue form identifiers are unique, required top-level keys exist,
   referenced labels are either pre-existing or documented as setup tasks, and
   blank-issue behavior matches maintainer intent.
9. Resolve every relative Markdown link and README anchor.
10. Run repository Markdown diagnostics and `git diff --check`.
11. Review the final diff for secrets, unsupported promises, accidental legal
    claims, unrelated edits, and duplicated policy text.

## Terms Requirements Brief

A requirements brief passes structural validation when it clearly states:

* It is not operative terms and is not legal advice
* Intended audience and participation surface
* Requested topics and unresolved legal questions
* Existing license and community policies that remain separate
* Required operational owners and review status
* A qualified legal-review gate before drafting or adoption

## Completion Report

Report:

* Files created and updated
* Upstream sources and versions
* Maintainer decisions applied
* Validation commands and results
* Repository settings or labels still requiring manual action
* Remaining legal, moderation, support, or security ownership risks
