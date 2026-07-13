---
name: create-session-handoff
description: "Create a timestamped development-session handoff with Git state, completed work, remaining work, discoveries, verification commands, and a fresh-session prompt. Use when: create session handoff, save session context, prepare next-session notes, create a development checkpoint, resume work in a new Copilot session."
argument-hint: "[completion-summary=...] [remaining-work=...]"
---

# Create Session Handoff

Use this skill at a session boundary, such as a context limit, break, or
completed task. It creates a concise Markdown record that lets the next person
or Copilot session resume without rediscovering the repository state.

## What The Learner Creates

The generated handoff includes:

* Current Git branch, working-tree status, and recent commits
* Completed work and remaining work supplied by the learner
* Important discoveries and verification commands
* A fresh-session prompt that directs the next session to read the handoff

The script writes a handoff file only. It does not stage, commit, push, stash,
or discard Git changes.

## Prerequisites

* PowerShell 7 or later
* Git repository available from the working directory
* A concise summary of completed work and any remaining work

## Quick Start

Run from the repository root:

```powershell
pwsh .github/skills/create-session-handoff/scripts/New-SessionHandoff.ps1 `
  -CompletionSummary 'Removed continuous learning from Exercise 99.08.' `
  -RemainingWork 'Review the capstone exercise and commit the documentation change.' `
  -KeyDiscovery 'Memory MCP stores durable project decisions in .memory/memory.json.' `
  -VerificationCommand 'git diff --check'
```

The script prints the path of a timestamped file under
`artifacts/session-handoffs/`. It checks that path first and creates it when
missing. File names use `session-handoff-YYYYMMDD-HHmm.md`; a second handoff in
the same minute receives a numeric suffix such as `-02` rather than overwriting
the first file. Review the handoff before ending the session.

## Checkpoints

A handoff preserves context. A checkpoint preserves the repository state with
an intentional Git commit. Create a checkpoint only after reviewing `git
status --short` and the generated handoff:

```powershell
git add -A
git commit -m "checkpoint: session handoff $(Get-Date -Format "yyyy-MM-dd HH:mm")"
```

`HH` uses the 24-hour clock, so the timestamp ranges from `00:00` through
`23:59`.

## Required Procedure

1. Summarize what you completed in plain language.
2. List the next concrete task or state that no work remains.
3. Record discoveries that would otherwise need rediscovery.
4. Include the commands that validate the completed work.
5. Run the script and review the generated Markdown file.
6. Create a Git checkpoint only when you intend to commit the current changes.
7. In the next session, open the handoff and follow its fresh-session prompt.

## Parameters

| Parameter | Purpose |
| --- | --- |
| `RepoRoot` | Repository root to inspect. Defaults to the current Git repository. |
| `OutputPath` | Handoff file path. Defaults to `artifacts/session-handoffs/` with a timestamped file name. |
| `CompletionSummary` | Work completed during the session. |
| `RemainingWork` | Tasks that still need attention. |
| `KeyDiscovery` | Decisions, risks, or facts worth preserving. |
| `VerificationCommand` | Commands to run when continuing the work. |

## Troubleshooting

### Git state cannot be collected

Run the script from inside a Git repository or provide `-RepoRoot` with the
repository path. The script stops rather than create a handoff with misleading
Git information.

### The handoff needs project-specific detail

Pass repeated `-KeyDiscovery`, `-RemainingWork`, or `-VerificationCommand`
values. The script writes each value as a separate Markdown list item.

## Attribution

This skill packages the session handoff and checkpoint workflow introduced in
Exercise 99.08.