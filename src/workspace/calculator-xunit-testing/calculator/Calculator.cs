using calculator;

bool continueCalculating = true;

while (continueCalculating)
{
    TryClearScreen();
    Console.WriteLine(".NET Calculator");
    Console.WriteLine("Supported operators: +, -, *, /, %, ^");

    double firstOperand = ReadOperand("Enter the first number:");
    double secondOperand = ReadOperand("Enter the second number:");
    char operation = ReadOperator("Enter an operator:");

    try
    {
        double result = operation switch
        {
            '+' => CalculatorOperations.Add(firstOperand, secondOperand),
            '-' => CalculatorOperations.Subtract(firstOperand, secondOperand),
            '*' => CalculatorOperations.Multiply(firstOperand, secondOperand),
            '/' => CalculatorOperations.Divide(firstOperand, secondOperand),
            '%' => CalculatorOperations.Modulo(firstOperand, secondOperand),
            '^' => CalculatorOperations.Exponent(firstOperand, secondOperand),
            _ => throw new InvalidOperationException("Unsupported operation.")
        };

        Console.WriteLine($"Result: {result}");
    }
    catch (DivideByZeroException ex)
    {
        Console.WriteLine($"Error: {ex.Message}");
    }

    continueCalculating = AskToContinue();
}

Console.WriteLine("Goodbye!");

static double ReadOperand(string prompt)
{
    while (true)
    {
        Console.WriteLine(prompt);
        string? input = Console.ReadLine();

        if (double.TryParse(input, out double value))
        {
            return value;
        }

        Console.WriteLine("Invalid number. Please try again.");
    }
}

static char ReadOperator(string prompt)
{
    while (true)
    {
        Console.WriteLine(prompt);
        string? input = Console.ReadLine();

        if (!string.IsNullOrWhiteSpace(input) && input.Length == 1 && "+-*/%^".Contains(input[0]))
        {
            return input[0];
        }

        Console.WriteLine("Invalid operator. Please use one of: +, -, *, /, %, ^");
    }
}

static bool AskToContinue()
{
    while (true)
    {
        Console.WriteLine("Do you want to perform another calculation? (y/n)");
        string? response = Console.ReadLine();

        if (string.Equals(response, "y", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        if (string.Equals(response, "n", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        Console.WriteLine("Invalid response. Enter 'y' or 'n'.");
    }
}

static void TryClearScreen()
{
    try
    {
        Console.Clear();
    }
    catch (IOException)
    {
        // Ignore clear failures in non-interactive environments.
    }
}
