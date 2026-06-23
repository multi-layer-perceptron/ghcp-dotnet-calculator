---
title: GitHub Copilot Instructions for Calculator Workspace
description: Repository-specific GitHub Copilot guidance for the calculator solution and customizations
---

## GitHub Copilot Instructions for Calculator Workspace

**Version:** 2.0  
**Last Updated:** June 2026  
**Repository:** `ghcp-dotnet-calculator`

## Overview

This repository is a focused .NET calculator learning workspace with GitHub Copilot customization assets. These instructions guide GitHub Copilot to keep code, tests, prompts, skills, and workflow guidance aligned with the files that exist in this repository.

High-signal areas include:

- A .NET 10 calculator solution under `src/workspace/calculator-xunit-testing/`
- A console calculator project under `src/workspace/calculator-xunit-testing/calculator/`
- A shared calculator library under `src/workspace/calculator-xunit-testing/calculator.library/`
- A Blazor web app under `src/workspace/calculator-xunit-testing/calculator.web/`
- An xUnit test project under `src/workspace/calculator-xunit-testing/calculator.tests/`
- Workspace setup and reset scripts under `src/workspace/`
- A PostgreSQL seeding skill for manual local workflows and a Testcontainers-first test strategy
- Prompt, agent, and skill customization assets under `.github/`
- GitHub workflows under `.github/workflows/`

When generating or modifying code, prefer patterns that already exist in the repository over generic or outdated examples.

---

## Repository Structure

```text
.github/
├── agents/          # Custom Copilot agent definitions (.agent.md)
├── instructions/    # Scoped instruction files (.instructions.md)
├── prompts/         # Numbered prompt workflows (.prompt.md)
├── skills/          # Repo-specific automation skills
├── workflows/       # GitHub Actions CI/CD workflows
├── scripts/         # Workflow helper scripts
├── dependabot.yml
└── dependency-review-config.yml

src/
├── workspace/
│   ├── Set-DotnetSlnForCalculator.ps1
│   ├── Remove-DotnetSlnForCalculator.ps1
│   └── calculator-xunit-testing/
│       ├── calculator.slnx
│       ├── calculator/
│       │   ├── calculator.csproj
│       │   └── Calculator.cs
│       ├── calculator.library/
│       │   ├── calculator.library.csproj
│       │   └── CalculatorOperations.cs
│       ├── calculator.tests/
│       │   ├── calculator.tests.csproj
│       │   ├── CalculatorTest.cs
│       │   └── TestCases.csv
│       └── calculator.web/
│           ├── calculator.web.csproj
│           ├── Components/
│           ├── Services/
│           └── wwwroot/
└── completed/
```

---

## Core Principles

1. **Prefer existing patterns** — Reuse helpers, scripts, project structures, and runners already in the repo before creating parallel implementations.
2. **Intent clarity** — Start with explicit action verbs; specify deliverable types and success criteria.
3. **Specificity** — Include exact names, data types, library versions, and numeric constraints.
4. **Structured communication** — Use bullet points, sections, and avoid ambiguous pronouns.
5. **Environment-driven configuration** — Use environment variables for integration points; make failure messages actionable by naming the missing variable or dependency.

---

## Programming Standards

### General Rules

- Add descriptive documentation comments (XML docs, JSDoc, docstrings) with parameters, returns, and exceptions
- Use input validation with early returns for error conditions
- Keep functions focused on a single responsibility (aim for < 50 lines)
- Use meaningful variable names (avoid single letters except in loops)
- Keep files under 200 lines when practical
- Use appropriate access modifiers (private by default)

### Language-Specific Conventions

| Language | Framework | Testing | Naming | Target |
|----------|-----------|---------|--------|--------|
| C# | .NET 8–10 | xUnit | PascalCase (public), camelCase (params) | `net8.0` or `net10.0` per project |
| C/C++ | CMake | Google Test / catch2 | snake_case / PascalCase | C++17 |
| Python | varies | pytest | snake_case | 3.8+ |
| TypeScript | strict mode | Jest | camelCase | ES2020+ |
| Java | Maven | JUnit 5 | PascalCase (classes), camelCase (methods) | 11+ |
| PowerShell | 7+ | Pester | PascalCase | Set-StrictMode Latest |
| Go | go modules | go test | exported PascalCase | latest stable |

