---
title: Azure Migration Assessment Baseline 3.02
description: Assessment-only Azure readiness baseline for the post-Blazor calculator workspace with AppCAT findings, target architecture mapping, and phased next steps
ms.date: 2026-07-07
ms.topic: how-to
---

## Assessment Status

* Overall status: Assessment completed successfully with validated local baseline; Phase A Blazor disposal blocker fixed and smoke-tested; Phase B deployment-preparation artifacts now include PostgreSQL runtime infrastructure; initial Azure provisioning and deployment completed
* Scope: Assessment, deployment preparation, Azure provisioning, and Azure App Service deployment for the `dev` environment
* App Modernization precheck: Completed
* AppCAT preparation: Updated .NET AppCAT from `1.0.878.50543` to `1.0.1127.58951` after precheck reported the installed version was below the minimum `1.0.1127`
* App Modernization assessment action ID: `20260707082945`
* App Modernization report ID: `report-20260707082945`
* App Modernization report webview: Opened successfully through the migration assessment report viewer
* Assessment domains: `dotnet-cloud-readiness`
* Assessment mode: `issue-only`
* Assessment result: 4 projects analyzed, 3 issues, 4 incidents, 10 total effort points
* Security result: No AppCAT security findings were reported in `report.json`

## Assessment Artifact Location

* Local assessment summary: `docs/azure-migration-assessment-3.02.md`
* Raw AppCAT report: `src/workspace/calculator-xunit-testing/.github/modernize/assessment/reports/report-20260707082945/report.json`
* AppCAT report ID: `report-20260707082945`
* AppCAT action ID: `20260707082945`
* Tooling note: The report webview opened with generic Java wording, but the raw report producer is `.NET AppCAT CLI` and the analyzed projects are the calculator `.csproj` files

## Local Execution Context

* Repository path: `c:\onedrive-prsn\OneDrive\02.00.00.GENERAL\repos\git-autocloudarc-labs\ghcp-dotnet-calculator`
* Assessment workspace: `src/workspace/calculator-xunit-testing`
* Operating system: Windows 10.0.26200, win-x64
* Active .NET SDK: `10.0.301`
* .NET host runtime: `10.0.9`
* Installed .NET SDKs observed:
  * `6.0.428`
  * `8.0.422`
  * `10.0.301`
* Installed ASP.NET Core runtimes observed:
  * `6.0.36`
  * `8.0.28`
  * `9.0.17`
  * `10.0.9`
* `global.json`: Not found
* Tool availability observed:
  * `dotnet.exe` from `C:\Program Files\dotnet\dotnet.exe`
  * `docker.exe` from Docker Desktop resources
  * `az.cmd` from Azure CLI
  * `azd.exe` version `1.25.600.0`
* Docker context: Docker Desktop was available and Testcontainers connected successfully to Docker Server `29.6.1`
* Local Docker containers: Persistent PostgreSQL container `test-container` running `postgres:latest` on host port `55432`, mapped to container port `5432`
* Local port state: PostgreSQL listeners were observed on ports `5432` and `55432`; no Blazor app listener was observed on `5297`, `5097`, or `7084` after the local dev server was stopped
* Repository status before report refresh: `git status --short` produced no output

## Commands Executed

* `git status --short`
* `dotnet --info`
* `docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}"`
* `dotnet build .\calculator.slnx`
* `dotnet test .\calculator.slnx --verbosity minimal`
* `dotnet run --project .\calculator.web\calculator.web.csproj --urls http://localhost:5297`
* `Invoke-WebRequest -Uri http://localhost:5297 -UseBasicParsing`
* `dotnet list .\calculator.slnx package`
* `Get-NetTCPConnection -LocalPort 5297,5097,7084,5432,55432 -ErrorAction SilentlyContinue`
* `Get-Command dotnet,docker,az,azd -ErrorAction SilentlyContinue`
* `az bicep build --file .\infra\main.bicep`
* `azd provision --preview --no-prompt`
* `azd provision --no-prompt`
* `azd deploy web --no-prompt`
* `azd up --no-prompt`
* `Invoke-WebRequest -Uri https://calc-dev-4p4xdqmfkhxpg-web.azurewebsites.net/health -UseBasicParsing`
* `Invoke-WebRequest -Uri https://calc-dev-4p4xdqmfkhxpg-web.azurewebsites.net/ -UseBasicParsing`
* App Modernization precheck assessment tool with workspace path `src/workspace/calculator-xunit-testing`
* AppCAT setup tool after precheck identified the older AppCAT version
* .NET AppCAT assessment tool with workspace path `src/workspace/calculator-xunit-testing`
* App Modernization assessment report tool with action ID `20260707082945`
* Migration assessment report viewer with report ID `report-20260707082945`

