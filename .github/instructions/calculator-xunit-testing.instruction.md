---
name: calculator-xunit-testing
description: "Guidance for the active .NET calculator console, library, Blazor, and xUnit solution"
applyTo: "src/workspace/calculator-xunit-testing/**"
---

# Calculator xUnit Testing Instructions

The Calculator xUnit Testing project is a .NET 10 solution demonstrating shared calculator logic, a console app, a Blazor web app, and xUnit tests.

## Folder Structure

* `src/workspace/calculator-xunit-testing/calculator/`: .NET console project with console interaction
* `src/workspace/calculator-xunit-testing/calculator.library/`: Shared calculator logic used by app and tests
* `src/workspace/calculator-xunit-testing/calculator.web/`: Blazor web app with calculator UI and services
* `src/workspace/calculator-xunit-testing/calculator.tests/`: xUnit test project
* `src/workspace/calculator-xunit-testing/calculator.slnx`: Solution file
* `src/workspace/Set-DotnetSlnForCalculator.ps1`: Script that creates the active solution structure
* `src/workspace/Remove-DotnetSlnForCalculator.ps1`: Script that removes the generated solution structure

## Libraries and Frameworks

* .NET 10.0 target framework
* Blazor Web App with server interactivity
* xUnit test framework
* Npgsql and Testcontainers PostgreSQL for automated PostgreSQL-backed test data
* `Microsoft.NET.Test.Sdk`, `xunit.runner.visualstudio`, and `coverlet.collector` test dependencies in `calculator.tests.csproj`

## Coding Standards

* Use PascalCase for classes, methods, and public members.
* Use camelCase for parameters and local variables.
* Keep calculator logic focused, deterministic, and free of console or web dependencies.
* Keep Blazor UI state in scoped services under `calculator.web/Services/`.
* Keep tests in `CalculatorTest.cs` and use descriptive test names such as `[MethodName]_[Scenario]_[ExpectedBehavior]`.
* Use xUnit `Assert` APIs for test assertions.
* Document public C# members with XML documentation comments.

## Key Practices

Run the following command from the repository root after calculator changes:

```bash
dotnet test src/workspace/calculator-xunit-testing/calculator.slnx
```

* Use `[Fact]` for single-scenario tests.
* Use `[Theory]` with `[InlineData]` or `[MemberData]` when parameterized tests are introduced.
* Keep generated `bin/` and `obj/` output out of documentation examples unless discussing build artifacts.
