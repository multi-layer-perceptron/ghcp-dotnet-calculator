namespace Calculator.Core;

/// <summary>
/// Calculator engine providing arithmetic operations.
/// Supports: Add, Subtract, Multiply, Divide, Modulo, Exponent
/// </summary>
public static class CalculatorEngine
{
    /// <summary>
    /// Adds two numbers together.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The sum of a and b.</returns>
    public static double Add(double a, double b)
    {
        return a + b;
    } // end Add

    /// <summary>
    /// Subtracts the second number from the first.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The difference of a and b.</returns>
    public static double Subtract(double a, double b)
    {
        return a - b;
    } // end Subtract

    /// <summary>
    /// Multiplies two numbers together.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The product of a and b.</returns>
    public static double Multiply(double a, double b)
    {
        return a * b;
    } // end Multiply

    /// <summary>
    /// Divides the first number by the second.
    /// </summary>
    /// <param name="a">The dividend.</param>
    /// <param name="b">The divisor.</param>
    /// <returns>The quotient of a divided by b.</returns>
    /// <exception cref="DivideByZeroException">Thrown when b is zero.</exception>
    public static double Divide(double a, double b)
    {
        if (b == 0)
        {
            throw new DivideByZeroException("Cannot divide by zero.");
        } // end if
        
        return a / b;
    } // end Divide

    /// <summary>
    /// Calculates the modulo (remainder) of the first number divided by the second.
    /// </summary>
    /// <param name="a">The dividend.</param>
    /// <param name="b">The divisor.</param>
    /// <returns>The remainder of a divided by b.</returns>
    /// <exception cref="DivideByZeroException">Thrown when b is zero.</exception>
    public static double Modulo(double a, double b)
    {
        if (b == 0)
        {
            throw new DivideByZeroException("Cannot perform modulo by zero.");
        } // end if
        
        return a % b;
    } // end Modulo

    /// <summary>
    /// Calculates the first number raised to the power of the second number.
    /// </summary>
    /// <param name="baseNumber">The base number.</param>
    /// <param name="exponent">The exponent.</param>
    /// <returns>The result of baseNumber raised to the power of exponent.</returns>
    public static double Exponent(double baseNumber, double exponent)
    {
        return Math.Pow(baseNumber, exponent);
    } // end Exponent
}
