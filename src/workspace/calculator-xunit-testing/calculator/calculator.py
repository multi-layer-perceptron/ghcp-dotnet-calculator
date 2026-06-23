import math


def add(left: float, right: float) -> float:
    return left + right


def subtract(left: float, right: float) -> float:
    return left - right


def multiply(left: float, right: float) -> float:
    return left * right


def divide(left: float, right: float) -> float:
    if right == 0:
        raise ZeroDivisionError("Cannot divide by zero.")
    return left / right


def modulo(left: float, right: float) -> float:
    if right == 0:
        raise ZeroDivisionError("Cannot modulo by zero.")
    return left % right


def exponent(left: float, right: float) -> float:
    return math.pow(left, right)
