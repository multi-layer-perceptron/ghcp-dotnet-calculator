---
title: Azure Migration Assessment Baseline 3.02
description: Assessment-only Azure readiness baseline for the post-Blazor calculator workspace with prioritized findings, target architecture mapping, and phased next steps
ms.date: 2026-06-23
ms.topic: how-to
---

## Assessment Status

* Overall status: Partial success with validated local baseline
* Prechecks completed: Yes
* App Modernization assessment report viewer: Opened successfully from the available extension tool
* App Modernization assessment command execution: Not executed from this chat runtime
* Reason: Direct assessment commands such as `mcp_github_copilot_appmod-precheck-assessment` and `mcp_github_copilot_appmod-run-assessment` are not exposed in the current toolset
* Tooling note: `mcp__microsoft_gi_appmod-run-task` is exposed, but it is a migration execution engine. It was not used because this prompt is assessment-only and must not perform code migration or deployment.

## Assessment Artifact Location

* Local report path: `docs/azure-migration-assessment-3.02.md`
* Extension report view: Opened through the migration assessment report viewer
* Extension raw report files: Not exposed to this chat runtime

## Execution Context

* Target path: `$(git rev-parse --show-toplevel)\src\workspace\calculator-xunit-testing`
* Operating system: Windows 10.0.26200, win-x64
* Active .NET SDK: 10.0.301
* .NET host runtime: 10.0.9
* Installed .NET SDKs observed:
  * 6.0.428
  * 8.0.422
  * 10.0.301
* Azure CLI availability: `az.cmd` installed
* Azure Developer CLI availability: `azd.exe` 1.25.600.0 installed
* Docker availability: Docker Desktop 29.5.3 available during test execution
* Repository status at assessment time:
  * Existing unrelated modified file: `.github/prompts/create-basic-workflow.prompt.md`
* Commands executed for baseline validation:
  * `dotnet --info`
  * `code --list-extensions | Select-String -Pattern "modern|migrate|azure|github.copilot"`
  * `docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"`
  * `dotnet build .\calculator.slnx`
  * `dotnet test .\calculator.slnx --verbosity minimal`
  * `dotnet list .\calculator.slnx package`
  * `Get-Command az,azd,docker,dotnet -ErrorAction SilentlyContinue | Select-Object Name,Version,Source`

## Runtime Baseline Results

* Solution build baseline: Pass
  * `calculator.library`: `net10.0` succeeded
  * `calculator`: `net10.0` succeeded
  * `calculator.tests`: `net10.0` succeeded
  * `calculator.web`: `net10.0` succeeded
* Test baseline: Pass
  * Total tests: 20
  * Failed: 0
  * Passed: 20
  * Skipped: 0
* Current framework target:
  * `calculator.csproj`: `net10.0`
  * `calculator.library.csproj`: `net10.0`
  * `calculator.tests.csproj`: `net10.0`
  * `calculator.web.csproj`: `net10.0`
* Current application surfaces:
  * Console host in `calculator`
  * Shared arithmetic library in `calculator.library`
  * Blazor Web App host in `calculator.web`
  * xUnit integration tests in `calculator.tests`
* PostgreSQL patterns identified:
  * Persistent local PostgreSQL container for iterative local app/UI workflows
  * Testcontainers PostgreSQL for automated test isolation in `calculator.tests`
  * One persistent local container was running during assessment: `test-container` on host port `55432`, mapped to PostgreSQL port `5432`
  * The persistent container did not block solution build or tests
* Local application interference check:
  * A previously running Blazor app process on `http://localhost:5297` was stopped before report generation
  * Stopping the app surfaced a Blazor `JSDisconnectedException` during component disposal in `Home.razor`

## Dependency Baseline

* `calculator.library`: No direct package references
* `calculator`: No direct package references
* `calculator.web`: Uses the framework-provided ASP.NET Core shared framework for `net10.0`
* `calculator.tests` direct packages:
  * `coverlet.collector` 6.0.0
  * `Microsoft.NET.Test.Sdk` 17.8.0
  * `Npgsql` 8.0.4
  * `Testcontainers.PostgreSql` 3.9.0
  * `xunit` 2.5.3
  * `xunit.runner.visualstudio` 2.5.3

## Prioritized Findings

### Critical blockers

* App Modernization extension assessment commands not executed in-session
  * Direct precheck and assessment commands are not available in the current chat toolset
  * The extension report viewer opened, but raw generated findings and file paths were not returned to this chat
  * Run the extension-native assessment workflow from the App Modernization UI or a tool context that exposes the assessment commands before using this report as a production migration signoff

### Major issues

* Blazor JavaScript interop disposal should be hardened before hosting in Azure
  * Stopping the local Blazor app produced `JSDisconnectedException` from `Home.razor` disposal
  * The app should tolerate disconnected circuits during shutdown, reconnect, browser refresh, and App Service recycle events
