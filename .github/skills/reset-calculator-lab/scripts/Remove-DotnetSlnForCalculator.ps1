#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Preserves and removes the generated calculator solution workspace.
.DESCRIPTION
    Copies calculator-xunit-testing to the existing completed folder when that
    folder is empty, verifies the preserved copy, and then deletes the workspace
    copy and verification report so the setup workflow can be rerun cleanly.
    If deletion is interrupted after preservation, a later run validates the
    preserved solution and resumes deletion without creating a second copy.
.EXAMPLE
    ./Remove-DotnetSlnForCalculator.ps1 -WhatIf
.EXAMPLE
    ./Remove-DotnetSlnForCalculator.ps1 -Confirm
.EXAMPLE
    ./Remove-DotnetSlnForCalculator.ps1 -CommitAndPush -Confirm
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 5)]
    [int]$MaxRemovalAttempts = 3,

    [Parameter(Mandatory = $false)]
    [switch]$CommitAndPush
)

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

function Test-PreservedSolution {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PreservedSolutionRoot
    )

    $RequiredPaths = @(
        'calculator.slnx',
        'calculator/calculator.csproj',
        'calculator.library/calculator.library.csproj',
        'calculator.tests/calculator.tests.csproj',
        'calculator.web/calculator.web.csproj'
    )

    $MissingPaths = @(
        foreach ($RequiredPath in $RequiredPaths) {
            $RequiredFilePath = Join-Path -Path $PreservedSolutionRoot -ChildPath $RequiredPath
            if (-not (Test-Path -Path $RequiredFilePath -PathType Leaf)) {
                $RequiredPath
            }
        }
    )

    return $MissingPaths.Count -eq 0
}

function Remove-SolutionWorkspace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SolutionRoot,

        [Parameter(Mandatory = $true)]
        [string]$PreservedSolutionRoot,

        [Parameter(Mandatory = $true)]
        [int]$MaxAttempts
    )

    for ($Attempt = 1; $Attempt -le $MaxAttempts; $Attempt++) {
        try {
            Remove-Item -Path $SolutionRoot -Recurse -Force
            Write-Status "Removed solution workspace: $SolutionRoot" 'Success'
            return
        }
        catch {
            if ($Attempt -eq $MaxAttempts) {
                throw "Unable to remove the workspace after $MaxAttempts attempts. Close any calculator run, debugger, or process holding '$SolutionRoot', then rerun this script. The preserved solution remains at '$PreservedSolutionRoot'."
            }

            Write-Status "Workspace removal attempt $Attempt of $MaxAttempts failed. Retrying." 'Info'
        }
    }
}

function Invoke-CleanupCommitAndPush {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRoot,

        [Parameter(Mandatory = $true)]
        [string[]]$CleanupPaths
    )

    Push-Location -Path $RepoRoot
    try {
        & git diff --cached --quiet
        if ($LASTEXITCODE -ne 0) {
            throw 'Refusing to commit because staged changes already exist. Review or unstage them before publishing cleanup deletions.'
        }

        $TrackedCleanupPaths = @(
            foreach ($CleanupPath in $CleanupPaths) {
                $TrackedFiles = @(& git ls-files -- $CleanupPath)
                if ($LASTEXITCODE -ne 0) {
                    throw "Unable to inspect tracked cleanup path: $CleanupPath"
                }

                if ($TrackedFiles.Count -gt 0) {
                    $CleanupPath
                }
            }
        )

        if ($TrackedCleanupPaths.Count -eq 0) {
            Write-Status 'No tracked cleanup paths require a commit.' 'Info'
            return
        }

        & git add --update -- $TrackedCleanupPaths
        if ($LASTEXITCODE -ne 0) {
            throw 'Unable to stage the cleanup deletions.'
        }

        & git diff --cached --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Status 'No cleanup deletions require a commit.' 'Info'
            return
        }

        $BranchName = (& git branch --show-current).Trim()
        if ([string]::IsNullOrWhiteSpace($BranchName)) {
            throw 'Unable to push cleanup changes because the repository is in a detached HEAD state.'
        }

        $OriginUrl = (& git remote get-url origin).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($OriginUrl)) {
            throw 'Unable to push cleanup changes because the origin remote is not configured.'
        }

        & git commit -m 'cleanup: remove generated calculator workspace'
        if ($LASTEXITCODE -ne 0) {
            throw 'Unable to create the cleanup commit.'
        }

        & git push origin $BranchName
        if ($LASTEXITCODE -ne 0) {
            throw "Cleanup commit was created locally but could not be pushed to origin/$BranchName."
        }

        Write-Status "Committed and pushed cleanup deletions to origin/$BranchName." 'Success'
    }
    finally {
        Pop-Location
    }
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

            if (Test-Path -Path $PreservedSolutionRoot -PathType Container) {
                if (-not (Test-PreservedSolution -PreservedSolutionRoot $PreservedSolutionRoot)) {
                    throw "Existing preserved solution is incomplete and cannot be used to resume cleanup: $PreservedSolutionRoot"
                }

                Write-Status "Found a verified preserved solution. Resuming workspace removal." 'Info'
            }
            else {
                $CompletedContent = Get-ChildItem -Path $CompletedRoot -Force | Select-Object -First 1
                if ($null -ne $CompletedContent) {
                    throw "Completed folder must be empty before preservation: $CompletedRoot"
                }

                $Action = 'Preserve the solution before removing the workspace copy'
                if ($PSCmdlet.ShouldProcess($SolutionRoot, $Action)) {
                    Copy-Item -Path $SolutionRoot -Destination $CompletedRoot -Recurse -Force
                    if (-not (Test-PreservedSolution -PreservedSolutionRoot $PreservedSolutionRoot)) {
                        throw "Preserved solution could not be verified: $PreservedSolutionRoot"
                    }

                    Write-Status "Preserved solution workspace at: $PreservedSolutionRoot" 'Success'
                }
            }

            if ((Test-Path -Path $PreservedSolutionRoot -PathType Container) -and $PSCmdlet.ShouldProcess($SolutionRoot, 'Remove the verified workspace copy')) {
                Remove-SolutionWorkspace -SolutionRoot $SolutionRoot -PreservedSolutionRoot $PreservedSolutionRoot -MaxAttempts $MaxRemovalAttempts
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

        if ($CommitAndPush) {
            $CleanupPaths = @(
                'src/workspace/calculator-xunit-testing',
                'SOLUTION_SETUP_VERIFICATION.md'
            )

            if ($PSCmdlet.ShouldProcess($RepoRoot, 'Commit and push tracked calculator workspace cleanup deletions')) {
                Invoke-CleanupCommitAndPush -RepoRoot $RepoRoot -CleanupPaths $CleanupPaths
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
