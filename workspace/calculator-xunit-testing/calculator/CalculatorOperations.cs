namespace calculator;

public static class CalculatorOperations
{
    public static double Add(double left, double right) => left + right;

    public static double Subtract(double left, double right) => left - right;

    public static double Multiply(double left, double right) => left * right;

    public static double Divide(double left, double right)
    {
        if (right == 0)
        {
            throw new DivideByZeroException("Cannot divide by zero.");
        }

        return left / right;
    }

    public static double Modulo(double left, double right)
    {
        if (right == 0)
        {
            throw new DivideByZeroException("Cannot modulo by zero.");
        }

        return left % right;
    }

    public static double Exponent(double left, double right) => Math.Pow(left, right);
}
