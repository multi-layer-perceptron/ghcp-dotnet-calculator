#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Validates the isolated CATES exercise workspace.
.DESCRIPTION
    Checks the template and workspace structure, rejects provider-shaped secret
    examples, and optionally runs the pinned CATES analyzer against the sample.
.PARAMETER TrackRoot
    Optional CATES track root. Defaults to the parent of this script folder.
.PARAMETER StructureOnly
    Skips Node.js and analyzer execution.
.EXAMPLE
    ./Test-CatesWorkspace.ps1 -StructureOnly
.EXAMPLE
    ./Test-CatesWorkspace.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$TrackRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter(Mandatory = $false)]
    [switch]$StructureOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

#region Functions
function Get-CatesFixtureManifest {
    <#
    .SYNOPSIS
        Reads and returns the CATES fixture manifest.
    .PARAMETER TemplateRoot
        Immutable workspace template root.
    .OUTPUTS
        System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplateRoot
    )

    $ManifestPath = Join-Path -Path $TemplateRoot -ChildPath '.cates-fixture.json'
    if (-not (Test-Path -Path $ManifestPath -PathType Leaf)) {
        throw "CATES fixture manifest was not found: $ManifestPath"
    }

    return Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json
}

function Assert-CatesRequiredPath {
    <#
    .SYNOPSIS
        Throws when a required fixture path is absent.
    .PARAMETER Root
        Root directory to validate.
    .PARAMETER RequiredPath
        Required relative fixture paths.
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
        $CandidatePath = Join-Path -Path $Root -ChildPath $RelativePath
        if (-not (Test-Path -Path $CandidatePath)) {
            throw "Required CATES fixture path is missing: $CandidatePath"
        }
    }
}

function Assert-NoProviderShapedSecret {
    <#
    .SYNOPSIS
        Rejects credential-shaped values in the isolated sample repository.
    .PARAMETER SampleRepositoryRoot
        Sample repository root to inspect.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SampleRepositoryRoot
    )

    $ForbiddenPatterns = @(
        'ghp_[A-Za-z0-9]{20,}',
        'sk-[A-Za-z0-9_-]{20,}',
        'AKIA[A-Z0-9]{16}',
        '-----BEGIN (RSA |EC )?PRIVATE KEY-----'
    )

    foreach ($File in Get-ChildItem -Path $SampleRepositoryRoot -File -Recurse -Force) {
        $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
        if ($null -eq $Content) {
            continue
        }

        foreach ($Pattern in $ForbiddenPatterns) {
            if ($Content -match $Pattern) {
                throw "Provider-shaped secret material is prohibited in CATES fixtures: $($File.FullName)"
            }
        }
    }
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $ResolvedTrackRoot = [System.IO.Path]::GetFullPath($TrackRoot)
        $TemplateRoot = Join-Path -Path $ResolvedTrackRoot -ChildPath 'assets/workspace-template'
        $WorkspaceRoot = Join-Path -Path $ResolvedTrackRoot -ChildPath 'workspace'
        $SampleRepositoryRoot = Join-Path -Path $WorkspaceRoot -ChildPath 'sample-repository'
        $Manifest = Get-CatesFixtureManifest -TemplateRoot $TemplateRoot

        Assert-CatesRequiredPath -Root $TemplateRoot -RequiredPath ([string[]]$Manifest.requiredPaths)
        Assert-CatesRequiredPath -Root $WorkspaceRoot -RequiredPath ([string[]]$Manifest.requiredPaths)
        Assert-NoProviderShapedSecret -SampleRepositoryRoot $SampleRepositoryRoot

        if (-not $StructureOnly) {
            if ($null -eq (Get-Command -Name 'node' -ErrorAction SilentlyContinue)) {
                throw 'Node.js is required for analyzer validation.'
            }

            $AnalyzerEntry = Join-Path -Path $ResolvedTrackRoot -ChildPath 'tools/cates/dist/cli/index.js'
            if (-not (Test-Path -Path $AnalyzerEntry -PathType Leaf)) {
                throw 'The commit-pinned CATES tool is not built. Run Install-CatesTool.ps1 or use -StructureOnly.'
            }

            & node $AnalyzerEntry $SampleRepositoryRoot --quiet
            if ($LASTEXITCODE -ne 0) {
                throw "cates-analyzer exited with code $LASTEXITCODE."
            }
        }

        Write-Host "[Success] CATES workspace validation passed: $WorkspaceRoot" -ForegroundColor Green
        exit 0
    }
    catch {
        Write-Error -ErrorAction Continue "CATES workspace validation failed: $($_.Exception.Message)"
        exit 1
    }
}
#endregion Main Execution