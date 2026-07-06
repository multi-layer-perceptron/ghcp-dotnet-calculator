namespace calculator.tests;

using calculator;
using System.Globalization;

public class CalculatorTest
{
    private static readonly string TestDataPath = Path.Combine(AppContext.BaseDirectory, "TestCases.csv");

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

    public static IEnumerable<object[]> GetAddTestCases() => GetTestCases("Add");

    public static IEnumerable<object[]> GetSubtractTestCases() => GetTestCases("Subtract");

    public static IEnumerable<object[]> GetMultiplyTestCases() => GetTestCases("Multiply");

    public static IEnumerable<object[]> GetDivideTestCases() => GetTestCases("Divide");

    public static IEnumerable<object[]> GetModuloTestCases() => GetTestCases("Modulo");

    public static IEnumerable<object[]> GetPowerTestCases() => GetTestCases("Exponent");

    private static IEnumerable<object[]> GetTestCases(string operation)
    {
        if (!File.Exists(TestDataPath))
        {
            throw new FileNotFoundException($"Test data file not found: {TestDataPath}");
        }

        return File.ReadLines(TestDataPath)
            .Skip(1)
            .Select(ParseTestCase)
            .Where(testCase => string.Equals(testCase.Operation, operation, StringComparison.OrdinalIgnoreCase))
            .Select(testCase => new object[] { testCase.Operand1, testCase.Operand2, testCase.ExpectedResult })
            .ToList();
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

    private sealed class CalculatorTestCase
    {
        public double Operand1 { get; set; }

        public double Operand2 { get; set; }

        public string Operation { get; set; } = string.Empty;

        public double ExpectedResult { get; set; }
    }
}