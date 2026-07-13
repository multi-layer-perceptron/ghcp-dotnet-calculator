---
title: Community Health Repository Assessment
description: Classification questions, artifact recommendations, and approval requirements for community health generation.
---

## Classification

Record evidence for each dimension before recommending files:

| Dimension | Questions |
| --- | --- |
| Visibility | Is the repository public, internal, or private? |
| Purpose | Is it an educational lab, library, application, specification, or internal tool? |
| Audience | Are users learners, contributors, customers, employees, or maintainers? |
| Contribution model | Are focused pull requests welcome, invited, or unsupported? |
| Support model | Which channel handles questions, defects, and event-specific help? Is support best effort? |
| Security intake | Which monitored private path receives vulnerability reports? |
| Conduct enforcement | Which monitored private path receives reports, and who moderates? |
| Hosted services | Does use create cloud resources, costs, telemetry, or third-party accounts? |
| Data sensitivity | Could users submit secrets, personal data, confidential data, or regulated data? |
| Legal context | Is there an existing license, CLA, DCO, participation agreement, or counsel-approved policy? |

## Artifact Decision Matrix

| Artifact | Recommend when | Required decisions |
| --- | --- | --- |
| `CODE_OF_CONDUCT.md` | Public participation is enabled | Moderator identity, private report channel, enforcement process |
| `CONTRIBUTING.md` | Feedback or pull requests are accepted | Contribution scope, large-change process, validation, licensing expectations |
| `SECURITY.md` | The repository accepts vulnerability reports | Private contact, supported-version posture, disclosure expectations |
| `SUPPORT.md` | Users need setup or usage help | Support channels, exclusions, response commitment |
| Issue forms | Public Issues are enabled | Categories, required evidence, labels that actually exist |
| Pull request template | Pull requests are accepted | Required review evidence and contributor responsibilities |
| Discussions guide | Discussions are enabled or planned | Categories, formats, moderation, routing |
| Participation terms brief | Hosted labs or participation rules may need legal terms | Intended users, services, costs, data, moderation, legal reviewer |
| `GOVERNANCE.md` | Multiple maintainers or formal decisions require transparency | Roles, appointment, voting, escalation, succession |

## Required Interview

Ask only questions unresolved by repository evidence. At minimum resolve:

1. Primary audience and repository profile
2. Approved artifact set
3. Contribution and large-change policy
4. Private conduct-reporting contact
5. Private vulnerability-reporting contact
6. Support channels and response expectations
7. Supported-version posture
8. Discussions categories and formats
9. Issue form and pull request evidence requirements
10. Legal draft boundary and review status
11. Maintainer public identity and brand voice
12. Whether generation, repository settings, commit, and push are separately approved

When generating GitHub issue `contact_links`, resolve security and conduct
routes to public `https://` policy pages. Those policy pages provide the
approved private reporting method; GitHub does not accept `mailto:` contact-link URLs.

## Approval Plan Format

Before editing, present a table with these columns:

| Path | Purpose | Source or baseline | Repository customization | Approval or review gate |
| --- | --- | --- | --- | --- |

List README updates and repository-setting actions separately. File approval
does not imply approval to enable Discussions, create labels, commit, or push.