### .NET/C# (Active Calculator Workspace)

- Use `#nullable enable` in all source files
- Include XML documentation (`///`) on all public members
- Prefer xUnit for tests in `calculator.tests`
- Use async/await for I/O operations
- Keep pure calculator behavior in `calculator.library`, application wiring in `calculator` or `calculator.web`, and assertions in `calculator.tests`
- For CSV-backed calculator tests, keep `TestCases.csv` in the `calculator.tests` project root and copy it to the output directory
- For iterative local app/UI development, use a persistent local PostgreSQL container seeded from `TestCases.csv`
- For automated PostgreSQL-backed calculator tests, prefer Testcontainers with per-run randomized credentials and runtime CSV seeding
- Use the PostgreSQL container seeding skill to maintain stable local connection settings during refactoring
- Do not include plaintext credential examples in prompts, skills, docs, or test code
- Follow Microsoft naming conventions strictly

### PowerShell

- Opening braces `{` on new line
- `Set-StrictMode -Version Latest` at script top
- `$ErrorActionPreference = 'Stop'` for deployment scripts
- Use `[Parameter(Mandatory=$true)]` validation
- Resolve repo root from `$PSScriptRoot`

### Python

- Follow PEP 8; use type hints on all function signatures
- Google-style docstrings
- Use `logging` module instead of `print()` in production code
- Keep dependencies in `requirements.txt`

### TypeScript

- `strict: true` in tsconfig.json; never use `any`
- Full type definitions on all exports
- Functional React components with hooks (for React projects)

---

## Testing Standards

- Write tests alongside implementation (TDD preferred)
- Test naming: `[MethodName]_[Scenario]_[ExpectedBehavior]`
- Include edge cases, error conditions, and happy paths
- Aim for 80%+ coverage on critical paths
- Extend existing test projects before introducing new frameworks
- For calculator validation, run `dotnet test src/workspace/calculator-xunit-testing/calculator.slnx`
- To recreate the exercise solution, run `pwsh src/workspace/Set-DotnetSlnForCalculator.ps1`; to reset it, run `pwsh src/workspace/Remove-DotnetSlnForCalculator.ps1`
- Keep integration/E2E tests deterministic and isolated; prefer ephemeral resources such as Testcontainers when feasible

---

## CI/CD and Workflow Conventions

- Use descriptive kebab-case names (`build-and-test-dotnet`)
- Pin action versions (`actions/checkout@v4`)
- Never hardcode secrets; use `secrets.` or environment variables
- Preserve GHAS coverage: CodeQL triggers on `push`, `pull_request`, `schedule`, `workflow_dispatch`
- Do not relax dependency review policy without explicit justification
- Separate build, test, and deploy jobs with proper `needs:` dependencies
- Use concurrency groups to cancel in-progress runs

---

## Infrastructure as Code

- Follow Azure naming conventions (`rg-${environment}-${project}`)
- Include parameter descriptions, metadata, and validation rules
- Implement consistent tagging (environment, cost center, owner, project)
- Use minimal RBAC permissions and enable diagnostics logging
- Add infrastructure assets only when needed for a tracked exercise, and document their location in the relevant prompt or skill

---

## Documentation Standards

- Markdown with proper heading hierarchy (H1 > H2 > H3)
- Language-tagged code fences (use `text` over empty fences when no language applies)
- Relative paths for internal links
- PRDs follow the template: Executive Summary → Problem Statement → Goals → Functional Requirements → Non-Functional Requirements → Implementation Guidance → Testing → Success Criteria

---

## Prompt, Agent, and Skill Conventions

- **Prompts** (`.github/prompts/`): Follow the numbered naming scheme (`1.14-...`, `2.03-...`, `3.04-...`) representing staged workflows
- **Agents** (`.github/agents/`): Keep frontmatter accurate; update existing definitions rather than creating duplicates
- **Skills** (`.github/skills/`): Self-contained folders with `SKILL.md` and supporting scripts
- **Accuracy**: Verify names and paths against live directory contents; older docs may lag behind
- **Upgrade history**: Preserve intentional pre-upgrade `.NET 8` references in stage-specific prompts, PRDs, and reports. Normalize only current active workspace guidance to `.NET 10` after the 3.01 upgrade workflow.

