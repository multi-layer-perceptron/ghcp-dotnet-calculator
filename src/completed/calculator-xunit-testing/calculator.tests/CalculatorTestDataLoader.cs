namespace calculator.tests;

using System.Reflection;
using Microsoft.Data.Sqlite;
using Xunit;

/// <summary>
/// Helper class to load and parse test data from SQLite database.
/// </summary>
public class CalculatorTestDataLoader
{
    /// <summary>
    /// Gets the path to the test data SQLite database file.
    /// </summary>
    private static string GetTestDataPath()
    {
        var assemblyLocation = typeof(CalculatorTestDataLoader).Assembly.Location;
        var assemblyDirectory = Path.GetDirectoryName(assemblyLocation);
        return Path.Combine(assemblyDirectory!, "TestData", "calculator-test-data.db");
    } // end GetTestDataPath

    /// <summary>
    /// Loads test data from SQLite database and returns as list of objects for Theory tests.
    /// </summary>
    /// <returns>Collection of objects containing test data.</returns>
    public static IEnumerable<object[]> GetTestData()
    {
        var dbPath = GetTestDataPath();

        if (!File.Exists(dbPath))
        {
            throw new FileNotFoundException($"Test data database not found: {dbPath}");
        } // end if

        var connectionString = $"Data Source={dbPath}";
        using var connection = new SqliteConnection(connectionString);
        connection.Open();

        using var command = connection.CreateCommand();
        command.CommandText = @"
            SELECT FirstNumber, SecondNumber, Operation, ExpectedValue, Description
            FROM CalculatorTestData
            ORDER BY Id
        ";

        using var reader = command.ExecuteReader();
        while (reader.Read())
        {
            var firstNumber = reader.GetDouble(0);
            var secondNumber = reader.GetDouble(1);
            var operation = reader.GetString(2);
            var expectedValue = reader.GetDouble(3);
            var description = reader.GetString(4);

            yield return new object[] { firstNumber, secondNumber, operation, expectedValue, description };
        } // end while
    } // end GetTestData
}