* Dependency modernization gap for test toolchain
  * `Microsoft.NET.Test.Sdk` 17.8.0, xUnit 2.5.3, `Npgsql` 8.0.4, and `Testcontainers.PostgreSql` 3.9.0 should be reviewed against current support baselines before migration hardening
* Data migration path is not codified yet
  * Local PostgreSQL and Testcontainers data patterns are established
  * No formal schema migration, seed promotion, or rollback process exists yet for Azure Database for PostgreSQL Flexible Server
* Runtime configuration has not been externalized for Azure
  * The app is currently self-contained for calculator behavior and does not require production database configuration
  * Future PostgreSQL-backed runtime behavior should use environment-specific configuration from App Settings and Key Vault rather than local Docker settings

### Informational recommendations

* Keep Linux-first parity from Codespaces or devcontainers through Azure App Service Linux hosting
* Retain the split PostgreSQL strategy: persistent local container for manual development, Testcontainers for automated tests
* Add Infrastructure as Code under `infra/` when moving from assessment to implementation
* Prefer `azd` for deployment orchestration once a deployment plan exists
* Use managed identity and least-privilege RBAC where Azure services need to access Key Vault or PostgreSQL-adjacent resources
* Keep historical `.NET 8` references in pre-upgrade prompts and reports where they describe that earlier stage; current active code targets `.NET 10`

## Recommended Azure Target Architecture

* Preferred app host: Azure App Service Linux for `calculator.web`
* Secondary app handling: Keep `calculator` as a console sample or operational utility, not the primary web migration target
* Shared logic: Deploy `calculator.library` as part of the web app build output, with calculator logic remaining pure and testable
* Data tier: Azure Database for PostgreSQL Flexible Server for any persisted calculator history, shared test-case catalog, or future runtime data
* Configuration and secrets:
  * Use Azure App Settings for non-secret environment values
  * Use Azure Key Vault for secrets
  * Prefer managed identity for Azure-hosted access where supported by the chosen data and secret access pattern
  * Do not carry local Docker usernames, passwords, or host ports into Azure configuration
* Test strategy:
  * Keep Testcontainers in automated tests and CI where Docker is available
  * Do not treat Testcontainers databases as migration sources
  * Promote data through explicit schema and seed scripts instead of copying ephemeral test databases
* Deployment implementation guidance:
  * Create IaC under `infra/` in a later deployment-preparation prompt
  * Validate generated deployment changes with preview or what-if before provisioning resources
  * Do not disable Key Vault purge protection in IaC

## Migration Readiness Summary

* Readiness level: Moderate for migration planning, not ready for production cutover
* What is ready now:
  * .NET 10 runtime baseline
  * Web-hostable Blazor app project
  * Shared calculator library separated from host-specific UI
  * Passing automated tests with isolated PostgreSQL test execution
  * Clear local PostgreSQL workflow for iterative development
* What must be completed next:
  * Run the official App Modernization assessment command path and capture raw artifacts
  * Harden Blazor JS interop disposal and reconnect behavior
  * Produce formal DB migration artifacts for Azure PostgreSQL
  * Define Azure runtime configuration and secret mapping
  * Add Azure deployment preparation artifacts in a separate, non-assessment step

## Phase-Based Next Steps

### Phase A: Close blockers

* Execute official App Modernization extension assessment commands and capture generated artifact paths
* Add a small Blazor disposal fix so `Home.razor` ignores expected JS disconnection during circuit teardown
* Decide whether the first Azure migration should host only `calculator.web` or also package the console app as a separate sample artifact

### Phase B: Implement migration prerequisites

* Define and validate database migration scripts for Azure PostgreSQL
* Review and update test/tooling dependencies to current supported baselines for .NET 10
* Add an environment mapping matrix for local, CI, and Azure App Service settings
* Create `infra/` deployment assets only after the assessment artifacts and target topology are confirmed
* Plan Key Vault, managed identity, and RBAC scope before any resource creation

### Phase C: Validate pre-deployment readiness

* Add Azure-targeted smoke tests
* Validate Linux parity in CI/CD and runtime configuration
* Run `azd provision --preview` or Azure deployment what-if in the deployment-preparation step
* Finalize cutover and rollback guidance for PostgreSQL schema changes

## Notes on Missing Artifacts

* Missing from this run:
  * Extension-native precheck output from `mcp_github_copilot_appmod-precheck-assessment`
  * Extension-native assessment output from `mcp_github_copilot_appmod-run-assessment`
  * Raw file path or report ID from the migration assessment report viewer
* Recommended remediation:
  * Run the App Modernization extension workflow from a context where assessment commands are available
  * Append the generated report IDs, file paths, and command output summaries to this report
