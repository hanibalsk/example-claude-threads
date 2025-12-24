# Calculator Requirements

## Overview

Simple calculator module for testing claude-threads multi-agent workflows.

## Current Features

- [x] Addition of two numbers
- [x] Operation history tracking
- [x] History retrieval and clearing

## Planned Features

### Priority 1 - Basic Operations

- [ ] **Subtraction** - Subtract two numbers
  - Acceptance: `calc.subtract(5, 3)` returns `2`
  - Tests required

- [ ] **Multiplication** - Multiply two numbers
  - Acceptance: `calc.multiply(4, 3)` returns `12`
  - Tests required

- [ ] **Division** - Divide two numbers
  - Acceptance: `calc.divide(10, 2)` returns `5`
  - Must handle division by zero with proper exception
  - Tests required

### Priority 2 - Memory Functions

- [ ] **Memory Store** - Store current result in memory
  - Acceptance: `calc.memory_store(value)` stores value

- [ ] **Memory Recall** - Recall stored value
  - Acceptance: `calc.memory_recall()` returns stored value

- [ ] **Memory Clear** - Clear stored value
  - Acceptance: `calc.memory_clear()` resets memory to 0

### Priority 3 - Advanced

- [ ] **Chain operations** - Support method chaining
  - Example: `calc.add(2, 3).multiply(4).result`

- [ ] **Undo** - Undo last operation
  - Must track state for undo

## Non-Functional Requirements

- All methods must record to history
- All methods must have docstrings
- Test coverage > 80%
- Type hints on all public methods

## Test Scenarios for Agents

### Scenario A: Add Subtraction
1. Developer agent implements subtract method
2. Test writer agent adds tests
3. Reviewer agent reviews code
4. PR manager creates PR

### Scenario B: Complete All Basic Operations
1. Multiple developer threads work in parallel
2. Each implements one operation
3. Reviewer reviews each
4. Final integration

### Scenario C: Refactoring
1. Explorer agent analyzes codebase
2. Developer proposes improvements
3. Interactive review with human
