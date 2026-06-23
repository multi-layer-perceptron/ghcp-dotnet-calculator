# TypeScript Calculator Application

A modern, web-based calculator application built with TypeScript, featuring comprehensive arithmetic operations, multi-language support, and robust testing capabilities.

## Features

### Core Calculator Functionality

- ✅ Basic arithmetic operations (addition, subtraction, multiplication, division)

- ✅ Advanced operations (modulo %, exponentiation ^)

- ✅ User-friendly web interface with colorized keypad

- ✅ Error handling and input validation

- ✅ Keyboard input support

### Multi-language Support

- 🌍 **English**: Complete documentation and interface

- 🇩🇪 **German**: Vollständige Dokumentation und Benutzeroberfläche

- 🇮🇳 **Hindi**: पूर्ण दस्तावेज़ीकरण और इंटरफ़ेस

- 🇯🇵 **Japanese**: 完全なドキュメントとインターフェース

### Development Features

- 📦 TypeScript implementation with strict mode

- 🧪 Comprehensive Jest testing suite (80%+ coverage)

- 🎨 Responsive CSS design with color-coded interface

- ⌨️ Full keyboard support

- 🛠️ Visual Studio Code integration

## Quick Start

### Prerequisites

Ensure you have Node.js installed on your system:

`\`js

powershell

## Windows 11 - Install Node.js via winget

winget install OpenJS.NodeJS

`\`js

text
text

### Installation

1. **Clone or navigate to the calculator directory**

```text
bash
   cd calculator/
```
1. **Install dependencies**

```text
bash
   npm install
```
1. **Build the TypeScript code**

```text
bash
   npm run build
```
1. **Open the calculator**
   - Open `index.html` in your web browser, or
   - Use Visual Studio Code Live Server extension

### Running Tests

Execute the comprehensive test suite:

`\`js

text
bash

## Run all tests

npm test

## Run tests in watch mode

npm run test:watch

## Run tests with coverage report

npm test -- --coverage

`\`js

text

### Development Mode

For development with automatic TypeScript compilation:

`\`js

text
bash
npm run dev

`\`js

text

## Project Structure

`\`js

text
text
calculator/
├── index.html              # Main application interface

├── calculator.css          # Styling and visual presentation

├── package.json            # Node.js dependencies and scripts

├── tsconfig.json           # TypeScript configuration

├── jest.config.js          # Jest testing configuration

├── .gitignore             # Git ignore patterns

├── src/
│   └── calculator.ts       # TypeScript source code

├── tests/
│   └── calculator.test.ts  # Jest test suite

├── dist/                   # Compiled JavaScript output

└── README.md              # This file

`\`js

text

## Usage Guide

### Basic Operations

| Operation      | Button | Keyboard | Example    |
| -------------- | ------ | -------- | ---------- |
| Addition       | +      | +        | 5 + 3 = 8  |
| Subtraction    | -      | -        | 10 - 4 = 6 |
| Multiplication | ×      | \*       | 7 × 6 = 42 |
| Division       | /      | /        | 15 / 3 = 5 |

### Advanced Operations

| Operation      | Button | Keyboard  | Example    |
| -------------- | ------ | --------- | ---------- |
| Modulo         | %      | %         | 10 % 3 = 1 |
| Exponentiation | ^      | \*\* or ^ | 2 ^ 3 = 8  |

### Interface Features

- **Color-coded Keypad**:
  - 🔵 Blue buttons for numbers
  - 🟠 Orange buttons for basic operations
  - 🟣 Purple buttons for advanced operations
  - 🟢 **Darker green** equals button (as specified in PRD)

- **Keyboard Support**:
  - Numbers: `0-9`
  - Operations: `+`, `-`, `*`, `/`, `%`
  - Calculate: `Enter` or `=`
  - Clear: `Escape` or `C`
  - Delete: `Backspace`

## Testing

The calculator includes a comprehensive test suite covering:

### Test Categories

- ✅ Basic arithmetic operations

- ✅ Advanced operations (modulo, exponentiation)

- ✅ Display operations (append, clear, delete)

- ✅ Complex calculations with order of operations

- ✅ Error handling and edge cases

- ✅ Multi-language documentation verification

### Coverage Requirements

- **Minimum 80% code coverage** (as specified in PRD)

- **All critical paths tested**

- **Edge cases and error scenarios covered**

### Running Specific Tests

`\`js

text
bash

## Run tests with verbose output

npm test -- --verbose

## Run specific test file

npm test calculator.test.ts

## Run tests matching pattern

npm test -- --testNamePattern="arithmetic"

`\`js

text

## Multi-language Code Documentation

The calculator features comprehensive multi-language documentation:

`\`js

text
typescript
/**

 * English: Function to add two numbers
 * German: Funktion zum Addieren zweier Zahlen
 * Hindi: दो संख्याओं को जोड़ने के लिए फ़ंक्शन
 * Japanese: 二つの数値を足し算する関数

 */
function add(a: number, b: number): number {
  return a + b;
}

`\`js

text

## Development Environment

### Visual Studio Code Setup

1. **Install recommended extensions**:
   - TypeScript and JavaScript Language Features
   - Jest Runner
   - Live Server

1. **Open project in VS Code**:

```text
bash
   code .
