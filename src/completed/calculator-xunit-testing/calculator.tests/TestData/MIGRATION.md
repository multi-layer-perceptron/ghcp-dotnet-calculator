# Calculator Test Data Migration: CSV to SQLite

## Overview

This document explains the migration of calculator test data from CSV format to a SQLite database.

## Database Structure

### Table: CalculatorTestData

| Column | Type | Description |
|--------|------|-------------|
| Id | INTEGER PRIMARY KEY AUTOINCREMENT | Unique identifier for each test case |
| FirstNumber | REAL | First operand in the calculation |
| SecondNumber | REAL | Second operand in the calculation |
| Operation | TEXT | Calculator operation (Add, Subtract, Multiply, Divide, Modulo, Exponent) |
| ExpectedValue | REAL | Expected result of the operation |
| Description | TEXT | Human-readable description of the test case |

### Indexes

- `idx_operation` - Index on the Operation column for faster queries

## Migration Process

The test data was migrated from `calculator-test-data.csv` to `calculator-test-data.db` using a custom migration utility. The database contains all 31 test cases that were originally in the CSV file.

### Data Verification

```sql
-- Total number of test cases
SELECT COUNT(*) FROM CalculatorTestData;
-- Result: 31

-- Test cases by operation
SELECT Operation, COUNT(*) as Count 
FROM CalculatorTestData 
GROUP BY Operation 
ORDER BY Operation;
```

Expected distribution:
- Add: 5 test cases
- Subtract: 5 test cases
- Multiply: 5 test cases
- Divide: 5 test cases
- Modulo: 5 test cases
- Exponent: 6 test cases

## Code Changes

### 1. CalculatorTestDataLoader.cs
- Updated to read from SQLite database instead of CSV file
- Uses `Microsoft.Data.Sqlite` package
- Maintains same interface for test data loading

### 2. calculator.tests.csproj
- Added `Microsoft.Data.Sqlite` NuGet package (version 8.0.0)
- Updated to copy `.db` file to output directory instead of `.csv`

### 3. CalculatorTest.cs
- Updated comments to reflect SQLite data source
- Test method renamed from `CalculatorOperations_WithCSVData_ReturnsExpectedResults` to `CalculatorOperations_WithSQLiteData_ReturnsExpectedResults`

## Benefits of SQLite Migration

1. **Structured Data**: Database schema enforces data types and constraints
2. **Query Capability**: Can filter, sort, and query test data using SQL
3. **Scalability**: Better performance with large datasets
4. **Data Integrity**: ACID compliance ensures data consistency
5. **Extensibility**: Easy to add new columns or tables for additional test data

## Backward Compatibility

The CSV file is retained in the repository for reference and potential future migration scenarios. However, the test suite now exclusively uses the SQLite database.

## How to Update Test Data

To add or modify test data:

1. Connect to the SQLite database using a SQLite client or command line:
   ```bash
   sqlite3 TestData/calculator-test-data.db
   ```

2. Insert new test case:
   ```sql
   INSERT INTO CalculatorTestData (FirstNumber, SecondNumber, Operation, ExpectedValue, Description)
   VALUES (10.0, 2.0, 'Divide', 5.0, 'Simple division');
   ```

3. Update existing test case:
   ```sql
   UPDATE CalculatorTestData 
   SET ExpectedValue = 25.0, Description = 'Updated: 5 squared'
   WHERE Id = 27;
   ```

4. Rebuild and run tests:
   ```bash
   dotnet build
   dotnet test
   ```

## Migration Script

A standalone migration utility is available in `/tmp/migration/` that can convert CSV data to SQLite format. This tool was used for the initial migration and can be reused if needed for other CSV files.

## Testing

After migration, all 39 tests continue to pass:
- 31 theory tests (data-driven from SQLite)
- 8 individual fact tests (error handling and specific operations)

Test execution time remains comparable to the CSV-based approach.
