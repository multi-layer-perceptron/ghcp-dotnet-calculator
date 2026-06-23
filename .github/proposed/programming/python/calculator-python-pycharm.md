# Calculator Python Pycharm

Creating a basic calculator program and testing it with pytest in PyCharm is straightforward. Here's a step-by-step guide:

1. **Set Up Your Project**:
   - Open PyCharm and create a new project.
   - Choose a location for your project and click "Create".

1. **Create Your Calculator Program**:
   - In the Project Explorer, right-click on your project folder and select `New` > `Python File`.
   - Name the file `calculator.py` and add the following code:

`\`python
 ```
`\`python

python

`\`python
 class Calculator:

```python
 def add(self, a, b):
     return a + b
`\`python

`\`python

`\`python

```python
 def subtract(self, a, b):
     return a - b
`\`python

`\`python

`\`python

```python
 def multiply(self, a, b):
     return a * b
`\`python

`\`python

`\`python

```python
 def divide(self, a, b):
     if b == 0:
         raise ValueError("Division by zero is not allowed.")
     return a / b
`\`python

 ```
`\`python

1. **Install pytest**:
   - Open the terminal in PyCharm (View > Tool Windows > Terminal) and install pytest using pip:

`\`python
 ```
`\`python

sh

`\`python
 ```
`\`python

   1. **Create Test Cases**:
   - In the Project Explorer, right-click on your project folder and select `New` > `Python File`.
   - Name the file `test_calculator.py` and add the following test cases:

`\`python
 ```
`\`python

python

`\`python
 import pytest
 from calculator import Calculator
`\`python

`\`python
 def test_add():

```python
 calculator = Calculator()
 assert calculator.add(2, 3) == 5
`\`python

`\`python

`\`python
 def test_subtract():

```python
 calculator = Calculator()
 assert calculator.subtract(5, 2) == 3
`\`python

`\`python

`\`python
 def test_multiply():

```python
 calculator = Calculator()
 assert calculator.multiply(4, 3) == 12
`\`python

`\`python

`\`python
 def test_divide():

```python
 calculator = Calculator()
 assert calculator.divide(10, 2) == 5
`\`python

`\`python

`\`python
 def test_divide_by_zero():

```python
 calculator = Calculator()
 with pytest.raises(ValueError, match="Division by zero is not allowed."):
     calculator.divide(1, 0)
`\`python

 ```
`\`python

1. **Run Your Tests**:
   - Right-click on the `test_calculator.py` file in the Project Explorer and select `Run 'pytest in test_calculator'`.
   - PyCharm will execute the tests and display the results in the Run tool window.

By following these steps, you can create and test your Python calculator program using pytest in PyCharm. If you have any questions or need further assistance, feel free to ask!
