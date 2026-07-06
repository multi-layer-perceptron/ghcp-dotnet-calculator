using calculator;
using Npgsql;
using System.Globalization;
using System.Security.Cryptography;
using Testcontainers.PostgreSql;

namespace calculator.tests;

public class CalculatorTest
{
    [Theory]
    [MemberData(nameof(GetAddTestCases))]
    public void Add_WithTwoOperands_ReturnsSum(double firstOperand, double secondOperand, double expectedResult)
    {
        var actualResult = CalculatorOperations.Add(firstOperand, secondOperand);

        Assert.Equal(expectedResult, actualResult, precision: 10);
    }

    [Theory]
    [MemberData(nameof(GetSubtractTestCases))]
    public void Subtract_WithTwoOperands_ReturnsDifference(double firstOperand, double secondOperand, double expectedResult)
    {
        var actualResult = CalculatorOperations.Subtract(firstOperand, secondOperand);

        Assert.Equal(expectedResult, actualResult, precision: 10);
    }

    [Theory]
    [MemberData(nameof(GetMultiplyTestCases))]
    public void Multiply_WithTwoOperands_ReturnsProduct(double firstOperand, double secondOperand, double expectedResult)
    {
        var actualResult = CalculatorOperations.Multiply(firstOperand, secondOperand);

        Assert.Equal(expectedResult, actualResult, precision: 10);
    }

    [Theory]
    [MemberData(nameof(GetDivideTestCases))]
    public void Divide_WithNonZeroDivisor_ReturnsQuotient(double firstOperand, double secondOperand, double expectedResult)
    {
        var actualResult = CalculatorOperations.Divide(firstOperand, secondOperand);

        Assert.Equal(expectedResult, actualResult, precision: 10);
    }

    [Fact]
    public void Divide_WithZeroDivisor_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Divide(10, 0));
    }

    [Theory]
    [MemberData(nameof(GetModuloTestCases))]
    public void Modulo_WithNonZeroDivisor_ReturnsRemainder(double firstOperand, double secondOperand, double expectedResult)
    {
        var actualResult = CalculatorOperations.Modulo(firstOperand, secondOperand);

        Assert.Equal(expectedResult, actualResult, precision: 10);
    }

    [Fact]
    public void Modulo_WithZeroDivisor_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Modulo(10, 0));
    }

    [Theory]
    [MemberData(nameof(GetPowerTestCases))]
    public void Power_WithTwoOperands_ReturnsPower(double firstOperand, double secondOperand, double expectedResult)
    {
        var actualResult = CalculatorOperations.Power(firstOperand, secondOperand);

        Assert.Equal(expectedResult, actualResult, precision: 10);
    }

    public static IEnumerable<object[]> GetAddTestCases() => PostgreSqlTestData.GetTestCases("Add");

    public static IEnumerable<object[]> GetSubtractTestCases() => PostgreSqlTestData.GetTestCases("Subtract");

    public static IEnumerable<object[]> GetMultiplyTestCases() => PostgreSqlTestData.GetTestCases("Multiply");

    public static IEnumerable<object[]> GetDivideTestCases() => PostgreSqlTestData.GetTestCases("Divide");

    public static IEnumerable<object[]> GetModuloTestCases() => PostgreSqlTestData.GetTestCases("Modulo");

    public static IEnumerable<object[]> GetPowerTestCases() => PostgreSqlTestData.GetTestCases("Exponent");
}

internal static class PostgreSqlTestData
{
    private const string TableName = "test_data";

    private static readonly Lazy<Task<string>> ConnectionStringTask = new(CreateSeededDatabaseAsync);
    private static readonly string TestDataPath = Path.Combine(AppContext.BaseDirectory, "TestCases.csv");

    public static IEnumerable<object[]> GetTestCases(string operation)
    {
        var connectionString = GetConnectionString();
        var testCases = new List<object[]>();

        using var connection = new NpgsqlConnection(connectionString);
        connection.Open();

        using var command = new NpgsqlCommand(
            $"SELECT \"Operand1\", \"Operand2\", \"ExpectedResult\" FROM {TableName} WHERE \"Operation\" = @operation ORDER BY ctid;",
            connection);
        command.Parameters.AddWithValue("operation", operation);

        using var reader = command.ExecuteReader();
        while (reader.Read())
        {
            if (TryReadDatabaseRow(reader, operation, out var testCase))
            {
                testCases.Add(testCase);
            }
        }

        if (testCases.Count == 0)
        {
            throw new InvalidOperationException($"No valid PostgreSQL test rows found for operation '{operation}'.");
        }

        return testCases;
    }

