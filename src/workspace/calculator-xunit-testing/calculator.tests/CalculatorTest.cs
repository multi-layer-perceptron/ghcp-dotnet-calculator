using calculator;

namespace calculator.tests;

public class CalculatorTest
{
    [Theory]
    [InlineData(2, 3, 5)]
    [InlineData(-2, 3, 1)]
    [InlineData(2.5, 3.5, 6)]
    public void GivenOperands_WhenAdd_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Add(left, right));
    }

    [Fact]
    public void GivenZeroDivisor_WhenDivide_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Divide(5, 0));
    }

    [Theory]
    [InlineData(8, 2, 4)]
    [InlineData(7.5, 2.5, 3)]
    [InlineData(-9, 3, -3)]
    public void GivenOperands_WhenDivide_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Divide(left, right));
    }

    [Theory]
    [InlineData(2, 3, 8)]
    [InlineData(5, 0, 1)]
    [InlineData(9, 0.5, 3)]
    public void GivenOperands_WhenExponent_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Exponent(left, right));
    }

    [Fact]
    public void GivenZeroDivisor_WhenModulo_ThrowsDivideByZeroException()
    {
        Assert.Throws<DivideByZeroException>(() => CalculatorOperations.Modulo(5, 0));
    }

    [Theory]
    [InlineData(10, 3, 1)]
    [InlineData(12, 4, 0)]
    [InlineData(-10, 3, -1)]
    public void GivenOperands_WhenModulo_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Modulo(left, right));
    }

    [Theory]
    [InlineData(2, 3, 6)]
    [InlineData(-2, 3, -6)]
    [InlineData(2.5, 4, 10)]
    public void GivenOperands_WhenMultiply_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Multiply(left, right));
    }

    [Theory]
    [InlineData(5, 3, 2)]
    [InlineData(-2, 3, -5)]
    [InlineData(2.5, 1.5, 1)]
    public void GivenOperands_WhenSubtract_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, CalculatorOperations.Subtract(left, right));
    }
}
