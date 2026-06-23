using Microsoft.Data.Sqlite;

namespace calculator.tests;

/// <summary>
/// Utility class to migrate test data from CSV to SQLite database.
/// This is a one-time migration tool that can be run to create the initial database.
/// Note: This implementation uses simple CSV parsing (comma-delimited) and expects
/// that Description fields do not contain commas. For production use with complex
/// CSV data, consider using a proper CSV parsing library like CsvHelper.
/// </summary>
public class TestDataMigration
{
    /// <summary>
    /// Migrates test data from CSV file to SQLite database.
    /// </summary>
    /// <param name="csvPath">Path to the CSV file.</param>
    /// <param name="dbPath">Path where the SQLite database should be created.</param>
    public static void MigrateCsvToSqlite(string csvPath, string dbPath)
    {
        if (!File.Exists(csvPath))
        {
            throw new FileNotFoundException($"CSV file not found: {csvPath}");
        } // end if

        // Delete existing database if it exists
        if (File.Exists(dbPath))
        {
            File.Delete(dbPath);
        } // end if

        // Create database and schema
        var connectionString = $"Data Source={dbPath}";
        using (var connection = new SqliteConnection(connectionString))
        {
            connection.Open();

            // Create table
            var createTableCommand = connection.CreateCommand();
            createTableCommand.CommandText = @"
                CREATE TABLE IF NOT EXISTS CalculatorTestData (
                    Id INTEGER PRIMARY KEY AUTOINCREMENT,
                    FirstNumber REAL NOT NULL,
                    SecondNumber REAL NOT NULL,
                    Operation TEXT NOT NULL,
                    ExpectedValue REAL NOT NULL,
                    Description TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_operation ON CalculatorTestData(Operation);
            ";
            createTableCommand.ExecuteNonQuery();

            // Read CSV and insert data
            var lines = File.ReadAllLines(csvPath).Skip(1); // Skip header row
            int count = 0;
            int lineNumber = 1; // Start at 1 for header

            foreach (var line in lines)
            {
                lineNumber++;
                
                // Skip empty lines
                if (string.IsNullOrWhiteSpace(line))
                {
                    continue;
                } // end if
                
                var parts = line.Split(',');
                if (parts.Length >= 5)
                {
                    // Parse and validate numeric values
                    if (!double.TryParse(parts[0], out double firstNumber))
                    {
                        throw new FormatException($"Line {lineNumber}: Invalid FirstNumber value '{parts[0]}'");
                    } // end if
                    
                    if (!double.TryParse(parts[1], out double secondNumber))
                    {
                        throw new FormatException($"Line {lineNumber}: Invalid SecondNumber value '{parts[1]}'");
                    } // end if
                    
                    var operation = parts[2].Trim();
                    
                    if (!double.TryParse(parts[3], out double expectedValue))
                    {
                        throw new FormatException($"Line {lineNumber}: Invalid ExpectedValue '{parts[3]}'");
                    } // end if
                    
                    var description = parts[4].Trim();

                    var insertCommand = connection.CreateCommand();
                    insertCommand.CommandText = @"
                        INSERT INTO CalculatorTestData (FirstNumber, SecondNumber, Operation, ExpectedValue, Description)
                        VALUES ($firstNumber, $secondNumber, $operation, $expectedValue, $description)
                    ";
                    insertCommand.Parameters.AddWithValue("$firstNumber", firstNumber);
                    insertCommand.Parameters.AddWithValue("$secondNumber", secondNumber);
                    insertCommand.Parameters.AddWithValue("$operation", operation);
                    insertCommand.Parameters.AddWithValue("$expectedValue", expectedValue);
                    insertCommand.Parameters.AddWithValue("$description", description);
                    insertCommand.ExecuteNonQuery();
                    count++;
                }
                else
                {
                    throw new FormatException($"Line {lineNumber}: Expected at least 5 columns, found {parts.Length}");
                } // end else
            } // end foreach
        } // end using

        Console.WriteLine($"Successfully migrated {File.ReadAllLines(csvPath).Skip(1).Count()} test cases to SQLite database: {dbPath}");
    } // end MigrateCsvToSqlite
}
