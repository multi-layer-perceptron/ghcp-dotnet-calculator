#!/usr/bin/env pwsh
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#Requires -Version 7.0

<#
.SYNOPSIS
    Creates MCP server configuration for the current workspace.
.DESCRIPTION
    Detects the active editor when possible and writes the MCP configuration
    shape expected by that client. VS Code receives .vscode/mcp.json with a
    top-level servers object. GitHub Copilot CLI receives .mcp.json with a
    top-level mcpServers object.

    The default server set is azureDevOps (http), github (http),
    microsoftLearn (http), and playwright (stdio via npx). Playwright is
    skipped with a warning when no Node.js and npx launcher is available.
.PARAMETER Editor
    Target editor or client shape. Use Auto, VSCode, or CopilotGeneric.
.PARAMETER RepoRoot
    Workspace root where the MCP configuration file is written.
.PARAMETER AzureDevOpsOrganization
    Azure DevOps organization used by the remote Azure DevOps MCP endpoint.
.PARAMETER PassThru
    Emits the written configuration path as pipeline output.
.EXAMPLE
    ./Set-McpServerConfiguration.ps1
.EXAMPLE
    ./Set-McpServerConfiguration.ps1 -Editor VSCode -AzureDevOpsOrganization autocloudarc-mcaps
.NOTES
    Run from the repository root or pass -RepoRoot explicitly.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Auto', 'VSCode', 'CopilotGeneric')]
    [string]$Editor = 'Auto',

    [Parameter(Mandatory = $false)]
    [string]$RepoRoot,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$AzureDevOpsOrganization = 'autocloudarc-mcaps',

    [Parameter(Mandatory = $false)]
    [switch]$PassThru
)

$ErrorActionPreference = 'Stop'

#region Functions
function Get-WorkspaceRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$RequestedRoot
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedRoot)) {
        return (Resolve-Path -Path $RequestedRoot).Path
    }

    $GitRoot = (& git rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($GitRoot)) {
        return (Resolve-Path -Path $GitRoot.Trim()).Path
    }

    return (Get-Location).Path
}

function Get-DetectedEditor {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    if ($env:TERM_PROGRAM -eq 'vscode' -or -not [string]::IsNullOrWhiteSpace($env:VSCODE_PID)) {
        return 'VSCode'
    }

    $ProcessNames = @(Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProcessName -Unique)
    if ($ProcessNames -contains 'Code' -or $ProcessNames -contains 'Code - Insiders') {
        return 'VSCode'
    }

    return 'CopilotGeneric'
}

function Get-NpxLauncher {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    $NodeCommand = Get-Command node -ErrorAction SilentlyContinue
    $NpxCommand = Get-Command npx -ErrorAction SilentlyContinue

    if ($null -ne $NodeCommand -and $null -ne $NpxCommand) {
        return [ordered]@{
            command    = 'npx'
            argsPrefix = @('-y')
        }
    }

    $CandidateNodeHomes = @()

    $NeutralNodeHome = 'C:\tools\nodejs'
    if (Test-Path -Path $NeutralNodeHome) {
        $CandidateNodeHomes += Get-Item -Path $NeutralNodeHome
    }

    $PortableNodeRoot = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Programs/nodejs-portable'
    $CandidateNodeHomes += @(Get-ChildItem -Path $PortableNodeRoot -Directory -Filter 'node-v*-win-x64' -ErrorAction SilentlyContinue |
        Sort-Object -Property Name -Descending)

    foreach ($NodeHome in $CandidateNodeHomes) {
        $NodePath = Join-Path -Path $NodeHome.FullName -ChildPath 'node.exe'
        $NpxCliPath = Join-Path -Path $NodeHome.FullName -ChildPath 'node_modules/npm/bin/npx-cli.js'

        if ((Test-Path -Path $NodePath) -and (Test-Path -Path $NpxCliPath)) {
            return [ordered]@{
                command    = $NodePath
                argsPrefix = @($NpxCliPath, '-y')
            }
        }
    }

    return $null
}

