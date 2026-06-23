using System.Globalization;
using calculator;
using Npgsql;
using Testcontainers.PostgreSql;

namespace calculator.tests;

public class TestCase
{
    public double Operand1 { get; set; }
    public double Operand2 { get; set; }
    public string Operation { get; set; } = string.Empty;
    public double ExpectedResult { get; set; }
}

public class CalculatorTest
{
    private static readonly Lazy<IReadOnlyList<TestCase>> TestCases = new(LoadAllTestCasesFromPostgres);

    private static IEnumerable<object[]> GetTestCases(string operation)
    {
        return TestCases.Value
            .Where(testCase => testCase.Operation.Equals(operation, StringComparison.OrdinalIgnoreCase))
            .Select(testCase => new object[] { testCase.Operand1, testCase.Operand2, testCase.ExpectedResult })
            .ToList();
    }

    private static IReadOnlyList<TestCase> LoadAllTestCasesFromPostgres()
    {
        var table = "test_data";
        var connectionString = TestDatabase.Container.GetConnectionString();

        var results = new List<TestCase>();

        try
        {
            using var connection = new NpgsqlConnection(connectionString);
            connection.Open();

            var sql = $"SELECT \"Operand1\", \"Operand2\", \"Operation\", \"ExpectedResult\" FROM \"{table}\";";
            using var command = new NpgsqlCommand(sql, connection);
            using var reader = command.ExecuteReader();

            var rowNumber = 0;
            while (reader.Read())
            {
                rowNumber++;

                var operand1Text = reader.IsDBNull(0) ? string.Empty : reader.GetValue(0)?.ToString() ?? string.Empty;
                var operand2Text = reader.IsDBNull(1) ? string.Empty : reader.GetValue(1)?.ToString() ?? string.Empty;
                var operation = reader.IsDBNull(2) ? string.Empty : reader.GetValue(2)?.ToString() ?? string.Empty;
                var expectedText = reader.IsDBNull(3) ? string.Empty : reader.GetValue(3)?.ToString() ?? string.Empty;

                if (!double.TryParse(operand1Text, NumberStyles.Float | NumberStyles.AllowThousands, CultureInfo.InvariantCulture, out var operand1) ||
                    !double.TryParse(operand2Text, NumberStyles.Float | NumberStyles.AllowThousands, CultureInfo.InvariantCulture, out var operand2) ||
                    !double.TryParse(expectedText, NumberStyles.Float | NumberStyles.AllowThousands, CultureInfo.InvariantCulture, out var expectedResult) ||
                    string.IsNullOrWhiteSpace(operation))
                {
                    Console.WriteLine(
                        $"Skipping malformed row {rowNumber} in table '{table}': Operand1='{operand1Text}', Operand2='{operand2Text}', Operation='{operation}', ExpectedResult='{expectedText}'.");
                    continue;
                }

                results.Add(new TestCase
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
                $"The PostgreSQL table '{table}' does not exist in the Testcontainers database. Ensure CSV seeding completed successfully.", ex);
        }
        catch (NpgsqlException ex)
        {
            throw new InvalidOperationException(
                "Unable to load test cases from the Testcontainers PostgreSQL instance. Verify Docker availability and container startup.", ex);
        }

        return results;
    }

    [Theory]
    [MemberData(nameof(GetAddTestCases))]
    public void Add_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Add(left, right));
    }

    public static IEnumerable<object[]> GetAddTestCases() => GetTestCases("Add");

    [Theory]
    [MemberData(nameof(GetSubtractTestCases))]
    public void Subtract_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Subtract(left, right));
    }

    public static IEnumerable<object[]> GetSubtractTestCases() => GetTestCases("Subtract");

    [Theory]
    [MemberData(nameof(GetMultiplyTestCases))]
    public void Multiply_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Multiply(left, right));
    }

    public static IEnumerable<object[]> GetMultiplyTestCases() => GetTestCases("Multiply");

    [Theory]
    [MemberData(nameof(GetDivideTestCases))]
    public void Divide_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Divide(left, right));
    }

    public static IEnumerable<object[]> GetDivideTestCases() => GetTestCases("Divide");

    [Fact]
    public void Divide_ByZero_Throws()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Divide(5, 0));
    }

    [Theory]
    [MemberData(nameof(GetModuloTestCases))]
    public void Modulo_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Modulo(left, right));
    }

    public static IEnumerable<object[]> GetModuloTestCases() => GetTestCases("Modulo");

    [Fact]
    public void Modulo_ByZero_Throws()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Modulo(5, 0));
    }

    [Theory]
    [MemberData(nameof(GetExponentTestCases))]
    public void Exponent_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Exponent(left, right));
    }

    public static IEnumerable<object[]> GetExponentTestCases() => GetTestCases("Exponent");

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
            var suffix = Guid.NewGuid().ToString("N")[..12];
            var testContainer = new PostgreSqlBuilder()
                .WithImage("postgres:16-alpine")
                .WithDatabase($"calc_tests_{suffix}")
                .WithUsername($"calc_user_{suffix}")
                .WithPassword($"pg_pwd_{Guid.NewGuid():N}!A1")
                .Build();

            testContainer.StartAsync().GetAwaiter().GetResult();
            SeedFromCsv(testContainer);

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

        private static void SeedFromCsv(PostgreSqlContainer testContainer)
        {
            var csvPath = ResolveCsvPath();
            var lines = File.ReadAllLines(csvPath);
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

            foreach (var row in lines.Skip(1))
            {
                if (string.IsNullOrWhiteSpace(row))
                {
                    continue;
                }

                var parts = row.Split(',');
                if (parts.Length != 4)
                {
                    Console.WriteLine($"Skipping malformed CSV row during seed: '{row}'");
                    continue;
                }

                using var insert = new NpgsqlCommand(
                    "INSERT INTO \"test_data\" (\"Operand1\", \"Operand2\", \"Operation\", \"ExpectedResult\") VALUES (@operand1, @operand2, @operation, @expectedResult);",
                    connection);
                insert.Parameters.AddWithValue("operand1", parts[0].Trim());
                insert.Parameters.AddWithValue("operand2", parts[1].Trim());
                insert.Parameters.AddWithValue("operation", parts[2].Trim());
                insert.Parameters.AddWithValue("expectedResult", parts[3].Trim());
                insert.ExecuteNonQuery();
            }
        }

        private static string ResolveCsvPath()
        {
            var fromBaseDirectory = Path.Combine(AppContext.BaseDirectory, "TestCases.csv");
            if (File.Exists(fromBaseDirectory))
            {
                return fromBaseDirectory;
            }

            var fromCurrentDirectory = Path.Combine(Directory.GetCurrentDirectory(), "TestCases.csv");
            if (File.Exists(fromCurrentDirectory))
            {
                return fromCurrentDirectory;
            }

            throw new FileNotFoundException(
                "TestCases.csv was not found. Ensure the file is copied to the test output directory.");
        }
    }
}