#!/usr/bin/env bash
#
# Scenario 8: BMAD Autopilot Workflow
#
# This scenario demonstrates BMAD (Business-Minded Autonomous Developer):
# - Epic-level task management
# - Story breakdown and implementation
# - TDD-driven development
# - Automatic review and iteration
#
# BMAD modes:
# - 7A: Full autopilot (implement story automatically)
# - 7S: Semi-auto (pause for approval at key points)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 8: BMAD Autopilot Demo ==="
echo ""

# Check prerequisites
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

# Show BMAD commands
echo "BMAD Commands (via Claude Code slash commands):"
echo ""
echo "  /bmad 7A              # Full autopilot mode"
echo "  /bmad 7S              # Semi-auto mode"
echo "  /bmad status          # Show BMAD status"
echo "  /bmad stories         # List stories in backlog"
echo ""

# Create a BMAD-style epic thread
echo "Creating BMAD epic thread..."
EPIC=$("$CT" thread create "bmad-epic" \
    --mode automatic \
    --template "$PROJECT_DIR/.claude-threads/templates/prompts/developer.md" \
    --context '{
        "epic": "Calculator Enhancement",
        "stories": [
            {
                "id": "CALC-001",
                "title": "Add power function",
                "acceptance_criteria": "calc.power(2, 3) returns 8"
            },
            {
                "id": "CALC-002",
                "title": "Add square root function",
                "acceptance_criteria": "calc.sqrt(16) returns 4"
            },
            {
                "id": "CALC-003",
                "title": "Add logarithm function",
                "acceptance_criteria": "calc.log(100, 10) returns 2"
            }
        ],
        "workflow": "bmad-7A"
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "bmad-epic")
echo "Epic thread: $EPIC"

# Explain BMAD workflow
echo ""
echo "=== BMAD Workflow Explained ==="
echo ""
echo "1. EPIC ANALYSIS"
echo "   - Break down epic into implementable stories"
echo "   - Identify dependencies between stories"
echo "   - Create implementation order"
echo ""
echo "2. STORY IMPLEMENTATION (per story)"
echo "   a. Analyze story requirements"
echo "   b. Write failing tests (TDD)"
echo "   c. Implement minimum code to pass"
echo "   d. Refactor if needed"
echo "   e. Self-review code"
echo "   f. Emit STORY_COMPLETED event"
echo ""
echo "3. INTEGRATION"
echo "   - Run all tests"
echo "   - Check for regressions"
echo "   - Prepare for review"
echo ""

# Show thread status
echo "=== Thread Status ==="
echo ""
"$CT" thread status "$EPIC" 2>/dev/null || echo "Thread created: $EPIC"

echo ""
echo "=== BMAD in Claude Code ==="
echo ""
echo "In Claude Code, use the /bmad command:"
echo ""
echo "  /bmad 7A"
echo ""
echo "  This will:"
echo "  1. Analyze the current story/task"
echo "  2. Create implementation plan"
echo "  3. Write tests first (TDD)"
echo "  4. Implement the solution"
echo "  5. Self-review and iterate"
echo "  6. Report completion"
echo ""

echo "=== Scenario 8 Info Complete ==="
echo ""
