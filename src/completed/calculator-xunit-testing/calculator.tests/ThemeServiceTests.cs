namespace calculator.tests;

using calculator.web.Services;

public class ThemeServiceTests
{
    private readonly ThemeService _sut;

    public ThemeServiceTests()
    {
        _sut = new ThemeService();
    }

    [Fact]
    public void GivenDefaultTheme_WhenCreated_UsesLightThemeClass()
    {
        Assert.False(_sut.IsDarkMode);
        Assert.Equal("theme-light", _sut.ThemeClass);
    }

    [Fact]
    public void GivenLightTheme_WhenToggle_UsesDarkThemeClass()
    {
        _sut.Toggle();

        Assert.True(_sut.IsDarkMode);
        Assert.Equal("theme-dark", _sut.ThemeClass);
    }

    [Fact]
    public void GivenDarkTheme_WhenToggleTwice_ReturnsToLightThemeClass()
    {
        _sut.Toggle();
        _sut.Toggle();

        Assert.False(_sut.IsDarkMode);
        Assert.Equal("theme-light", _sut.ThemeClass);
    }
}