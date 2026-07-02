using System.Globalization;
using calculator;

namespace calculator.tests;

public class CalculatorTest
{
    private static readonly string TestDataPath = Path.Combine(AppContext.BaseDirectory, "TestCases.csv");

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
        if (!File.Exists(TestDataPath))
        {
            throw new FileNotFoundException($"Test data file not found: {TestDataPath}");
        }

        return File.ReadLines(TestDataPath)
            .Skip(1)
            .Select((line, index) => ParseTestCase(line, index + 2))
            .Where(testCase => testCase.Operation.Equals(operation, StringComparison.OrdinalIgnoreCase))
            .Select(testCase => new object[] { testCase.Operand1, testCase.Operand2, testCase.ExpectedResult })
            .ToList();
    }

    private static CalculatorTestCase ParseTestCase(string line, int lineNumber)
    {
        string[] columns = line.Split(',');

        if (columns.Length != 4)
        {
            throw new InvalidDataException($"TestCases.csv line {lineNumber} must contain 4 columns.");
        }

        if (!double.TryParse(columns[0], NumberStyles.Float, CultureInfo.InvariantCulture, out double operand1) ||
            !double.TryParse(columns[1], NumberStyles.Float, CultureInfo.InvariantCulture, out double operand2) ||
            !double.TryParse(columns[3], NumberStyles.Float, CultureInfo.InvariantCulture, out double expectedResult))
        {
            throw new InvalidDataException($"TestCases.csv line {lineNumber} contains an invalid numeric value.");
        }

        string operation = columns[2].Trim();
        if (string.IsNullOrWhiteSpace(operation))
        {
            throw new InvalidDataException($"TestCases.csv line {lineNumber} contains an empty operation.");
        }

        return new CalculatorTestCase
        {
            Operand1 = operand1,
            Operand2 = operand2,
            Operation = operation,
            ExpectedResult = expectedResult
        };
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
}
