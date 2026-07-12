namespace calculator.tests;

using calculator.library;
using System.Globalization;
using System.Security.Cryptography;
using Npgsql;
using Testcontainers.PostgreSql;

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

    public static IEnumerable<object[]> GetAddTestCases() => GetTestCases("Add");

    public static IEnumerable<object[]> GetSubtractTestCases() => GetTestCases("Subtract");

    public static IEnumerable<object[]> GetMultiplyTestCases() => GetTestCases("Multiply");

    public static IEnumerable<object[]> GetDivideTestCases() => GetTestCases("Divide");

    public static IEnumerable<object[]> GetModuloTestCases() => GetTestCases("Modulo");

    public static IEnumerable<object[]> GetPowerTestCases() => GetTestCases("Exponent");

    public static IEnumerable<object[]> GetSquareRootTestCases() => GetTestCases("SquareRoot");

    private static IEnumerable<object[]> GetTestCases(string operation) => PostgreSqlTestData.GetTestCases(operation)
        .Select(testCase => new object[] { testCase.Operand1, testCase.Operand2, testCase.ExpectedResult });
}

internal sealed class CalculatorTestCase
{
    public double Operand1 { get; set; }

    public double Operand2 { get; set; }

    public string Operation { get; set; } = string.Empty;

    public double ExpectedResult { get; set; }
}

internal static class PostgreSqlTestData
{
    private static readonly string TestDataPath = Path.Combine(AppContext.BaseDirectory, "TestCases.csv");

    private static readonly Lazy<Task<IReadOnlyList<CalculatorTestCase>>> TestCases = new(LoadTestCasesAsync);

    public static IEnumerable<CalculatorTestCase> GetTestCases(string operation) => TestCases.Value
        .GetAwaiter()
        .GetResult()
        .Where(testCase => string.Equals(testCase.Operation, operation, StringComparison.OrdinalIgnoreCase))
        .ToList();

    private static async Task<IReadOnlyList<CalculatorTestCase>> LoadTestCasesAsync()
    {
        if (!File.Exists(TestDataPath))
        {
            throw new FileNotFoundException($"Test data file not found: {TestDataPath}");
        }

        var userName = $"calc_user_{Guid.NewGuid():N}";
        var databaseName = $"calc_db_{Guid.NewGuid():N}";
        var password = Convert.ToHexString(RandomNumberGenerator.GetBytes(24));

        var container = new PostgreSqlBuilder("postgres:15.1")
            .WithUsername(userName)
            .WithPassword(password)
            .WithDatabase(databaseName)
            .Build();

        await container.StartAsync();

        await SeedTestCasesAsync(container.GetConnectionString());

        return await QueryTestCasesAsync(container.GetConnectionString());
    }

    private static CalculatorTestCase ParseTestCase(string line)
    {
        var columns = line.Split(',');

        if (columns.Length != 4)
        {
            throw new FormatException($"Invalid test case row: {line}");
        }

        return new CalculatorTestCase
        {
            Operand1 = double.Parse(columns[0], CultureInfo.InvariantCulture),
            Operand2 = double.Parse(columns[1], CultureInfo.InvariantCulture),
            Operation = columns[2].Trim(),
            ExpectedResult = double.Parse(columns[3], CultureInfo.InvariantCulture)
        };
    }

    private static async Task SeedTestCasesAsync(string connectionString)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        await using (var createTableCommand = connection.CreateCommand())
        {
            createTableCommand.CommandText = """
                CREATE TABLE test_data (
                    id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                    operand1 double precision NOT NULL,
                    operand2 double precision NOT NULL,
                    operation text NOT NULL,
                    expected_result double precision NOT NULL
                );
                """;
            await createTableCommand.ExecuteNonQueryAsync();
        }

        foreach (var testCase in File.ReadLines(TestDataPath).Skip(1).Select(ParseTestCase))
        {
            await using var insertCommand = connection.CreateCommand();
            insertCommand.CommandText = """
                INSERT INTO test_data (operand1, operand2, operation, expected_result)
                VALUES (@operand1, @operand2, @operation, @expectedResult);
                """;
            insertCommand.Parameters.AddWithValue("operand1", testCase.Operand1);
            insertCommand.Parameters.AddWithValue("operand2", testCase.Operand2);
            insertCommand.Parameters.AddWithValue("operation", testCase.Operation);
            insertCommand.Parameters.AddWithValue("expectedResult", testCase.ExpectedResult);
            await insertCommand.ExecuteNonQueryAsync();
        }
    }

    private static async Task<IReadOnlyList<CalculatorTestCase>> QueryTestCasesAsync(string connectionString)
    {
        var testCases = new List<CalculatorTestCase>();

        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT operand1, operand2, operation, expected_result
            FROM test_data
            ORDER BY id;
            """;

        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            testCases.Add(new CalculatorTestCase
            {
                Operand1 = reader.GetDouble(0),
                Operand2 = reader.GetDouble(1),
                Operation = reader.GetString(2),
                ExpectedResult = reader.GetDouble(3)
            });
        }

        return testCases;
    }
}