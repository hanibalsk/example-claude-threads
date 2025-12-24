---
name: add-tests
description: Add tests for new calculator functionality
variables:
  - method_name
  - test_file
---

# Task: Add Tests for {{method_name}}

You are a test writer agent tasked with adding comprehensive tests.

## Context

- Test file: {{test_file}}
- Method to test: {{method_name}}
- Follow existing test patterns in the file

## Requirements

1. Add test class or extend existing one
2. Test cases needed:
   - Positive numbers
   - Negative numbers
   - Mixed (positive and negative)
   - Floating point numbers
   - Zero operands
   - History recording

## Test Pattern

```python
def test_{{method_name}}_positive_numbers(self):
    """Test {{method_name}} with positive numbers."""
    # Arrange
    calc = Calculator()
    # Act
    result = calc.{{method_name}}(...)
    # Assert
    assert result == expected
```

## Completion

When done, run tests to verify:
```bash
pytest tests/ -v
```

Then output:
```json
{"event": "TESTS_ADDED", "method": "{{method_name}}", "test_count": N}
```
