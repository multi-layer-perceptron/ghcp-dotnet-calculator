---
title: GitHub Discussions Setup for {{REPOSITORY_NAME}}
description: Maintainer checklist and category design for enabling GitHub Discussions in {{REPOSITORY_NAME}}.
---

## Purpose

Use Discussions for learner questions, ideas, maintainers' announcements, and
community demonstrations. Keep reproducible defects in Issues and route security
or conduct reports to their private processes.

## Maintainer Setup

1. Enable Discussions in repository settings.
2. Create or configure the categories below.
3. Add links to {{SUPPORT_PATH}}, {{SECURITY_PATH}}, and {{CONDUCT_PATH}} in
   category descriptions where routing may be ambiguous.
4. Pin a concise welcome post that states the public-data warning and channel routing.
5. Review moderation permissions and notification ownership for {{MAINTAINER_NAME}}.

## Categories

| Category | Format | Description |
| --- | --- | --- |
| Announcements | Announcement | Maintainer updates, workshop releases, and material repository changes |
| Q&A | Question and answer | Setup, exercise, tooling, and usage questions with accepted answers |
| Ideas | Open-ended discussion | Proposals and broad changes before an issue or pull request |
| Show and tell | Open-ended discussion | Learner outcomes, adaptations, demonstrations, and lessons learned |

## Moderation And Routing

* Apply {{CODE_OF_CONDUCT_PATH}} to every Discussion category.
* Move actionable defects to a structured Issue when enough evidence exists.
* Ask broad pull request proposals to begin in Ideas.
* Remove secrets, personal data, confidential information, and vulnerability details from public view as quickly as platform permissions allow.
* Route suspected vulnerabilities to {{SECURITY_EMAIL}} and conduct reports to
  {{CONDUCT_EMAIL}} rather than investigating them publicly.

## Manual Verification

After setup, confirm that each category has the intended format, only maintainers
can create Announcements, Q&A supports accepted answers, and repository links
resolve to the adopted community files.
