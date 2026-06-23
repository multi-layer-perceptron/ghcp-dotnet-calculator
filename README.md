# ghcp-dotnet-calculator

This project demonstrates GitHub Copilot concepts and features while building a basic .NET calculator application with comprehensive xUnit testing. The calculator will support standard arithmetic operations and be designed with a focus on testability, maintainability, and proper error handling.

## Workspace

- Setup script: `./src/workspace/Set-DotnetSlnForCalculator.ps1`
- Cleanup script: `./src/workspace/Remove-DotnetSlnForCalculator.ps1`
- Solution: `./src/workspace/calculator-xunit-testing/calculator.sln`

## Run

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File ./src/workspace/Set-DotnetSlnForCalculator.ps1
dotnet test ./src/workspace/calculator-xunit-testing/calculator.sln
dotnet run --project ./src/workspace/calculator-xunit-testing/calculator/calculator.csproj
```
