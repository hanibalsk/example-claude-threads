"""
Simple Calculator Module

A basic calculator implementation for testing claude-threads agents.
Intentionally incomplete to provide tasks for agents.
"""


class Calculator:
    """Basic calculator with arithmetic operations."""

    def __init__(self):
        self.result = 0
        self.history = []

    def add(self, a: float, b: float) -> float:
        """Add two numbers."""
        result = a + b
        self._record(f"{a} + {b} = {result}")
        return result

    def _record(self, operation: str):
        """Record operation in history."""
        self.history.append(operation)

    def get_history(self) -> list:
        """Return operation history."""
        return self.history.copy()

    def clear_history(self):
        """Clear operation history."""
        self.history = []


# TODO: Add subtraction method
# TODO: Add multiplication method
# TODO: Add division method (handle division by zero)
# TODO: Add memory functions (store, recall, clear)
