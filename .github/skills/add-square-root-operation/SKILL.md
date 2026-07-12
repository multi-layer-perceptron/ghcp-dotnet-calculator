---
name: add-square-root-operation
description: "Add or repair the idempotent SquareRoot operation in CalculatorOperations.cs for lab 99.04. Use when: add SquareRoot operation, add calculator square root method, repair SquareRoot method, lab 99.04 SquareRoot library change."
---

# Add SquareRoot Operation

## Purpose

Add the small calculator library change required by lab 99.04 while preserving
the existing arithmetic operation style in `CalculatorOperations.cs`. The skill
is idempotent: running it multiple times must leave the target file with one
canonical `SquareRoot` method and no unrelated edits.

This skill updates the active calculator library under
`src/workspace/calculator-xunit-testing/calculator.library/`. It adds or repairs
the `SquareRoot` operation so the build hook has a realistic C# library edit and
the test project has focused behavior to verify.

## Use When

* Adding the `SquareRoot` operation for lab 99.04
* Repairing a missing or malformed `SquareRoot` method
* Normalizing the SquareRoot XML documentation or negative-input guard
* Verifying the calculator library change without duplicating methods

## Target File

* `src/workspace/calculator-xunit-testing/calculator.library/CalculatorOperations.cs`

## Required Steps

1. Open `CalculatorOperations.cs` and find the existing operation methods in the
   `CalculatorOperations` class.
2. Search for an existing `SquareRoot` method before editing.
3. Add this method near the other operation methods if it is not already
  present, or replace the existing `SquareRoot` method with this canonical
  implementation if one is present but differs:

   ```csharp
   /// <summary>
   /// Calculates the square root of the specified operand.
   /// </summary>
   /// <param name="operand">The operand value.</param>
   /// <returns>The square root of the operand.</returns>
   /// <exception cref="ArgumentOutOfRangeException">Thrown when the operand is negative.</exception>
   public static double SquareRoot(double operand)
   {
       if (operand < 0)
       {
           throw new ArgumentOutOfRangeException(nameof(operand), "Cannot calculate the square root of a negative number.");
       }

       return Math.Sqrt(operand);
   }
   ```

4. Preserve the surrounding namespace, class declaration, operation order, and
   existing methods.
5. Use the repository's C# indentation style: four spaces inside the class and
   four additional spaces inside method blocks.

## Idempotency Rules

* Do not add a second `SquareRoot` method if one already exists.
* If `SquareRoot` already exists, update that method in place instead of adding
  a new method.
* If the existing `SquareRoot` method has missing XML documentation, add the
  documentation shown above.
* If the existing `SquareRoot` method does not guard negative operands, add the
  `ArgumentOutOfRangeException` guard shown above.
* If the existing `SquareRoot` method returns anything other than
  `Math.Sqrt(operand)` for non-negative operands, replace the body with the
  canonical implementation shown above.
* If multiple `SquareRoot` methods already exist, keep one canonical method and
  remove only the duplicate `SquareRoot` methods.
* If the file already contains one canonical `SquareRoot` method, make no code
  edits.
* Leave unrelated operations such as `Add`, `Subtract`, `Multiply`, `Divide`,
  `Modulo`, and `Power` unchanged.

## Validation

Run the focused library build after editing:

```powershell
& 'C:\Program Files\dotnet\dotnet.exe' build src/workspace/calculator-xunit-testing/calculator.library/calculator.library.csproj --verbosity minimal
```

If `dotnet` is available on `PATH`, the equivalent `dotnet build` command is
acceptable.

## Expected Outcome

`CalculatorOperations.cs` contains one documented `SquareRoot` method. Negative
operands throw `ArgumentOutOfRangeException`, and non-negative operands return
`Math.Sqrt(operand)`.