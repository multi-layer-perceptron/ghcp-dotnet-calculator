namespace calculator;

/// <summary>
/// Provides pure arithmetic operations for calculator clients.
/// </summary>
public static class CalculatorOperations
{
    /// <summary>
    /// Adds two operands.
    /// </summary>
    /// <param name="left">The left operand.</param>
    /// <param name="right">The right operand.</param>
    /// <returns>The sum of both operands.</returns>
    public static double Add(double left, double right) => left + right;

    /// <summary>
    /// Subtracts the right operand from the left operand.
    /// </summary>
    /// <param name="left">The left operand.</param>
    /// <param name="right">The right operand.</param>
    /// <returns>The subtraction result.</returns>
    public static double Subtract(double left, double right) => left - right;

    /// <summary>
    /// Multiplies two operands.
    /// </summary>
    /// <param name="left">The left operand.</param>
    /// <param name="right">The right operand.</param>
    /// <returns>The product of both operands.</returns>
    public static double Multiply(double left, double right) => left * right;

    /// <summary>
    /// Divides the left operand by the right operand.
    /// </summary>
    /// <param name="left">The left operand.</param>
    /// <param name="right">The right operand.</param>
    /// <returns>The division result.</returns>
    /// <exception cref="DivideByZeroException">Thrown when <paramref name="right"/> is zero.</exception>
    public static double Divide(double left, double right)
    {
        if (right == 0)
        {
            throw new DivideByZeroException("Cannot divide by zero.");
        }

        return left / right;
    }

    /// <summary>
    /// Calculates the remainder after dividing the left operand by the right operand.
    /// </summary>
    /// <param name="left">The left operand.</param>
    /// <param name="right">The right operand.</param>
    /// <returns>The modulo result.</returns>
    /// <exception cref="DivideByZeroException">Thrown when <paramref name="right"/> is zero.</exception>
    public static double Modulo(double left, double right)
    {
        if (right == 0)
        {
            throw new DivideByZeroException("Cannot modulo by zero.");
        }

        return left % right;
    }

    /// <summary>
    /// Raises the left operand to the power of the right operand.
    /// </summary>
    /// <param name="left">The left operand.</param>
    /// <param name="right">The exponent.</param>
    /// <returns>The exponentiation result.</returns>
    public static double Exponent(double left, double right) => Math.Pow(left, right);
}