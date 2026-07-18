#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Installs the commit-pinned CATES reference implementation for this track.
.DESCRIPTION
    Clones the Microsoft CATES repository at the track's verified commit, runs
    npm ci, and builds the analyzer and optimizer under cates-exercises/tools.
    Existing mismatched or incomplete checkouts are rejected, not overwritten.
.PARAMETER TrackRoot
    Optional CATES track root. Defaults to the parent of this script folder.
.EXAMPLE
    ./Install-CatesTool.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$TrackRoot = (Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $CatesCommit = 'e49da25b0bd94068419bda2a0c73fbb42c527e7e'
        $CatesRepository = 'https://github.com/microsoft/cates.git'
        $ResolvedTrackRoot = [System.IO.Path]::GetFullPath($TrackRoot)
        $ToolRoot = Join-Path -Path $ResolvedTrackRoot -ChildPath 'tools/cates'
        $ToolParent = Split-Path -Path $ToolRoot -Parent
        $StagingRoot = Join-Path -Path $ToolParent -ChildPath ('.cates-install-{0}' -f [guid]::NewGuid().ToString('N'))
        $AnalyzerEntry = Join-Path -Path $ToolRoot -ChildPath 'dist/cli/index.js'
        $OptimizerEntry = Join-Path -Path $ToolRoot -ChildPath 'dist/optimizer/cli.js'

        foreach ($CommandName in @('git', 'node', 'npm')) {
            if ($null -eq (Get-Command -Name $CommandName -ErrorAction SilentlyContinue)) {
                throw "Required command was not found: $CommandName"
            }
        }

        if (Test-Path -Path $ToolRoot -PathType Container) {
            Push-Location -Path $ToolRoot
            try {
                $ExistingCommit = (& git rev-parse HEAD 2>$null).Trim()
            }
            finally {
                Pop-Location
            }

            if ($ExistingCommit -ne $CatesCommit) {
                throw "Existing CATES checkout is not the required commit. Archive or remove it before reinstalling: $ToolRoot"
            }

            if ((Test-Path -Path $AnalyzerEntry -PathType Leaf) -and
                (Test-Path -Path $OptimizerEntry -PathType Leaf)) {
                Write-Host "[Success] CATES tool is already built at commit $CatesCommit." -ForegroundColor Green
                exit 0
            }

            throw "Existing CATES checkout is incomplete. Archive or remove it before reinstalling: $ToolRoot"
        }

        New-Item -Path $ToolParent -ItemType Directory -Force | Out-Null
        & git clone --filter=blob:none --no-checkout $CatesRepository $StagingRoot
        if ($LASTEXITCODE -ne 0) {
            throw 'Unable to clone the CATES reference implementation.'
        }

        Push-Location -Path $StagingRoot
        try {
            & git checkout --detach $CatesCommit
            if ($LASTEXITCODE -ne 0) {
                throw "Unable to check out CATES commit $CatesCommit."
            }

            & npm ci --ignore-scripts
            if ($LASTEXITCODE -ne 0) {
                throw 'Unable to restore CATES npm dependencies.'
            }

            & npm exec -- tsc
            if ($LASTEXITCODE -ne 0) {
                throw 'Unable to build the CATES analyzer and optimizer.'
            }
        }
        finally {
            Pop-Location
        }

        $StagedAnalyzerEntry = Join-Path -Path $StagingRoot -ChildPath 'dist/cli/index.js'
        $StagedOptimizerEntry = Join-Path -Path $StagingRoot -ChildPath 'dist/optimizer/cli.js'
        if (-not (Test-Path -Path $StagedAnalyzerEntry -PathType Leaf) -or
            -not (Test-Path -Path $StagedOptimizerEntry -PathType Leaf)) {
            throw 'CATES build completed without the expected analyzer and optimizer entry points.'
        }

        Move-Item -Path $StagingRoot -Destination $ToolRoot
        if (-not (Test-Path -Path $AnalyzerEntry -PathType Leaf) -or
            -not (Test-Path -Path $OptimizerEntry -PathType Leaf)) {
            throw 'CATES tool publication failed after a successful staged build.'
        }

        Write-Host "[Success] Installed CATES tool at commit $CatesCommit." -ForegroundColor Green
        exit 0
    }
    catch {
        if ((Get-Variable -Name StagingRoot -ErrorAction SilentlyContinue) -and
            (Test-Path -Path $StagingRoot -PathType Container)) {
            Remove-Item -Path $StagingRoot -Recurse -Force -ErrorAction SilentlyContinue
        }

        Write-Error -ErrorAction Continue "CATES tool installation failed: $($_.Exception.Message)"
        exit 1
    }
}
#endregion Main Execution