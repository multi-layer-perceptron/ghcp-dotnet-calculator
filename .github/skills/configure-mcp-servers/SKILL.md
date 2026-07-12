---
name: configure-mcp-servers
description: "Configure Azure DevOps, GitHub, Microsoft Learn, Playwright, and memory MCP servers for a workspace. Use when: setup MCP servers, activate MCP, add Azure DevOps MCP, add GitHub MCP, add Playwright MCP, add memory MCP, configure mcp.json, configure mcp-config.json, MCP server configuration."
---

# Configure MCP Servers Skill

Use this skill to create or refresh MCP server configuration for a workspace.
The default server set supports Azure DevOps project tools, GitHub repository
tools, documentation lookup through Microsoft Learn, browser automation
through Playwright, and persistent knowledge-graph memory.

## When To Use

Use this skill when the user asks to:

* Configure MCP servers for the calculator workspace
* Add the Azure DevOps, GitHub, Microsoft Learn, Playwright, or memory MCP server
* Create `.vscode/mcp.json` for VS Code
* Create `.mcp.json` for GitHub Copilot CLI
* Compare GitHub Copilot IDE MCP support with other MCP-capable clients
* Troubleshoot why configured MCP servers do not appear in the active editor

## Prerequisites

* PowerShell 7 or later available through `pwsh`
* An Azure DevOps organization connected to Microsoft Entra ID
* Node.js and `npx` available when enabling the local `playwright` and `memory`
  MCP servers
* Write access to the workspace root
* Trust in the configured MCP server commands and endpoints

Check the local stdio server prerequisites with:

```powershell
Get-Command node -ErrorAction SilentlyContinue
Get-Command npx -ErrorAction SilentlyContinue
```

Both commands must return a result for the `playwright` and `memory` servers to
start. A common Windows failure mode is a broken Node install where `npx`
shims exist on PATH but `node.exe` does not; VS Code then reports
`"node" is not recognized` when starting the server. Fix it by installing
Node.js to a neutral path such as `C:\tools\nodejs` (a portable ZIP install
works without admin rights), adding that folder to the PATH environment
variable, and restarting VS Code.

When `node` and `npx` do not resolve on PATH, the setup script also checks
`C:\tools\nodejs` and `%LOCALAPPDATA%\Programs\nodejs-portable` for a working
install and writes Playwright with an explicit `node.exe` launcher. If no
launcher is found, the script writes only the hosted `http` servers.

The script defaults to the `autocloudarc-mcaps` Azure DevOps organization for
this repository. For another organization, pass its URL segment (not the full
URL) through `-AzureDevOpsOrganization`:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -AzureDevOpsOrganization your-organization
```

This produces `https://mcp.dev.azure.com/your-organization`. Do not use the
Azure DevOps portal URL `https://dev.azure.com/your-organization` as the MCP
endpoint.

## Quick Start

From the repository root, run:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1
```

The script detects the active editor when possible:

* VS Code writes `.vscode/mcp.json` with a top-level `servers` object.
* GitHub Copilot CLI writes `.mcp.json` with a top-level `mcpServers` object.

If detection is ambiguous, pass the target explicitly:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -Editor VSCode
```

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -Editor CopilotGeneric
```

## Parameters Reference

| Parameter      | Default | Description |
|----------------|---------|-------------|
| `Editor`       | `Auto`  | `Auto`, `VSCode`, or `CopilotGeneric` |
| `RepoRoot`     | Git root or current directory | Workspace root where configuration is written |
| `AzureDevOpsOrganization` | `autocloudarc-mcaps` | Azure DevOps organization URL segment |
| `PassThru`     | `false` | Return the written file path as pipeline output |

## Script Reference

Create the appropriate configuration for the detected editor:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1
```

Create the configuration for a different Azure DevOps organization:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -Editor VSCode -AzureDevOpsOrganization your-organization
```

Create the GitHub Copilot CLI `mcpServers` configuration shape:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -Editor CopilotGeneric
```

## Activation After Writing Configuration

### VS Code

1. Run `MCP: List Servers` from the Command Palette.
2. Select a server such as `azureDevOps`, `github`, `microsoftLearn`,
  `playwright`, or `memory`.
3. Choose `Start`, `Enable`, or `Show Output` as needed.
4. Accept the trust prompt if VS Code asks whether you trust the workspace MCP
   configuration.
5. Open Copilot Chat and use **Configure Tools** to confirm the MCP tools are
   enabled.
6. If the servers do not appear, run `Developer: Reload Window`, then check
   `MCP: List Servers` again.

### GitHub Copilot CLI

