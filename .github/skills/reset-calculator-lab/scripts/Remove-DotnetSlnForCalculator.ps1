#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Preserves and removes the generated calculator solution workspace.
.DESCRIPTION
    Copies calculator-xunit-testing to the existing completed folder when that
    folder is empty, verifies the preserved copy, and then deletes the workspace
    copy and verification report so the setup workflow can be rerun cleanly.
.EXAMPLE
    ./Remove-DotnetSlnForCalculator.ps1 -WhatIf
.EXAMPLE
    ./Remove-DotnetSlnForCalculator.ps1 -Confirm
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Functions
function Write-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Error')]
        [string]$Kind = 'Info'
    )

    $Color = switch ($Kind) {
        'Success' { 'Green' }
        'Error' { 'Red' }
        default { 'Cyan' }
    }

    Write-Host "[$Kind] $Message" -ForegroundColor $Color
}

function Get-RepositoryRoot {
    [CmdletBinding()]
    param()

    $RepoRoot = & git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($RepoRoot)) {
        throw 'Unable to determine repository root. Run this script from inside a Git repository.'
    }

    return $RepoRoot.Trim()
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $RepoRoot = Get-RepositoryRoot
        $WorkspacePath = Join-Path -Path $RepoRoot -ChildPath 'src' | Join-Path -ChildPath 'workspace'
        $SolutionRoot = Join-Path -Path $WorkspacePath -ChildPath 'calculator-xunit-testing'
        $CompletedRoot = Join-Path -Path $RepoRoot -ChildPath 'src' | Join-Path -ChildPath 'completed'
        $PreservedSolutionRoot = Join-Path -Path $CompletedRoot -ChildPath 'calculator-xunit-testing'
        $VerificationReport = Join-Path -Path $RepoRoot -ChildPath 'SOLUTION_SETUP_VERIFICATION.md'

        if (Test-Path -Path $SolutionRoot) {
            if (-not (Test-Path -Path $CompletedRoot -PathType Container)) {
                throw "Expected completed folder was not found: $CompletedRoot"
            }

            $CompletedContent = Get-ChildItem -Path $CompletedRoot -Force | Select-Object -First 1
            if ($null -ne $CompletedContent) {
                throw "Completed folder must be empty before preservation: $CompletedRoot"
            }

            $Action = 'Preserve the solution when required, then remove the workspace copy'
            if ($PSCmdlet.ShouldProcess($SolutionRoot, $Action)) {
                Copy-Item -Path $SolutionRoot -Destination $CompletedRoot -Recurse -Force
                if (-not (Test-Path -Path $PreservedSolutionRoot -PathType Container)) {
                    throw "Preserved solution could not be verified: $PreservedSolutionRoot"
                }

                Write-Status "Preserved solution workspace at: $PreservedSolutionRoot" 'Success'
                Remove-Item -Path $SolutionRoot -Recurse -Force
                Write-Status "Removed solution workspace: $SolutionRoot" 'Success'
            }
        }
        else {
            Write-Status "Nothing to remove at: $SolutionRoot" 'Info'
        }

        if (Test-Path -Path $VerificationReport) {
            if ($PSCmdlet.ShouldProcess($VerificationReport, 'Remove the setup verification report')) {
                Remove-Item -Path $VerificationReport -Force
                Write-Status "Removed verification report: $VerificationReport" 'Success'
            }
        }

        exit 0
    }
    catch {
        Write-Status $_.Exception.Message 'Error'
        exit 1
    }
}
#endregion Main Execution
