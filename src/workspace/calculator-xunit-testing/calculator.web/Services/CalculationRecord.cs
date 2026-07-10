namespace calculator.web.Services;

/// <summary>
/// Represents one completed calculator expression and its result.
/// </summary>
/// <param name="Expression">The expression entered by the user.</param>
/// <param name="Result">The calculated result.</param>
/// <param name="CreatedAt">The time the calculation was completed.</param>
public sealed record CalculationRecord(string Expression, double Result, DateTimeOffset CreatedAt)
{
    /// <summary>
    /// Gets the formatted result for display.
    /// </summary>
    public string FormattedResult => CalculatorFormatter.FormatNumber(Result);
}