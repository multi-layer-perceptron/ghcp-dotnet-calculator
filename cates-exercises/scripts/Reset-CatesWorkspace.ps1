#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Archives a completed CATES workspace and restores the starter template.
.DESCRIPTION
    Moves the active workspace to a collision-safe timestamped folder under
    completed, verifies the archive, and recreates a clean workspace. Supports
    WhatIf and confirmation and never deletes or overwrites prior archives.
.PARAMETER TrackRoot
    Optional CATES track root. Defaults to the parent of this script folder.
.PARAMETER ArchiveTime
    Optional timestamp used for deterministic lifecycle testing.
.EXAMPLE
    ./Reset-CatesWorkspace.ps1 -WhatIf
.EXAMPLE
    ./Reset-CatesWorkspace.ps1 -Confirm
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$TrackRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [datetime]$ArchiveTime = (Get-Date)
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Functions
function Get-CatesArchivePath {
    <#
    .SYNOPSIS
        Returns a unique timestamped completion archive path.
    .PARAMETER CompletedRoot
        Root directory for archived runs.
    .PARAMETER Timestamp
        Timestamp to include in the archive name.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CompletedRoot,

        [Parameter(Mandatory = $true)]
        [datetime]$Timestamp
    )

    $BaseName = 'run-{0}' -f $Timestamp.ToString('yyyyMMdd-HHmm')
    $CandidatePath = Join-Path -Path $CompletedRoot -ChildPath $BaseName
    $Sequence = 1

    while (Test-Path -Path $CandidatePath) {
        $CandidatePath = Join-Path -Path $CompletedRoot -ChildPath ('{0}-{1:D2}' -f $BaseName, $Sequence)
        $Sequence++
    }

    return $CandidatePath
}

function Get-CatesRequiredPath {
    <#
    .SYNOPSIS
        Reads required paths from the immutable template manifest.
    .PARAMETER TemplateRoot
        Immutable workspace template root.
    .OUTPUTS
        System.String[]
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplateRoot
    )

    $ManifestPath = Join-Path -Path $TemplateRoot -ChildPath '.cates-fixture.json'
    if (-not (Test-Path -Path $ManifestPath -PathType Leaf)) {
        throw "CATES template manifest was not found: $ManifestPath"
    }

    $Manifest = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
    return [string[]]$Manifest.requiredPaths
}

function Assert-CatesRequiredPath {
    <#
    .SYNOPSIS
        Throws when any required path is absent.
    .PARAMETER Root
        Root directory to validate.
    .PARAMETER RequiredPath
        Required relative paths.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$RequiredPath
    )

    foreach ($RelativePath in $RequiredPath) {
        if (-not (Test-Path -Path (Join-Path -Path $Root -ChildPath $RelativePath))) {
            throw "CATES lifecycle validation failed for required path '$RelativePath' under '$Root'."
        }
    }
}

function Copy-CatesTemplate {
    <#
    .SYNOPSIS
        Copies all immutable template children to the workspace.
    .PARAMETER TemplateRoot
        Immutable template directory.
    .PARAMETER WorkspaceRoot
        Destination workspace directory.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplateRoot,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceRoot
    )

    New-Item -Path $WorkspaceRoot -ItemType Directory -Force | Out-Null
    foreach ($TemplateChild in Get-ChildItem -Path $TemplateRoot -Force) {
        Copy-Item -Path $TemplateChild.FullName -Destination $WorkspaceRoot -Recurse -Force
    }
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $ResolvedTrackRoot = [System.IO.Path]::GetFullPath($TrackRoot)
        $TemplateRoot = Join-Path -Path $ResolvedTrackRoot -ChildPath 'assets/workspace-template'
        $WorkspaceRoot = Join-Path -Path $ResolvedTrackRoot -ChildPath 'workspace'
        $CompletedRoot = Join-Path -Path $ResolvedTrackRoot -ChildPath 'completed'
        $RequiredPath = Get-CatesRequiredPath -TemplateRoot $TemplateRoot

        if (-not (Test-Path -Path $WorkspaceRoot -PathType Container)) {
            throw "CATES workspace was not found: $WorkspaceRoot"
        }

        Assert-CatesRequiredPath -Root $WorkspaceRoot -RequiredPath $RequiredPath
        $ArchivePath = Get-CatesArchivePath -CompletedRoot $CompletedRoot -Timestamp $ArchiveTime
        $Action = "Archive to '$ArchivePath' and restore the immutable starter workspace"

        if ($PSCmdlet.ShouldProcess($WorkspaceRoot, $Action)) {
            New-Item -Path $CompletedRoot -ItemType Directory -Force | Out-Null
            Move-Item -Path $WorkspaceRoot -Destination $ArchivePath
            Assert-CatesRequiredPath -Root $ArchivePath -RequiredPath $RequiredPath

            Copy-CatesTemplate -TemplateRoot $TemplateRoot -WorkspaceRoot $WorkspaceRoot
            Assert-CatesRequiredPath -Root $WorkspaceRoot -RequiredPath $RequiredPath

            Write-Host "[Success] Archived CATES run: $ArchivePath" -ForegroundColor Green
            Write-Host "[Success] Restored clean CATES workspace: $WorkspaceRoot" -ForegroundColor Green
        }

        exit 0
    }
    catch {
        Write-Error -ErrorAction Continue "CATES workspace reset failed: $($_.Exception.Message)"
        exit 1
    }
}
#endregion Main Execution