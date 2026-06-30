namespace calculator.web.Services;

/// <summary>
/// Tracks the active calculator theme for the current Blazor circuit.
/// </summary>
public sealed class ThemeService
{
    /// <summary>
    /// Occurs when the theme changes.
    /// </summary>
    public event Action? OnThemeChanged;

    /// <summary>
    /// Gets the CSS class for the active theme.
    /// </summary>
    public string CssClass => IsDarkMode ? "theme-dark" : "theme-light";

    /// <summary>
    /// Gets a value indicating whether dark mode is active.
    /// </summary>
    public bool IsDarkMode { get; private set; }

    /// <summary>
    /// Toggles between light and dark themes.
    /// </summary>
    public void ToggleTheme()
    {
        IsDarkMode = !IsDarkMode;
        OnThemeChanged?.Invoke();
    }
}