## Runtime Baseline Results

* Solution build baseline: Pass
  * `calculator.library`: `net10.0` succeeded
  * `calculator`: `net10.0` succeeded
  * `calculator.web`: `net10.0` succeeded
  * `calculator.tests`: `net10.0` succeeded
* Test baseline: Pass
  * Total tests: 37
  * Failed: 0
  * Passed: 37
  * Skipped: 0
* Blazor smoke baseline: Pass
  * `http://localhost:5297` returned HTTP 200
  * Response content contained `Calculator`
  * Stopping the local server no longer produced `Microsoft.JSInterop.JSDisconnectedException`
  * The HTTP-only local run still logged the expected HTTPS redirection port warning
* Azure smoke baseline: Pass
  * `https://calc-dev-4p4xdqmfkhxpg-web.azurewebsites.net/health` returned HTTP 200 with `Healthy`
  * `https://calc-dev-4p4xdqmfkhxpg-web.azurewebsites.net/` returned HTTP 200
  * The deployed home page contained `Calculator`
* Current application surfaces:
  * Console host in `calculator`
  * Shared arithmetic library in `calculator.library`
  * Blazor Web App host in `calculator.web`
  * xUnit integration and service tests in `calculator.tests`
* Current framework target:
  * `calculator.csproj`: `net10.0`
  * `calculator.library.csproj`: `net10.0`
  * `calculator.tests.csproj`: `net10.0`
  * `calculator.web.csproj`: `net10.0`

## Dependency Baseline

* `calculator.library`: No direct package references
* `calculator`: No direct package references
* `calculator.web`: Uses the framework-provided ASP.NET Core shared framework for `net10.0`; the SDK auto-reference resolved `Microsoft.AspNetCore.App.Internal.Assets` `10.0.9`
* `calculator.tests` direct packages:
  * `coverlet.collector` `6.0.0`
  * `Microsoft.NET.Test.Sdk` `17.5.0`
  * `Npgsql` `10.0.3`
  * `Testcontainers.PostgreSql` `4.13.0`
  * `xunit` `2.6.2`
  * `xunit.runner.visualstudio` `2.5.1`

## AppCAT Findings Summary

| Rule         | Severity  | Incidents | Project            | Category | Summary                        |
|--------------|-----------|-----------|--------------------|----------|--------------------------------|
| `Local.0003` | Potential | 2         | `calculator.tests` | Local    | Local or network I/O detected  |
| `Perf.0001`  | Optional  | 1         | `calculator.tests` | Perf     | Synchronous API usage detected |
| `Scale.0001` | Optional  | 1         | `calculator.web`   | Scale    | Static content detected        |

### AppCAT Incidents

* `Local.0003`: `calculator.tests\CalculatorTest.cs`, lines 117 and 176, detected `System.IO.File` usage for CSV-backed test data
* `Perf.0001`: `calculator.tests\CalculatorTest.cs`, line 109, detected `TaskAwaiter<T>.GetResult()` in the xUnit `MemberData` path
* `Scale.0001`: `calculator.web\calculator.web.csproj`, detected 25 static web assets under `wwwroot`, including `app.css`, `favicon.png`, `calculatorKeyboard.js`, and Bootstrap files

## Prioritized Findings

### Critical blockers

