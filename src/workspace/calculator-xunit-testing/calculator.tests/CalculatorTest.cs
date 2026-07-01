#nullable enable

using System.Globalization;

namespace calculator.tests;

public class CalculatorOperationsTests
{
    private static readonly string _testDataPath = Path.Combine(AppContext.BaseDirectory, "TestCases.csv");

    [Theory]
    [MemberData(nameof(GetAddTestCases))]
    public void GivenTwoNumbers_WhenAdd_ReturnsSum(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Add(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Theory]
    [MemberData(nameof(GetDivideTestCases))]
    public void GivenTwoNumbers_WhenDivide_ReturnsQuotient(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Divide(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Fact]
    public void GivenZeroDivisor_WhenDivide_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => global::calculator.CalculatorOperations.Divide(1, 0));
    }

    [Theory]
    [MemberData(nameof(GetModuloTestCases))]
    public void GivenTwoNumbers_WhenModulo_ReturnsRemainder(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Modulo(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Fact]
    public void GivenZeroDivisor_WhenModulo_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => global::calculator.CalculatorOperations.Modulo(1, 0));
    }

    [Theory]
    [MemberData(nameof(GetMultiplyTestCases))]
    public void GivenTwoNumbers_WhenMultiply_ReturnsProduct(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Multiply(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Theory]
    [MemberData(nameof(GetPowerTestCases))]
    public void GivenTwoNumbers_WhenPower_ReturnsPower(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Power(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Theory]
    [MemberData(nameof(GetSubtractTestCases))]
    public void GivenTwoNumbers_WhenSubtract_ReturnsDifference(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Subtract(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    public static IEnumerable<object[]> GetAddTestCases() => GetTestCases("Add");

    public static IEnumerable<object[]> GetDivideTestCases() => GetTestCases("Divide");

    public static IEnumerable<object[]> GetModuloTestCases() => GetTestCases("Modulo");

    public static IEnumerable<object[]> GetMultiplyTestCases() => GetTestCases("Multiply");

    public static IEnumerable<object[]> GetPowerTestCases() => GetTestCases("Exponent");

    public static IEnumerable<object[]> GetSubtractTestCases() => GetTestCases("Subtract");

    private static IEnumerable<object[]> GetTestCases(string operation)
    {
        if (!File.Exists(_testDataPath))
        {
            throw new FileNotFoundException($"Test data file not found: {_testDataPath}", _testDataPath);
        }

        return File.ReadLines(_testDataPath)
            .Skip(1)
            .Where(line => !string.IsNullOrWhiteSpace(line))
            .Select(ParseTestCase)
            .Where(testCase => string.Equals(testCase.Operation, operation, StringComparison.OrdinalIgnoreCase))
            .Select(testCase => new object[] { testCase.Operand1, testCase.Operand2, testCase.ExpectedResult })
            .ToList();
    }

    private static CalculatorTestCase ParseTestCase(string line)
    {
        var values = line.Split(',');
        if (values.Length != 4)
        {
            throw new FormatException($"Invalid test case row: {line}");
        }

        return new CalculatorTestCase
        {
            Operand1 = double.Parse(values[0], CultureInfo.InvariantCulture),
            Operand2 = double.Parse(values[1], CultureInfo.InvariantCulture),
            Operation = values[2],
            ExpectedResult = double.Parse(values[3], CultureInfo.InvariantCulture)
        };
    }

    private sealed class CalculatorTestCase
    {
        public double ExpectedResult { get; init; }

        public double Operand1 { get; init; }

        public double Operand2 { get; init; }

        public string Operation { get; init; } = string.Empty;
    }
}