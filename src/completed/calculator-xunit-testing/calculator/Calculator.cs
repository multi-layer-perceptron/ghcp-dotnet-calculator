using calculator.library;

Console.WriteLine("Basic Calculator");

var continueCalculating = true;
var isFirstCalculation = true;

while (continueCalculating)
{
	if (!isFirstCalculation)
	{
		ClearScreenWhenPossible();
		Console.WriteLine("Basic Calculator");
	}

	var firstOperand = ReadOperand("Enter the first number: ");
	var secondOperand = ReadOperand("Enter the second number: ");

	Console.Write("Enter an operator (+, -, *, /, %, ^): ");
	var operation = Console.ReadLine()?.Trim();

	try
	{
		var result = operation switch
		{
			"+" => CalculatorOperations.Add(firstOperand, secondOperand),
			"-" => CalculatorOperations.Subtract(firstOperand, secondOperand),
			"*" => CalculatorOperations.Multiply(firstOperand, secondOperand),
			"/" => CalculatorOperations.Divide(firstOperand, secondOperand),
			"%" => CalculatorOperations.Modulo(firstOperand, secondOperand),
			"^" => CalculatorOperations.Power(firstOperand, secondOperand),
			_ => throw new InvalidOperationException("Please enter one of these operators: +, -, *, /, %, ^.")
		};

		Console.WriteLine($"Result: {result}");
	}
	catch (DivideByZeroException ex)
	{
		Console.WriteLine($"{ex.Message} Please try another calculation.");
	}
	catch (InvalidOperationException ex)
	{
		Console.WriteLine(ex.Message);
	}

	Console.Write("Would you like to perform another calculation? (y/n): ");
	var response = Console.ReadLine()?.Trim();
	continueCalculating = string.Equals(response, "y", StringComparison.OrdinalIgnoreCase)
		|| string.Equals(response, "yes", StringComparison.OrdinalIgnoreCase);
	isFirstCalculation = false;
}

static void ClearScreenWhenPossible()
{
	try
	{
		Console.Clear();
	}
	catch (IOException)
	{
		Console.WriteLine();
	}
}

static double ReadOperand(string prompt)
{
	while (true)
	{
		Console.Write(prompt);
		var input = Console.ReadLine()?.Trim();

		if (double.TryParse(input, out var operand))
		{
			return operand;
		}

		Console.WriteLine("Please enter a valid number.");
	}
}
