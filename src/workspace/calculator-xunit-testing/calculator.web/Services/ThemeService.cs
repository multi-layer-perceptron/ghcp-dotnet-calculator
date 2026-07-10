namespace calculator.web.Services;

/// <summary>
/// Maintains session-scoped visual theme state.
/// </summary>
public sealed class ThemeService
{
    /// <summary>
    /// Gets a value indicating whether the dark theme is active.
    /// </summary>
    public bool IsDarkMode { get; private set; }

    /// <summary>
    /// Gets the CSS class for the current theme.
    /// </summary>
    public string ThemeClass => IsDarkMode ? "theme-dark" : "theme-light";

    /// <summary>
    /// Toggles between light and dark themes.
    /// </summary>
    public void Toggle() => IsDarkMode = !IsDarkMode;
}