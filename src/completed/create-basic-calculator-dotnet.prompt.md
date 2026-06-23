# Create Basic Calculator Dotnet.Prompt

---

description: Create a .NET 8 console calculator application with xUnit testing framework, following best practices for testability, maintainability, and proper error handling.

name: create-basic-calculator-dotnet

agent: agent

model: Claude Haiku 4.5 (copilot)

tools:
\n\ngithub/*

---

\n\nCreate Basic .NET Calculator with xUnit Testing

You are an expert .NET developer helping users build a well-structured calculator application that demonstrates modern C# development practices.

\n\nObjective

Create a .NET 8 console calculator application with xUnit unit testing that supports arithmetic operations (+, -, \*, /, %, ^), proper error handling, and comprehensive test coverage.

\n\nKey Requirements

\n\nApplication Structure

\n\n.NET 8 console application using C# top-level statements

\n\nSeparate xUnit test project with comprehensive test coverage
\n\nWell-organized solution following .NET project conventions
\n\nAll arithmetic operations implemented as separate, testable methods
\n\nPublic methods for testing accessibility

\n\nFunctional Requirements

\n\nSupport arithmetic operations: addition, subtraction, multiplication, division, modulo, exponent
\n\nGraceful error handling for division by zero
\n\nUser input validation with meaningful feedback
\n\nAllow multiple calculations without restarting
\n\nClear console interface with screen clearing between calculations
\n\nConfirmation before exiting application
\n\nProper null handling to prevent runtime exceptions

\n\nCode Quality Standards

\n\nFollow C# best practices and coding conventions (PascalCase for variables/functions)

\n\nInclude comprehensive JSDoc/XML documentation comments for all methods
\n\nImplement input validation and early returns for error conditions
\n\nUse meaningful variable names
\n\nKeep functions focused and appropriately sized
\n\nAll core functionality covered by unit tests

\n\nTesting Strategy

\n\nUse xUnit framework for unit testing
\n\nImplement both Fact tests for simple assertions
\n\nUse Theory tests with InlineData for multiple test cases
\n\nInclude edge cases and failure scenarios (e.g., division by zero)
\n\nProvide at least three test cases per operation
\n\nEnsure all tests pass before completion

\n\nDevelopment Workflow

\n\n**Setup Phase**
\n\nCreate solution folder structure: `calculator-xunit-testing`
\n\nInitialize .NET 8 solution
\n\nCreate console application project named `calculator`
\n\nCreate xUnit test project named `calculator.tests`
\n\nConfigure project references

\n\n**Implementation Phase**
\n\nImplement calculator in `Calculator.cs` using top-level statements
\n\nConvert operations to individual testable methods
\n\nAdd input validation and error handling
\n\nImplement modulo and exponent operations
\n\nAdd screen clearing for better UX
\n\nFix null reference warnings using proper null handling

\n\n**Testing Phase**
\n\nCreate comprehensive xUnit tests in `CalculatorTest.cs`
\n\nTest all arithmetic operations with multiple scenarios
\n\nInclude edge case testing
\n\nVerify error handling

\n\n**Cleanup**
\n\nEnsure no warnings or errors remain
\n\nVerify all tests pass
\n\nCreate cleanup script for resetting the exercise

\n\nGuidelines

\n\n**Simplicity First**: Use straightforward implementations before adding complexity
\n\n**No Duplication**: Check for similar code elsewhere in the codebase
\n\n**Testability**: Design all operations as public methods that can be easily tested
\n\n**Error Handling**: Validate inputs and handle exceptions gracefully
\n\n**Documentation**: Include JSDoc comments for each method explaining parameters and return values
\n\n**Best Practices**: Follow the copilot-instructions.md standards for C# and .NET development

\n\nReference Materials

\n\nPRD Location: [PRD: .NET Calculator with xUnit Testing](${workspaceFolder}/src/workspace/prd-csharp-basic-calculator-solution.md)
\n\nCoding Standards: [Copilot Instructions](${workspaceFolder}/.github/copilot-instructions.md)

\n\nSuccess Criteria

\n\nAll calculator operations work correctly with valid and invalid inputs
\n\nxUnit tests cover all arithmetic operations with multiple test cases
\n\nConsole application runs without crashes
\n\nAll build and test commands execute successfully
\n\nCode meets .NET null safety standards
\n\nClear, helpful documentation is present

\n\nExample Usage

Once created, users can:

\n\nRun the calculator: `dotnet run --project calculator`
\n\nExecute tests: `dotnet test calculator.tests`
\n\nBuild solution: `dotnet build`

\n\nOutput Format

Provide:

\n\nClear step-by-step implementation guidance
\n\nComplete, production-ready code
\n\nExplanation of key design decisions
\n\nTest execution results showing all tests passing
\n\nAny additional documentation or scripts needed

\n
