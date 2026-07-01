#nullable enable

using System.Globalization;
using calculator;

var keepCalculating = true;

while (keepCalculating)
{
	TryClearConsole();
	Console.WriteLine("Calculator");
	Console.WriteLine("Supported operators: +, -, *, /, %, ^");
	Console.WriteLine();

	var firstOperand = PromptForNumber("Enter the first operand: ");
	var secondOperand = PromptForNumber("Enter the second operand: ");
	var operatorSymbol = PromptForOperator("Enter an operator (+, -, *, /, %, ^): ");

	try
	{
		var result = operatorSymbol switch
		{
			"+" => CalculatorOperations.Add(firstOperand, secondOperand),
			"-" => CalculatorOperations.Subtract(firstOperand, secondOperand),
			"*" => CalculatorOperations.Multiply(firstOperand, secondOperand),
			"/" => CalculatorOperations.Divide(firstOperand, secondOperand),
			"%" => CalculatorOperations.Modulo(firstOperand, secondOperand),
			"^" => CalculatorOperations.Power(firstOperand, secondOperand),
			_ => throw new InvalidOperationException("Unsupported operator.")
		};

		Console.WriteLine();
		Console.WriteLine($"Result: {result.ToString(CultureInfo.InvariantCulture)}");
	}
	catch (DivideByZeroException exception)
	{
		Console.WriteLine();
		Console.WriteLine($"Calculation error: {exception.Message}");
	}

	keepCalculating = PromptToContinue("Perform another calculation? (y/n): ");
}

Console.WriteLine("Goodbye.");

static double PromptForNumber(string prompt)
{
	while (true)
	{
		Console.Write(prompt);
		var input = Console.ReadLine();

		if (double.TryParse(input, NumberStyles.Float, CultureInfo.InvariantCulture, out var number))
		{
			return number;
		}

		Console.WriteLine("Enter a valid number.");
	}
}

static string PromptForOperator(string prompt)
{
	string[] supportedOperators = ["+", "-", "*", "/", "%", "^"];

	while (true)
	{
		Console.Write(prompt);
		var input = Console.ReadLine()?.Trim();

		if (input is not null && supportedOperators.Contains(input))
		{
			return input;
		}

		Console.WriteLine("Enter one of these operators: +, -, *, /, %, ^.");
	}
}

static bool PromptToContinue(string prompt)
{
	while (true)
	{
		Console.WriteLine();
		Console.Write(prompt);
		var input = Console.ReadLine()?.Trim().ToLowerInvariant();

		if (input is "y" or "yes")
		{
			return true;
		}

		if (input is "n" or "no")
		{
			return false;
		}

		Console.WriteLine("Enter y to continue or n to exit.");
	}
}

static void TryClearConsole()
{
	try
	{
		Console.Clear();
	}
	catch (IOException)
	{
		// Some redirected or hosted consoles cannot be cleared.
	}
}
