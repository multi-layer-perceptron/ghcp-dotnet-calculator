# Calculator TypeScript

A simple TypeScript calculator console application that performs basic arithmetic operations. This project was converted from a C# calculator console application.

## Features

- **Arithmetic Operations**: Addition, Subtraction, Multiplication, Division, Modulo, and Exponentiation

- **Input Validation**: Validates numeric inputs and operators

- **Error Handling**: Handles division by zero and invalid operations

- **Interactive CLI**: User-friendly command-line interface with readline

- **Type Safety**: Full TypeScript type annotations and strict mode enabled

## Supported Operations

- `+` - Addition

- `-` - Subtraction

- `*` - Multiplication

- `/` - Division (with division by zero protection)

- `%` - Modulo (with modulo by zero protection)

- `^` - Exponentiation

## Project Structure

`\`ts

text
calculator-typescript/
├── src/
│   ├── calculator.ts    # Calculator class with arithmetic operations

│   ├── cli.ts          # Command-line interface and main entry point

│   └── test.ts         # Basic test suite demonstrating usage

├── package.json        # Project dependencies and scripts

├── tsconfig.json       # TypeScript compiler configuration

└── README.md          # This file

`\`ts

text
text

## Prerequisites

- Node.js (v16 or higher recommended)

- npm (comes with Node.js)

## Installation

1. Navigate to the project directory:

   ```

bash
   cd programming/typescript-react/workspace/calculator-typescript
   ```

1. Install dependencies:
   ```

bash
   npm install
   ```

## Usage

### Running the Calculator

To start the interactive calculator:

`\`ts

text
bash
npm start

`\`ts

text

or

`\`ts

text
bash
npm run dev

`\`ts

text

### Running Tests

To run the basic test suite:

`\`ts

text
bash
npm test

`\`ts

text

### Building the Project

To compile TypeScript to JavaScript:

`\`ts

text
bash
npm run build

`\`ts

text

The compiled JavaScript files will be in the `dist` directory.

## Interactive Calculator Usage

When you run the calculator, you'll see a menu like this:

`\`ts

text
text
=== Simple Calculator ===

Enter first operand: 10
Enter second operand: 5
Enter operator (+, -, *, /, %, ^): +

Result: 10 + 5 = 15

Do you want to perform another calculation? (yes/no):

`\`ts

text

Simply follow the prompts to perform calculations. Enter `yes` or `y` to continue, or `no` or `n` to exit.

## API Documentation

### Calculator Class

The `Calculator` class provides static methods for performing arithmetic operations.

#### Methods

##### `add(first: number, second: number): number`

Adds two numbers and returns the sum.

## Example

`\`ts

text
typescript
import { Calculator } from "./calculator";
const result = Calculator.add(10, 5); // 15

`\`ts

text

##### `subtract(first: number, second: number): number`

Subtracts the second number from the first and returns the difference.

## Example

`\`ts

text
typescript
const result = Calculator.subtract(10, 5); // 5

`\`ts

text

##### `multiply(first: number, second: number): number`

Multiplies two numbers and returns the product.

## Example

`\`ts

text
typescript
const result = Calculator.multiply(10, 5); // 50

`\`ts

text

##### `divide(first: number, second: number): number`

Divides the first number by the second and returns the quotient. Returns `NaN` if dividing by zero.

## Example

`\`ts

text
typescript
const result = Calculator.divide(10, 5); // 2
const error = Calculator.divide(10, 0); // NaN (with error message)

`\`ts

text

##### `modulo(first: number, second: number): number`

Returns the remainder when dividing the first number by the second. Returns `NaN` if dividing by zero.

## Example

`\`ts

text
typescript
const result = Calculator.modulo(10, 3); // 1
const error = Calculator.modulo(10, 0); // NaN (with error message)

`\`ts

text

##### `exponent(first: number, second: number): number`

Raises the first number to the power of the second number.

## Example

`\`ts

text
typescript
const result = Calculator.exponent(2, 3); // 8

`\`ts

text

##### `performCalculation(first: number, operator: string, second: number): number`

Performs a calculation based on the provided operator. Returns `NaN` for invalid operators.

## Example

`\`ts

text
typescript
const result = Calculator.performCalculation(10, "+", 5); // 15

`\`ts

text

##### `isValidOperator(operator: string): boolean`

Validates if a string is a valid operator (+, -, \*, /, %, ^).

## Example

`\`ts

text
typescript
const valid = Calculator.isValidOperator("+"); // true
const invalid = Calculator.isValidOperator("?"); // false

`\`ts

text

## Error Handling

The calculator handles the following error cases:

- **Division by Zero**: Returns `NaN` and displays an error message

- **Modulo by Zero**: Returns `NaN` and displays an error message

- **Invalid Operators**: Returns `NaN` for invalid operators

- **Invalid Numeric Input**: Prompts the user to re-enter valid numbers

## Development

### TypeScript Configuration

The project uses strict TypeScript configuration (`strict: true`) for maximum type safety. Key compiler options:

- **Target**: ES2020

- **Module**: CommonJS

- **Strict Mode**: Enabled

- **Source Maps**: Enabled for debugging

### Code Style

- Uses JSDoc comments for all exported functions and classes

- Follows TypeScript best practices

- Implements proper error handling

- Uses descriptive variable and function names

## Conversion Notes

This TypeScript calculator was converted from a C# console application located at:
`programming/dotnet/csharp/workspace/calculator-xunit-testing/calculator/Calculator.cs`

Key differences from the C# version:

- Uses Node.js `readline` module instead of `Console.ReadLine()`

- Uses `async/await` for handling asynchronous user input

- Uses TypeScript's type system instead of C# types

- Uses `Math.pow()` instead of `Math.Pow()`

- Uses `NaN` instead of `double.NaN`

## License

MIT
