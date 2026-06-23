---
title: ghcp-dotnet-calculator
description: GitHub Copilot learning workspace for a .NET calculator with xUnit tests
---

## ghcp-dotnet-calculator

This project demonstrates GitHub Copilot concepts and features while building a basic .NET calculator application with comprehensive xUnit testing. The calculator will support standard arithmetic operations and be designed with a focus on testability, maintainability, and proper error handling.

## Workspace

- Setup script: `./src/workspace/Set-DotnetSlnForCalculator.ps1`
- Cleanup script: `./src/workspace/Remove-DotnetSlnForCalculator.ps1`
- Solution: `./src/workspace/calculator-xunit-testing/calculator.sln`

## Run

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File ./src/workspace/Set-DotnetSlnForCalculator.ps1
dotnet test ./src/workspace/calculator-xunit-testing/calculator.sln
dotnet run --project ./src/workspace/calculator-xunit-testing/calculator/calculator.csproj
```

## Test Data Strategy

The calculator test project supports two PostgreSQL-based data workflows:

* Local development workflow: persistent local PostgreSQL Docker container for iterative app/UI refactoring.
* Automated test workflow: Testcontainers PostgreSQL in test execution.

### Why persistent local container is used for local app iteration

* Keeps connection settings stable across local development sessions.
* Supports iterative Blazor UI refactoring backed by realistic PostgreSQL data.
* Enables easier local debugging and data inspection while features evolve.

### Why Testcontainers is preferred for automated tests

* Uses per-run randomized database credentials.
* Avoids fixed host port dependencies and local `5432` conflicts.
* Keeps test runs isolated and reproducible.

### When to use each

Use persistent local container seeding for iterative local app and UI work.
Use Testcontainers for automated tests and CI reliability.

After local behavior is stable, map schema/data expectations from the local container workflow into the Azure PostgreSQL migration plan.

* Prompt for manual seed workflow: `.github/prompts/2.02-convert-csv-test-data-to-postgresql-container.prompt.md`
* Prompt for test refactor workflow: `.github/prompts/2.03-switch-test-data-to-pg.prompt.md`
