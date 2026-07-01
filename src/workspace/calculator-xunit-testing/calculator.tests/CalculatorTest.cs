#nullable enable

namespace calculator.tests;

public class CalculatorOperationsTests
{
    [Theory]
    [InlineData(1, 2, 3)]
    [InlineData(-1, 2, 1)]
    [InlineData(1.5, 2.5, 4)]
    public void GivenTwoNumbers_WhenAdd_ReturnsSum(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Add(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Theory]
    [InlineData(4, 2, 2)]
    [InlineData(5, 2, 2.5)]
    [InlineData(-6, 3, -2)]
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
    [InlineData(5, 2, 1)]
    [InlineData(9, 3, 0)]
    [InlineData(-5, 2, -1)]
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
    [InlineData(2, 3, 6)]
    [InlineData(-2, 3, -6)]
    [InlineData(1.5, 2, 3)]
    public void GivenTwoNumbers_WhenMultiply_ReturnsProduct(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Multiply(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Theory]
    [InlineData(2, 3, 8)]
    [InlineData(5, 0, 1)]
    [InlineData(9, 0.5, 3)]
    public void GivenTwoNumbers_WhenPower_ReturnsPower(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Power(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }

    [Theory]
    [InlineData(3, 2, 1)]
    [InlineData(-1, -2, 1)]
    [InlineData(1.5, 0.5, 1)]
    public void GivenTwoNumbers_WhenSubtract_ReturnsDifference(double firstOperand, double secondOperand, double expected)
    {
        var actual = global::calculator.CalculatorOperations.Subtract(firstOperand, secondOperand);

        Assert.Equal(expected, actual, precision: 10);
    }
}