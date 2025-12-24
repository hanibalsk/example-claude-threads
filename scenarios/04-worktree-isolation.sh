#!/usr/bin/env bash
#
# Scenario 4: Git Worktree Isolation
#
# This scenario demonstrates using git worktrees for parallel development:
# - Each thread works in its own isolated worktree
# - Changes don't interfere with each other
# - Clean merge back to main
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 4: Git Worktree Isolation ==="
echo ""

# Check prerequisites
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

# Show current worktrees
echo "Current worktrees:"
git -C "$PROJECT_DIR" worktree list
echo ""

# Create a worktree-enabled thread for feature A
echo "Creating worktree thread for feature-a..."
FEATURE_A=$("$CT" thread create "feature-a" \
    --mode automatic \
    --worktree \
    --context '{
        "task": "Add power function to calculator",
        "file": "src/calculator.py",
        "requirements": "calc.power(2, 3) should return 8"
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "Thread: $FEATURE_A"

# Create another worktree thread for feature B
echo ""
echo "Creating worktree thread for feature-b..."
FEATURE_B=$("$CT" thread create "feature-b" \
    --mode automatic \
    --worktree \
    --context '{
        "task": "Add modulo function to calculator",
        "file": "src/calculator.py",
        "requirements": "calc.modulo(10, 3) should return 1"
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "Thread: $FEATURE_B"

# Show worktree status
echo ""
echo "Worktree list:"
"$CT" worktree list

# Show where each thread is working
echo ""
echo "Thread details:"
"$CT" thread status "$FEATURE_A" 2>/dev/null || echo "Thread A created"
echo ""
"$CT" thread status "$FEATURE_B" 2>/dev/null || echo "Thread B created"

# List all threads
echo ""
echo "All threads:"
"$CT" thread list

echo ""
echo "=== Scenario 4 Setup Complete ==="
echo ""
echo "Both threads work in isolated worktrees."
echo "They can modify the same files without conflicts."
echo ""
echo "Commands:"
echo "  ct worktree list            - List all worktrees"
echo "  ct worktree status <id>     - Show worktree details"
echo "  ct worktree cleanup         - Remove orphaned worktrees"
echo "  ct thread start <id>        - Start a thread"
echo ""
