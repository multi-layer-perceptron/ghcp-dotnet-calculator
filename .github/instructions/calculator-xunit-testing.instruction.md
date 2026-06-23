---
description: "Guidance for the active .NET calculator console and xUnit solution"
applyTo: "src/workspace/calculator-xunit-testing/**"
---

# Calculator xUnit Testing Instructions

The Calculator xUnit Testing project is a .NET 8.0 solution demonstrating calculator logic and xUnit tests. The active workspace contains a console application project and a test project only.

## Folder Structure

* `src/workspace/calculator-xunit-testing/calculator/`: .NET console project with calculator implementation
* `src/workspace/calculator-xunit-testing/calculator.tests/`: xUnit test project
* `src/workspace/calculator-xunit-testing/calculator.sln`: Solution file
* `src/workspace/Set-DotnetSlnForCalculator.ps1`: Script that creates the active solution structure
* `src/workspace/Remove-DotnetSlnForCalculator.ps1`: Script that removes the generated solution structure

## Libraries and Frameworks

* .NET 8.0 target framework
* xUnit test framework
* `Microsoft.NET.Test.Sdk`, `xunit.runner.visualstudio`, and `coverlet.collector` test dependencies in `calculator.tests.csproj`

## Coding Standards

* Use PascalCase for classes, methods, and public members.
* Use camelCase for parameters and local variables.
* Keep calculator logic focused and deterministic.
* Keep tests in `CalculatorTest.cs` and use descriptive test names such as `[MethodName]_[Scenario]_[ExpectedBehavior]`.
* Use xUnit `Assert` APIs for test assertions.
* Document public C# members with XML documentation comments.

## Key Practices

Run the following command from the repository root after calculator changes:

```bash
dotnet test src/workspace/calculator-xunit-testing/calculator.sln
```

* Use `[Fact]` for single-scenario tests.
* Use `[Theory]` with `[InlineData]` or `[MemberData]` when parameterized tests are introduced.
* Keep generated `bin/` and `obj/` output out of documentation examples unless discussing build artifacts.
