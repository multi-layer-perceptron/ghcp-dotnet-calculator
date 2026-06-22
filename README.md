# ghcp-dotnet-calculator
This project demonstrates GitHub Copilot concepts and features while building a basic .NET calculator application with comprehensive xUnit testing. The calculator will support standard arithmetic operations and be designed with a focus on testability, maintainability, and proper error handling.

## Workspace

- Setup script: `./programming/dotnet/csharp/workspace/Set-DotnetSlnForCalculator.ps1`
- Cleanup script: `./programming/dotnet/csharp/workspace/Remove-DotnetSlnForCalculator.ps1`
- Solution: `./programming/dotnet/csharp/workspace/calculator-xunit-testing/calculator.sln`

## Run

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File ./programming/dotnet/csharp/workspace/Set-DotnetSlnForCalculator.ps1
dotnet test ./programming/dotnet/csharp/workspace/calculator-xunit-testing/calculator.sln
dotnet run --project ./programming/dotnet/csharp/workspace/calculator-xunit-testing/calculator/calculator.csproj
```
