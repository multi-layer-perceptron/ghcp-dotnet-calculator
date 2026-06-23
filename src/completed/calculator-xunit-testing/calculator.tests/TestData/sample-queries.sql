-- Sample SQL queries for exploring calculator test data
-- Usage: sqlite3 calculator-test-data.db < sample-queries.sql

.mode column
.headers on

-- Query 1: Count total test cases
SELECT 'Total Test Cases:' as Query, COUNT(*) as Result FROM CalculatorTestData;

-- Query 2: Test cases by operation type
SELECT Operation, COUNT(*) as TestCount 
FROM CalculatorTestData 
GROUP BY Operation 
ORDER BY Operation;

-- Query 3: All Add operation tests
SELECT Id, FirstNumber, SecondNumber, ExpectedValue, Description 
FROM CalculatorTestData 
WHERE Operation = 'Add';

-- Query 4: Tests involving negative numbers
SELECT Id, FirstNumber, SecondNumber, Operation, ExpectedValue, Description 
FROM CalculatorTestData 
WHERE FirstNumber < 0 OR SecondNumber < 0;

-- Query 5: Tests with decimal/fractional numbers
SELECT Id, FirstNumber, SecondNumber, Operation, ExpectedValue, Description 
FROM CalculatorTestData 
WHERE FirstNumber != CAST(FirstNumber AS INTEGER) 
   OR SecondNumber != CAST(SecondNumber AS INTEGER);

-- Query 6: Tests with zero operands
SELECT Id, FirstNumber, SecondNumber, Operation, ExpectedValue, Description 
FROM CalculatorTestData 
WHERE FirstNumber = 0 OR SecondNumber = 0;

-- Query 7: Exponent operation tests (showing power calculations)
SELECT Id, FirstNumber || '^' || SecondNumber as Expression, 
       ExpectedValue as Result, Description 
FROM CalculatorTestData 
WHERE Operation = 'Exponent';

-- Query 8: Complex queries - Operations that produce zero
SELECT Operation, COUNT(*) as ZeroResultCount 
FROM CalculatorTestData 
WHERE ExpectedValue = 0 
GROUP BY Operation;
