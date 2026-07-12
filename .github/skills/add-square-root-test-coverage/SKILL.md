---
name: add-square-root-test-coverage
description: "Add idempotent SquareRoot xUnit tests, MemberData provider, and TestCases.csv rows for lab 99.04. Use when: add SquareRoot test coverage, add SquareRoot MemberData tests, update calculator SquareRoot CSV rows, add GetSquareRootTestCases, lab 99.04 SquareRoot tests."
---

# Add SquareRoot Test Coverage

## Purpose

Add the SquareRoot test coverage required by lab 99.04 while preserving the
calculator test project's existing PostgreSQL-backed `[MemberData]` pattern.

This skill updates the active xUnit test project under
`src/workspace/calculator-xunit-testing/calculator.tests/`. It adds the
SquareRoot theory and exception tests, adds the matching public data provider,
and keeps `TestCases.csv` as the source of truth for the PostgreSQL-backed test
data that the tests load at runtime.

## Use When

* Adding the `SquareRoot` operation tests for lab 99.04
* Adding or repairing the `SquareRoot_WithNonNegativeOperand_ReturnsSquareRoot`
  theory
* Adding or repairing the `SquareRoot_WithNegativeOperand_ThrowsArgumentOutOfRangeException`
  fact
* Adding or repairing the `GetSquareRootTestCases` xUnit data provider
* Synchronizing `SquareRoot` rows in `TestCases.csv`
* Verifying the SquareRoot test path without duplicating methods, providers, or
  rows

## Target Files

* `src/workspace/calculator-xunit-testing/calculator.tests/CalculatorTest.cs`
* `src/workspace/calculator-xunit-testing/calculator.tests/TestCases.csv`

## Required Steps

1. Open `CalculatorTest.cs` and find the existing operation tests.
2. Add these tests near the other operation tests if they are not already
   present:

   ```csharp
   [Theory]
   [MemberData(nameof(GetSquareRootTestCases))]
   public void SquareRoot_WithNonNegativeOperand_ReturnsSquareRoot(
       double operand,
       double ignoredSecondOperand,
       double expectedResult)
   {
       _ = ignoredSecondOperand;

       var actualResult = CalculatorOperations.SquareRoot(operand);

       Assert.Equal(expectedResult, actualResult, precision: 10);
   }

   [Fact]
   public void SquareRoot_WithNegativeOperand_ThrowsArgumentOutOfRangeException()
   {
       Assert.Throws<ArgumentOutOfRangeException>(() => CalculatorOperations.SquareRoot(-1));
   }
   ```

3. Open `CalculatorTest.cs` and find the existing public `Get*TestCases`
   methods.
4. Add this provider near the other operation-specific providers if it is not
   already present:

   ```csharp
   public static IEnumerable<object[]> GetSquareRootTestCases() => GetTestCases("SquareRoot");
   ```

5. Open `TestCases.csv` and confirm it has the header
   `Operand1,Operand2,Operation,ExpectedResult`.
6. Ensure these exact rows exist once, with no duplicates:

   ```csv
   0,0,SquareRoot,0
   4,0,SquareRoot,2
   9,0,SquareRoot,3
   2,0,SquareRoot,1.4142135623730951
   ```

7. Preserve the existing four-column CSV shape. Square root uses one operand, so
   keep `Operand2` as `0`.
8. Preserve existing non-SquareRoot tests, providers, CSV rows, and operation
   names.
9. Keep the CSV file ending with a single trailing newline.

## Idempotency Rules

* Do not add a second `SquareRoot_WithNonNegativeOperand_ReturnsSquareRoot`
  method if one already exists.
* Do not add a second
  `SquareRoot_WithNegativeOperand_ThrowsArgumentOutOfRangeException` method if
  one already exists.
* Do not add a second `GetSquareRootTestCases` method if one already exists.
* If a SquareRoot test method exists but is missing `_ = ignoredSecondOperand;`,
  add that discard assignment inside the existing method instead of adding a new
  method.
* If the non-negative SquareRoot theory does not reference
  `GetSquareRootTestCases`, update the existing SquareRoot theory to use
  `[MemberData(nameof(GetSquareRootTestCases))]` instead of adding a new theory.
* Do not duplicate any `SquareRoot` CSV row.
* If old or incorrect `SquareRoot` rows exist, replace only the `SquareRoot` rows
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

`CalculatorTest.cs` contains one SquareRoot theory, one negative-input fact, and
one `GetSquareRootTestCases` provider. `TestCases.csv` contains the four
canonical `SquareRoot` rows exactly once. The test project's PostgreSQL
Testcontainer receives matching `SquareRoot` rows because it seeds runtime test
data from `TestCases.csv`.