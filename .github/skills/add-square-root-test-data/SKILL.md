---
name: add-square-root-test-data
description: "Add an idempotent SquareRoot theory tuple to CalculatorTest.cs for lab 99.04. Use when: add SquareRoot theory data, add calculator test tuple, add SquareRoot MemberData tuple, lab 99.04 minor test change."
---

# Add SquareRoot Test Data

## Purpose

Add one small SquareRoot theory tuple to the active calculator test project for
lab 99.04. This C# edit provides a realistic, low-risk event that triggers the
post-tool-use build hook while preserving the PostgreSQL-backed CSV data source.

## Target File

* `src/workspace/calculator-xunit-testing/calculator.tests/CalculatorTest.cs`

## Required Steps

1. Open `CalculatorTest.cs` and find `GetSquareRootTestCases`.
2. If the method does not already append the canonical tuple, update it to:

   ```csharp
   public static IEnumerable<object[]> GetSquareRootTestCases() => GetTestCases("SquareRoot")
       .Append(new object[] { 16d, 0d, 4d });
   ```

3. Preserve the `GetTestCases("SquareRoot")` call so the existing PostgreSQL-backed
   CSV cases remain the primary data source.
4. Do not change `TestCases.csv`. This tuple is intentionally a minor C# test
   project change that exercises the build hook separately from CSV-backed data.

## Idempotency Rules

* Do not append the canonical tuple more than once.
* If `GetSquareRootTestCases` already includes `new object[] { 16d, 0d, 4d }`,
  make no code edits.
* If a different appended SquareRoot tuple exists, preserve it and add only the
  canonical tuple when it is missing.
* Leave other test methods, data providers, and CSV rows unchanged.

## Validation

Run the focused calculator test validation after editing:

```powershell
dotnet test src/workspace/calculator-xunit-testing/calculator.tests/calculator.tests.csproj --filter FullyQualifiedName~CalculatorTest --verbosity minimal --artifacts-path artifacts/test-runs/square-root-test-data
```

Then simulate the C# post-tool-use event:

```powershell
$env:TOOL_NAME = 'edit'
$env:FILE_PATH = 'src/workspace/calculator-xunit-testing/calculator.tests/CalculatorTest.cs'
.\scripts\hooks\post-tool-use-dotnet-build.ps1
```

## Expected Outcome

`GetSquareRootTestCases` supplies the PostgreSQL-backed CSV cases plus one
additional `16 -> 4` theory tuple. The edit targets a `.cs` file, so the build
hook runs when it receives the `CalculatorTest.cs` path.
