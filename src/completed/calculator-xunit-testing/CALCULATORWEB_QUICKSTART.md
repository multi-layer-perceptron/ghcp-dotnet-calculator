# CalculatorWeb.sln - Quick Start Guide

\n\n?? Location

```

text

.\src\completed\calculator-xunit-testing\CalculatorWeb.sln

```

text
text

\n\n?? Quick Commands

\n\nBuild

```

powershell

cd .\src\completed\calculator-xunit-testing

dotnet build CalculatorWeb.sln

```

text
text

\n\nRun

```

powershell

dotnet run --project CalculatorBlazor\CalculatorBlazor.csproj

```

text
text

\n\nOpen in Browser

```

text

<https://localhost:7264>

```

text
text

\n\n?? Solution Contents

| Project | Type | Purpose |

| -------------------- | -------------- | ---------------------------- |

| **Calculator.Core** | Class Library | Arithmetic operations engine |

| **CalculatorBlazor** | Blazor Web App | Interactive web UI |

\n\n? Build Status

? **Success** - Both projects build without errors

\n\nCalculator.Core: ? Ready
\n\nCalculatorBlazor: ? Ready

\n\n?? Configuration

\n\n**.NET Version:** 8.0
\n\n**HTTPS Port:** 7264
\n\n**HTTP Port:** 5073
\n\n**Configuration:** Debug|Any CPU, Release|Any CPU

\n\n?? Documentation

See `CALCULATORWEB_SOLUTION.md` for detailed information.

\n\n?? What's Included

? Calculator.Core library with 6 operations

? CalculatorBlazor web application

? Interactive calculator component

? Error handling (division by zero, etc.)

? Bootstrap UI styling

? Full integration between projects

\n\n?? Next Steps

\n\nBuild: `dotnet build CalculatorWeb.sln`
\n\nRun: `dotnet run --project CalculatorBlazor\CalculatorBlazor.csproj`
\n\nTest: Open <https://localhost:7264>
\n\nCalculate: Use the interactive calculator UI

\n\n?? Tips

\n\nUse `dotnet clean CalculatorWeb.sln` to clear build artifacts
\n\nUse `--configuration Release` for production builds
\n\nBoth projects automatically update together in this solution

---

**Created:** CalculatorWeb.sln - Consolidated solution combining Calculator.Core and CalculatorBlazor

**Status:** ? Ready for development, testing, and deployment

\n
