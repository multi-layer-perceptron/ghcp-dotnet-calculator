# .NET 10.0 Upgrade Plan

\n\nExecution Steps

Execute steps below sequentially one by one in the order they are listed.

\n\nValidate that a .NET 10.0 SDK required for this upgrade is installed on the machine and if not, help to get it installed.
\n\nEnsure that the SDK version specified in global.json files is compatible with the .NET 10.0 upgrade.
\n\nRun unit tests to validate upgrade in the projects listed below:
\n\ncalculator.tests\calculator.tests.csproj
\n\nUpgrade Calculator.Core\Calculator.Core.csproj
\n\nUpgrade CalculatorBlazor\CalculatorBlazor.csproj
\n\nRun unit tests for the CalculatorBlazor project to validate upgrade.

\n\nSettings

\n\nProject upgrade details

\n\ncalculator\calculator.csproj modifications

Project properties changes:

\n\nTarget framework should be changed from `net8.0` to `net10.0`

\n\ncalculator.tests\calculator.tests.csproj modifications

Project properties changes:

\n\nTarget framework should be changed from `net8.0` to `net10.0`

\n
