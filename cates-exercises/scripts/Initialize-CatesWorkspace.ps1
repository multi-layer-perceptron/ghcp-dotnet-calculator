#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Creates or verifies the isolated CATES exercise workspace.
.DESCRIPTION
    Copies the immutable workspace template into the track workspace when the
    workspace is absent or empty. Existing complete workspaces are preserved,
    and partial workspaces are rejected to prevent accidental overwrites.
.PARAMETER TrackRoot
    Optional CATES track root. Defaults to the parent of this script folder.
.EXAMPLE
    ./Initialize-CatesWorkspace.ps1
.EXAMPLE
    ./Initialize-CatesWorkspace.ps1 -TrackRoot /tmp/cates-exercises
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$TrackRoot = (Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Functions
function Get-CatesRequiredPath {
    <#
    .SYNOPSIS
        Reads required workspace paths from the template manifest.
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
    if ($null -eq $Manifest.requiredPaths -or $Manifest.requiredPaths.Count -eq 0) {
        throw "CATES template manifest has no requiredPaths entries: $ManifestPath"
    }

    return [string[]]$Manifest.requiredPaths
}

function Test-CatesRequiredPath {
    <#
    .SYNOPSIS
        Tests whether every required relative path exists under a root.
    .PARAMETER Root
        Root directory to validate.
    .PARAMETER RequiredPath
        Required relative paths from the fixture manifest.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
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
            return $false
        }
    }

    return $true
}

function Copy-CatesTemplate {
    <#
    .SYNOPSIS
        Copies all template children, including hidden files, to a workspace.
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

        if (-not (Test-Path -Path $TemplateRoot -PathType Container)) {
            throw "CATES workspace template was not found: $TemplateRoot"
        }

        $RequiredPath = Get-CatesRequiredPath -TemplateRoot $TemplateRoot
        $WorkspaceContent = @(
            if (Test-Path -Path $WorkspaceRoot -PathType Container) {
                Get-ChildItem -Path $WorkspaceRoot -Force
            }
        )

        if ($WorkspaceContent.Count -gt 0) {
            if (Test-CatesRequiredPath -Root $WorkspaceRoot -RequiredPath $RequiredPath) {
                Write-Host "[Success] Existing CATES workspace is complete; no files were changed." -ForegroundColor Green
                exit 0
            }

            throw "CATES workspace contains partial or unrelated content. Archive or remove it before initialization: $WorkspaceRoot"
        }

        Copy-CatesTemplate -TemplateRoot $TemplateRoot -WorkspaceRoot $WorkspaceRoot
        if (-not (Test-CatesRequiredPath -Root $WorkspaceRoot -RequiredPath $RequiredPath)) {
            throw "CATES workspace copy failed validation: $WorkspaceRoot"
        }

        Write-Host "[Success] Created CATES workspace: $WorkspaceRoot" -ForegroundColor Green
        exit 0
    }
    catch {
        Write-Error -ErrorAction Continue "CATES workspace initialization failed: $($_.Exception.Message)"
        exit 1
    }
}
#endregion Main Execution