---
name: create-csv-test-dataset
description: "Refactor xUnit tests to use a CSV file as the data source for parameterized test cases. Use when: refactor calculator tests to CSV, create test data CSV, parameterize test data, data-driven tests, CSV test dataset."
---

# Create CSV Test Dataset

## Purpose

Refactor the existing xUnit test project for the .NET 8 console calculator application to utilize a CSV file as the data source for test cases. This enables data-driven testing, improves test maintainability, and separates test data from test logic.

## Use When

- Refactoring hardcoded test data into external files
- Creating data-driven parameterized tests with xUnit's `MemberData`
- Building maintainable test datasets with multiple operation types
- Testing calculator operations (addition, subtraction, multiplication, division, modulo, exponent)

## Overview

The refactoring process involves three core steps:

1. **Create TestData folder and CSV file** — Establish the test data structure
2. **Implement CSV parsing logic** — Create public methods to load and parse CSV data
3. **Refactor test methods** — Convert test methods to use `[MemberData]` attributes pointing to CSV-sourced data

## Step 1: Create TestData Folder and CSV File

### Directory Structure

Create a new folder `TestData` inside the test project directory:

```
calculator.tests/
├── CalculatorTest.cs
├── calculator.tests.csproj
└── TestData/
    └── CalculatorTestData.csv
```

### CSV File Format

Create `CalculatorTestData.csv` with the following structure:

```csv
firstNumber,secondNumber,operator,expectedResult,testDescription
10,5,+,15,Basic addition
10,5,-,5,Basic subtraction
10,5,*,50,Basic multiplication
10,2,/,5,Basic division
10,3,%,1,Modulo operation
2,3,^,8,Exponent (power)
0,5,+,5,Addition with zero
5,0,-,5,Subtraction with zero
5,0,*,0,Multiplication by zero
100,0,/,Infinity,Division by zero
```

**Column definitions:**
- `firstNumber` — First operand (double)
- `secondNumber` — Second operand (double)
- `operator` — Arithmetic operator (+, -, *, /, %, ^)
- `expectedResult` — Expected result of the operation (double or special value like "Infinity")
- `testDescription` — Human-readable description of the test case

## Step 2: Configure CSV File in Project

### Update .csproj

Add the CSV file to your `calculator.tests.csproj` to ensure it is copied to the output directory at build time:

```xml
<ItemGroup>
  <None Update="TestData\CalculatorTestData.csv">
    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
  </None>
</ItemGroup>
```

**Why this is required:** During build, the test assembly runs from the output directory (e.g., `bin/Debug/net8.0/`), not the source directory. Without this configuration, the CSV file won't be available to the tests at runtime.

## Step 3: Implement CSV Parsing Logic

### Define the Test Data Path

Add this static field to your test class:

```csharp
private static readonly string TestDataPath = Path.Combine(
    AppContext.BaseDirectory,
    "TestData",
    "CalculatorTestData.csv"
);
```

**Why `AppContext.BaseDirectory`:** This resolves to the directory where the test assembly is executing (the output directory), ensuring the CSV file is found correctly at runtime.

### Create a Public Data Provider Method

Add this public static method to your test class. xUnit requires `MemberData` to reference **public** methods only:

```csharp
public static IEnumerable<object[]> LoadTestDataFromCsv()
{
    if (!File.Exists(TestDataPath))
        throw new FileNotFoundException($"Test data file not found: {TestDataPath}");

    var lines = File.ReadAllLines(TestDataPath);

    foreach (var line in lines.Skip(1)) // Skip header row
    {
        if (string.IsNullOrWhiteSpace(line))
            continue;

        var parts = line.Split(',');
        if (parts.Length < 5)
            continue;

        // Parse CSV columns
        if (double.TryParse(parts[0].Trim(), out double firstNumber) &&
            double.TryParse(parts[1].Trim(), out double secondNumber) &&
            double.TryParse(parts[3].Trim(), out double expectedResult))
        {
            yield return new object[]
            {
                firstNumber,
                secondNumber,
                parts[2].Trim(),        // operator
                expectedResult,
                parts[4].Trim()         // testDescription
            };
        }
    }
}
```

### Handle Special Values

For operations like division by zero that produce `Infinity` or `NaN`, update your CSV to use these string representations and parse them appropriately:

```csharp
if (parts[3].Trim() == "Infinity")
{
    expectedResult = double.PositiveInfinity;
}
else if (parts[3].Trim() == "NaN")
{
    expectedResult = double.NaN;
}
```

## Step 4: Refactor Test Methods

### Use MemberData Attribute

Replace your existing hardcoded test data with the `[MemberData]` attribute:

```csharp
[Theory]
[MemberData(nameof(LoadTestDataFromCsv))]
public void PerformCalculation_WithValidInput_ReturnsExpectedResult(
    double firstNumber,
    double secondNumber,
    string op,
    double expectedResult,
    string testDescription)
{
    // Arrange
    int firstNum = (int)firstNumber;
    int secondNum = (int)secondNumber;

    // Act
    int result = Calculator.Calculate(firstNum, secondNum, op);

    // Assert
    // Handle floating-point precision for division and power operations
    if (op == "^" || op == "/")
    {
        Assert.Equal(expectedResult, result, precision: 10);
    }
    else
    {
        Assert.Equal(expectedResult, result);
    }
}
```

### Important Precision Handling

For division (`/`) and exponent (`^`) operations, use precision parameter to account for floating-point rounding errors:

```csharp
Assert.Equal(expectedResult, result, precision: 10);
```

This compares the results with 10 decimal places of precision rather than exact equality.

## Troubleshooting

### xUnit1016: MemberData must reference a public member

**Cause:** The data provider method is `private`.

**Fix:** Change visibility to `public static`.

### FileNotFoundException: Test data file not found

**Cause:** The CSV file path is incorrect or the file wasn't copied to the output directory.

**Fix:** 
- Verify the `.csproj` has the `<CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>` entry
- Run `dotnet clean` and `dotnet build` to ensure the file is copied
- Verify the file path matches: `AppContext.BaseDirectory + "TestData/CalculatorTestData.csv"`

### Test discovery shows fewer tests than expected

**Cause:** CSV parsing failed silently (invalid format, missing columns, or parse errors).

**Fix:**
- Verify CSV has correct headers (no extra spaces)
- Ensure all data rows have exactly 5 columns
- Check that numeric columns are valid doubles
- Add logging to the data provider to debug parsing issues

### Floating-point precision errors on division results

**Cause:** Direct equality comparison of floating-point results.

**Fix:** Use `Assert.Equal(expected, actual, precision: 10)` for division and power operations.

## Quality Checklist

- ✅ CSV file exists at `TestData/CalculatorTestData.csv`
- ✅ CSV has header row with columns: firstNumber, secondNumber, operator, expectedResult, testDescription
- ✅ All numeric values are valid doubles
- ✅ Operators are valid (+, -, *, /, %, ^)
- ✅ `.csproj` includes `<CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>`
- ✅ Data provider method is `public static`
- ✅ Test method uses `[Theory]` and `[MemberData(nameof(LoadTestDataFromCsv))]`
- ✅ `dotnet clean && dotnet build && dotnet test` all pass
- ✅ Test count matches expected number of data rows (excluding header)