```
1. **Run and debug**:
   - Use `Ctrl+Shift+P` → "TypeScript: Build"
   - Open `index.html` with Live Server
   - Use integrated terminal for npm commands

### TypeScript Configuration

The project uses strict TypeScript configuration for maximum type safety:

`\`js

text
json
{
  "compilerOptions": {

```js
"strict": true,
"target": "ES2020",
"module": "commonjs"
`\`js

  }
}

`\`js

text

## Browser Compatibility

✅ **Supported Browsers**:

- Chrome (latest 2 versions)

- Firefox (latest 2 versions)

- Safari (latest 2 versions)

- Edge (latest 2 versions)

## Performance

- ⚡ **Response Time**: < 100ms for calculations

- 🚀 **Load Time**: < 2 seconds on standard browsers

- 💾 **Memory Usage**: < 50MB browser memory

## Alternative Testing Frameworks

While this project uses Jest, other testing frameworks were evaluated:

| Framework   | Pros                                        | Use Cases                                   |
| ----------- | ------------------------------------------- | ------------------------------------------- |
| **Jest**    | Excellent TypeScript support, comprehensive | **Recommended** for most projects           |
| **Mocha**   | Flexible, good for complex scenarios        | Large applications with custom requirements |
| **Jasmine** | BDD-focused, minimal setup                  | Behavior-driven development                 |
| **Karma**   | Browser-based testing                       | Cross-browser testing requirements          |
| **AVA**     | Concurrent execution, minimal API           | Performance-critical test suites            |

## Troubleshooting

### Common Issues

**TypeScript compilation errors**:

`\`js

text
bash

## Clean and rebuild

rm -rf dist/
npm run build

`\`js

text

**Jest test failures**:

`\`js

text
bash

## Clear Jest cache

npm test -- --clearCache

`\`js

text

**Module not found errors**:

`\`js

text
bash

## Reinstall dependencies

rm -rf node_modules/
npm install

`\`js

text

### Package Management

**Remove a package**:

`\`js

text
bash
npm uninstall {package_name}

`\`js

text

**Update dependencies**:

`\`js

text
bash
npm update

`\`js

text

## Contributing

1. Fork the repository
1. Create a feature branch
1. Make changes with appropriate multi-language documentation
1. Ensure all tests pass (`npm test`)
1. Submit a pull request

### Code Style Guidelines

- Use TypeScript strict mode

- Maintain 80%+ test coverage

- Include multi-language documentation for new functions

- Follow existing naming conventions

- Add comprehensive error handling

## Future Enhancements

### Potential Features

- 📱 Mobile responsive design optimization

- 🔬 Scientific calculator functions (trigonometry, logarithms)

- 💾 History and memory functions

- ⌨️ Enhanced keyboard shortcuts

- 🎨 Theme customization options

### Platform Expansion

- 📦 Progressive Web App (PWA) conversion

- 🖥️ Electron desktop application

- 📱 React Native mobile application

- 🐍 Python Flask web application alternative

### Internationalization Expansion

- 🌐 Additional language support (Spanish, French, Chinese)

- ↔️ Right-to-left language support (Arabic, Hebrew)

- 🌍 Cultural number formatting

- 💱 Currency and unit conversion features

## License

MIT License - See LICENSE file for details.

## Multi-language Summary

### English

A comprehensive TypeScript calculator with testing and multi-language support.

### German | Deutsch

Ein umfassender TypeScript-Rechner mit Tests und mehrsprachiger Unterstützung.

### Hindi | हिंदी

परीक्षण और बहुभाषी समर्थन के साथ एक व्यापक टाइपस्क्रिप्ट कैलकुलेटर।

### Japanese | 日本語

テストと多言語サポートを備えた包括的なTypeScript電卓。

---

## Built with ❤️ using TypeScript, Jest, and modern web technologies
