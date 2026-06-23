---
title: Azure Migration Assessment Baseline 3.02
description: Assessment-only Azure readiness baseline for calculator-xunit-testing with prioritized findings, target architecture mapping, and phased next steps
ms.date: 2026-06-23
ms.topic: how-to
---

## Assessment Status

* Overall status: Partial success
* Prechecks completed: Yes
* App Modernization extension command execution: Not executed from this chat runtime
* Reason: The required App Modernization MCP/extension commands are not exposed in the current toolset for direct invocation in-session

## Assessment Artifact Location

* Report path: docs/azure-migration-assessment-3.02.md

## Execution Context

* Target path: `$(git rev-parse --show-toplevel)\src\workspace\calculator-xunit-testing`
* Dotnet version: 10.0.301
* Installed SDKs observed:
  * 6.0.428
  * 8.0.422
  * 10.0.301
* Commands executed for baseline validation:
  * `dotnet --version`
  * `dotnet --list-sdks`
  * `dotnet restore .\calculator.slnx`
  * `dotnet test .\calculator.tests\calculator.tests.csproj --verbosity minimal`
  * `dotnet list .\src\workspace\calculator-xunit-testing\calculator.tests\calculator.tests.csproj package`

## Runtime Baseline Results

* Build/restore baseline: Pass
* Test baseline: Pass
  * Total tests: 20
  * Failed: 0
  * Passed: 20
* Current framework target:
  * `calculator.csproj`: `net10.0`
  * `calculator.tests.csproj`: `net10.0`
* PostgreSQL patterns identified:
  * Persistent local PostgreSQL container used for iterative local app/UI workflows (prompt/skill guidance)
  * Testcontainers PostgreSQL used for automated test isolation in `calculator.tests`

## Prioritized Findings

### Critical blockers

* No deployable web/API host in current project scope
  * Current app project is console-oriented (`calculator`), which is not a direct Azure App Service target for web hosting
  * Planned Blazor/web refactor is required before a full App Service migration path can be finalized
* App Modernization extension assessment commands not executed in-session
  * The official extension run output and generated extension artifacts are missing in this report

### Major issues

* Dependency modernization gap for test toolchain
  * `Microsoft.NET.Test.Sdk` 17.8.0, xUnit 2.5.3, and some test dependencies are behind latest ecosystem baselines for .NET 10-era projects
* Solution restore command warning
  * `dotnet restore .\calculator.slnx` produced warning: unable to find a project to restore
  * Project-level restore and test still succeeded, but solution-level restore behavior should be normalized for reliability
* Data migration path is not codified yet
  * Local PostgreSQL and Testcontainers data patterns are established, but no formal migration scripts/process are yet defined for Azure PostgreSQL promotion

### Informational recommendations

* Keep Linux-first parity from devcontainer/Codespaces through Azure hosting
* Retain split strategy:
  * Persistent local PostgreSQL container for iterative development
  * Testcontainers for automated tests/CI
* Introduce migration artifacts early:
  * Schema migration scripts
  * Seed/transform scripts
  * Environment mapping matrix (local to Azure)

## Recommended Azure Target Architecture

* App host: Azure App Service Linux (preferred for Linux-first parity)
* Data tier: Azure Database for PostgreSQL Flexible Server
* Secret/configuration strategy:
  * Move connection values to Azure App Settings
  * Store secrets in Azure Key Vault
  * Prefer managed identity where feasible for service-to-service access patterns

## Migration Readiness Summary

* Readiness level: Moderate for pre-migration planning, low for immediate production cutover
* What is ready now:
  * .NET 10 runtime baseline
  * Passing automated tests with isolated PostgreSQL test execution
  * Clear local PostgreSQL workflow for iterative development
* What must be completed next:
  * Complete Blazor/web hosting refactor track
  * Produce formal DB migration artifacts for Azure PostgreSQL
  * Run App Modernization extension assessment commands to generate official extension findings

## Phase-Based Next Steps

### Phase A: Close blockers

* Implement web-hostable application surface (Blazor/web app track)
* Execute official App Modernization extension assessment commands and capture generated artifacts

### Phase B: Implement migration prerequisites

* Define and validate database migration scripts for Azure PostgreSQL
* Upgrade test/tooling dependencies to current supported baselines for .NET 10
* Resolve solution-level restore warning and validate deterministic build flow

### Phase C: Validate pre-deployment readiness

* Add Azure-targeted smoke tests
* Validate Linux parity in CI/CD and runtime configuration
* Run dry-run deployment checks and finalize cutover/rollback plan

## Notes on Missing Artifacts

* Missing from this run:
  * Extension-native report output from `mcp_github_copilot_appmod-precheck-assessment`
  * Extension-native report output from `mcp_github_copilot_appmod-run-assessment`
* Recommended remediation:
  * Run the App Modernization extension workflow from a context where those commands are available and append the output paths to this report
