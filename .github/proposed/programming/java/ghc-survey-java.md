# Java Calculator - Unit Testing Guide

This document provides a step-by-step guide for setting up and performing unit testing on the Java calculator application.

\n\nTable of Contents

\n\n[Project Overview](#project-overview)
\n\n[Prerequisites](#prerequisites)
\n\n[Setting Up the Test Environment](#setting-up-the-test-environment)
\n\n[Creating Unit Tests](#creating-unit-tests)
\n\n[Running the Tests](#running-the-tests)
\n\n[Best Practices](#best-practices)
\n\n[Advanced Testing Techniques](#advanced-testing-techniques)

\n\nProject Overview

The Java calculator application is a simple command-line calculator that supports basic arithmetic operations:

\n\nAddition (+)
\n\nSubtraction (-)
\n\nMultiplication (\*)
\n\nDivision (/)
\n\nModulo (%)
\n\nExponentiation (^)

The application follows a typical Maven project structure, with the main code located in `src/main/java` and test code in `src/test/java`.

\n\nPrerequisites

Before setting up unit testing, ensure you have:

\n\nJava Development Kit (JDK) 11 or later installed
\n\nApache Maven installed
\n\nBasic understanding of JUnit 5 framework
\n\nBasic understanding of Maven build system

\n\nSetting Up the Test Environment

\n\nStep 1: Verify Maven Dependencies

Ensure your `pom.xml` file includes the necessary JUnit 5 dependencies:

`\`java

xml

<dependencies>

```java
<!-- JUnit 5 dependencies -->
`\`java

```java
<dependency>
`\`java

```java
    <groupId>org.junit.jupiter</groupId>
`\`java

```java
    <artifactId>junit-jupiter-api</artifactId>
`\`java

```java
    <version>${junit.jupiter.version}</version>
`\`java

```java
    <scope>test</scope>
`\`java

```java
</dependency>
`\`java

```java
<dependency>
`\`java

```java
    <groupId>org.junit.jupiter</groupId>
`\`java

```java
    <artifactId>junit-jupiter-engine</artifactId>
`\`java

```java
    <version>${junit.jupiter.version}</version>
`\`java

```java
    <scope>test</scope>
`\`java

```java
</dependency>
`\`java

</dependencies>

`\`java

text
text

\n\nStep 2: Create the Test Directory Structure

Maven follows a standard directory structure for tests:

`\`java

text

src

├── main

│   └── java

│       └── com

│           └── project13

│               └── App.java

└── test

```java
└── java
`\`java

```java
    └── com
`\`java

```java
        └── project13
`\`java

```java
            └── AppTest.java
`\`java

`\`java

text
text

If this structure doesn't exist yet, create it:

`\`java

bash

mkdir -p src/test/java/com/project13

`\`java

text
text

\n\nCreating Unit Tests

\n\nStep 3: Create a Test Class

Create a test class called `AppTest.java` in the `src/test/java/com/project13` directory. Start with a basic structure:

`\`java

java

package com.project13;

import org.junit.jupiter.api.DisplayName;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
\n\nUnit tests for the App class calculator functionality.

 */

public class AppTest {

```java
// Tests will go here
`\`java

}

`\`java

text
text

\n\nStep 4: Write Basic Tests for Each Operation

Add tests for each calculator operation. Here's an example for addition:

`\`java

java

/**
\n\nTests for the add method.

 */

@Test

@DisplayName("Addition: Test with positive numbers")

public void testAddPositiveNumbers() {

```java
assertEquals(5.0, App.add(2.0, 3.0),
`\`java

```java
    "2.0 + 3.0 should equal 5.0");
`\`java

}

@Test

@DisplayName("Addition: Test with negative numbers")

public void testAddNegativeNumbers() {

```java
assertEquals(-5.0, App.add(-2.0, -3.0),
`\`java

```java
    "-2.0 + -3.0 should equal -5.0");
`\`java

}

@Test

@DisplayName("Addition: Test with decimal numbers")

public void testAddDecimals() {

```java
assertEquals(5.3, App.add(2.1, 3.2), 0.0001,
`\`java

```java
    "2.1 + 3.2 should equal 5.3");
`\`java

}

`\`java

text
text

\n\nStep 5: Test Edge Cases

Don't forget to test edge cases, such as division by zero:

`\`java

java

@Test

@DisplayName("Division: Test division by zero")

public void testDivideByZero() {

```java
assertEquals(0.0, App.divide(5.0, 0.0),
`\`java

```java
    "Division by zero should return 0 as defined in the method");
`\`java

}

`\`java

text
text

\n\nStep 6: Add Parameterized Tests

For more efficient testing of multiple test cases, use parameterized tests:

`\`java

java

@ParameterizedTest

@CsvSource({

```java
"1.0, 1.0, 2.0",
`\`java

```java
"10.5, 10.5, 21.0",
`\`java

```java
"-5.0, 5.0, 0.0",
`\`java

```java
"0.0, 0.0, 0.0"
`\`java

})

@DisplayName("Addition: Parameterized test")

public void testAddParameterized(double a, double b, double expected) {

```java
assertEquals(expected, App.add(a, b), 0.0001,
`\`java

```java
    String.format("%f + %f should equal %f", a, b, expected));
`\`java

}

`\`java

text
text

\n\nStep 7: Test the Main Calculate Method

Test the central `calculate` method which handles all operations:

`\`java

java

@ParameterizedTest

@CsvSource({

```java
"5.0, 3.0, +, 8.0",
`\`java

```java
"5.0, 3.0, -, 2.0",
`\`java

```java
"5.0, 3.0, *, 15.0",
`\`java

```java
"6.0, 3.0, /, 2.0",
`\`java

```java
"7.0, 3.0, %, 1.0",
`\`java

```java
"2.0, 3.0, ^, 8.0",
`\`java

```java
"5.0, 3.0, X, 0.0"  // Invalid operator test
`\`java

})

@DisplayName("Calculate method: Parameterized test")

public void testCalculateParameterized(double a, double b, char operator, double expected) {

```java
assertEquals(expected, App.calculate(a, b, operator), 0.0001,
`\`java

```java
    String.format("%f %c %f should equal %f", a, b, operator, expected));
`\`java

}

`\`java

text
text

\n\nRunning the Tests

\n\nStep 8: Run Tests Using Maven

To run the tests, use Maven from the command line:

`\`java

bash

mvn test

`\`java

text
text

This will compile the code and run all tests, providing a summary of test results.

\n\nStep 9: Run Tests in an IDE

Most IDEs (like IntelliJ IDEA, Eclipse, or VS Code with Java extensions) have built-in support for running JUnit tests:

\n\nOpen the `AppTest.java` file
\n\nRight-click in the editor or on the test class/method
\n\nSelect "Run Test" or equivalent option

\n\nBest Practices

\n\nFollow AAA Pattern

Structure your tests using the Arrange-Act-Assert pattern:

\n\n**Arrange**: Set up the test data
\n\n**Act**: Call the method under test
\n\n**Assert**: Verify the result

\n\nMake Tests Independent

Each test should be independent and not rely on other tests or external state.

\n\nUse Descriptive Test Names

Use clear and descriptive test method names that indicate what's being tested.

\n\nUse Meaningful Assertions

Include helpful error messages in assertions to make test failures easier to understand.

\n\nAdvanced Testing Techniques

\n\nTest Coverage Analysis

Use tools like JaCoCo to analyze your test coverage:

`\`java

xml

<plugin>

```java
<groupId>org.jacoco</groupId>
`\`java

```java
<artifactId>jacoco-maven-plugin</artifactId>
`\`java

```java
<version>0.8.7</version>
`\`java

```java
<executions>
`\`java

```java
    <execution>
`\`java

```java
        <goals>
`\`java

```java
            <goal>prepare-agent</goal>
`\`java

```java
        </goals>
`\`java

```java
    </execution>
`\`java

```java
    <execution>
`\`java

```java
        <id>report</id>
`\`java

```java
        <phase>test</phase>
`\`java

```java
        <goals>
`\`java

```java
            <goal>report</goal>
`\`java

```java
        </goals>
`\`java

```java
    </execution>
`\`java

```java
</executions>
`\`java

</plugin>

`\`java

text
text

Then run:

`\`java

bash

mvn clean test

`\`java

text
text

Coverage reports will be generated in `target/site/jacoco/`.

\n\nContinuous Integration

Set up automated testing in a CI environment (like GitHub Actions, Jenkins, etc.) by creating a workflow file that runs your tests on each push or pull request.

---

This completes the guide for unit testing the Java calculator application. By following these steps, you'll have a comprehensive test suite that verifies all the functionality of your calculator and helps maintain code quality as the project evolves.

\n\n
