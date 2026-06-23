namespace calculator.tests;

using Xunit;

/// <summary>
/// Comprehensive xUnit tests for the calculator application.
/// Tests cover normal cases, edge cases, and error conditions.
/// Test data is sourced from a SQLite database for better maintainability and organization.
/// </summary>
public class CalculatorTest
{
    #region SQLite-Based Theory Tests

    /// <summary>
    /// Theory test that loads test data from SQLite database.
    /// Tests all operations (Add, Subtract, Multiply, Divide, Modulo, Exponent).
    /// </summary>
    [Theory]
    [MemberData(nameof(CalculatorTestDataLoader.GetTestData), MemberType = typeof(CalculatorTestDataLoader))]
    public void CalculatorOperations_WithSQLiteData_ReturnsExpectedResults(
        double firstNumber, 
        double secondNumber, 
        string operation, 
        double expectedValue, 
        string description)
    {
        // Act
        double result = operation switch
        {
            "Add" => Program.Add(firstNumber, secondNumber),
            "Subtract" => Program.Subtract(firstNumber, secondNumber),
            "Multiply" => Program.Multiply(firstNumber, secondNumber),
            "Divide" => Program.Divide(firstNumber, secondNumber),
            "Modulo" => Program.Modulo(firstNumber, secondNumber),
            "Exponent" => Program.Exponent(firstNumber, secondNumber),
            _ => throw new InvalidOperationException($"Unknown operation: {operation}")
        };

        // Assert
        Assert.Equal(expectedValue, result);
    } // end CalculatorOperations_WithSQLiteData_ReturnsExpectedResults

    #endregion

    #region Error Handling Tests

    /// <summary>
    /// Fact test for division by zero error handling.
    /// </summary>
    [Fact]
    public void DivideByZero_ThrowsDivideByZeroException()
    {
        // Arrange
        double a = 10;
        double b = 0;

        // Act & Assert
        Assert.Throws<DivideByZeroException>(() => Program.Divide(a, b));
    } // end DivideByZero_ThrowsDivideByZeroException

    /// <summary>
    /// Fact test for modulo by zero error handling.
    /// </summary>
    [Fact]
    public void ModuloByZero_ThrowsDivideByZeroException()
    {
        // Arrange
        double a = 10;
        double b = 0;

        // Act & Assert
        Assert.Throws<DivideByZeroException>(() => Program.Modulo(a, b));
    } // end ModuloByZero_ThrowsDivideByZeroException

    #endregion

    #region Individual Operation Fact Tests

    /// <summary>
    /// Fact test for basic addition operation.
    /// </summary>
    [Fact]
    public void AddTwoPositiveNumbers_ReturnsCorrectSum()
    {
        // Arrange
        double a = 5;
        double b = 3;
        double expected = 8;

        // Act
        double result = Program.Add(a, b);

        // Assert
        Assert.Equal(expected, result);
    } // end AddTwoPositiveNumbers_ReturnsCorrectSum

    /// <summary>
    /// Fact test for basic subtraction operation.
    /// </summary>
    [Fact]
    public void SubtractTwoNumbers_ReturnsCorrectDifference()
    {
        // Arrange
        double a = 10;
        double b = 3;
        double expected = 7;

        // Act
        double result = Program.Subtract(a, b);

        // Assert
        Assert.Equal(expected, result);
    } // end SubtractTwoNumbers_ReturnsCorrectDifference

    /// <summary>
    /// Fact test for basic multiplication operation.
    /// </summary>
    [Fact]
    public void MultiplyTwoNumbers_ReturnsCorrectProduct()
    {
        // Arrange
        double a = 4;
        double b = 5;
        double expected = 20;

        // Act
        double result = Program.Multiply(a, b);

        // Assert
        Assert.Equal(expected, result);
    } // end MultiplyTwoNumbers_ReturnsCorrectProduct

    /// <summary>
    /// Fact test for basic division operation.
    /// </summary>
    [Fact]
    public void DivideTwoNumbers_ReturnsCorrectQuotient()
    {
        // Arrange
        double a = 20;
        double b = 4;
        double expected = 5;

        // Act
        double result = Program.Divide(a, b);

        // Assert
        Assert.Equal(expected, result);
    } // end DivideTwoNumbers_ReturnsCorrectQuotient

    /// <summary>
    /// Fact test for basic modulo operation.
    /// </summary>
    [Fact]
    public void ModuloTwoNumbers_ReturnsCorrectRemainder()
    {
        // Arrange
        double a = 17;
        double b = 5;
        double expected = 2;

        // Act
        double result = Program.Modulo(a, b);

        // Assert
        Assert.Equal(expected, result);
    } // end ModuloTwoNumbers_ReturnsCorrectRemainder

    /// <summary>
    /// Fact test for basic exponent operation.
    /// </summary>
    [Fact]
    public void ExponentTwoNumbers_ReturnsCorrectPower()
    {
        // Arrange
        double baseNumber = 2;
        double exponent = 3;
        double expected = 8;

        // Act
        double result = Program.Exponent(baseNumber, exponent);

        // Assert
        Assert.Equal(expected, result);
    } // end ExponentTwoNumbers_ReturnsCorrectPower

    #endregion
}
