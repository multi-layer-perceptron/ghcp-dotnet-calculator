#!/usr/bin/env pwsh
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#Requires -Version 7.0

<#!
.SYNOPSIS
    Creates a Markdown handoff document for the next development session.
.DESCRIPTION
    Captures the current Git branch, working-tree status, recent commits, and
    learner-provided session details. The script writes a handoff document but
    never stages, commits, stashes, pushes, or discards Git changes.
.PARAMETER RepoRoot
    Repository root to inspect. Defaults to the current Git repository.
.PARAMETER OutputPath
    Destination path for the generated Markdown handoff.
.PARAMETER CompletionSummary
    Summary of work completed in the current session.
.PARAMETER RemainingWork
    Tasks that remain after the current session.
.PARAMETER KeyDiscovery
    Decisions, risks, or facts that a future session should know.
.PARAMETER VerificationCommand
    Commands that verify the completed work.
.EXAMPLE
    ./New-SessionHandoff.ps1 -CompletionSummary 'Updated session documentation.'
.NOTES
    The generated handoff is written under artifacts/session-handoffs by default.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RepoRoot,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [string]$CompletionSummary = 'No completion summary was supplied.',

    [Parameter(Mandatory = $false)]
    [string[]]$RemainingWork = @('No remaining work was supplied.'),

    [Parameter(Mandatory = $false)]
    [string[]]$KeyDiscovery = @('No additional discoveries were supplied.'),

    [Parameter(Mandatory = $false)]
    [string[]]$VerificationCommand = @('Review git status --short and run the relevant focused validation.')
)

$ErrorActionPreference = 'Stop'

#region Functions
function Get-RepositoryRoot
{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$RequestedRoot
    )

    $CandidateRoot = if ([string]::IsNullOrWhiteSpace($RequestedRoot)) { (Get-Location).Path } else { $RequestedRoot }
    $GitRoot = & git -C $CandidateRoot rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($GitRoot))
    {
        throw "Unable to locate a Git repository from: $CandidateRoot"
    }

    return (Resolve-Path -Path $GitRoot.Trim()).Path
}

function Get-GitOutput
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $Output = & git -C $RepositoryRoot @Arguments 2>&1
    if ($LASTEXITCODE -ne 0)
    {
        throw "Git command failed: git $($Arguments -join ' ')`n$($Output -join [Environment]::NewLine)"
    }

    return @($Output)
}

function ConvertTo-MarkdownList
{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Items
    )

    return (($Items | ForEach-Object { "* $_" }) -join [Environment]::NewLine)
}

function Initialize-HandoffDirectory
{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $HandoffDirectory = Join-Path -Path $RepositoryRoot -ChildPath 'artifacts/session-handoffs'
    if (Test-Path -Path $HandoffDirectory -PathType Leaf)
    {
        throw "The handoff directory path is a file: $HandoffDirectory"
    }

    if (-not (Test-Path -Path $HandoffDirectory -PathType Container))
    {
        New-Item -ItemType Directory -Path $HandoffDirectory -ErrorAction Stop | Out-Null
        Write-Host "Created handoff directory: $HandoffDirectory" -ForegroundColor Green
    }

    return (Resolve-Path -Path $HandoffDirectory).Path
}

function Get-AvailableHandoffPath
{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$HandoffDirectory
    )

    $Timestamp = Get-Date -Format 'yyyyMMdd-HHmm'
    $CandidatePath = Join-Path -Path $HandoffDirectory -ChildPath "session-handoff-$Timestamp.md"
    $Sequence = 2
    while (Test-Path -Path $CandidatePath)
    {
        $CandidatePath = Join-Path -Path $HandoffDirectory -ChildPath ("session-handoff-$Timestamp-{0:D2}.md" -f $Sequence)
        $Sequence++
    }

    return $CandidatePath
}

function New-SessionHandoffDocument
{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$CompletionSummary,

        [Parameter(Mandatory = $true)]
        [string[]]$RemainingWork,

        [Parameter(Mandatory = $true)]
        [string[]]$KeyDiscovery,

        [Parameter(Mandatory = $true)]
        [string[]]$VerificationCommand
    )

    $Branch = (Get-GitOutput -RepositoryRoot $RepositoryRoot -Arguments @('branch', '--show-current')) -join [Environment]::NewLine
    $Status = (Get-GitOutput -RepositoryRoot $RepositoryRoot -Arguments @('status', '--short')) -join [Environment]::NewLine
    $RecentCommits = (Get-GitOutput -RepositoryRoot $RepositoryRoot -Arguments @('log', '--oneline', '-5')) -join [Environment]::NewLine
    $Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
    $StatusText = if ([string]::IsNullOrWhiteSpace($Status)) { 'Working tree clean.' } else { $Status }

    return @"
---
title: Session Handoff
description: Development-session context for the next contributor or Copilot session
created: $Timestamp
---

## Session Summary

$CompletionSummary

## Repository State

* Branch: ``$Branch``
* Captured: ``$Timestamp``

### Working Tree

```text
$StatusText
```

### Recent Commits

```text
$RecentCommits
```

## Remaining Work

$(ConvertTo-MarkdownList -Items $RemainingWork)

## Key Discoveries And Decisions

$(ConvertTo-MarkdownList -Items $KeyDiscovery)

## Verification Commands

```powershell
$($VerificationCommand -join [Environment]::NewLine)
```

## Fresh-Session Prompt

```text
Read this session handoff first. Confirm the current Git status, run the listed
verification commands, then continue the remaining work. Preserve unrelated
changes and report any difference between this handoff and the current state.
```
"@
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.')
{
    try
    {
        $ResolvedRepoRoot = Get-RepositoryRoot -RequestedRoot $RepoRoot
        if ([string]::IsNullOrWhiteSpace($OutputPath))
        {
            $HandoffDirectory = Initialize-HandoffDirectory -RepositoryRoot $ResolvedRepoRoot
            $OutputPath = Get-AvailableHandoffPath -HandoffDirectory $HandoffDirectory
        }

        $ResolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
        $OutputDirectory = Split-Path -Path $ResolvedOutputPath -Parent
        if (Test-Path -Path $OutputDirectory -PathType Leaf)
        {
            throw "The output directory path is a file: $OutputDirectory"
        }

        if (-not (Test-Path -Path $OutputDirectory -PathType Container))
        {
            New-Item -ItemType Directory -Path $OutputDirectory -ErrorAction Stop | Out-Null
        }

        $Document = New-SessionHandoffDocument -RepositoryRoot $ResolvedRepoRoot -CompletionSummary $CompletionSummary -RemainingWork $RemainingWork -KeyDiscovery $KeyDiscovery -VerificationCommand $VerificationCommand
        Set-Content -Path $ResolvedOutputPath -Value $Document -Encoding utf8
        Write-Host "Created session handoff: $ResolvedOutputPath" -ForegroundColor Green
        exit 0
    }
    catch
    {
        Write-Error -ErrorAction Continue "New-SessionHandoff failed: $($_.Exception.Message)"
        exit 1
    }
}
#endregion Main Execution