function New-VSCodeMcpConfiguration {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Organization,

        [Parameter(Mandatory = $false)]
        [hashtable]$NpxLauncher
    )

    $Servers = [ordered]@{
        'azureDevOps'    = [ordered]@{
            type = 'http'
            url  = "https://mcp.dev.azure.com/$Organization"
        }
        'github'         = [ordered]@{
            type = 'http'
            url  = 'https://api.githubcopilot.com/mcp/'
        }
        'microsoftLearn' = [ordered]@{
            type = 'http'
            url  = 'https://learn.microsoft.com/api/mcp'
        }
    }

    if ($null -ne $NpxLauncher) {
        $Servers['playwright'] = [ordered]@{
            type    = 'stdio'
            command = $NpxLauncher.command
            args    = @($NpxLauncher.argsPrefix) + @('@playwright/mcp@latest')
        }

    }

    return [ordered]@{
        servers = $Servers
    }
}

function New-CopilotGenericMcpConfiguration {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Organization,

        [Parameter(Mandatory = $false)]
        [hashtable]$NpxLauncher
    )

    $Servers = [ordered]@{
        'azureDevOps'    = [ordered]@{
            type  = 'http'
            url   = "https://mcp.dev.azure.com/$Organization"
            tools = @('*')
        }
        'github'         = [ordered]@{
            type  = 'http'
            url   = 'https://api.githubcopilot.com/mcp/'
            tools = @('*')
        }
        'microsoftLearn' = [ordered]@{
            type  = 'http'
            url   = 'https://learn.microsoft.com/api/mcp'
            tools = @('*')
        }
    }

    if ($null -ne $NpxLauncher) {
        $Servers['playwright'] = [ordered]@{
            type    = 'local'
            command = $NpxLauncher.command
            args    = @($NpxLauncher.argsPrefix) + @('@playwright/mcp@latest')
            tools   = @('*')
        }

    }

    return [ordered]@{
        mcpServers = $Servers
    }
}

function Set-McpConfigurationFile {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspaceRoot,

        [Parameter(Mandatory = $true)]
        [ValidateSet('VSCode', 'CopilotGeneric')]
        [string]$TargetEditor,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Organization,

        [Parameter(Mandatory = $false)]
        [hashtable]$NpxLauncher
    )

    if ($TargetEditor -eq 'VSCode') {
        $DirectoryPath = Join-Path -Path $WorkspaceRoot -ChildPath '.vscode'
        $FilePath = Join-Path -Path $DirectoryPath -ChildPath 'mcp.json'
        $Configuration = New-VSCodeMcpConfiguration -Organization $Organization -NpxLauncher $NpxLauncher
    }
    else {
        $DirectoryPath = $WorkspaceRoot
        $FilePath = Join-Path -Path $DirectoryPath -ChildPath '.mcp.json'
        $Configuration = New-CopilotGenericMcpConfiguration -Organization $Organization -NpxLauncher $NpxLauncher
    }

    New-Item -ItemType Directory -Path $DirectoryPath -Force | Out-Null
    $Configuration | ConvertTo-Json -Depth 10 | Set-Content -Path $FilePath -Encoding UTF8

    return $FilePath
}
#endregion Functions

#region Main Execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $WorkspaceRoot = Get-WorkspaceRoot -RequestedRoot $RepoRoot
        $TargetEditor = if ($Editor -eq 'Auto') { Get-DetectedEditor } else { $Editor }
        $NpxLauncher = Get-NpxLauncher

        if ($null -eq $NpxLauncher) {
            Write-Warning 'Skipping the Playwright MCP server because no Node.js and npx launcher was found. Install Node.js to a PATH location such as C:\tools\nodejs.'
        }

        $WrittenPath = Set-McpConfigurationFile -WorkspaceRoot $WorkspaceRoot -TargetEditor $TargetEditor -Organization $AzureDevOpsOrganization -NpxLauncher $NpxLauncher

        Write-Host "MCP configuration written for ${TargetEditor}: $WrittenPath" -ForegroundColor Green

        if ($TargetEditor -eq 'VSCode') {
            Write-Host 'Next: run MCP: List Servers in VS Code, start the servers, and accept the trust prompt if shown.' -ForegroundColor Cyan
        }
        else {
            Write-Host 'Next: run copilot mcp list or /mcp show to verify the CLI can see the generated .mcp.json servers.' -ForegroundColor Cyan
        }

        if ($PassThru) {
            $WrittenPath
        }

        exit 0
    }
    catch {
        Write-Error -ErrorAction Continue "Set-McpServerConfiguration failed: $($_.Exception.Message)"
        exit 1
    }
}
#endregion Main Execution
