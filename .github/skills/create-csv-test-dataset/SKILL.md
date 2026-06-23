---
name: create-csv-test-dataset
description: "Refactor xUnit tests to use a CSV file as the data source for parameterized test cases. Use when: refactor calculator tests to CSV, create test data CSV, parameterize test data, data-driven tests, CSV test dataset."
---

# Create CSV Test Dataset

## Purpose

Refactor the xUnit test project at `src/workspace/calculator-xunit-testing/calculator.tests/` for the .NET 8 console calculator application to use `TestCases.csv` as the data source for data-driven operation tests. This enables data-driven testing, improves test maintainability, and separates test data from test logic.

This skill is the CSV dataset stage. The default runtime execution path should then move to Testcontainers PostgreSQL via prompt `2.03-switch-test-data-to-pg`.

## Use When

* Refactoring hardcoded test data into external files
* Creating data-driven parameterized tests with xUnit's `MemberData`
* Building maintainable test datasets with multiple operation types
* Testing calculator operations (addition, subtraction, multiplication, division, modulo, exponent)

## Overview

The refactoring process involves four core steps:

1. **Create the CSV file** — Add `TestCases.csv` to the test project root
2. **Configure the project file** — Copy the CSV file to the output directory at build time
3. **Implement CSV parsing logic** — Create public methods to load and parse CSV data
4. **Refactor test methods** — Convert data-driven test methods to use `[MemberData]` attributes pointing to CSV-sourced data

## Step 1: Create the CSV File

### Directory Structure

Create `TestCases.csv` in the test project directory:

```text
calculator.tests/
├── CalculatorTest.cs
├── calculator.tests.csproj
└── TestCases.csv
```

### CSV File Format

Create `TestCases.csv` with the following structure:

```csv
Operand1,Operand2,Operation,ExpectedResult
1,2,Add,3
-5,2,Add,-3
2.5,0.5,Add,3.0
5,3,Subtract,2
5,3,Multiply,15
6,3,Divide,2
7,3,Modulo,1
2,3,Exponent,8
```

**Column definitions:**
- `Operand1` — First operand (double)
- `Operand2` — Second operand (double)
- `Operation` — Calculator operation name (`Add`, `Subtract`, `Multiply`, `Divide`, `Modulo`, or `Exponent`)
- `ExpectedResult` — Expected result of the operation (double)

## Step 2: Configure CSV File in Project

### Update .csproj

Add the CSV file to your `calculator.tests.csproj` to ensure it is copied to the output directory at build time:

```xml
<ItemGroup>
    <None Update="TestCases.csv">
        <CopyToOutputDirectory>Always</CopyToOutputDirectory>
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
    "TestCases.csv"
);
```

**Why `AppContext.BaseDirectory`:** This resolves to the directory where the test assembly is executing (the output directory), ensuring the CSV file is found correctly at runtime.

### Use a CsvHelper Model Class

CsvHelper needs a parameterless model type with settable properties unless you configure constructor mapping. Avoid positional records for this workflow.

```csharp
public class TestCase
{
    public double Operand1 { get; set; }
    public double Operand2 { get; set; }
    public string Operation { get; set; } = string.Empty;
    public double ExpectedResult { get; set; }
}
```

If using a class map, include `using CsvHelper.Configuration;` so `ClassMap<T>` resolves.

### Create Public Data Provider Methods

Add public static methods to your test class. xUnit requires `MemberData` to reference **public** methods:

```csharp
private static IEnumerable<object[]> GetTestCases(string operation)
{
    if (!File.Exists(TestDataPath))
    {
        throw new FileNotFoundException($"Test data file not found: {TestDataPath}");
    }

    using (var reader = new StreamReader(TestDataPath))
    using (var csv = new CsvReader(reader, CultureInfo.InvariantCulture))
    {
        return csv.GetRecords<TestCase>()
            .Where(testCase => testCase.Operation == operation)
            .Select(testCase => new object[] { testCase.Operand1, testCase.Operand2, testCase.ExpectedResult })
            .ToList();
    }
}

public static IEnumerable<object[]> GetAddTestCases() => GetTestCases("Add");
```

## Step 4: Refactor Test Methods

### Use MemberData Attribute

Replace your existing hardcoded test data with the `[MemberData]` attribute:

```csharp
[Theory]
[MemberData(nameof(GetAddTestCases))]
public void Add_ReturnsExpectedResult(double left, double right, double expected)
{
    Assert.Equal(expected, CalculatorOperations.Add(left, right));
}
```

Keep non-data-driven exception tests, such as divide-by-zero or modulo-by-zero checks, as `[Fact]` methods unless they also need externalized data.

## Troubleshooting

### xUnit1016: MemberData must reference a public member

**Cause:** The data provider method is `private`.

**Fix:** Change visibility to `public static`.

### FileNotFoundException: Test data file not found

**Cause:** The CSV file path is incorrect or the file wasn't copied to the output directory.

**Fix:**

* Verify the `.csproj` has the `<CopyToOutputDirectory>Always</CopyToOutputDirectory>` entry
* Run `dotnet clean` and `dotnet build` to ensure the file is copied
* Verify the file path matches: `Path.Combine(AppContext.BaseDirectory, "TestCases.csv")`

### CS0246: ClassMap<> could not be found

**Cause:** `CsvHelper.Configuration` was not imported.

**Fix:** Add `using CsvHelper.Configuration;` or remove the class map when CSV headers match property names exactly.

### MissingMethodException: Constructor TestCase() was not found

**Cause:** CsvHelper attempted to materialize a positional record or another type without a parameterless constructor.

**Fix:** Use a class with a parameterless constructor and settable properties, or configure CsvHelper constructor mapping explicitly.

### Test discovery shows fewer tests than expected

**Cause:** CSV parsing failed silently (invalid format, missing columns, or parse errors).

**Fix:**

* Verify CSV has correct headers with no extra spaces
* Ensure all data rows have exactly 4 columns
* Check that numeric columns are valid doubles
* Add logging to the data provider to debug parsing issues

### Floating-point precision errors

**Cause:** Direct equality comparison of floating-point results.

**Fix:** Use `Assert.Equal(expected, actual, precision: 10)` if calculator behavior produces rounded or non-terminating decimal results. Exact equality is acceptable for values already represented exactly by the current test dataset.

## Quality Checklist

* CSV file exists at `TestCases.csv` in the test project root
* CSV has header row with columns: `Operand1`, `Operand2`, `Operation`, `ExpectedResult`
* All numeric values are valid doubles
* Operations are valid (`Add`, `Subtract`, `Multiply`, `Divide`, `Modulo`, `Exponent`)
* `.csproj` includes `<CopyToOutputDirectory>Always</CopyToOutputDirectory>`
* CsvHelper model has a parameterless constructor and settable properties
* MemberData provider methods are `public static`
* Test methods use `[Theory]` and operation-specific `[MemberData]` providers
* `dotnet clean && dotnet build && dotnet test` all pass
* Test count matches expected number of data rows excluding the header
