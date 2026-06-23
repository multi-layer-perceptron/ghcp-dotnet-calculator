-- SQLite database schema for calculator test data
-- This script creates the table structure to store test cases
-- 
-- Usage:
--   sqlite3 calculator-test-data.db < create-test-database.sql

CREATE TABLE IF NOT EXISTS CalculatorTestData (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstNumber REAL NOT NULL,
    SecondNumber REAL NOT NULL,
    Operation TEXT NOT NULL CHECK(Operation IN ('Add', 'Subtract', 'Multiply', 'Divide', 'Modulo', 'Exponent')),
    ExpectedValue REAL NOT NULL,
    Description TEXT NOT NULL
);

-- Create an index on the Operation column for faster queries
CREATE INDEX IF NOT EXISTS idx_operation ON CalculatorTestData(Operation);

-- Sample queries to verify the schema and data
-- SELECT sql FROM sqlite_master WHERE type='table' AND name='CalculatorTestData';
-- SELECT COUNT(*) as TotalTests FROM CalculatorTestData;
-- SELECT Operation, COUNT(*) as Count FROM CalculatorTestData GROUP BY Operation;