### GitHub Copilot Agent Skills

Use agent skills for repeatable, on-demand workflows that should load only when relevant. Prefer custom instructions for broad, always-on repository guidance, prompt files for single reusable task prompts, and custom agents when the workflow needs a distinct persona, context isolation, or tool restrictions.

Create project skills under `.github/skills/<skill-name>/` unless there is a clear reason to use `.agents/skills/<skill-name>/` or `.claude/skills/<skill-name>/`. Each skill must include a file named exactly `SKILL.md`; optional supporting files can live beside it in folders such as `scripts/`, `references/`, or `assets/`.

Required `SKILL.md` frontmatter:

```yaml
---
name: skill-name
description: "What the skill does. Use when: include specific trigger phrases users will type."
---
```

- Keep the skill folder name and `name` value lowercase, hyphenated, and matching.
- Make the `description` keyword-rich because Copilot uses it to decide when to load the skill.
- Put step-by-step procedure, examples, quality bars, and tool guidance in the Markdown body.
- Reference bundled resources with relative paths such as `[script](./scripts/run-checks.ps1)`.
- Keep `SKILL.md` focused; move long supporting guidance into `references/` and load it only when needed.
- Only pre-approve shell-like tools after reviewing every included script and trusting the source.

Example structure:

```text
.github/skills/python-cli-app/
├── SKILL.md
├── scripts/
│   └── smoke-test.ps1
├── references/
│   └── python-style.md
└── assets/
    └── starter-template.py
```

For Copilot CLI sessions, use `/skills reload`, `/skills list`, and `/skills info <skill-name>` after adding or changing a skill. When using GitHub CLI skill management, inspect third-party skills before installing them with `gh skill preview`, then use `gh skill install`, `gh skill update`, or `gh skill publish --dry-run` as appropriate.

---

## Pull Request Guidelines

### PR Description Structure

```markdown
## What changed
- Summary of modifications and affected components
- Link to related issues

## Why
- Business context and technical reasoning

## Testing
- [ ] Unit tests pass and cover new functionality
- [ ] Manual testing completed for user-facing changes
- [ ] Performance/security considerations addressed


## Breaking Changes
- API changes or behavioral modifications with migration instructions

## Checklist
- [ ] Code follows project style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] All tests passing locally
```

### Code Review Focus

- **Security:** Input validation, auth, secrets, data handling
- **Performance:** Query optimization, algorithmic complexity, memory
- **Testing:** Coverage, edge cases, integration scenarios
- **Documentation:** Comments, README updates, inline docs

---

## Quality Metrics

- **Maintainability:** Readable by new team members within 15 minutes
- **Test Coverage:** 80%+ on critical paths; 100% on business logic
- **Complexity:** Cyclomatic complexity < 10 per function (aim for < 5)
- **Performance:** Build < 5 minutes; deploy < 10 minutes
- **Security:** No hardcoded secrets; validated inputs; no sensitive data in logs

---

## Pre-Submission Checklist

- [ ] Follows language-specific style guide
- [ ] All tests pass locally
- [ ] No security vulnerabilities (secrets, unvalidated input)
- [ ] Error handling implemented appropriately
- [ ] PR description follows template
- [ ] Commit messages: `verb: description`
- [ ] No `console.log`/`Debug.WriteLine` or commented-out code left behind

---

## Anti-Patterns to Avoid

| ❌ Don't | ✅ Do |
|-----------|--------|
| "Fix this code" | "Fix the null reference in CalculateTotal() by validating the values parameter" |
| "Create a function" | "Create a function validating emails per RFC 5322, throwing ArgumentException for invalid input" |
| "Optimize performance" | "Optimize the query to < 500ms by indexing UserId and CreatedDate" |
| "Update that file" | "Update Program.cs to add input validation following the pattern in Calculator.cs" |

---

## Resources

- [GitHub Copilot Docs](https://docs.github.com/en/copilot)
- [Agent Definitions](agents/)
- [Workflow Examples](workflows/)
- [Prompt Library](prompts/)
