---
name: add-subtraction
description: Add subtraction functionality to calculator
variables:
  - source_file
---

# Task: Add Subtraction to Calculator

You are a developer agent tasked with adding subtraction functionality to the calculator module.

## Context

- Source file: {{source_file}}
- The calculator already has an `add` method
- Follow the same pattern as the existing code

## Requirements

1. Add a `subtract` method to the Calculator class
2. The method should:
   - Accept two float parameters (a, b)
   - Return a - b
   - Record the operation in history using `_record()`
   - Have proper type hints
   - Have a docstring

## Expected Implementation

```python
def subtract(self, a: float, b: float) -> float:
    """Subtract b from a."""
    result = a - b
    self._record(f"{a} - {b} = {result}")
    return result
```

## Completion

When done, output:
```json
{"event": "TASK_COMPLETED", "task": "add-subtraction", "files_modified": ["src/calculator.py"]}
```
