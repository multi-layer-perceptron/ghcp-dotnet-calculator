---
applyTo: "programming/dotnet/csharp/workspace/calculator-xunit-testing/**"
---
# Project Overview

The Calculator xUnit Testing project is a .NET 8.0 solution demonstrating test-driven development with xUnit, parameterized testing using CSV test data, Blazor web UI components, and a service-based architecture. The project includes a core calculator library, comprehensive unit tests, and an interactive web interface.

# Folder Structure

- `/calculator`: Core calculator library with arithmetic logic
- `/calculator.tests`: xUnit unit tests with parameterized test data
- `TestData/`: CSV files for test data
- `/calculator.web`: Blazor web UI application
- `Components/`: Reusable Razor components (CalculatorKeypad, HistoryPanel, ThemeToggle)
- `Services/`: Business logic services (CalculatorService, HistoryService, ThemeService)
- `Pages/`: Routable pages and layouts
- `Models/`: Data models
- `wwwroot/css/`: Styling for components
- `/calculator.sln`: Solution file

# Libraries and Frameworks

- **.NET 8.0**: Target framework (Long-Term Support)
- **xUnit**: Unit testing framework with parameterized test support
- **Blazor**: Interactive web UI framework with component-based architecture
- **Microsoft.NET.Sdk.BlazorWebAssembly**: Blazor WebAssembly SDK

# Coding Standards

- **Naming**: PascalCase for classes, methods, and properties; camelCase for private fields and local variables.
- **Testing**: Write tests before or alongside implementation (TDD); use `[MethodName]_[Condition]_[ExpectedResult]` naming for test methods.
- **Test Data**: Store parameterized test data in CSV files within the `TestData/` folder; use `[MemberData]` attributes.
- **Components**: Keep Razor components focused on UI rendering; use dependency injection for business logic.
- **Assertions**: Use xUnit's `Assert` class for clarity in tests.
- **Code Organization**: Separate concerns using service-based architecture; avoid over-engineering.
- **Documentation**: Document public methods with XML documentation comments (`///`).

# Key Practices

- Always run the following command before committing changes:

```bash
dotnet test
```

- Use `[Theory]` with `[InlineData]` or `[MemberData]` for parameterized tests.
- Inject services into Blazor components using the `@inject` directive.
- Validate numeric inputs in calculator methods.
- Keep test data in CSV files to avoid duplication.

\n
