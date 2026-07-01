#nullable enable

namespace calculator;

/// <summary>
/// Provides arithmetic operations for the console calculator.
/// </summary>
public static class CalculatorOperations
{
    /// <summary>
    /// Adds two numbers.
    /// </summary>
    /// <param name="firstOperand">The first number to add.</param>
    /// <param name="secondOperand">The second number to add.</param>
    /// <returns>The sum of the two numbers.</returns>
    public static double Add(double firstOperand, double secondOperand) => firstOperand + secondOperand;

    /// <summary>
    /// Subtracts the second number from the first number.
    /// </summary>
    /// <param name="firstOperand">The number to subtract from.</param>
    /// <param name="secondOperand">The number to subtract.</param>
    /// <returns>The difference between the two numbers.</returns>
    public static double Subtract(double firstOperand, double secondOperand) => firstOperand - secondOperand;

    /// <summary>
    /// Multiplies two numbers.
    /// </summary>
    /// <param name="firstOperand">The first number to multiply.</param>
    /// <param name="secondOperand">The second number to multiply.</param>
    /// <returns>The product of the two numbers.</returns>
    public static double Multiply(double firstOperand, double secondOperand) => firstOperand * secondOperand;

    /// <summary>
    /// Divides the first number by the second number.
    /// </summary>
    /// <param name="firstOperand">The dividend.</param>
    /// <param name="secondOperand">The divisor.</param>
    /// <returns>The quotient of the two numbers.</returns>
    /// <exception cref="DivideByZeroException">Thrown when <paramref name="secondOperand"/> is zero.</exception>
    public static double Divide(double firstOperand, double secondOperand)
    {
        if (secondOperand == 0)
        {
            throw new DivideByZeroException("Cannot divide by zero.");
        }

        return firstOperand / secondOperand;
    }

    /// <summary>
    /// Calculates the remainder after dividing the first number by the second number.
    /// </summary>
    /// <param name="firstOperand">The dividend.</param>
    /// <param name="secondOperand">The divisor.</param>
    /// <returns>The remainder after division.</returns>
    /// <exception cref="DivideByZeroException">Thrown when <paramref name="secondOperand"/> is zero.</exception>
    public static double Modulo(double firstOperand, double secondOperand)
    {
        if (secondOperand == 0)
        {
            throw new DivideByZeroException("Cannot perform modulo by zero.");
        }

        return firstOperand % secondOperand;
    }

    /// <summary>
    /// Raises the first number to the power of the second number.
    /// </summary>
    /// <param name="firstOperand">The base number.</param>
    /// <param name="secondOperand">The exponent.</param>
    /// <returns>The power calculation result.</returns>
    public static double Power(double firstOperand, double secondOperand) => Math.Pow(firstOperand, secondOperand);
}
