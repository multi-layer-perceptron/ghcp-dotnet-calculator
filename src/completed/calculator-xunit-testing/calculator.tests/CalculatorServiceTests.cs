namespace calculator.tests;

using calculator.web.Services;

public class CalculatorServiceTests
{
    private readonly CalculatorService _sut;

    public CalculatorServiceTests()
    {
        _sut = new CalculatorService();
    }

    private CalculationRecord? Press(params string[] keys)
    {
        CalculationRecord? record = null;

        foreach (var key in keys)
        {
            if (key.Length > 1 && key != "clear")
            {
                foreach (var character in key)
                {
                    record = _sut.HandleKey(character.ToString());
                }

                continue;
            }

            record = _sut.HandleKey(key);
        }

        return record;
    }

    [Fact]
    public void GivenCompletedCalculation_WhenClear_ResetsDisplayAndExpression()
    {
        Press("9", "+", "1", "=");

        _sut.Clear();

        Assert.Equal("0", _sut.Display);
        Assert.Equal("Ready", _sut.Expression);
        Assert.Null(_sut.ErrorMessage);
    }

    [Theory]
    [InlineData("+", "3", "8", "11", "3 + 8")]
    [InlineData("-", "9", "4", "5", "9 - 4")]
    [InlineData("*", "7", "6", "42", "7 * 6")]
    [InlineData("/", "8", "2", "4", "8 / 2")]
    [InlineData("%", "10", "4", "2", "10 % 4")]
    [InlineData("^", "2", "3", "8", "2 ^ 3")]
    public void GivenTwoOperands_WhenEquals_ReturnsCompletedCalculation(
        string calculatorOperator,
        string firstOperand,
        string secondOperand,
        string expectedDisplay,
        string expectedExpression)
    {
        var record = Press(firstOperand, calculatorOperator, secondOperand, "=");

        Assert.NotNull(record);
        Assert.Equal(expectedDisplay, _sut.Display);
        Assert.Equal(expectedExpression, _sut.Expression);
        Assert.Equal(expectedExpression, record.Expression);
    }

    [Fact]
    public void GivenDecimalInput_WhenDigitAndDecimalPressed_BuildsDecimalDisplay()
    {
        Press("1", ".", "5");

        Assert.Equal("1.5", _sut.Display);
    }

    [Fact]
    public void GivenDivideByZero_WhenEquals_SetsErrorAndDoesNotCreateHistoryRecord()
    {
        var record = Press("8", "/", "0", "=");

        Assert.Null(record);
        Assert.Equal("Cannot divide by zero.", _sut.ErrorMessage);
    }

    [Fact]
    public void GivenInvalidKey_WhenHandleKey_DoesNotChangeDisplay()
    {
        _sut.HandleKey("ignored");

        Assert.Equal("0", _sut.Display);
    }

    [Fact]
    public void GivenReplayedResult_WhenReplayResult_DisplaysResultAndClearsErrors()
    {
        Press("8", "/", "0", "=");

        _sut.ReplayResult(42);

        Assert.Equal("42", _sut.Display);
        Assert.Equal("Replayed result", _sut.Expression);
        Assert.Null(_sut.ErrorMessage);
    }
}