#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Removes the generated calculator solution workspace.
.DESCRIPTION
    Deletes the calculator-xunit-testing directory and verification report so the
    solution setup workflow can be rerun from a clean state.
.EXAMPLE
    ./Remove-DotnetSlnForCalculator.ps1
#>

[CmdletBinding()]
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
        $VerificationReport = Join-Path -Path $RepoRoot -ChildPath 'SOLUTION_SETUP_VERIFICATION.md'

        if (Test-Path -Path $SolutionRoot) {
            Remove-Item -Path $SolutionRoot -Recurse -Force
            Write-Status "Removed solution workspace: $SolutionRoot" 'Success'
        }
        else {
            Write-Status "Nothing to remove at: $SolutionRoot" 'Info'
        }

        if (Test-Path -Path $VerificationReport) {
            Remove-Item -Path $VerificationReport -Force
            Write-Status "Removed verification report: $VerificationReport" 'Success'
        }

        exit 0
    }
    catch {
        Write-Status $_.Exception.Message 'Error'
        exit 1
    }
}
#endregion Main Execution
