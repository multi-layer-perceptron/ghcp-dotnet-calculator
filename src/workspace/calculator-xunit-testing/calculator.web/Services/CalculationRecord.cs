namespace calculator.web.Services;

/// <summary>
/// Represents a completed calculator operation shown in history.
/// </summary>
/// <param name="LeftOperand">The left operand.</param>
/// <param name="Operator">The operation symbol.</param>
/// <param name="RightOperand">The right operand.</param>
/// <param name="Result">The calculated result.</param>
/// <param name="Timestamp">The time the calculation completed.</param>
public sealed record CalculationRecord(
    double LeftOperand,
    string Operator,
    double RightOperand,
    double Result,
    DateTimeOffset Timestamp)
{
    /// <summary>
    /// Gets formatted text for display in the history panel.
    /// </summary>
    public string DisplayText => $"{LeftOperand:G15} {Operator} {RightOperand:G15} = {Result:G15} ({Timestamp:HH:mm:ss})";
}