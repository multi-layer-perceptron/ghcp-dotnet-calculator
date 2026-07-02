using System.Globalization;
using calculator;
using Npgsql;
using Testcontainers.PostgreSql;

namespace calculator.tests;

public class CalculatorTest
{
    private static readonly Lazy<IReadOnlyList<CalculatorTestCase>> TestCases = new(LoadAllTestCasesFromPostgres);

    [Theory]
    [MemberData(nameof(GetAddTestCases))]
    public void GivenOperands_WhenAdd_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Add(left, right));
    }

    public static IEnumerable<object[]> GetAddTestCases() => GetTestCases("Add");

    public static IEnumerable<object[]> GetDivideTestCases() => GetTestCases("Divide");

    public static IEnumerable<object[]> GetExponentTestCases() => GetTestCases("Exponent");

    public static IEnumerable<object[]> GetModuloTestCases() => GetTestCases("Modulo");

    public static IEnumerable<object[]> GetMultiplyTestCases() => GetTestCases("Multiply");

    public static IEnumerable<object[]> GetSubtractTestCases() => GetTestCases("Subtract");

    private static IEnumerable<object[]> GetTestCases(string operation)
    {
        return TestCases.Value
            .Where(testCase => testCase.Operation.Equals(operation, StringComparison.OrdinalIgnoreCase))
            .Select(testCase => new object[] { testCase.Operand1, testCase.Operand2, testCase.ExpectedResult })
            .ToList();
    }

    private static IReadOnlyList<CalculatorTestCase> LoadAllTestCasesFromPostgres()
    {
        const string tableName = "test_data";
        string connectionString = TestDatabase.Container.GetConnectionString();
        var results = new List<CalculatorTestCase>();

        try
        {
            using var connection = new NpgsqlConnection(connectionString);
            connection.Open();

            using var command = new NpgsqlCommand(
                $"SELECT \"Operand1\", \"Operand2\", \"Operation\", \"ExpectedResult\" FROM \"{tableName}\";",
                connection);
            using var reader = command.ExecuteReader();

            int rowNumber = 0;
            while (reader.Read())
            {
                rowNumber++;

                string operand1Text = reader.IsDBNull(0) ? string.Empty : reader.GetValue(0)?.ToString() ?? string.Empty;
                string operand2Text = reader.IsDBNull(1) ? string.Empty : reader.GetValue(1)?.ToString() ?? string.Empty;
                string operation = reader.IsDBNull(2) ? string.Empty : reader.GetValue(2)?.ToString() ?? string.Empty;
                string expectedText = reader.IsDBNull(3) ? string.Empty : reader.GetValue(3)?.ToString() ?? string.Empty;

                if (!double.TryParse(operand1Text, NumberStyles.Float | NumberStyles.AllowThousands, CultureInfo.InvariantCulture, out double operand1) ||
                    !double.TryParse(operand2Text, NumberStyles.Float | NumberStyles.AllowThousands, CultureInfo.InvariantCulture, out double operand2) ||
                    !double.TryParse(expectedText, NumberStyles.Float | NumberStyles.AllowThousands, CultureInfo.InvariantCulture, out double expectedResult) ||
                    string.IsNullOrWhiteSpace(operation))
                {
                    Console.WriteLine(
                        $"Skipping malformed row {rowNumber} in table '{tableName}': Operand1='{operand1Text}', Operand2='{operand2Text}', Operation='{operation}', ExpectedResult='{expectedText}'.");
                    continue;
                }

                results.Add(new CalculatorTestCase
                {
                    Operand1 = operand1,
                    Operand2 = operand2,
                    Operation = operation.Trim(),
                    ExpectedResult = expectedResult
                });
            }
        }
        catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UndefinedTable)
        {
            throw new InvalidOperationException(
                $"The PostgreSQL table '{tableName}' does not exist in the Testcontainers database. Ensure CSV seeding completed successfully.", ex);
        }
        catch (NpgsqlException ex)
        {
            throw new InvalidOperationException(
                "Unable to load test cases from the Testcontainers PostgreSQL instance. Verify Docker availability and container startup.", ex);
        }

        return results;
    }

    [Theory]
    [MemberData(nameof(GetDivideTestCases))]
    public void GivenOperands_WhenDivide_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Divide(left, right));
    }

    [Theory]
    [MemberData(nameof(GetExponentTestCases))]
    public void GivenOperands_WhenExponent_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Exponent(left, right));
    }

    [Fact]
    public void GivenZeroDivisor_WhenDivide_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Divide(5, 0));
    }

    [Theory]
    [MemberData(nameof(GetModuloTestCases))]
    public void GivenOperands_WhenModulo_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Modulo(left, right));
    }

    [Fact]
    public void GivenZeroDivisor_WhenModulo_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Modulo(5, 0));
    }

    [Theory]
    [MemberData(nameof(GetMultiplyTestCases))]
    public void GivenOperands_WhenMultiply_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Multiply(left, right));
    }

    [Theory]
    [MemberData(nameof(GetSubtractTestCases))]
    public void GivenOperands_WhenSubtract_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Subtract(left, right));
    }

    private sealed class CalculatorTestCase
    {
        public double ExpectedResult { get; set; }

        public double Operand1 { get; set; }

        public double Operand2 { get; set; }

        public string Operation { get; set; } = string.Empty;
    }

    private static class TestDatabase
    {
        private static readonly object SyncRoot = new();

        private static PostgreSqlContainer? container;

        public static PostgreSqlContainer Container
        {
            get
            {
                lock (SyncRoot)
                {
                    container ??= StartAndSeedContainer();
                    return container;
                }
            }
        }

        private static PostgreSqlContainer StartAndSeedContainer()
        {
            string suffix = Guid.NewGuid().ToString("N")[..12];
            var testContainer = new PostgreSqlBuilder("postgres:16-alpine")
                .WithDatabase($"calc_tests_{suffix}")
                .WithUsername($"calc_user_{suffix}")
                .WithPassword(GeneratePassword())
                .Build();

            try
            {
                testContainer.StartAsync().GetAwaiter().GetResult();
                SeedFromCsv(testContainer);
            }
            catch (Exception ex) when (ex is InvalidOperationException or TimeoutException or Docker.DotNet.DockerApiException)
            {
                throw new InvalidOperationException(
                    "Unable to start or seed the Testcontainers PostgreSQL instance. Verify Docker is running and accessible.", ex);
            }

            AppDomain.CurrentDomain.ProcessExit += (_, _) =>
            {
                try
                {
                    testContainer.DisposeAsync().AsTask().GetAwaiter().GetResult();
                }
                catch
                {
                    // Best-effort cleanup at process shutdown.
                }
            };

            return testContainer;
        }

        private static string GeneratePassword()
        {
            return Convert.ToBase64String(System.Security.Cryptography.RandomNumberGenerator.GetBytes(18)) + "!A1";
        }

        private static void SeedFromCsv(PostgreSqlContainer testContainer)
        {
            string csvPath = ResolveCsvPath();
            string[] lines = File.ReadAllLines(csvPath);

            if (lines.Length <= 1)
            {
                throw new InvalidOperationException($"CSV test case file '{csvPath}' does not contain data rows.");
            }

            using var connection = new NpgsqlConnection(testContainer.GetConnectionString());
            connection.Open();

            using (var create = new NpgsqlCommand(
                "CREATE TABLE IF NOT EXISTS \"test_data\" (\"Operand1\" TEXT, \"Operand2\" TEXT, \"Operation\" TEXT, \"ExpectedResult\" TEXT);",
                connection))
            {
                create.ExecuteNonQuery();
            }

            using (var truncate = new NpgsqlCommand("TRUNCATE TABLE \"test_data\";", connection))
            {
                truncate.ExecuteNonQuery();
            }

            foreach (string row in lines.Skip(1))
            {
                if (string.IsNullOrWhiteSpace(row))
                {
                    continue;
                }

                string[] columns = row.Split(',');
                if (columns.Length != 4)
                {
                    Console.WriteLine($"Skipping malformed CSV row during seed: '{row}'");
                    continue;
                }

                using var insert = new NpgsqlCommand(
                    "INSERT INTO \"test_data\" (\"Operand1\", \"Operand2\", \"Operation\", \"ExpectedResult\") VALUES (@operand1, @operand2, @operation, @expectedResult);",
                    connection);
                insert.Parameters.AddWithValue("operand1", columns[0].Trim());
                insert.Parameters.AddWithValue("operand2", columns[1].Trim());
                insert.Parameters.AddWithValue("operation", columns[2].Trim());
                insert.Parameters.AddWithValue("expectedResult", columns[3].Trim());
                insert.ExecuteNonQuery();
            }
        }

        private static string ResolveCsvPath()
        {
            string fromBaseDirectory = Path.Combine(AppContext.BaseDirectory, "TestCases.csv");
            if (File.Exists(fromBaseDirectory))
            {
                return fromBaseDirectory;
            }

            string fromCurrentDirectory = Path.Combine(Directory.GetCurrentDirectory(), "TestCases.csv");
            if (File.Exists(fromCurrentDirectory))
            {
                return fromCurrentDirectory;
            }

            throw new FileNotFoundException(
                "TestCases.csv was not found. Ensure the file is copied to the test output directory.");
        }
    }
}
