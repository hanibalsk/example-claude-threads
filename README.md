# example-claude-threads

Test project for showcasing and testing [claude-threads](https://github.com/hanibalsk/claude-threads) v1.4.1 - Multi-Agent Thread Orchestration Framework for Claude Code.

## Purpose

This project serves as:
1. **Test environment** - For testing claude-threads installation and features
2. **Showcase** - Demonstrates multi-agent workflows
3. **Example templates** - Sample prompts and workflows
4. **Scenario library** - 10 complete scenarios from simple to complex

## Quick Start

```bash
# Install claude-threads (from claude-threads repo)
./install.sh

# Initialize in this project
.claude-threads/bin/ct init

# Start orchestrator
.claude-threads/bin/ct orchestrator start

# Create a thread
.claude-threads/bin/ct thread create developer --mode automatic
```

## Scenarios

Run the example scenarios to learn claude-threads features:

| Scenario | Description | Command |
|----------|-------------|---------|
| **01** | Simple single-thread task | `./scenarios/01-simple-task.sh` |
| **02** | Multi-thread workflow | `./scenarios/02-multi-thread.sh` |
| **03** | Full orchestrator demo | `./scenarios/03-orchestrator.sh` |
| **04** | Git worktree isolation | `./scenarios/04-worktree-isolation.sh` |
| **05** | PR Shepherd auto-fix | `./scenarios/05-pr-shepherd.sh` |
| **06** | Remote connection API | `./scenarios/06-remote-connection.sh` |
| **07** | Blackboard events | `./scenarios/07-blackboard-events.sh` |
| **08** | BMAD autopilot workflow | `./scenarios/08-bmad-workflow.sh` |
| **09** | Epic parallel development | `./scenarios/09-epic-parallel.sh` |
| **10** | Full development pipeline | `./scenarios/10-full-pipeline.sh` |

### Scenario Highlights

#### 01-03: Basic Usage
- Create and manage threads
- Run orchestrator daemon
- Monitor thread status

#### 04: Worktree Isolation
- Parallel development in git worktrees
- No merge conflicts between threads
- Clean branch management

#### 05: PR Shepherd
- Automatic CI failure detection
- Auto-fix threads in worktrees
- Review comment responses

#### 06: Remote Connection
- API server for multi-instance coordination
- Claude Code commands: `/ct-connect`, `/ct-spawn`
- Cross-project thread spawning

#### 07: Blackboard Events
- Event-driven thread coordination
- Producer/consumer patterns
- Custom event types

#### 08: BMAD Workflow
- Epic breakdown to stories
- TDD-driven implementation
- Automatic review cycles

#### 09: Epic Parallel
- Multiple stories in parallel
- Each in isolated worktree
- Orchestrator coordination

#### 10: Full Pipeline
- Complete dev-to-merge workflow
- Developer → Reviewer → PR Manager
- CI monitoring with auto-fix

## Commands Quick Reference

```bash
# Thread management
ct thread create <name> --mode automatic
ct thread create <name> --worktree        # Isolated worktree
ct thread list
ct thread status <id>
ct thread start <id>
ct thread stop <id>

# Orchestrator
ct orchestrator start
ct orchestrator stop
ct orchestrator status

# Worktrees
ct worktree list
ct worktree status <id>
ct worktree cleanup

# PR Shepherd
ct pr watch 123                           # Watch PR #123
ct pr status                              # All watched PRs
ct pr daemon                              # Background daemon

# Events
ct event list
ct event post <type> <json>

# API
ct api start
ct api status

# Claude Code commands
/threads list
/threads create <name>
/ct-connect localhost:31337
/ct-spawn "task description"
/bmad 7A
```

## Project Structure

```
example-claude-threads/
├── README.md
├── scenarios/               # Example scenarios (10 total)
│   ├── 01-simple-task.sh
│   ├── 02-multi-thread.sh
│   ├── 03-orchestrator.sh
│   ├── 04-worktree-isolation.sh
│   ├── 05-pr-shepherd.sh
│   ├── 06-remote-connection.sh
│   ├── 07-blackboard-events.sh
│   ├── 08-bmad-workflow.sh
│   ├── 09-epic-parallel.sh
│   └── 10-full-pipeline.sh
├── prompts/                 # Template prompts
│   ├── implement-feature.md
│   └── code-review.md
├── src/                     # Sample source code
│   └── calculator.py
├── tests/                   # Test files
│   └── test_calculator.py
├── docs/                    # Documentation
│   └── REQUIREMENTS.md
├── integration-tests/       # Integration test utilities
├── .claude/                 # Claude Code config
│   ├── commands/           # Slash commands
│   ├── skills/             # Skills
│   └── agents/             # Agent definitions
└── .claude-threads/         # claude-threads installation
    ├── bin/ct              # CLI tool
    ├── lib/                # Core libraries
    ├── scripts/            # Daemon scripts
    ├── templates/          # Prompt templates
    └── threads.db          # SQLite database
```

## Sample Tasks for Testing

### Task 1: Add Math Functions
```bash
ct thread create add-power --mode automatic --worktree \
  --context '{"task": "Add power function", "test": "calc.power(2,3)==8"}'
```

### Task 2: Multi-Feature Epic
```bash
# Start orchestrator
ct orchestrator start

# Create parallel feature threads
for feature in power sqrt factorial; do
  ct thread create "add-$feature" --mode automatic --worktree
done
```

### Task 3: Full Pipeline
```bash
# Run the complete pipeline scenario
./scenarios/10-full-pipeline.sh
```

## License

MIT
