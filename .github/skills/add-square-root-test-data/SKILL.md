---
name: add-square-root-test-data
description: "Add an idempotent, parameterized SquareRoot test-data row to TestCases.csv for lab 99.04. Use when: add SquareRoot CSV data, add calculator test tuple, add SquareRoot test case, lab 99.04 minor test change."
---

# Add SquareRoot Test Data

## Purpose

Add one parameterized SquareRoot test-data tuple to the active calculator test
project for lab 99.04. The CSV is the source of truth for the PostgreSQL-backed
test-data path.

## Inputs

* `operand`: Required non-negative number whose square root is tested
* `expectedResult`: Required expected square root of `operand`

For the lab demonstration, use `operand=16` and `expectedResult=4`. These
values produce the CSV tuple `(16, 0, SquareRoot, 4)` and row
`16,0,SquareRoot,4`.

## Target File

* `src/workspace/calculator-xunit-testing/calculator.tests/TestCases.csv`

## Required Steps

1. Confirm `operand` is non-negative and `expectedResult` is the intended square
   root for that operand.
2. Open `TestCases.csv` and preserve its four-column header:

   ```csv
   Operand1,Operand2,Operation,ExpectedResult
   ```

3. Add one row using the supplied parameter values and the fixed SquareRoot
   columns: `<operand>,0,SquareRoot,<expectedResult>`.
4. For the lab values `operand=16 expectedResult=4`, add:

   ```csv
   16,0,SquareRoot,4
   ```

5. Do not modify `CalculatorTest.cs`; its existing `MemberData` provider loads
   SquareRoot cases from the PostgreSQL-seeded CSV data.

## Idempotency Rules

* Do not add the parameterized row more than once.
* If the exact row for the supplied values already exists, make no changes.
* Preserve all existing rows, the header, and the final newline.
* Do not change test methods or data providers.

## Validation

Run the focused calculator test validation after editing:

```powershell
dotnet test src/workspace/calculator-xunit-testing/calculator.tests/calculator.tests.csproj --filter FullyQualifiedName~CalculatorTest --verbosity minimal --artifacts-path artifacts/test-runs/square-root-test-data
```

## Expected Outcome

`GetSquareRootTestCases` loads the existing PostgreSQL-backed CSV cases plus the
parameterized SquareRoot row. For the lab values, the theory includes the
additional `16 -> 4` case. A CSV edit does not trigger the C#-only build hook.
