// Calculator console application using top-level statements
// Supports arithmetic operations: +, -, *, /, %, ^

using Calculator.Core;

bool continueCalculation = true;

while (continueCalculation)
{
    // Clear screen for better user experience
    Console.Clear();
    
    // Prompt for first operand
    Console.Write("Enter the first operand: ");
    string? input1 = Console.ReadLine();
    
    // Validate first operand input
    if (string.IsNullOrWhiteSpace(input1) || !double.TryParse(input1, out double operand1))
    {
        Console.WriteLine("Invalid input for first operand. Please enter a valid number.");
        Console.WriteLine("Press any key to continue...");
        Console.ReadKey();
        continue;
    } // end if

    // Prompt for second operand
    Console.Write("Enter the second operand: ");
    string? input2 = Console.ReadLine();
    
    // Validate second operand input
    if (string.IsNullOrWhiteSpace(input2) || !double.TryParse(input2, out double operand2))
    {
        Console.WriteLine("Invalid input for second operand. Please enter a valid number.");
        Console.WriteLine("Press any key to continue...");
        Console.ReadKey();
        continue;
    } // end if

    // Prompt for operator
    Console.Write("Enter an operator (+, -, *, /, %, ^): ");
    string? operatorInput = Console.ReadLine();
    
    // Validate operator input with null checking
    if (string.IsNullOrWhiteSpace(operatorInput))
    {
        Console.WriteLine("Invalid operator. Please enter a valid operator.");
        Console.WriteLine("Press any key to continue...");
        Console.ReadKey();
        continue;
    } // end if

    // Perform calculation based on operator
    double result;
    bool validOperation = true;

    try
    {
        switch (operatorInput)
        {
            case "+":
                result = CalculatorEngine.Add(operand1, operand2);
                break;
            case "-":
                result = CalculatorEngine.Subtract(operand1, operand2);
                break;
            case "*":
                result = CalculatorEngine.Multiply(operand1, operand2);
                break;
            case "/":
                result = CalculatorEngine.Divide(operand1, operand2);
                break;
            case "%":
                result = CalculatorEngine.Modulo(operand1, operand2);
                break;
            case "^":
                result = CalculatorEngine.Exponent(operand1, operand2);
                break;
            default:
                Console.WriteLine($"Error: '{operatorInput}' is not a valid operator.");
                validOperation = false;
                result = 0;
                break;
        } // end switch
    }
    catch (DivideByZeroException ex)
    {
        Console.WriteLine($"Error: {ex.Message}");
        validOperation = false;
        result = 0;
    } // end catch

    // Display result if operation was valid
    if (validOperation)
    {
        Console.WriteLine($"Result: {operand1} {operatorInput} {operand2} = {result}");
    } // end if

    // Ask if user wants to perform another calculation
    Console.Write("\nWould you like to perform another calculation? (y/n): ");
    string? response = Console.ReadLine();
    
    // Handle user response with null checking
    if (string.IsNullOrWhiteSpace(response) || !response.Trim().Equals("y", StringComparison.OrdinalIgnoreCase))
    {
        continueCalculation = false;
        Console.Clear();
        Console.WriteLine("Thank you for using the calculator. Goodbye!");
    } // end if
} // end while

// Make the Program class public and partial for testing access
public partial class Program 
{
    // Static methods for arithmetic operations - testable from xUnit project
    // These wrap the Calculator.Core.CalculatorEngine methods for backward compatibility with tests

    /// <summary>
    /// Adds two numbers together.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The sum of a and b.</returns>
    public static double Add(double a, double b)
    {
        return CalculatorEngine.Add(a, b);
    } // end Add

    /// <summary>
    /// Subtracts the second number from the first.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The difference of a and b.</returns>
    public static double Subtract(double a, double b)
    {
        return CalculatorEngine.Subtract(a, b);
    } // end Subtract

    /// <summary>
    /// Multiplies two numbers together.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The product of a and b.</returns>
    public static double Multiply(double a, double b)
    {
        return CalculatorEngine.Multiply(a, b);
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
        return CalculatorEngine.Divide(a, b);
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
        return CalculatorEngine.Modulo(a, b);
    } // end Modulo

    /// <summary>
    /// Calculates the first number raised to the power of the second number.
    /// </summary>
    /// <param name="baseNumber">The base number.</param>
    /// <param name="exponent">The exponent.</param>
    /// <returns>The result of baseNumber raised to the power of exponent.</returns>
    public static double Exponent(double baseNumber, double exponent)
    {
        return CalculatorEngine.Exponent(baseNumber, exponent);
    } // end Exponent
}
