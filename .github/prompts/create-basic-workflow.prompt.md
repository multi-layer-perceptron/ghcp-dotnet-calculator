---
description: Create a basic workflow using GitHub Actions and Azure DevOps.

name: create-basic-workflow

tools:
  [
    "vscode",

    "execute/testFailure",

    "execute/getTerminalOutput",

    "execute/runInTerminal",

    "execute/runTests",

    "read/problems",

    "read/readFile",

    "read/terminalSelection",

    "read/terminalLastCommand",

    "edit",

    "search",

    "web",

    "azure-mcp/search",
  ]

model: Claude Haiku 4.5 (copilot)
---

\n\nCreate Basic Workflow

\n\nOverview

This prompt guides the creation of a basic CI/CD workflow. The workflow has two jobs. In the first job it will list the contents of this repo and upload the results as an artifact. In the second job it will download the artifact and display the results along with some workflow metadata.

\n\nDetails

The workflow should demonstrate essential GitHub Actions capabilities with the following specifications and the file must be named: `01-level-workflow.yml`

\n\nWorkflow Triggers

\n\nPush to main branch (excluding .github directory changes)
\n\nPull requests targeting main branch
\n\nScheduled execution (daily at midnight UTC)
\n\nManual dispatch via GitHub UI

\n\nJob 1: list-contents

**Purpose:** Display repository structure and contents

# Steps

\n\nDisplay workflow trigger information (event name, branch, repository, actor)
\n\nCheck out repository code using actions/checkout@v4
\n\nList repository contents using tree command (depth 3, with sizes)
\n\nList src directory contents recursively using PowerShell with:

\n\nDirectory/file type indicators
\n\nFile sizes in KB
\n\nColor-coded output (Yellow for directories, Green for files)
\n\nIndentation based on directory depth
\n\nGraceful handling if src directory doesn't exist

\n\nJob 2: retrieve-values

**Purpose:** Display workflow metadata and context

**Dependencies:** Must run after list-contents job completes

## Steps

\n\nDisplay comprehensive branch information including:

\n\nBranch name (github.ref_name)
\n\nFull ref (github.ref)
\n\nHead ref for pull requests (github.head_ref)
\n\nBase ref for pull requests (github.base_ref)
\n\nDefault branch (github.event.repository.default_branch)

\n\nTechnical Requirements

\n\nRunner: ubuntu-latest for both jobs
\n\nPowerShell Core (pwsh) for cross-platform scripting
\n\nProper formatting with section dividers (==========)
\n\nColor-coded console output for better readability
\n\nDescriptive job and step names for clarity

\n\nPath Resolution

All paths in this document are relative to the git repository root, which can be obtained using:

```pwsh

$repoRoot = git rev-parse --show-toplevel

```text
\n\nOutput Location

.github/workflows/01-level-workflow.yml

## Prompt Requirements Summary

Create a GitHub Actions workflow that automates repository content listing and workflow metadata reporting with the following requirements:

\n\nMultiple trigger types (push, PR, schedule, manual)
\n\nRepository content listing using tree command
\n\nDirectory-specific listing using PowerShell
\n\nWorkflow metadata reporting
\n\nJob dependencies and sequencing

## Response

Created comprehensive workflow with two jobs: list-contents and retrieve-values.

## PRD Location

```text
pwsh
\n\nRelative path

cicd/prd-01-level-workspace.md

\n\nFull path resolution

$repoRoot = git rev-parse --show-toplevel

Join-Path -Path $repoRoot -ChildPath "cicd/prd-01-level-workspace.md"

```text
\n\nRelated Documentation

\n\n[GitHub Actions Documentation](https://docs.github.com/en/actions)

\n
