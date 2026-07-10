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
    top-level servers object. Generic Copilot-style clients receive
    .copilot/mcp-config.json with a top-level mcpServers object.

    The default server set is github (http), microsoftLearn (http),
    playwright (stdio via npx), and fetch (stdio via npx). Stdio servers are
    skipped with a warning when no Node.js and npx launcher is available.
.PARAMETER Editor
    Target editor or client shape. Use Auto, VSCode, or CopilotGeneric.
.PARAMETER RepoRoot
    Workspace root where the MCP configuration file is written.
.PARAMETER SkipFetch
    Omits the local fetch MCP server from the generated configuration.
.PARAMETER PassThru
    Emits the written configuration path as pipeline output.
.EXAMPLE
    ./Set-McpServerConfiguration.ps1
.EXAMPLE
    ./Set-McpServerConfiguration.ps1 -Editor VSCode -SkipFetch
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
    [switch]$SkipFetch,

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
        [Parameter(Mandatory = $false)]
        [switch]$SkipFetchServer,

        [Parameter(Mandatory = $false)]
        [hashtable]$NpxLauncher
    )

    $Servers = [ordered]@{
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

        if (-not $SkipFetchServer) {
            $Servers['fetch'] = [ordered]@{
                type    = 'stdio'
                command = $NpxLauncher.command
                args    = @($NpxLauncher.argsPrefix) + @('@modelcontextprotocol/server-fetch')
            }
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
        [Parameter(Mandatory = $false)]
        [switch]$SkipFetchServer,

        [Parameter(Mandatory = $false)]
        [hashtable]$NpxLauncher
    )

    $Servers = [ordered]@{
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

        if (-not $SkipFetchServer) {
            $Servers['fetch'] = [ordered]@{
                type    = 'local'
                command = $NpxLauncher.command
                args    = @($NpxLauncher.argsPrefix) + @('@modelcontextprotocol/server-fetch')
                tools   = @('*')
            }
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

        [Parameter(Mandatory = $false)]
        [switch]$SkipFetchServer,

        [Parameter(Mandatory = $false)]
        [hashtable]$NpxLauncher
    )

    if ($TargetEditor -eq 'VSCode') {
        $DirectoryPath = Join-Path -Path $WorkspaceRoot -ChildPath '.vscode'
        $FilePath = Join-Path -Path $DirectoryPath -ChildPath 'mcp.json'
        $Configuration = New-VSCodeMcpConfiguration -SkipFetchServer:$SkipFetchServer -NpxLauncher $NpxLauncher
    }
    else {
        $DirectoryPath = Join-Path -Path $WorkspaceRoot -ChildPath '.copilot'
        $FilePath = Join-Path -Path $DirectoryPath -ChildPath 'mcp-config.json'
        $Configuration = New-CopilotGenericMcpConfiguration -SkipFetchServer:$SkipFetchServer -NpxLauncher $NpxLauncher
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
        $ShouldSkipFetch = $SkipFetch.IsPresent
        $NpxLauncher = Get-NpxLauncher

        if ($null -eq $NpxLauncher) {
            Write-Warning 'Skipping stdio MCP servers (playwright, fetch) because no Node.js and npx launcher was found. Install Node.js to a PATH location such as C:\tools\nodejs.'
            $ShouldSkipFetch = $true
        }

        $WrittenPath = Set-McpConfigurationFile -WorkspaceRoot $WorkspaceRoot -TargetEditor $TargetEditor -SkipFetchServer:$ShouldSkipFetch -NpxLauncher $NpxLauncher

        Write-Host "MCP configuration written for ${TargetEditor}: $WrittenPath" -ForegroundColor Green

        if ($TargetEditor -eq 'VSCode') {
            Write-Host 'Next: run MCP: List Servers in VS Code, start the servers, and accept the trust prompt if shown.' -ForegroundColor Cyan
        }
        else {
            Write-Host 'Next: verify this client supports the generated mcpServers shape and the configured transports.' -ForegroundColor Cyan
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
