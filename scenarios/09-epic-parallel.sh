#!/usr/bin/env bash
#
# Scenario 9: Epic Parallel Development
#
# This scenario demonstrates parallel story implementation:
# - Multiple threads work on different stories simultaneously
# - Each thread uses its own worktree (no conflicts)
# - Orchestrator coordinates the work
# - Results merge back to main
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 9: Epic Parallel Development ==="
echo ""

# Check prerequisites
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

# Ensure orchestrator is running
echo "Starting orchestrator..."
"$CT" orchestrator start 2>/dev/null || true
sleep 2

# Define stories
STORIES=(
    "Add floor division method|calc.floor_div(7, 2) returns 3"
    "Add ceiling function|calc.ceil(3.2) returns 4"
    "Add absolute value|calc.abs(-5) returns 5"
    "Add min/max functions|calc.min(3,7) returns 3, calc.max(3,7) returns 7"
)

echo ""
echo "Creating parallel story threads..."
echo ""

THREAD_IDS=()
for i in "${!STORIES[@]}"; do
    IFS='|' read -r title criteria <<< "${STORIES[$i]}"

    echo "Story $((i+1)): $title"
    THREAD_ID=$("$CT" thread create "story-$((i+1))" \
        --mode automatic \
        --worktree \
        --context '{
            "story_number": '$((i+1))',
            "title": "'"$title"'",
            "acceptance_criteria": "'"$criteria"'",
            "parallel": true
        }' \
        2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "story-$((i+1))")
    THREAD_IDS+=("$THREAD_ID")
    echo "  Thread: $THREAD_ID"
done

# Show all threads
echo ""
echo "All story threads:"
"$CT" thread list

# Show worktrees
echo ""
echo "Worktrees (each story has its own):"
"$CT" worktree list 2>/dev/null || git -C "$PROJECT_DIR" worktree list

# Show orchestrator status
echo ""
echo "Orchestrator status:"
"$CT" orchestrator status

echo ""
echo "=== Parallel Execution Explained ==="
echo ""
echo "1. Each story thread works in isolated worktree"
echo "2. No merge conflicts during development"
echo "3. Orchestrator monitors all threads"
echo "4. Events coordinate dependencies"
echo ""
echo "Example event flow:"
echo "  Thread 1: STORY_STARTED -> ... -> STORY_COMPLETED"
echo "  Thread 2: STORY_STARTED -> ... -> STORY_COMPLETED"
echo "  Thread 3: STORY_STARTED -> ... -> STORY_COMPLETED"
echo "  Orchestrator: All complete -> EPIC_READY_FOR_MERGE"
echo ""

# Commands
echo "=== Monitoring Commands ==="
echo ""
echo "  ct thread list                 # All threads"
echo "  ct thread status <id>          # Thread details"
echo "  ct worktree list               # All worktrees"
echo "  ct event list                  # Event timeline"
echo "  ct orchestrator status         # Orchestrator state"
echo ""
echo "  # Watch logs in real-time:"
echo "  tail -f $PROJECT_DIR/.claude-threads/logs/orchestrator.log"
echo ""

echo "=== Scenario 9 Setup Complete ==="
echo ""
echo "4 story threads created in parallel worktrees."
echo "Start them with: ct thread start story-1 story-2 story-3 story-4"
echo ""
