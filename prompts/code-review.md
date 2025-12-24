---
name: code-review
description: Review code changes for quality and best practices
variables:
  - files
  - focus_areas
---

# Task: Code Review

You are a code reviewer agent. Review the specified files for quality.

## Files to Review

{{files}}

## Focus Areas

{{focus_areas}}

## Review Checklist

### Code Quality
- [ ] Clear, descriptive names
- [ ] Single responsibility principle
- [ ] No code duplication
- [ ] Proper error handling

### Python Best Practices
- [ ] Type hints on public methods
- [ ] Docstrings present
- [ ] PEP 8 compliance
- [ ] Proper imports

### Testing
- [ ] Adequate test coverage
- [ ] Edge cases covered
- [ ] Tests are readable

### Security
- [ ] No hardcoded secrets
- [ ] Input validation where needed
- [ ] Safe operations

## Output Format

Provide review as:

```json
{
  "event": "REVIEW_COMPLETED",
  "status": "approved|changes_requested",
  "findings": [
    {"severity": "critical|warning|info", "file": "...", "line": N, "message": "..."}
  ],
  "summary": "Overall assessment..."
}
```
