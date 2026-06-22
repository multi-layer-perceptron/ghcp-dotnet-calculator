namespace calculator.tests;

public class CalculatorTest
{
    [Theory]
    [InlineData(1, 2, 3)]
    [InlineData(-5, 2, -3)]
    [InlineData(2.5, 0.5, 3.0)]
    public void Add_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, global::CalculatorOperations.Add(left, right));
    }

    [Theory]
    [InlineData(5, 3, 2)]
    [InlineData(-5, -2, -3)]
    [InlineData(2.5, 0.5, 2.0)]
    public void Subtract_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, global::CalculatorOperations.Subtract(left, right));
    }

    [Theory]
    [InlineData(5, 3, 15)]
    [InlineData(-5, -2, 10)]
    [InlineData(2.5, 0.5, 1.25)]
    public void Multiply_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, global::CalculatorOperations.Multiply(left, right));
    }

    [Theory]
    [InlineData(6, 3, 2)]
    [InlineData(-8, 2, -4)]
    [InlineData(2.5, 0.5, 5)]
    public void Divide_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, global::CalculatorOperations.Divide(left, right));
    }

    [Fact]
    public void Divide_ByZero_Throws()
    {
        Assert.Throws<DivideByZeroException>(() => global::CalculatorOperations.Divide(5, 0));
    }

    [Theory]
    [InlineData(7, 3, 1)]
    [InlineData(8, 2, 0)]
    [InlineData(5.5, 2, 1.5)]
    public void Modulo_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, global::CalculatorOperations.Modulo(left, right));
    }

    [Fact]
    public void Modulo_ByZero_Throws()
    {
        Assert.Throws<DivideByZeroException>(() => global::CalculatorOperations.Modulo(5, 0));
    }

    [Theory]
    [InlineData(2, 3, 8)]
    [InlineData(9, 0.5, 3)]
    [InlineData(2, -2, 0.25)]
    public void Exponent_ReturnsExpectedResult(double left, double right, double expected)
    {
        Assert.Equal(expected, global::CalculatorOperations.Exponent(left, right));
    }
}
