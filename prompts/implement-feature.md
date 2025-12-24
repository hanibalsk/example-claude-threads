---
name: implement-feature
description: Generic feature implementation template
variables:
  - feature_name
  - description
  - acceptance_criteria
---

# Task: Implement {{feature_name}}

You are a developer agent implementing a new feature.

## Feature Description

{{description}}

## Acceptance Criteria

{{acceptance_criteria}}

## Workflow

1. **Analyze** - Understand the codebase and requirements
2. **Plan** - Design the implementation approach
3. **Implement** - Write the code
4. **Test** - Add or update tests
5. **Verify** - Run tests and ensure they pass

## Guidelines

- Follow existing code patterns
- Keep changes minimal and focused
- Add type hints and docstrings
- Ensure backward compatibility

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/{{feature_name}}

# Make changes and commit
git add -A
git commit -m "feat: {{feature_name}}"
```

## Completion

When feature is complete:

```json
{
  "event": "FEATURE_COMPLETED",
  "feature": "{{feature_name}}",
  "branch": "feature/{{feature_name}}",
  "files_modified": [...],
  "tests_added": N
}
```

If blocked:

```json
{
  "event": "BLOCKED",
  "feature": "{{feature_name}}",
  "reason": "...",
  "needs": "..."
}
```
