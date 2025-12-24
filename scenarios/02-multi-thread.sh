#!/usr/bin/env bash
#
# Scenario 2: Multi-Thread Workflow
#
# This scenario demonstrates multiple threads working together:
# - Developer thread implements features
# - Reviewer thread reviews code
# - Both communicate via blackboard
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 2: Multi-Thread Workflow ==="
echo ""

# Create developer thread
echo "Creating developer thread..."
DEV_ID=$("$CT" thread create "developer" \
    --mode automatic \
    --template "$PROJECT_DIR/prompts/implement-feature.md" \
    --context '{
        "feature_name": "multiplication",
        "description": "Add multiply method to calculator",
        "acceptance_criteria": "calc.multiply(3, 4) returns 12"
    }' \
    2>/dev/null | tail -1)
echo "Developer thread: $DEV_ID"

# Create reviewer thread
echo "Creating reviewer thread..."
REV_ID=$("$CT" thread create "reviewer" \
    --mode semi-auto \
    --template "$PROJECT_DIR/prompts/code-review.md" \
    --context '{
        "files": "src/calculator.py",
        "focus_areas": "code quality, testing"
    }' \
    2>/dev/null | tail -1)
echo "Reviewer thread: $REV_ID"

# List all threads
echo ""
echo "All threads:"
"$CT" thread list

# Start developer
echo ""
echo "Starting developer thread..."
"$CT" thread start "$DEV_ID"

echo ""
echo "Threads will communicate via blackboard events."
echo "Developer emits FEATURE_COMPLETED when done."
echo "Reviewer reacts to start review."
echo ""

echo "=== Scenario 2 Setup Complete ==="
echo ""
echo "Monitor with: ct thread status $DEV_ID"
echo "View events:  ct event list"
