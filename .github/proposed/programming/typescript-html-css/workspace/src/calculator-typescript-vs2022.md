# Calculator Typescript Vs2022

Creating a basic calculator app with TypeScript in Visual Studio 2022 is a great way to get started with both TypeScript and Visual Studio. Here's a step-by-step guide:

1. **Set Up Your Project**:
   - Open Visual Studio 2022 and create a new project.
   - Select "ASP.NET Core Web Application" and click "Next".
   - Name your project and choose a location to save it, then click "Create".
   - Select "Empty" as the project template and make sure "Enable Docker Support" and "Configure for HTTPS" are unchecked. Click "Create".

1. **Add TypeScript Support**:
   - Right-click on your project in the Solution Explorer and select "Add" > "New Item".
   - Choose "TypeScript JSON Configuration File" and name it `tsconfig.json`. This file will configure the TypeScript compiler options.

`\`ts
 ```
`\`ts

json

`\`ts
 {
   "compilerOptions": {

```ts
 "target": "es5",
 "module": "commonjs",
 "strict": true,
 "esModuleInterop": true,
 "skipLibCheck": true,
 "forceConsistentCasingInFileNames": true
`\`ts

   }
 }
 ```
`\`ts

1. **Create the Calculator App**:
   - Add a new TypeScript file to your project. Right-click on your project, select "Add" > "New Item", and choose "TypeScript File". Name it `calculator.ts`.

`\`ts
 ```
`\`ts

typescript

`\`ts
 class Calculator {
   add(a: number, b: number): number {

```ts
 return a + b;
`\`ts

   }
`\`ts

`\`ts
   subtract(a: number, b: number): number {

```ts
 return a - b;
`\`ts

   }
`\`ts

`\`ts
   multiply(a: number, b: number): number {

```ts
 return a * b;
`\`ts

   }
`\`ts

`\`ts
   divide(a: number, b: number): number {

```ts
 if (b === 0) {
   throw new Error("Division by zero is not allowed.");
 }
 return a / b;
`\`ts

   }
 }
`\`ts

`\`ts
 // Example usage
 const calculator = new Calculator();
 console.log(calculator.add(2, 3)); // Output: 5
 console.log(calculator.subtract(5, 2)); // Output: 3
 console.log(calculator.multiply(4, 3)); // Output: 12
 console.log(calculator.divide(10, 2)); // Output: 5
 ```
`\`ts

1. **Compile TypeScript to JavaScript**:
   - Open the terminal in Visual Studio (View > Terminal) and run the TypeScript compiler:

`\`ts
 ```
`\`ts

sh

`\`ts
 tsc
 ```
`\`ts

   This will compile your TypeScript code to JavaScript.

1. **Run Your App**:
   - You can run the compiled JavaScript file using Node.js. In the terminal, run:

`\`ts
 ```
`\`ts

sh

`\`ts
 node calculator.js
 ```
`\`ts

   This will execute your calculator app and display the results in the terminal.

That's it! You've created a basic calculator app with TypeScript in Visual Studio 2022. If you have any questions or need further assistance, feel free to ask!

To test your TypeScript calculator app with Vitest in Visual Studio 2022, follow these steps:

1. **Set Up Your Project**:
   - Ensure you have Node.js installed. If not, download and install it from nodejs.org.

1. **Install Vitest**:
   - Open the terminal in Visual Studio (View > Terminal) and navigate to your project directory.
   - Install Vitest as a development dependency:

`\`ts
 ```
`\`ts

sh

`\`ts
 npm install --save-dev vitest
 ```
`\`ts

1. **Configure Vitest**:
   - Add a `vitest.config.ts` file to your project root with the following content:

`\`ts
 ```
`\`ts

typescript

`\`ts
 import { defineConfig } from "vitest/config";
`\`ts

`\`ts
 export default defineConfig({
   test: {

```ts
 globals: true,
 environment: "node",
`\`ts

   },
 });
 ```
`\`ts

1. **Create Test Cases**:
   - Create a new file named `calculator.test.ts` in your project directory and add your test cases:

`\`ts
 ```
`\`ts

typescript

`\`ts
 import { describe, it, expect } from "vitest";
 import { Calculator } from "./calculator";
`\`ts

`\`ts
 describe("Calculator", () => {
   it("should add two numbers", () => {

```ts
 const calculator = new Calculator();
 expect(calculator.add(2, 3)).toBe(5);
`\`ts

   });
`\`ts

`\`ts
   it("should subtract two numbers", () => {

```ts
 const calculator = new Calculator();
 expect(calculator.subtract(5, 2)).toBe(3);
`\`ts

   });
`\`ts

`\`ts
   it("should multiply two numbers", () => {

```ts
 const calculator = new Calculator();
 expect(calculator.multiply(4, 3)).toBe(12);
`\`ts

   });
`\`ts

`\`ts
   it("should divide two numbers", () => {

```ts
 const calculator = new Calculator();
 expect(calculator.divide(10, 2)).toBe(5);
`\`ts

   });
`\`ts

`\`ts
   it("should throw an error when dividing by zero", () => {

```ts
 const calculator = new Calculator();
 expect(() => calculator.divide(1, 0)).toThrow(
   "Division by zero is not allowed.",
 );
`\`ts

   });
 });
 ```
`\`ts

1. **Add Test Script**:
   - Open your `package.json` file and add the following script:

`\`ts
 ```
`\`ts

json

`\`ts
 "scripts": {
   "test": "vitest"
 }
 ```
`\`ts

1. **Run Your Tests**:
   - In the terminal, run the following command to execute your tests:

`\`ts
 ```
`\`ts

sh

`\`ts
 npm run test
 ```
`\`ts

   - Visual Studio will execute the tests and display the results in the terminal.

By following these steps, you can set up and run tests for your TypeScript calculator app using Vitest in Visual Studio 2022. If you have any questions or run into issues, feel free to ask!
