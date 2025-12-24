# example-claude-threads

Test project for showcasing and testing [claude-threads](https://github.com/hanibalsk/claude-threads) - Multi-Agent Thread Orchestration Framework for Claude Code.

## Purpose

This project serves as:
1. **Test environment** - For testing claude-threads installation and features
2. **Showcase** - Demonstrates multi-agent workflows
3. **Example templates** - Sample prompts and workflows

## Quick Start

```bash
# Install claude-threads
cd /path/to/claude-threads
./install.sh --target /path/to/example-claude-threads

# Initialize
ct init

# Create a thread
ct thread create developer --mode automatic --template prompts/developer.md

# Start orchestrator
ct orchestrator start
```

## Test Scenarios

### 1. Simple Task Thread
Single thread executing a simple task.

```bash
ct thread create simple-task --mode automatic --context '{"task": "Create hello world"}'
ct thread start <id>
```

### 2. Multi-Thread Workflow
Multiple threads working together via blackboard.

```bash
# Start developer thread
ct thread create developer --mode automatic

# Start reviewer thread (reacts to developer events)
ct thread create reviewer --mode semi-auto
```

### 3. Scheduled Thread
Thread that wakes periodically.

```bash
ct thread create monitor --mode sleeping --schedule '{"interval": 300}'
```

### 4. Interactive Thread
Foreground thread with full interaction.

```bash
ct thread create interactive-dev --mode interactive
ct thread resume <id>
```

## Project Structure

```
example-claude-threads/
├── README.md
├── src/                    # Sample source code for agents to work on
│   └── calculator.py       # Simple calculator module
├── tests/                  # Test files
│   └── test_calculator.py  # Calculator tests
├── docs/                   # Documentation
│   └── REQUIREMENTS.md     # Feature requirements
└── .gitignore
```

## Sample Tasks for Testing

### Task 1: Add Subtraction
Add subtraction functionality to the calculator.

### Task 2: Add Multiplication with Tests
Add multiplication with comprehensive tests.

### Task 3: Code Review
Review existing code for improvements.

### Task 4: Documentation
Generate documentation for the calculator module.

## License

MIT
