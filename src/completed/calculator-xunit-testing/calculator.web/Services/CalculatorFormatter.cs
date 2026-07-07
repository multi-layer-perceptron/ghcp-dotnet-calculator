namespace calculator.web.Services;

using System.Globalization;

/// <summary>
/// Formats calculator values consistently across the web app.
/// </summary>
public static class CalculatorFormatter
{
    /// <summary>
    /// Formats a number using invariant culture and practical precision.
    /// </summary>
    /// <param name="value">The numeric value to format.</param>
    /// <returns>A formatted number string.</returns>
    public static string FormatNumber(double value) => value.ToString("G12", CultureInfo.InvariantCulture);
}