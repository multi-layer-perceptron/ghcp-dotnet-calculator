---
name: reset-calculator-lab
description: "Safely orchestrate Exercise 99.09 cleanup after Exercise 99.08, including runtime resources, generated workspace preservation, Azure, Docker, Memory MCP lab data, optional Copilot state, and Git changes. Use when: reset calculator lab, clean up calculator workshop, run Exercise 99.09, full workshop cleanup, clean Memory MCP lab data, preserve completed solution, remove generated .NET solution."
argument-hint: "[reset-depth={runtime|workspace|full}]"
---

# Reset Calculator Lab

Use this skill for the final cleanup workflow after Exercise 99.08 is complete.
It separates reversible runtime cleanup from generated-workspace removal and
coordinates the focused Azure, Docker, and Memory MCP cleanup prompts without
hiding destructive actions.

## Prerequisites

* Exercise 99.08 is complete and required evidence has been saved
* Git and PowerShell 7 or later are available
* The repository contains the existing `src/completed/` folder
* The user has selected the intended reset depth
* Cloud deletion and Git restoration have separate explicit approval

## Quick Start

1. Review `git status --short` and preserve any work that must survive cleanup.
2. Ask the user to choose `runtime`, `workspace`, or `full` reset depth when the
   request does not already specify one.
3. Preview generated-workspace cleanup:

   ```powershell
   pwsh .github/skills/reset-calculator-lab/scripts/Remove-DotnetSlnForCalculator.ps1 -WhatIf
   ```

4. Describe the preview and request explicit confirmation before running the
   script without `-WhatIf`.
5. Run only the approved cleanup phases and verify their postconditions.

## Reset Depths

| Depth     | Actions |
|-----------|---------|
| `runtime` | Stop lab-owned processes and containers without deleting source, volumes, cloud resources, or Git changes |
| `workspace` | Perform runtime cleanup, preserve the generated solution in `src/completed`, and remove its workspace copy |
| `full` | Perform workspace cleanup, then coordinate separately approved Azure, Docker-data, Memory MCP, Copilot-state, and Git reset actions |

## Required Procedure

1. Establish a recoverable checkpoint with `git status --short` and saved test,
   report, screenshot, and issue evidence.
2. Confirm Exercise 99.08 is complete. Do not remove the workspace while later
   exercises still depend on it.
3. For runtime cleanup, identify only lab-owned processes and containers before
   stopping them. Do not use global process termination or Docker prune commands.
4. For workspace cleanup, inspect `src/completed/`. The bundled script requires
   that folder to exist and be empty.
5. Run the bundled script with `-WhatIf`, summarize the planned paths, and obtain
   explicit confirmation.
6. Run the script with confirmation enabled:

   ```powershell
   pwsh .github/skills/reset-calculator-lab/scripts/Remove-DotnetSlnForCalculator.ps1 -Confirm
   ```

7. For Azure cleanup, follow
   `.github/prompts/3.03-reset-azure-environment.prompt.md` and preserve its
   confirmation boundary.
8. For local PostgreSQL cleanup, follow
   `.github/prompts/3.04-reset-local-docker-pg.prompt.md` and preserve its
   named-resource checks.
9. For Exercise 99.08 Memory MCP cleanup, follow
   `.github/prompts/99.09-cleanup-memory-mcp.prompt.md`. Preview only its
   allowlisted entities, relations, and observations, then preserve its
   separate confirmation and graph-verification boundary.
10. Treat Git restoration and other Copilot learning-state deletion as
    independent destructive actions. Show the exact scope and ask for
    confirmation for each.
11. Verify every approved reset phase before reporting completion.

## Script Behavior

The bundled
[Remove-DotnetSlnForCalculator.ps1](./scripts/Remove-DotnetSlnForCalculator.ps1)
script:

* Resolves the repository root through Git
* Supports `-WhatIf` and `-Confirm`
* Requires the existing `src/completed/` folder
* Blocks cleanup when `src/completed/` is not empty
* Copies `src/workspace/calculator-xunit-testing/` to
  `src/completed/calculator-xunit-testing/`
* Verifies the preserved directory exists before deleting the workspace copy
* Removes `SOLUTION_SETUP_VERIFICATION.md` when present
* Reports a no-op when the generated workspace is already absent

## Safety Boundaries

Never run these actions without separate, explicit user approval:

* Azure resource deletion
* Docker volume or network deletion
* Global Docker prune commands
* `git reset --hard`, `git clean`, or broad `git restore` commands
* Memory MCP graph, Copilot learning-state, or customization deletion
* Workspace removal before Exercise 99.08 is complete

Do not create `src/completed/` automatically. A missing or populated destination
requires user review because cleanup cannot guarantee preservation.

## Validation

For workspace cleanup, verify:

```powershell
Test-Path src/completed/calculator-xunit-testing
Test-Path src/workspace/calculator-xunit-testing
Test-Path SOLUTION_SETUP_VERIFICATION.md
git status --short
```

The expected Boolean results are `True`, `False`, and `False`. Review the Git
status output to confirm that only intended files changed.

For an approved Memory MCP cleanup, use the focused prompt's final `read_graph`
check to prove that confirmed Exercise 99.08 targets are absent and unrelated
knowledge remains unchanged.

## Troubleshooting

### The completed folder is missing

Stop cleanup and restore the repository-provided `src/completed/` folder. Do not
create a substitute folder automatically.

### The completed folder is not empty

Stop cleanup and ask the user to archive, rename, or intentionally remove its
existing content. Rerun `-WhatIf` after the destination is empty.

### The preservation copy fails

The script exits before removing the workspace. Resolve permissions, disk space,
path length, or file-lock issues, then rerun the preview.

### The workspace is already absent

Treat the script result as an idempotent no-op. Verify any other approved reset
phases independently.

## Attribution

This repository skill packages the Exercise 99.09 cleanup workflow and its
PowerShell implementation for GitHub Copilot in VS Code.
