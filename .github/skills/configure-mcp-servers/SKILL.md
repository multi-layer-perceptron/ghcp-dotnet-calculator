---
name: configure-mcp-servers
description: "Configure Microsoft Learn and fetch MCP servers for a workspace. Use when: setup MCP servers, activate MCP, configure mcp.json, configure mcp-config.json, MCP server configuration."
---

# Configure MCP Servers Skill

Use this skill to create or refresh MCP server configuration for a workspace.
The default server set supports documentation lookup through Microsoft Learn and
public web retrieval through the Model Context Protocol fetch server.

## When To Use

Use this skill when the user asks to:

* Configure MCP servers for the calculator workspace
* Activate Microsoft Learn MCP or fetch MCP
* Create `.vscode/mcp.json` for VS Code
* Create `.copilot/mcp-config.json` for clients that use `mcpServers`
* Compare GitHub Copilot IDE MCP support with other MCP-capable clients
* Troubleshoot why configured MCP servers do not appear in the active editor

## Prerequisites

* PowerShell 7 or later available through `pwsh`
* Node.js and `npx` available when enabling the local `fetch` MCP server
* Write access to the workspace root
* Trust in the configured MCP server commands and endpoints

Check the local `fetch` prerequisite with:

```powershell
Get-Command npx -ErrorAction SilentlyContinue
```

## Quick Start

From the repository root, run:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1
```

The script detects the active editor when possible:

* VS Code writes `.vscode/mcp.json` with a top-level `servers` object.
* Generic Copilot-style clients write `.copilot/mcp-config.json` with a
  top-level `mcpServers` object.

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
| `SkipFetch`    | `false` | Omit the local fetch MCP server when `npx` is unavailable or not desired |
| `PassThru`     | `false` | Return the written file path as pipeline output |

## Script Reference

Create the appropriate configuration for the detected editor:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1
```

Create only the Microsoft Learn server for VS Code:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -Editor VSCode -SkipFetch
```

Create the generic `mcpServers` configuration shape:

```powershell
pwsh .github/skills/configure-mcp-servers/scripts/Set-McpServerConfiguration.ps1 -Editor CopilotGeneric
```

## Activation After Writing Configuration

### VS Code

1. Run `MCP: List Servers` from the Command Palette.
2. Select `microsoft-learn` or `fetch`.
3. Choose `Start`, `Enable`, or `Show Output` as needed.
4. Accept the trust prompt if VS Code asks whether you trust the workspace MCP
   configuration.
5. Open Copilot Chat and use **Configure Tools** to confirm the MCP tools are
   enabled.
6. If the servers do not appear, run `Developer: Reload Window`, then check
   `MCP: List Servers` again.

### Other MCP Clients

MCP is portable, but configuration files are client-specific. Confirm the
client's expected file path, top-level key, and supported transports before
copying configuration. Some clients support only local `stdio` servers and may
not support remote `http` endpoints.

## Client Coverage Policy

This skill writes only configurations whose location and schema are intentionally
scoped for the lab:

* `VSCode` writes `.vscode/mcp.json` with top-level `servers`.
* `CopilotGeneric` writes `.copilot/mcp-config.json` with top-level
  `mcpServers` as a portable reference shape for clients that document that
  convention.

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
4. Adapt the `microsoft-learn` and `fetch` server definitions only after the
   client-specific wrapper format is known.
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

* `microsoft-learn`: remote `http` server at
  `https://learn.microsoft.com/api/mcp`
* `fetch`: local server started with
  `npx -y @modelcontextprotocol/server-fetch`

## Troubleshooting

### Servers Do Not Appear In VS Code

Verify that the file is `.vscode/mcp.json`, not `.copilot/mcp-config.json`, and
that it uses the top-level `servers` object. Run `MCP: List Servers` and check
whether the servers are disabled, untrusted, or reporting output errors.

### Fetch Server Does Not Start

Run `Get-Command npx -ErrorAction SilentlyContinue`. If no command is returned,
install Node.js or rerun the script with `-SkipFetch`.

### Microsoft Learn Server Does Not Work In Another Client

Check whether the client supports remote `http` MCP servers. If it only supports
local `stdio`, use the client documentation to find a supported connector or
omit the Microsoft Learn endpoint.

### Claude, Codex, Or Gemini Config Does Not Load

Do not assume `.vscode/mcp.json` or `.copilot/mcp-config.json` applies. Confirm
the current client-specific file path and schema, then copy only the server
definition pieces that the client supports.

## Security Notes

* Review local server commands before running them.
* Avoid storing secrets or credentials in MCP configuration.
* Keep tool access limited to the servers needed for the current workflow.
* Treat workspace MCP configuration as executable project configuration.