For GitHub Copilot CLI, create or refresh the root `.mcp.json` file:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -Editor CopilotGeneric
```

Then verify the CLI can see the servers:

```powershell
copilot mcp list
```

Inside an interactive Copilot CLI session, use `/mcp show` or `/mcp reload`.

### Other MCP Clients

MCP is portable, but configuration files are client-specific. Confirm the
client's expected file path, top-level key, and supported transports before
copying configuration. Some clients support only local `stdio` servers and may
not support remote `http` endpoints.

## Client Coverage Policy

This skill writes only configurations whose location and schema are intentionally
scoped for the lab:

* `VSCode` writes `.vscode/mcp.json` with top-level `servers`.
* `CopilotGeneric` writes `.mcp.json` with top-level `mcpServers` for GitHub
  Copilot CLI.

Do not add automatic writes for Claude, Codex, Gemini, or another harness until
you have verified the current client documentation for that exact product and
version. Those tools can use different config file names, user-level paths,
project-level paths, command-line registration flows, and transport support.
Stale MCP paths are worse than no path because they appear authoritative while
silently doing nothing.

When a user asks for one of those clients, use this workflow:

1. Identify the exact product and runtime, such as Claude Desktop, Claude Code,
   Codex CLI, or Gemini CLI.
2. Check that client's current MCP documentation.
3. Confirm the expected config file path, top-level key, and transport support.
4. Adapt the `azureDevOps`, `github`, `microsoftLearn`, `playwright`, and
  `memory` server definitions only after the client-specific wrapper format
  is known.
5. Avoid writing secrets, tokens, or credential headers into committed files.

## GitHub Copilot IDE Coverage

GitHub Copilot documentation currently describes MCP setup and usage across
these IDE families:

* Visual Studio Code
* Visual Studio
* JetBrains IDEs, including IntelliJ IDEA, Android Studio, CLion, DataGrip,
  DataSpell, GoLand, PhpStorm, PyCharm, Rider, RubyMine, RustRover, and
  WebStorm
* Xcode through the GitHub Copilot for Xcode extension
* Eclipse through the GitHub Copilot extension

GitHub Copilot extension documentation also covers coding-assistance setup for
Azure Data Studio and Vim/Neovim. Treat those as Copilot extension environments,
not as proof that the same MCP configuration path or setup flow applies.

For the lab, prefer VS Code as the executable path and use the other IDEs as a
comparison point. Visual Studio, JetBrains IDEs, Xcode, and Eclipse expose MCP
configuration through their Copilot UI flows and may still use a `servers` JSON
shape internally, but learners should follow each IDE's current setup screen
instead of copying `.vscode/mcp.json` into an assumed path.

## Server Definitions

The skill configures these servers:

* `azureDevOps`: remote `http` server at
  `https://mcp.dev.azure.com/{organization}` for Azure DevOps projects, work
  items, repositories, pull requests, and pipelines
* `github`: remote `http` server at `https://api.githubcopilot.com/mcp/` for
  repository, issue, and pull request tools
* `microsoftLearn`: remote `http` server at
  `https://learn.microsoft.com/api/mcp`
* `playwright`: local server started with `npx -y @playwright/mcp@latest` for
  browser automation and UI validation
* `memory`: local server started with
  `npx -y @modelcontextprotocol/server-memory` for persistent knowledge-graph
  memory tools

The remote Azure DevOps MCP server is in public preview and authenticates with
Microsoft Entra ID. Learners must replace `{organization}` with their own
Azure DevOps organization value.

## Troubleshooting

### Servers Do Not Appear In VS Code

Verify that the file is `.vscode/mcp.json`, not `.mcp.json`, and
that it uses the top-level `servers` object. Run `MCP: List Servers` and check
whether the servers are disabled, untrusted, or reporting output errors.

### Local Servers Do Not Start

Run `Get-Command node -ErrorAction SilentlyContinue` and
`Get-Command npx -ErrorAction SilentlyContinue`. If either command is missing,
install Node.js to a PATH location such as `C:\tools\nodejs`, restart VS Code
so new processes pick up the PATH change, or rerun the script so it writes an
explicit `node.exe` launcher from a detected local install. This requirement
applies to both the `playwright` and `memory` servers.

### Microsoft Learn Server Does Not Work In Another Client

Check whether the client supports remote `http` MCP servers. If it only supports
local `stdio`, use the client documentation to find a supported connector or
omit the Microsoft Learn endpoint.

### Claude, Codex, Or Gemini Config Does Not Load

Do not assume `.vscode/mcp.json` or `.mcp.json` applies. Confirm
the current client-specific file path and schema, then copy only the server
definition pieces that the client supports.

## Security Notes

* Review local server commands before running them.
* Avoid storing secrets or credentials in MCP configuration.
* Keep tool access limited to the servers needed for the current workflow.
* Treat workspace MCP configuration as executable project configuration.
