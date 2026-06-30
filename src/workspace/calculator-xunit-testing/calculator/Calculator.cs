#nullable enable

using calculator;

bool continueCalculating = true;

while (continueCalculating)
{
    try
    {
        Console.Clear();
    }
    catch (IOException)
    {
        // Console.Clear() may throw when output is redirected; ignore.
    }

    Console.WriteLine("=== .NET 8 Calculator ===");
    Console.WriteLine("Supported operators: +  -  *  /  %  ^");
    Console.WriteLine();

    double firstOperand = PromptForNumber("Enter the first operand: ");
    double secondOperand = PromptForNumber("Enter the second operand: ");
    string operatorSymbol = PromptForOperator();

    try
    {
        double result = operatorSymbol switch
        {
            "+" => CalculatorOperations.Add(firstOperand, secondOperand),
            "-" => CalculatorOperations.Subtract(firstOperand, secondOperand),
            "*" => CalculatorOperations.Multiply(firstOperand, secondOperand),
            "/" => CalculatorOperations.Divide(firstOperand, secondOperand),
            "%" => CalculatorOperations.Modulo(firstOperand, secondOperand),
            "^" => CalculatorOperations.Power(firstOperand, secondOperand),
            _ => throw new InvalidOperationException($"Unknown operator: {operatorSymbol}")
        };

        Console.WriteLine();
        Console.WriteLine($"  {firstOperand} {operatorSymbol} {secondOperand} = {result}");
    }
    catch (DivideByZeroException ex)
    {
        Console.WriteLine();
        Console.WriteLine($"  Error: {ex.Message}");
    }

    Console.WriteLine();
    continueCalculating = PromptToContinue();
}

Console.WriteLine("Goodbye!");

// --- Local helper methods ---

static double PromptForNumber(string prompt)
{
    while (true)
    {
        Console.Write(prompt);
        string? input = Console.ReadLine();

        if (input is null)
        {
            Console.WriteLine("  No input received. Please enter a numeric value.");
            continue;
        }

        if (double.TryParse(input.Trim(), out double value))
        {
            return value;
        }

        Console.WriteLine($"  '{input.Trim()}' is not a valid number. Please try again.");
    }
}

static string PromptForOperator()
{
    string[] validOperators = ["+", "-", "*", "/", "%", "^"];

    while (true)
    {
        Console.Write("Enter the operator (+, -, *, /, %, ^): ");
        string? input = Console.ReadLine();

        if (input is null)
        {
            Console.WriteLine("  No input received. Please enter an operator.");
            continue;
        }

        string trimmed = input.Trim();

        if (Array.Exists(validOperators, op => op == trimmed))
        {
            return trimmed;
        }

        Console.WriteLine($"  '{trimmed}' is not a valid operator. Please try again.");
    }
}

static bool PromptToContinue()
{
    while (true)
    {
        Console.Write("Perform another calculation? (y/n): ");
        string? input = Console.ReadLine();

        if (input is null)
        {
            return false;
        }

        string trimmed = input.Trim().ToLowerInvariant();

        if (trimmed is "y" or "yes")
        {
            return true;
        }

        if (trimmed is "n" or "no")
        {
            return false;
        }

        Console.WriteLine("  Please enter 'y' or 'n'.");
    }
}