* None open after Phase A.
  `Home.razor` disposal now handles expected `JSDisconnectedException` during Blazor Server circuit teardown, and the shutdown smoke test no longer reproduces the previous circuit failure.

### Major issues

* Runtime configuration and secret mapping are now defined for the initial Azure target.
  The web app receives `ConnectionStrings__CalculatorPostgreSql` as an App Service setting backed by a Key Vault reference, with the PostgreSQL administrator password left as a secure Bicep parameter. Application code does not yet use this runtime connection string.
* Data migration artifacts are not codified yet.
  Local PostgreSQL and Testcontainers workflows are established, but no formal schema migration, seed promotion, or rollback process exists for Azure Database for PostgreSQL Flexible Server. Testcontainers databases must remain test fixtures, not migration sources.
* AppCAT local I/O findings need to remain test-scoped.
  The detected `System.IO.File` usage is in `calculator.tests` for `TestCases.csv`, which is acceptable for test execution when the file is copied to output. Do not move this pattern into production runtime code without replacing it with durable Azure storage or packaged read-only content.
* AppCAT synchronous API finding should be reviewed in the test data path.
  `GetAwaiter().GetResult()` is used to bridge async PostgreSQL loading into xUnit `MemberData`. This is test-only, but it can make discovery slower or more fragile. Consider an async-friendly xUnit data strategy or fixture pattern if test discovery becomes unstable in CI.
* Test toolchain versions should be reviewed before CI migration hardening.
  The current packages pass locally on .NET 10, but `Microsoft.NET.Test.Sdk` `17.5.0`, xUnit `2.6.2`, and `xunit.runner.visualstudio` `2.5.1` are older than the active SDK/runtime baseline. Review supported versions before relying on them for Azure deployment gates.

### Informational recommendations

* Treat `Scale.0001` as a future optimization, not a launch blocker.
  The current `wwwroot` assets are small app assets and Bootstrap files. Azure Blob Storage plus CDN can be considered if static content grows, changes independently of app deployments, or needs edge caching.
* Keep Azure App Service Linux as the primary web hosting target for `calculator.web`.
  The app is a small Blazor Web App with server interactivity and no current need for Kubernetes or container orchestration.
* Keep `calculator.library` deployed through the web app build output.
  The shared calculator logic is pure and already separated from host-specific UI concerns.
* Keep `calculator` as a console sample or utility, not the primary migration target.
  The user-facing host is now `calculator.web`.
* Retain Testcontainers for automated tests where Docker is available.
  This preserves isolated PostgreSQL test execution and avoids coupling CI to a persistent shared database.

## Recommended Azure Target Architecture

* Application host: Azure App Service Linux running `calculator.web`
* Runtime: .NET 10 on Linux App Service, aligned with the current `net10.0` project targets
* Shared logic: `calculator.library` included as a normal project reference in the web app build output
* Data tier: Azure Database for PostgreSQL Flexible Server provisioned as an initial runtime dependency for future persisted calculator history, shared test-case catalog, or operational data
* Secrets and configuration:
  * Use Azure App Settings for non-secret values such as environment name and feature flags
  * Use Azure Key Vault for the PostgreSQL connection string and other sensitive operational values
  * Use a user-assigned managed identity for App Service access to Key Vault
  * Do not carry local Docker usernames, passwords, database names, or host ports into Azure configuration
* Static content:
  * Serve current small static assets from App Service initially
  * Revisit Azure Blob Storage and CDN only if asset scale, performance, independent deployment, or caching requirements justify it
* Testing:
  * Keep Testcontainers and `TestCases.csv` for automated test data setup
  * Add Azure-targeted smoke tests after deployment-preparation artifacts exist
  * Do not treat Testcontainers databases or persistent local containers as migration sources

## Migration Readiness Summary