    private static async Task<string> CreateSeededDatabaseAsync()
    {
        if (!File.Exists(TestDataPath))
        {
            throw new FileNotFoundException($"Test data file not found: {TestDataPath}");
        }

        var username = $"calc_user_{Guid.NewGuid():N}";
        var password = Convert.ToHexString(RandomNumberGenerator.GetBytes(24));
        var databaseName = $"calc_db_{Guid.NewGuid():N}";
        var container = new PostgreSqlBuilder("postgres:15.1")
            .WithUsername(username)
            .WithPassword(password)
            .WithDatabase(databaseName)
            .Build();

        try
        {
            await container.StartAsync();
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException("Failed to start the PostgreSQL Testcontainers instance. Verify Docker is running and reachable.", ex);
        }

        var connectionString = container.GetConnectionString();
        await SeedDatabaseAsync(connectionString);
        return connectionString;
    }

    private static string GetConnectionString()
    {
        try
        {
            return ConnectionStringTask.Value.GetAwaiter().GetResult();
        }
        catch (Exception ex) when (ex is not InvalidOperationException and not FileNotFoundException)
        {
            throw new InvalidOperationException("Failed to initialize PostgreSQL test data from Testcontainers.", ex);
        }
    }

    private static async Task SeedDatabaseAsync(string connectionString)
    {
        var testCases = File.ReadLines(TestDataPath)
            .Skip(1)
            .Select(TryParseCsvRow)
            .Where(testCase => testCase is not null)
            .Select(testCase => testCase!)
            .ToList();

        if (testCases.Count == 0)
        {
            throw new InvalidOperationException("No valid rows were found in TestCases.csv.");
        }

        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        await using var createCommand = new NpgsqlCommand(
            $"CREATE TABLE {TableName} (\"Operand1\" TEXT, \"Operand2\" TEXT, \"Operation\" TEXT, \"ExpectedResult\" TEXT);",
            connection);
        await createCommand.ExecuteNonQueryAsync();

        foreach (var testCase in testCases)
        {
            await using var insertCommand = new NpgsqlCommand(
                $"INSERT INTO {TableName} (\"Operand1\", \"Operand2\", \"Operation\", \"ExpectedResult\") VALUES (@operand1, @operand2, @operation, @expectedResult);",
                connection);
            insertCommand.Parameters.AddWithValue("operand1", testCase.Operand1Text);
            insertCommand.Parameters.AddWithValue("operand2", testCase.Operand2Text);
            insertCommand.Parameters.AddWithValue("operation", testCase.Operation);
            insertCommand.Parameters.AddWithValue("expectedResult", testCase.ExpectedResultText);
            await insertCommand.ExecuteNonQueryAsync();
        }
    }

    private static CalculatorTestCase? TryParseCsvRow(string line)
    {
        if (string.IsNullOrWhiteSpace(line))
        {
            return null;
        }

        var columns = line.Split(',');

        if (columns.Length != 4)
        {
            Console.Error.WriteLine($"Skipping malformed CSV row with {columns.Length} columns: {line}");
            return null;
        }

        return new CalculatorTestCase
        {
            Operand1Text = columns[0].Trim(),
            Operand2Text = columns[1].Trim(),
            Operation = columns[2].Trim(),
            ExpectedResultText = columns[3].Trim()
        };
    }

    private static bool TryReadDatabaseRow(NpgsqlDataReader reader, string operation, out object[] testCase)
    {
        var operand1Text = reader.GetString(0);
        var operand2Text = reader.GetString(1);
        var expectedResultText = reader.GetString(2);

        if (double.TryParse(operand1Text, CultureInfo.InvariantCulture, out var operand1)
            && double.TryParse(operand2Text, CultureInfo.InvariantCulture, out var operand2)
            && double.TryParse(expectedResultText, CultureInfo.InvariantCulture, out var expectedResult))
        {
            testCase = [operand1, operand2, expectedResult];
            return true;
        }

        Console.Error.WriteLine($"Skipping malformed PostgreSQL test row for operation '{operation}'.");
        testCase = [];
        return false;
    }

    private sealed class CalculatorTestCase
    {
        public string Operand1Text { get; init; } = string.Empty;

        public string Operand2Text { get; init; } = string.Empty;

        public string Operation { get; init; } = string.Empty;

        public string ExpectedResultText { get; init; } = string.Empty;
    }
}