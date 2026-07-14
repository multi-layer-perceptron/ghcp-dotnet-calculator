---
name: community-health-files
description: "Assess, create, update, and validate GitHub community health files for public educational lab repositories. Use when: add community health files, create code of conduct, contributing guide, security policy, support policy, issue forms, pull request template, Discussions guidance, participation terms requirements, repository governance, community standards, prepare a learning repository for public adoption."
argument-hint: "[mode={assess|generate|refresh|validate}] [profile=educational-lab]"
---

# Community Health Files

Build a coherent, repository-specific educational community experience without inventing
support commitments, enforcement contacts, or legal approval. The workflow
classifies the repository, interviews maintainers, presents a file-by-file
plan, and writes only approved artifacts.

## Prerequisites

* A Git repository with a reviewable README and license
* Maintainer approval for every file to create or update
* A GitHub-hosted or monitored private conduct-reporting route before finalizing a code of conduct
* A GitHub-hosted or monitored private vulnerability-reporting route before finalizing a security policy
* Qualified legal review before adopting custom participation or usage terms

## Quick Start

Ask Copilot:

```text
Use the community-health-files skill to assess this public educational lab,
recommend community files, and present a plan before editing anything.
```

Or run `/create-community-health-files` for the explicit workflow launcher.

## Required Procedure

1. Read [repository assessment](./references/repository-assessment.md) and
   classify the repository before recommending files.
2. Inventory existing community files, issue forms, pull request templates,
   Discussions guidance, README links, license terms, and security reporting.
3. Collect the maintainer decisions required by the assessment. Never infer a
   private reporting contact, support response time, contributor agreement, or
   legal jurisdiction.
4. Read [policy boundaries](./references/policy-boundaries.md) before drafting
   conduct, security, support, licensing, or participation language.
5. Present a file-by-file plan listing purpose, source, customization, risk,
   and validation. Obtain explicit approval before creating or replacing files.
6. Generate only approved artifacts from `./assets/`. Adapt examples to the
   repository's audience, contribution model, technology, and validation commands.
7. For `CODE_OF_CONDUCT.md`, fetch the latest stable official Contributor
   Covenant Markdown source at generation time, replace all official template
   notes, configure the approved private reporting method, and preserve visible
   source, version, steward, and license attribution.
8. Keep legal requirements separate from operative terms. Generate a
   requirements brief unless the user explicitly requests a draft, and label
   every draft non-operative pending qualified legal review.
9. Add concise README routing links without duplicating whole policies.
10. Run [validation](./references/validation.md), report unresolved decisions,
    and stop short of commit, push, repository settings changes, or Discussion
    creation unless those actions receive separate approval.

## Modes

| Mode | Result |
| --- | --- |
| `assess` | Inventory, classification, gaps, questions, and proposed plan; no edits |
| `generate` | Create approved missing artifacts and README links |
| `refresh` | Compare existing files with current policy and upstream sources before proposing updates |
| `validate` | Check structure, placeholders, contacts, links, issue forms, attribution, and policy consistency |

## Educational Lab Profile

Recommend these artifacts unless repository evidence or maintainer choices
justify a different set:

* `CODE_OF_CONDUCT.md` based on the current Contributor Covenant
* `CONTRIBUTING.md` for focused pull requests and prior discussion of broad changes
* `SECURITY.md` for private vulnerability intake without a support promise
* `SUPPORT.md` routing questions to Discussions and defects to Issues
* `.github/ISSUE_TEMPLATE/` forms for bugs, lab documentation, features, and configuration help
* `.github/pull_request_template.md` for rationale, validation, learner impact,
  security, cost, and cleanup effects
* `DISCUSSIONS_SETUP.md` for maintainer-configured categories and routing
* A participation-terms requirements brief when legal terms are under consideration

The assets are portable across educational lab repositories through metadata
inputs and repository-specific adaptation. Assess non-lab repositories before
use and do not present this package as a complete governance profile for a
general open-source product or private enterprise repository.

## Safety Boundaries

* Do not claim a policy has legal approval, creates an SLA, or guarantees support.
* Do not publish an unmonitored email address or public issue as a private reporting path.
* Do not request vulnerability details, credentials, personal data, or conduct reports in public issues or Discussions.
* Do not alter `LICENSE` or add contributor-assignment requirements without explicit maintainer and legal approval.
* Do not overwrite customized community files merely because a newer template exists.
* Do not create labels, enable Discussions, change repository settings, commit,
  or push as an implicit side effect of file generation.

## Resources

* [Repository assessment](./references/repository-assessment.md)
* [Policy boundaries](./references/policy-boundaries.md)
* [Validation](./references/validation.md)
* [Portable templates](./assets/)

## Troubleshooting

### A private reporting route is missing

Generate a plan or visibly marked draft only. Validation must fail until an
approved GitHub-hosted or monitored private route replaces the marker.

### Existing files conflict with the selected profile

Preserve the existing files, summarize the conflict, and propose a focused
diff. Maintainer intent takes precedence over generic template defaults.

### The latest Contributor Covenant changed

Report the source version, licensing, template notes, and substantive changes.
Do not silently replace an adopted code of conduct.

## Attribution

This skill follows GitHub community-health file conventions and uses official
upstream templates only with their required attribution and licensing terms.