* Readiness level: Moderate for migration planning, with initial Azure deployment validated in the `dev` environment
* What is ready now:
  * .NET 10 runtime baseline
  * Passing solution build
  * Passing 37-test baseline
  * Web-hostable Blazor app project
  * Blazor JavaScript interop disposal hardened for disconnected circuit teardown
  * Shared calculator library separated from UI and console hosts
  * AppCAT cloud-readiness report generated and opened
  * Clear local PostgreSQL and Testcontainers test patterns
  * Azure App Service Linux, Application Insights, Log Analytics, Key Vault, managed identity, and PostgreSQL Flexible Server Bicep artifacts
  * Azure Database for PostgreSQL Flexible Server availability checked in `eastus2`
  * `/health` endpoint aligned with App Service health-check configuration
  * `azd provision`, `azd deploy web`, and `azd up` completed successfully
  * Deployed endpoint validated at `https://calc-dev-4p4xdqmfkhxpg-web.azurewebsites.net/`
* What must be completed before production cutover:
  * Produce PostgreSQL schema migration, seed, rollback, and validation artifacts before application code writes runtime data to Azure PostgreSQL
  * Review and modernize the test toolchain for .NET 10 CI reliability
  * Add repeatable Azure smoke tests to CI or release validation

## Phase-Based Next Steps

### Phase A: Close blockers

* Completed: Fixed `Home.razor` disposal so expected `JSDisconnectedException` during circuit teardown does not fail the circuit
* Completed: Re-ran `dotnet build .\calculator.slnx` and `dotnet test .\calculator.slnx --verbosity minimal`; both passed
* Completed: Smoke-tested `calculator.web` on `http://localhost:5297`; HTTP 200 returned and shutdown no longer logged the prior JS disconnection failure
* Optional: Re-run AppCAT after Phase B deployment-preparation changes and record the new action ID and report ID
* Confirm that the initial Azure migration target is `calculator.web` only, with `calculator` retained as a sample utility

### Phase B: Implement migration prerequisites

* Completed: Added Azure Developer CLI and Bicep artifacts for App Service Linux, observability, Key Vault, managed identity, and PostgreSQL Flexible Server
* Completed: Added PostgreSQL runtime configuration through `ConnectionStrings__CalculatorPostgreSql` as a Key Vault-backed App Service setting
* Completed: Selected `eastus2`, resource prefix `calc`, database name `calculator`, PostgreSQL version `17`, and Burstable `Standard_B1ms` for the initial data tier
* Completed: Provisioned the `dev` environment in `rg-dev`
* Completed: Removed stale `azd-service-name=web` tag from the older `calc-dev-hhmzuztbik52y-web` App Service so AZD could target `calc-dev-4p4xdqmfkhxpg-web`
* Add an environment mapping matrix for local, CI, and Azure App Service settings
* Define PostgreSQL schema migration, seed promotion, rollback, and validation steps before application runtime data is written to Azure PostgreSQL
* Review `Microsoft.NET.Test.Sdk`, xUnit, and runner package versions against current .NET 10 support baselines
* Decide whether AppCAT test-only local I/O and synchronous discovery findings require code changes before CI migration
* Plan Key Vault, managed identity, RBAC scope, and App Service App Settings before any resource creation

### Phase C: Validate pre-deployment readiness

* Completed: Validated generated deployment changes with `azd provision --preview --no-prompt`
* Completed: Ran `azd provision --no-prompt`, `azd deploy web --no-prompt`, and `azd up --no-prompt`
* Completed: Smoke-tested deployed startup through `/health` and `/`
* Add Azure-targeted smoke tests for app startup and calculator workflow behavior
* Validate Linux parity for build, test, and runtime configuration
* Finalize cutover and rollback guidance for any PostgreSQL schema changes

## Missing Artifact Log

* No missing AppCAT report artifact remains for this run. The raw report was generated at `src/workspace/calculator-xunit-testing/.github/modernize/assessment/reports/report-20260707082945/report.json`
* No raw terminal log files were written for the local baseline commands; command summaries are captured in this document
* No PostgreSQL migration script, seed promotion artifact, rollback script, or environment mapping artifact exists yet
* Azure deployment preview and deployment command summaries are captured in this document and `.azure/deployment-plan.md`, but no separate raw Azure terminal log artifact was written
