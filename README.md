---
title: ghcp-dotnet-calculator
description: GitHub Copilot learning workspace for a .NET calculator with xUnit tests
---

## ghcp-dotnet-calculator

This project demonstrates GitHub Copilot concepts and features while building a .NET 8 calculator workspace with a console app and xUnit tests. The calculator supports addition, subtraction, multiplication, division, modulo, and exponent operations with input validation and divide-by-zero handling.

## Workspace

- Solution: `./src/workspace/calculator-xunit-testing/calculator.slnx`
- Console app: `./src/workspace/calculator-xunit-testing/calculator/`
- Tests: `./src/workspace/calculator-xunit-testing/calculator.tests/`
- Test data: `./src/workspace/calculator-xunit-testing/calculator.tests/TestCases.csv`
- Setup script: `./src/workspace/Set-DotnetSlnForCalculator.ps1`
- Cleanup script: `./src/workspace/Remove-DotnetSlnForCalculator.ps1`

## Setup and Validate

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File ./src/workspace/Set-DotnetSlnForCalculator.ps1
dotnet test ./src/workspace/calculator-xunit-testing/calculator.slnx
```

Use the cleanup script to remove the generated calculator workspace and verification report when you need to rerun the setup workflow from a clean state:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File ./src/workspace/Remove-DotnetSlnForCalculator.ps1
```

## Run the Console App

```powershell
dotnet run --project ./src/workspace/calculator-xunit-testing/calculator/calculator.csproj
```

## Test Data Strategy

The xUnit project uses `TestCases.csv` for parameterized arithmetic tests. The test project copies this CSV file to the test output directory so `dotnet test` can discover the data at runtime.
