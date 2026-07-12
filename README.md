---
title: ghcp-dotnet-calculator
description: GitHub Copilot learning workspace for a .NET 10 console calculator with xUnit, CSV, and Testcontainers PostgreSQL tests
---

## Overview

GitHub Copilot learning workspace for a small .NET 10 calculator lab.

[License: MIT](LICENSE) [.NET 10](https://dotnet.microsoft.com/) [xUnit](https://xunit.net/) [Testcontainers](https://testcontainers.com/) [GitHub Copilot](https://github.com/features/copilot)

This repository contains a compact calculator workspace for practicing GitHub
Copilot-assisted development, testing, refactoring, prompt workflows, and
incremental modernization. The app shows how a small console program can expose
arithmetic operations, input validation, divide-by-zero handling, CSV-backed test
data, Testcontainers-backed PostgreSQL seeding, and repeatable setup prompts.

The implementation is intentionally small rather than production-deep. It gives
participants a realistic but approachable codebase for practicing GitHub Flow,
debugging, refactoring, unit testing, documentation, GitHub Actions concepts, and
custom Copilot prompt and skill authoring.

## Prerequisites

### Must-Have Now

| Tool | Why you need it |
| ---- | --------------- |
| GitHub account | Required to fork, clone, open Codespaces, and use Copilot-assisted workshop flows. |
| Git | Required to clone the repository, create branches, and practice GitHub Flow. |
| VS Code | Recommended editor for the workspace, reusable prompt files, and Copilot Chat. |
| .NET 10 SDK | Required to restore, build, test, and run the calculator locally. |
| Docker Desktop | Required for the Testcontainers PostgreSQL-backed test data workflow. |
| Node.js LTS | Required for MCP-related exercises that use `npx` to run local MCP server configurations. |
| GitHub Copilot | Recommended for the workshop exercises; the calculator can build and run without Copilot. |

### Additional Tools By Path

| Path | Additional tools |
| ---- | ---------------- |
| GitHub Codespaces | Browser or VS Code access. Confirm the image includes .NET 10 and Docker support before running Testcontainers tests. |
| Local Windows, macOS, or Linux setup | .NET 10 SDK, Git, VS Code, Docker Desktop, and Node.js LTS for MCP `npx` workflows. |
| Manual PowerShell validation | PowerShell 7, .NET 10 SDK, Docker Desktop, and repository write access. |
| GitHub Actions practice | GitHub CLI is optional, but useful for creating issues, branches, and pull requests from the terminal. |
| Copilot workshop flows | A Copilot-enabled GitHub account and access to Copilot Chat in VS Code. |

### Hide The Completed Solution

Before starting the lab exercises, hide the `src/completed/` folder from your
working context. That folder contains the finished reference solution, and if
it stays visible, GitHub Copilot can draw on it while you work, which
inadvertently interferes with the integrity and the learning process of
building the same solution yourself through the lab exercises.

Use one of the following approaches:

* **.gitignore (any Copilot SKU):** in your fork, delete or move the
  `src/completed/` folder out of the repository and add an entry to
  [.gitignore](.gitignore) so it is never re-committed:

  ```gitignore
  # Hide the completed reference solution during lab exercises
  src/completed/
  ```

  Note that `.gitignore` only affects untracked files. If `src/completed/` is
  already tracked in your fork, remove it from the index first with
  `git rm -r --cached src/completed`, commit, and keep a copy outside the
  repository for later comparison.

* **Content Exclusion (GitHub Copilot Enterprise SKU):** if your organization
  has Copilot Enterprise, an administrator can configure the
  [Content Exclusion](https://docs.github.com/en/copilot/managing-copilot/configuring-and-auditing-content-exclusion)
  feature for the repository so Copilot never reads the folder, without
  changing the repository contents. Add a repository-level exclusion such as:

  ```yaml
  "*":
    - "src/completed/**"
  ```

Either way, the completed solution stays available to facilitators for
reference while participants build their own solution from a clean slate.

### Local Setup Preflight

When running locally, first open the repository in VS Code and confirm the .NET
SDK is available:

```bash
dotnet --info
```

Then restore, build, and test the calculator solution before starting an
exercise:

```bash
dotnet restore src/workspace/calculator-xunit-testing/calculator.slnx
dotnet build src/workspace/calculator-xunit-testing/calculator.slnx --no-restore
dotnet test src/workspace/calculator-xunit-testing/calculator.slnx --no-build
```

### Permissions And Licensing

| Activity | Requirement |
| -------- | ----------- |
| Run validation commands | Read access to this repository and permission to run local developer tools. |
| Run Testcontainers tests | Docker daemon access on the local machine or development container. |
| Use Codespaces | Codespaces enabled for your GitHub account or organization. |
| Fork for workshop edits | Permission to fork public repositories, or permission to create a copy inside your organization. |
| Push changes or open PRs | Write access to your fork or target repository. |
| Use GitHub Copilot | Copilot Individual, Business, Enterprise, or another license assigned by your organization. |

If your organization restricts Codespaces, Copilot, Docker, GitHub Actions, or
third-party extensions through policy, confirm those features with your
administrator before the workshop. This repository is licensed under [MIT](LICENSE).

## Choose Your Path

| Path | Typical time | Best for | Status |
| ---- | ------------ | -------- | ------ |
| GitHub Codespaces | 5-10 min | Participants who want the least local setup | Supported when .NET 10 and Docker are available |
| Local VS Code setup | 10-15 min | Participants who already have .NET and Docker installed | Recommended |
| Manual PowerShell validation | 10-15 min | Windows users validating from PowerShell | Supported |
| Facilitator walkthrough | 15-20 min | Instructors leading setup, test execution, and first calculator run | Supported |

### Option A - GitHub Codespaces

1. Open the repository in GitHub.
2. Select Code > Codespaces > Create codespace on main.
3. Wait for the environment to finish loading. The first setup can take a few
   minutes.
4. Open a terminal and continue with Validate The Stack.

Codespaces is useful when local .NET installation is a barrier. Confirm the
selected image supports .NET 10 and Docker before running the PostgreSQL-backed
test suite.

### Option B - Local VS Code Setup

1. Install [VS Code](https://code.visualstudio.com/), Git, the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0), and Docker Desktop.
2. Clone or fork the repository using Fork And Clone.
3. Open the repository folder in VS Code.
4. Run `dotnet --info` in the integrated terminal.
5. Start Docker Desktop.
6. Continue with Validate The Stack.

### Option C - Manual PowerShell Validation

Use this path when you want to run setup, tests, and the console calculator from
PowerShell.

1. Install Git for Windows, PowerShell 7, Docker Desktop, and the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).
2. Open a new PowerShell terminal so PATH changes are loaded.
3. Verify the SDK:

   ```powershell
   dotnet --info
   ```

4. Clone or fork the repository using Fork And Clone.
5. Open the repository in VS Code.
6. Run the commands in Validate The Stack.

### Option D - Facilitator Walkthrough

Use this path when you are leading the workshop and want all participants to
start from the same checkpoints.

1. Confirm every participant can open the repository in Codespaces or local VS
   Code.
2. Ask participants to run `dotnet test src/workspace/calculator-xunit-testing/calculator.slnx` before making changes.
3. Walk through the setup, implementation, testing, CSV, PostgreSQL, and .NET
   upgrade prompts in order.
4. Start with a small scoped change, then review the generated diff and test
   results together.

## Fork And Clone

Forking is recommended when you plan to edit the repository, open pull requests,
or use it as a workshop sandbox.

1. On GitHub, select Fork.
2. Clone your fork:

   ```bash
   git clone https://github.com/YOUR-USERNAME/ghcp-dotnet-calculator.git
   cd ghcp-dotnet-calculator
   ```

3. Verify the solution builds:

   ```bash
   dotnet build src/workspace/calculator-xunit-testing/calculator.slnx
   ```

If your organization uses GitHub Enterprise Managed Users and cannot fork
external repositories, create an empty repository in your allowed namespace,
clone this source repository, then change `origin` to your new repository:

```bash
git clone https://github.com/multi-layer-perceptron/ghcp-dotnet-calculator.git
cd ghcp-dotnet-calculator
git remote set-url origin https://github.com/YOUR-ORG-OR-USER/ghcp-dotnet-calculator.git
git push --all origin
git push --tags origin
```

## Getting Started Tutorial

### Validate The Stack

Run these commands from the repository root. Codespaces and properly configured
local environments should both support the same solution commands.

### .NET Calculator Workflow

```bash
dotnet restore src/workspace/calculator-xunit-testing/calculator.slnx
dotnet build src/workspace/calculator-xunit-testing/calculator.slnx --no-restore
dotnet test src/workspace/calculator-xunit-testing/calculator.slnx --no-build
```

Expected result: the solution restores, builds, and the xUnit tests pass across
addition, subtraction, multiplication, division, modulo, exponentiation,
divide-by-zero handling, CSV loading, and PostgreSQL-backed test data seeding.

### Run The Console App

```bash
dotnet run --project src/workspace/calculator-xunit-testing/calculator/calculator.csproj
```

Expected result: the console app prompts for two operands and one operator. It
supports `+`, `-`, `*`, `/`, `%`, and `^`, then asks whether to perform another
calculation.

### Review The Test Data

The test project copies `TestCases.csv` to the test output directory and seeds a
temporary PostgreSQL container from it during automated tests.

```bash
cat src/workspace/calculator-xunit-testing/calculator.tests/TestCases.csv
```

Expected result: the CSV lists arithmetic operation rows with `Operand1`,
`Operand2`, `Operation`, and `ExpectedResult` columns.

### Prompt Workflow Tour

The `.github/prompts/` directory contains reusable prompt files that walk through
the staged calculator workflow:

```text
1.12.1-solution-setup.prompt.md
1.12.2-calculator-implementation.prompt.md
1.12.3-refactor-steps.prompt.md
1.12.4-testing-strategy.prompt.md
2.01-create-csv-test-dataset.prompt.md
2.02-convert-csv-test-data-to-postgresql-container.prompt.md
2.03-switch-test-data-to-pg.prompt.md
3.01-upgrade-dotnet-from-8-to-10.prompt.md
```

## Lab Exercises

The [lab-exercises/](lab-exercises/) folder contains guided exercises that
translate the staged prompt workflows into a progressive lab. The exercises
are re-indexed with a hierarchical dotted-decimal scheme (`module.exercise`)
based on the progression logic of the prompts: build first, then modernize,
then validate quality and security. Each exercise references its associated
prompt and summarizes the learning objectives and how the prompt is used.

Complete the [Hide The Completed Solution](#hide-the-completed-solution)
prerequisite before starting Module 01. Start with Module 00 if you want a
short tour of the Copilot configuration files that drive the lab sequence.

### Module 00 - Explore The Copilot Workspace

| Exercise | Title | Associated prompt |
| -------- | ----- | ----------------- |
| [00.01](lab-exercises/00.01.explore-copilot-config-files.md) | Explore Copilot Configuration Files | None |
| [00.02](lab-exercises/00.02.create-dotnet-dev-agent.md) | Create A .NET Development Agent | None |

### Module 01 - Build The Calculator Solution

| Exercise | Title | Associated prompt |
| -------- | ----- | ----------------- |
| [01.01](lab-exercises/01.01-solution-setup.md) | Solution Setup | `1.12.1-solution-setup` |
| [01.02](lab-exercises/01.02-calculator-implementation.md) | Calculator Implementation | `1.12.2-calculator-implementation` |
| [01.03](lab-exercises/01.03-refactoring-steps.md) | Refactoring Steps | `1.12.3-refactor-steps` |
| [01.04](lab-exercises/01.04-testing-strategy.md) | Testing Strategy | `1.12.4-testing-strategy` |
| [01.05](lab-exercises/01.05-full-solution-walkthrough.md) | Optional Full Baseline Walkthrough | `1.12-implement-full-calculator-solution` |

### Module 02 - Modernize And Migrate

| Exercise | Title | Associated prompt |
| -------- | ----- | ----------------- |
| [02.01](lab-exercises/02.01-upgrade-dotnet-8-to-10.md) | Upgrade .NET 8 To .NET 10 | `3.01-upgrade-dotnet-from-8-to-10` |
| [02.02](lab-exercises/02.02-refactor-to-blazor.md) | Refactor To A Blazor Web App | `3.01.1-refactor-calculator-blazor-app` |
| [02.03](lab-exercises/02.03-azure-migration-assessment.md) | Azure Migration Assessment | `3.02-migrate-to-azure` |

### Module 03 - Quality, Security, And Wrap-Up

| Exercise | Title | Associated prompt |
| -------- | ----- | ----------------- |
| [03.01](lab-exercises/03.01-security-assessment.md) | Security Assessment | `7.01-conduct-security-assessment` |
| [03.02](lab-exercises/03.02-comprehensive-quality-gate.md) | Comprehensive Quality Gate | `12.00.test-for-quality` |
| [03.03](lab-exercises/03.03-final-validation-and-handoff.md) | Final Validation And Handoff | None |

### Module 99 - Finished Project Customization

Use these exercises only after completing the current exercise set from `00.01`
through `03.03` and confirming the completed project exists under
`src/workspace/calculator-xunit-testing/`.

Exercise 99.03 uses the `configure-mcp-servers` skill to configure Azure
DevOps, GitHub, Microsoft Learn, and Playwright. Its Azure DevOps example uses
`autocloudarc-mcaps`; learners substitute their own organization value in the
`https://mcp.dev.azure.com/{organization}` endpoint pattern.

| Exercise | Title | Associated prompt |
| -------- | ----- | ----------------- |
| [99.01](lab-exercises/99.01.custom-instructions-and-agents.md) | Custom Instructions And Agents | None |
| [99.02](lab-exercises/99.02.skills-and-prompts.md) | Skills And Prompts | None |
| [99.03](lab-exercises/99.03.mcp-server-configuration.md) | MCP Server Configuration | None |
| [99.04](lab-exercises/99.04.create-hooks.md) | Create Hooks | None |
| [99.05](lab-exercises/99.05.multi-agent-orchestration.md) | Multi-Agent Orchestration | None |
| [99.06](lab-exercises/99.06.github-agentic-workflows.md) | GitHub Agentic Workflow Diagnostics | None |
| [99.07](lab-exercises/99.07.copilot-coding-agent-code-review.md) | Copilot Coding Agent And Code Review | None |
| [99.08](lab-exercises/99.08.capstone-exercises.md) | Capstone Exercises | None |
| [99.09](lab-exercises/99.09.reset-environments.md) | Reset Azure And Local Environments | `reset-calculator-lab` skill, `3.03-reset-azure-environment`, `3.04-reset-local-docker-pg` |

## Calculator Tutorial

The console calculator is the workshop's main hands-on surface. It walks
participants through the same path the tests exercise: read operands, choose an
operator, execute pure arithmetic operations, handle invalid input, and validate
behavior with repeatable tests.

### Calculator Workflow Diagram

```mermaid
flowchart LR
    User[Console user] --> Prompt[Operand and operator prompts]
    Prompt --> Validation[Input validation]
    Validation --> Operations[CalculatorOperations]
    Operations --> Result[Console result]
    Operations --> Tests[xUnit tests]
    Csv[TestCases.csv] --> PostgreSQL[Testcontainers PostgreSQL]
    PostgreSQL --> Tests
```

### Step 1 - Perform Arithmetic

Purpose: exercise the calculator operations from the console app or direct unit
tests.

How to use it:

1. Start the console app.
2. Enter the first number.
3. Enter the second number.
4. Choose one of `+`, `-`, `*`, `/`, `%`, or `^`.

What this step produces: a calculated result from the corresponding
`CalculatorOperations` method.

### Step 2 - Handle Invalid Input

Purpose: practice safe console input validation and user feedback.

How to use it:

1. Enter non-numeric text when prompted for an operand.
2. Enter an unsupported operator.
3. Divide or modulo by zero.
4. Continue or exit using `y` or `n`.

What this step produces: clear validation messages without crashing the console
session.

### Step 3 - Validate With CSV-Backed Tests

Purpose: separate test data from test code and make arithmetic coverage easy to
extend.

How to use it:

1. Add a row to `TestCases.csv` with operands, operation name, and expected
   result.
2. Run `dotnet test src/workspace/calculator-xunit-testing/calculator.slnx`.
3. Confirm the matching `[MemberData]` theory consumes the new row.

What this step produces: a repeatable xUnit test case generated from structured
CSV data.

### Step 4 - Validate PostgreSQL Test Data Loading

Purpose: practice containerized dependency testing without requiring a shared
database.

How to use it:

1. Start Docker Desktop.
2. Run the xUnit test suite.
3. Let Testcontainers create a temporary PostgreSQL container.
4. Confirm the tests seed and query the `test_data` table.

What this step produces: deterministic test data loaded through PostgreSQL for
the duration of the test run.

### Glossary For Workshop Participants

These terms appear throughout the calculator code, tests, docs, and exercises.
They are deliberately small because the lab is designed for learning rather than
domain complexity.

| Term | Meaning |
| ---- | ------- |
| Console calculator | A command-line app that prompts for operands and an operator. |
| Operand | A numeric input used by an arithmetic operation. |
| Operator | A symbol such as `+`, `-`, `*`, `/`, `%`, or `^` that selects an operation. |
| CalculatorOperations | Static C# class containing pure arithmetic methods. |
| CSV test data | Structured rows in `TestCases.csv` that drive parameterized tests. |
| xUnit | Test framework used by the calculator test project. |
| MemberData | xUnit data source pattern used to feed theory tests. |
| Testcontainers | Library used to create temporary PostgreSQL containers for automated tests. |
| PostgreSQL seed table | Runtime `test_data` table populated from the CSV file during tests. |
| Reusable prompt file | A `.prompt.md` file that gives Copilot repeatable instructions for a common task. |
| Skill | A reusable Copilot workflow package with guidance, scripts, and templates. |

## Useful Commands

| Task | Command |
| ---- | ------- |
| Restore packages | `dotnet restore src/workspace/calculator-xunit-testing/calculator.slnx` |
| Build solution | `dotnet build src/workspace/calculator-xunit-testing/calculator.slnx` |
| Run tests | `dotnet test src/workspace/calculator-xunit-testing/calculator.slnx` |
| Run console app | `dotnet run --project src/workspace/calculator-xunit-testing/calculator/calculator.csproj` |
| Recreate workspace | `pwsh -NoProfile -ExecutionPolicy Bypass -File src/workspace/Set-DotnetSlnForCalculator.ps1` |
| Preview generated-workspace reset | `pwsh .github/skills/reset-calculator-lab/scripts/Remove-DotnetSlnForCalculator.ps1 -WhatIf` |
| Install GitHub Agentic Workflows CLI | `gh extension install github/gh-aw` |
| Upgrade GitHub Agentic Workflows CLI | `gh extension upgrade github/gh-aw` |
| Compile 99.06 agentic workflow | `gh aw compile --strict .github/workflows/99.06.workflow-failure-doctor.md` |
| Check 99.06 agentic workflow status | `gh aw status 99.06.workflow-failure-doctor` |
| Run 99.06 agentic workflow | `gh aw run 99.06.workflow-failure-doctor` |
| Check repository status | `git status --short --branch` |

## Project Layout

```text
ghcp-dotnet-calculator/
  README.md                                      Repository overview and workshop quickstart
  LICENSE                                        MIT license
  azure.yaml                                     Azure Developer CLI metadata for later migration stages
  docs/
    prd-csharp-basic-calculator-solution.md      Calculator product requirements
    azure-migration-assessment-3.02.md           Azure migration assessment notes
  lab-exercises/
    00.01.explore-copilot-config-files.md        Copilot configuration orientation exercise
    00.02.create-dotnet-dev-agent.md             Custom .NET development agent exercise
    01.01-solution-setup.md                      Module 01-03 guided lab exercises
    99.01.custom-instructions-and-agents.md      Finished project customization exercise
    99.02.skills-and-prompts.md                  Finished project skills and prompts exercise
    99.03.mcp-server-configuration.md            Finished project MCP configuration exercise
    99.04.create-hooks.md                        Finished project .NET build hook exercise
    99.05.multi-agent-orchestration.md           Finished project multi-agent orchestration exercise
    99.06.github-agentic-workflows.md            Finished project agentic workflow diagnostics exercise
    99.07.copilot-coding-agent-code-review.md    Finished project Copilot coding agent repair exercise
    99.08.capstone-exercises.md                  Finished project capstone: indexing, memory, and advanced features
  src/
    workspace/
      Set-DotnetSlnForCalculator.ps1             Setup script for the active calculator workspace
      calculator-xunit-testing/
        calculator.slnx                          .NET solution
        calculator/
          Calculator.cs                          Console workflow and input handling
          CalculatorOperations.cs                Pure arithmetic operations
          calculator.csproj                      .NET 10 console app project
        calculator.tests/
          CalculatorTest.cs                      xUnit v3 tests with PostgreSQL-backed data loading
          TestCases.csv                          Arithmetic test dataset
          calculator.tests.csproj                .NET 10 xUnit test project
  .github/
    copilot-instructions.md                      Repository-specific Copilot guidance
    hooks/                                       Copilot lifecycle hook configuration (default.json)
    prompts/                                     Reusable Copilot prompt files
    skills/                                      Reusable Copilot skill packages
      continuous-learning-v2/                    Instinct-based learning skill with background observer
      reset-calculator-lab/                      Final lab reset skill and bundled cleanup script
    workflows/                                   GitHub Actions workflow examples
      99.06.workflow-failure-doctor.md           GitHub Agentic Workflow diagnostic example
      99.06.workflow-failure-doctor.lock.yml      Compiled GitHub Actions workflow for 99.06
      shared/                                    Shared agentic workflow components imported at compile time
  scripts/
    hooks/                                       Lifecycle hook scripts (observation, secret scan, .NET build check)
```

## Control Flow

```mermaid
flowchart TD
    Start[Console app starts] --> ReadFirst[Read first operand]
    ReadFirst --> ReadSecond[Read second operand]
    ReadSecond --> ReadOperator[Read operator]
    ReadOperator --> Dispatch[Switch to CalculatorOperations]
    Dispatch --> DivideCheck{Divide or modulo by zero?}
    DivideCheck -->|No| Result[Print result]
    DivideCheck -->|Yes| Error[Print safe error message]
    Result --> Continue{Continue?}
    Error --> Continue
    Continue -->|Yes| ReadFirst
    Continue -->|No| Exit[Goodbye]
```

## Data Flow

```mermaid
flowchart LR
    Csv[TestCases.csv] --> Seed[SeedFromCsv]
    Seed --> Table[test_data table]
    Table --> Query[LoadAllTestCasesFromPostgres]
    Query --> MemberData[xUnit MemberData providers]
    MemberData --> Tests[Calculator operation tests]
    Tests --> Operations[CalculatorOperations]
```

## Implemented Workflow

1. Create or verify the .NET calculator solution structure.
2. Implement the interactive console calculator.
3. Refactor arithmetic behavior into testable operations.
4. Add xUnit coverage for normal and error cases.
5. Move parameterized test data into `TestCases.csv`.
6. Seed PostgreSQL test data from CSV for automated tests.
7. Use Testcontainers to create isolated PostgreSQL instances per test run.
8. Upgrade the active calculator workspace from .NET 8 to .NET 10.
9. Run build and test validation after each staged prompt.
10. Capture reusable workflows as prompts and skills.
11. Configure and compile the 99.06 GitHub Agentic Workflow diagnostic example.

## Key Documentation

* [Calculator PRD](docs/prd-csharp-basic-calculator-solution.md)
* [Azure migration assessment](docs/azure-migration-assessment-3.02.md)
* [Solution setup prompt](.github/prompts/1.12.1-solution-setup.prompt.md)
* [Calculator setup skill](.github/skills/calculator-setup/SKILL.md)
* [CSV test dataset skill](.github/skills/create-csv-test-dataset/SKILL.md)
* [PostgreSQL container skill](.github/skills/convert-csv-test-data-to-postgresql-container/SKILL.md)
* [Configure MCP servers skill](.github/skills/configure-mcp-servers/SKILL.md)

## Notes For Workshop Facilitators

* The project is intentionally compact and uses calculator behavior rather than
  a domain-heavy business model.
* The active workspace is a .NET 10 console app plus xUnit test project.
* Docker must be running before the Testcontainers-backed tests execute.
* The CSV file remains the human-editable source for arithmetic test cases.
* The PostgreSQL container is temporary for automated tests and is cleaned up at
  process shutdown.
* The prompt files are staged so participants can practice one workflow at a
  time.
* Prefer small, readable changes over broad rewrites during workshop exercises.

## License

[MIT](LICENSE)
