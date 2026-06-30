#nullable enable

namespace calculator;

/// <summary>
/// Provides public static arithmetic methods for the calculator application.
/// </summary>
public static class CalculatorOperations
{
    /// <summary>
    /// Adds two numbers.
    /// </summary>
    /// <param name="a">First operand.</param>
    /// <param name="b">Second operand.</param>
    /// <returns>The sum of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public static double Add(double a, double b) => a + b;

    /// <summary>
    /// Subtracts the second number from the first.
    /// </summary>
    /// <param name="a">First operand.</param>
    /// <param name="b">Second operand.</param>
    /// <returns>The difference of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public static double Subtract(double a, double b) => a - b;

    /// <summary>
    /// Multiplies two numbers.
    /// </summary>
    /// <param name="a">First operand.</param>
    /// <param name="b">Second operand.</param>
    /// <returns>The product of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public static double Multiply(double a, double b) => a * b;

    /// <summary>
    /// Divides the first number by the second.
    /// </summary>
    /// <param name="a">Dividend.</param>
    /// <param name="b">Divisor.</param>
    /// <returns>The quotient of <paramref name="a"/> divided by <paramref name="b"/>.</returns>
    /// <exception cref="DivideByZeroException">Thrown when <paramref name="b"/> is zero.</exception>
    public static double Divide(double a, double b)
    {
        if (b == 0)
        {
            throw new DivideByZeroException("Cannot divide by zero.");
        }

        return a / b;
    }

    /// <summary>
    /// Returns the remainder of dividing the first number by the second.
    /// </summary>
    /// <param name="a">Dividend.</param>
    /// <param name="b">Divisor.</param>
    /// <returns>The remainder of <paramref name="a"/> modulo <paramref name="b"/>.</returns>
    /// <exception cref="DivideByZeroException">Thrown when <paramref name="b"/> is zero.</exception>
    public static double Modulo(double a, double b)
    {
        if (b == 0)
        {
            throw new DivideByZeroException("Cannot perform modulo by zero.");
        }

        return a % b;
    }

    /// <summary>
    /// Raises the first number to the power of the second.
    /// </summary>
    /// <param name="a">Base.</param>
    /// <param name="b">Exponent.</param>
    /// <returns><paramref name="a"/> raised to the power of <paramref name="b"/>.</returns>
    public static double Power(double a, double b) => Math.Pow(a, b);
}
