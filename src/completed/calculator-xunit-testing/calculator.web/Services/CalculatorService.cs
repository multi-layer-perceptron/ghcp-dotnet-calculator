namespace calculator.web.Services;

using System.Globalization;
using calculator.library;

/// <summary>
/// Maintains calculator entry state and delegates arithmetic to the shared library.
/// </summary>
public sealed class CalculatorService
{
    private double? storedOperand;
    private string? pendingOperator;
    private bool resetDisplayOnNextEntry;

    /// <summary>
    /// Gets the current calculator display value.
    /// </summary>
    public string Display { get; private set; } = "0";

    /// <summary>
    /// Gets the current expression label shown above the display.
    /// </summary>
    public string Expression { get; private set; } = "Ready";

    /// <summary>
    /// Gets the current error text, when the last operation failed.
    /// </summary>
    public string? ErrorMessage { get; private set; }

    /// <summary>
    /// Handles a keypad or keyboard key.
    /// </summary>
    /// <param name="key">The normalized calculator key.</param>
    /// <returns>A completed calculation record when equals completes an operation; otherwise, null.</returns>
    public CalculationRecord? HandleKey(string key)
    {
        ErrorMessage = null;

        if (key.Length == 1 && char.IsDigit(key[0]))
        {
            EnterDigit(key);
            return null;
        }

        return key switch
        {
            "." => EnterDecimal(),
            "+" or "-" or "*" or "/" or "%" or "^" => SetOperator(key),
            "=" => Calculate(),
            "clear" => Clear(),
            _ => null
        };
    }

    /// <summary>
    /// Clears the current calculation state.
    /// </summary>
    public CalculationRecord? Clear()
    {
        storedOperand = null;
        pendingOperator = null;
        resetDisplayOnNextEntry = false;
        Display = "0";
        Expression = "Ready";
        ErrorMessage = null;
        return null;
    }

    /// <summary>
    /// Replays a result value from history into the current display.
    /// </summary>
    /// <param name="result">The result to replay.</param>
    public void ReplayResult(double result)
    {
        storedOperand = null;
        pendingOperator = null;
        resetDisplayOnNextEntry = true;
        ErrorMessage = null;
        Display = CalculatorFormatter.FormatNumber(result);
        Expression = "Replayed result";
    }

    private CalculationRecord? EnterDecimal()
    {
        if (resetDisplayOnNextEntry)
        {
            Display = "0";
            resetDisplayOnNextEntry = false;
        }

        if (!Display.Contains('.', StringComparison.Ordinal))
        {
            Display += ".";
        }

        return null;
    }

    private void EnterDigit(string digit)
    {
        if (resetDisplayOnNextEntry || Display == "0")
        {
            Display = digit;
            resetDisplayOnNextEntry = false;
            return;
        }

        Display += digit;
    }

    private CalculationRecord? SetOperator(string calculatorOperator)
    {
        if (storedOperand.HasValue && pendingOperator is not null && !resetDisplayOnNextEntry)
        {
            CalculateIntermediate();
        }

        storedOperand = ParseDisplay();
        pendingOperator = calculatorOperator;
        resetDisplayOnNextEntry = true;
        Expression = $"{Display} {calculatorOperator}";
        return null;
    }

    private CalculationRecord? Calculate()
    {
        if (!storedOperand.HasValue || pendingOperator is null)
        {
            return null;
        }

        var firstOperand = storedOperand.Value;
        var secondOperand = ParseDisplay();
        var expression = $"{CalculatorFormatter.FormatNumber(firstOperand)} {pendingOperator} {CalculatorFormatter.FormatNumber(secondOperand)}";

        try
        {
            var result = ExecuteOperation(firstOperand, secondOperand, pendingOperator);
            Display = CalculatorFormatter.FormatNumber(result);
            Expression = expression;
            storedOperand = null;
            pendingOperator = null;
            resetDisplayOnNextEntry = true;
            return new CalculationRecord(expression, result, DateTimeOffset.Now);
        }
        catch (DivideByZeroException ex)
        {
            ErrorMessage = ex.Message;
            resetDisplayOnNextEntry = true;
            return null;
        }
    }

    private void CalculateIntermediate()
    {
        if (!storedOperand.HasValue || pendingOperator is null)
        {
            return;
        }

        var result = ExecuteOperation(storedOperand.Value, ParseDisplay(), pendingOperator);
        Display = CalculatorFormatter.FormatNumber(result);
    }

    private double ParseDisplay() => double.Parse(Display, CultureInfo.InvariantCulture);

    private static double ExecuteOperation(double firstOperand, double secondOperand, string calculatorOperator) => calculatorOperator switch
    {
        "+" => CalculatorOperations.Add(firstOperand, secondOperand),
        "-" => CalculatorOperations.Subtract(firstOperand, secondOperand),
        "*" => CalculatorOperations.Multiply(firstOperand, secondOperand),
        "/" => CalculatorOperations.Divide(firstOperand, secondOperand),
        "%" => CalculatorOperations.Modulo(firstOperand, secondOperand),
        "^" => CalculatorOperations.Power(firstOperand, secondOperand),
        _ => throw new InvalidOperationException($"Unsupported operator: {calculatorOperator}")
    };
}