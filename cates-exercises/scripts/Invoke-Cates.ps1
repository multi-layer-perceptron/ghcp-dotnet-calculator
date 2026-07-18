#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Runs the track-pinned CATES analyzer or optimizer.
.DESCRIPTION
    Invokes the built JavaScript entry point from the isolated tool checkout and
    forwards arguments without installing packages in the calculator repository.
.PARAMETER Tool
    Selects the analyzer or optimizer command.
.PARAMETER ArgumentList
    Arguments forwarded to the selected CATES command.
.PARAMETER TrackRoot
    Optional CATES track root. Defaults to the parent of this script folder.
.EXAMPLE
    ./Invoke-Cates.ps1 -Tool analyzer -ArgumentList 'workspace/sample-repository'
.EXAMPLE
    ./Invoke-Cates.ps1 -Tool optimizer -ArgumentList 'workspace/sample-repository', '--dry-run'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('analyzer', 'optimizer')]
    [string]$Tool,

    [Parameter(Mandatory = $false, Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$ArgumentList = @(),

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$TrackRoot = (Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $ResolvedTrackRoot = [System.IO.Path]::GetFullPath($TrackRoot)
        $RelativeEntry = if ($Tool -eq 'analyzer') {
            'tools/cates/dist/cli/index.js'
        }
        else {
            'tools/cates/dist/optimizer/cli.js'
        }
        $EntryPoint = Join-Path -Path $ResolvedTrackRoot -ChildPath $RelativeEntry

        if (-not (Test-Path -Path $EntryPoint -PathType Leaf)) {
            throw "CATES $Tool is not built. Run cates-exercises/scripts/Install-CatesTool.ps1 first."
        }

        & node $EntryPoint @ArgumentList
        exit $LASTEXITCODE
    }
    catch {
        Write-Error -ErrorAction Continue "CATES $Tool invocation failed: $($_.Exception.Message)"
        exit 1
    }
}
#endregion Main Execution