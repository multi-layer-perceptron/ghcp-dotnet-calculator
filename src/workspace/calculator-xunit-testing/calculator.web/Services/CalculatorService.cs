using System.Globalization;
using calculator;

namespace calculator.web.Services;

/// <summary>
/// Maintains calculator input state and executes arithmetic operations.
/// </summary>
public sealed class CalculatorService
{
    private bool shouldReplaceDisplay = true;
    private double? pendingOperand;
    private string? pendingOperator;

    /// <summary>
    /// Occurs when a calculation completes.
    /// </summary>
    public event Action<CalculationRecord>? OnCalculationCompleted;

    /// <summary>
    /// Occurs when display state changes.
    /// </summary>
    public event Action? OnDisplayChanged;

    /// <summary>
    /// Gets the calculator display value.
    /// </summary>
    public string Display { get; private set; } = "0";

    /// <summary>
    /// Gets the latest user-facing error message, if any.
    /// </summary>
    public string? ErrorMessage { get; private set; }

    /// <summary>
    /// Clears calculator state.
    /// </summary>
    public void Clear()
    {
        Display = "0";
        ErrorMessage = null;
        pendingOperand = null;
        pendingOperator = null;
        shouldReplaceDisplay = true;
        NotifyDisplayChanged();
    }

    /// <summary>
    /// Executes the pending calculation if possible.
    /// </summary>
    public void Calculate()
    {
        if (pendingOperand is null || pendingOperator is null)
        {
            return;
        }

        if (!TryGetDisplayValue(out var rightOperand))
        {
            return;
        }

        ExecutePendingOperation(pendingOperand.Value, pendingOperator, rightOperand);
    }

    /// <summary>
    /// Enters a decimal separator.
    /// </summary>
    public void EnterDecimal()
    {
        ErrorMessage = null;

        if (shouldReplaceDisplay)
        {
            Display = "0.";
            shouldReplaceDisplay = false;
        }
        else if (!Display.Contains('.', StringComparison.Ordinal))
        {
            Display += ".";
        }

        NotifyDisplayChanged();
    }

    /// <summary>
    /// Enters a digit.
    /// </summary>
    /// <param name="digit">The digit text.</param>
    public void EnterDigit(string digit)
    {
        if (digit.Length != 1 || !char.IsDigit(digit[0]))
        {
            return;
        }

        ErrorMessage = null;
        if (shouldReplaceDisplay || Display == "0")
        {
            Display = digit;
            shouldReplaceDisplay = false;
        }
        else
        {
            Display += digit;
        }

        NotifyDisplayChanged();
    }

    /// <summary>
    /// Stores or executes an operator for chained calculations.
    /// </summary>
    /// <param name="operation">The operation symbol.</param>
    public void EnterOperator(string operation)
    {
        var normalizedOperation = NormalizeOperator(operation);
        if (normalizedOperation is null || !TryGetDisplayValue(out var currentValue))
        {
            return;
        }

        if (pendingOperand is not null && pendingOperator is not null && !shouldReplaceDisplay)
        {
            ExecutePendingOperation(pendingOperand.Value, pendingOperator, currentValue);
            if (!TryGetDisplayValue(out currentValue))
            {
                return;
            }
        }

        pendingOperand = currentValue;
        pendingOperator = normalizedOperation;
        shouldReplaceDisplay = true;
        ErrorMessage = null;
        NotifyDisplayChanged();
    }

    /// <summary>
    /// Replays a historical result into the current display.
    /// </summary>
    /// <param name="record">The record to replay.</param>
    public void Replay(CalculationRecord record)
    {
        ArgumentNullException.ThrowIfNull(record);
        Display = FormatNumber(record.Result);
        ErrorMessage = null;
        pendingOperand = null;
        pendingOperator = null;
        shouldReplaceDisplay = true;
        NotifyDisplayChanged();
    }

    private static string FormatNumber(double value) => value.ToString("G15", CultureInfo.InvariantCulture);

    private static string? NormalizeOperator(string operation) => operation switch
    {
        "+" => "+",
        "-" or "−" => "−",
        "*" or "×" => "×",
        "/" or "÷" => "÷",
        "%" => "%",
        "^" => "^",
        _ => null
    };

    private static double RunOperation(double leftOperand, string operation, double rightOperand) => operation switch
    {
        "+" => CalculatorOperations.Add(leftOperand, rightOperand),
        "−" => CalculatorOperations.Subtract(leftOperand, rightOperand),
        "×" => CalculatorOperations.Multiply(leftOperand, rightOperand),
        "÷" => CalculatorOperations.Divide(leftOperand, rightOperand),
        "%" => CalculatorOperations.Modulo(leftOperand, rightOperand),
        "^" => CalculatorOperations.Exponent(leftOperand, rightOperand),
        _ => throw new InvalidOperationException($"Unsupported operation '{operation}'.")
    };

    private void ExecutePendingOperation(double leftOperand, string operation, double rightOperand)
    {
        try
        {
            var result = RunOperation(leftOperand, operation, rightOperand);
            Display = FormatNumber(result);
            ErrorMessage = null;
            pendingOperand = null;
            pendingOperator = null;
            shouldReplaceDisplay = true;
            OnCalculationCompleted?.Invoke(new CalculationRecord(leftOperand, operation, rightOperand, result, DateTimeOffset.Now));
        }
        catch (DivideByZeroException ex)
        {
            ErrorMessage = ex.Message;
            shouldReplaceDisplay = true;
        }

        NotifyDisplayChanged();
    }

    private void NotifyDisplayChanged() => OnDisplayChanged?.Invoke();

    private bool TryGetDisplayValue(out double value)
    {
        if (double.TryParse(Display, NumberStyles.Float, CultureInfo.InvariantCulture, out value))
        {
            return true;
        }

        ErrorMessage = "Current display value is not a valid number.";
        NotifyDisplayChanged();
        return false;
    }
}