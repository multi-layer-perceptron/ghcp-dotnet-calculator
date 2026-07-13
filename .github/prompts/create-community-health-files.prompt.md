---
description: "Assess a repository and create or refresh approved community health files using the community-health-files skill"
agent: agent
argument-hint: "[mode={assess|generate|refresh|validate}] [profile=educational-lab]"
---

# Create Community Health Files

Use the `community-health-files` skill for the current repository.

## Inputs

- `${input:mode:assess}`: Workflow mode: `assess`, `generate`, `refresh`, or `validate`.
- `${input:profile:educational-lab}`: Educational lab profile. Confirm that it matches repository evidence.

## Requirements

1. Follow the skill's repository assessment and collect unresolved maintainer decisions.
2. Present the file-by-file plan and obtain approval before editing.
3. Generate only approved artifacts from current official sources and bundled portable templates.
4. Keep legal requirements separate from adopted policy and enforce the legal-review gate.
5. Validate contacts, placeholders, YAML, Markdown, links, attribution, and policy consistency.
6. Do not enable repository features, create labels, commit, or push without separate approval.
