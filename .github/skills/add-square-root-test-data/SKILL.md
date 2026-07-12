---
name: add-square-root-test-data
description: "Add SquareRoot xUnit MemberData provider and synchronize SquareRoot rows in TestCases.csv for lab 99.04. Use when: add SquareRoot test data, update calculator SquareRoot CSV rows, add GetSquareRootTestCases, lab 99.04 SquareRoot data provider."
---

# Add SquareRoot Test Data

## Purpose

Add the data-provider and CSV test-data updates required by lab 99.04 after the
SquareRoot operation and SquareRoot tests are added to the calculator workspace.

This skill updates the active xUnit test project under
`src/workspace/calculator-xunit-testing/calculator.tests/`. It keeps the CSV file
as the source of truth for the PostgreSQL-backed test data that the tests load at
runtime.

## Use When

* Adding the `SquareRoot` operation test data for lab 99.04
* Adding or repairing the `GetSquareRootTestCases` xUnit data provider
* Synchronizing `SquareRoot` rows in `TestCases.csv`
* Verifying the SquareRoot data-provider path without duplicating rows

## Target Files

* `src/workspace/calculator-xunit-testing/calculator.tests/CalculatorTest.cs`
* `src/workspace/calculator-xunit-testing/calculator.tests/TestCases.csv`

## Required Steps

1. Open `CalculatorTest.cs` and find the existing public `Get*TestCases` methods.
2. Add this provider near the other operation-specific providers if it is not
   already present:

   ```csharp
   public static IEnumerable<object[]> GetSquareRootTestCases() => GetTestCases("SquareRoot");
   ```

3. Open `TestCases.csv` and confirm it has the header
   `Operand1,Operand2,Operation,ExpectedResult`.
4. Ensure these exact rows exist once, with no duplicates:

   ```csv
   0,0,SquareRoot,0
   4,0,SquareRoot,2
   9,0,SquareRoot,3
   2,0,SquareRoot,1.4142135623730951
   ```

5. Preserve the existing four-column CSV shape. Square root uses one operand, so
   keep `Operand2` as `0`.
6. Preserve existing non-SquareRoot rows and operation names.
7. Keep the CSV file ending with a single trailing newline.

## Idempotency Rules

* Do not add a second `GetSquareRootTestCases` method if one already exists.
* Do not duplicate any `SquareRoot` CSV row.
* If old or incorrect `SquareRoot` rows exist, replace the `SquareRoot` block
  with the four canonical rows above.
* Leave unrelated tests, providers, and CSV rows unchanged.

## Validation

Run the focused calculator test validation after editing:

```powershell
& 'C:\Program Files\dotnet\dotnet.exe' test src/workspace/calculator-xunit-testing/calculator.tests/calculator.tests.csproj --filter FullyQualifiedName~CalculatorTest --verbosity minimal --artifacts-path artifacts/test-runs/square-root
```

If `dotnet` is available on `PATH`, the equivalent `dotnet test` command is
acceptable. The isolated `--artifacts-path` avoids build output locks when the
Blazor web app is already running.

## Expected Outcome

The SquareRoot theory can use `[MemberData(nameof(GetSquareRootTestCases))]`, and
the test project's PostgreSQL Testcontainer receives matching `SquareRoot` rows
because it seeds runtime test data from `TestCases.csv`.