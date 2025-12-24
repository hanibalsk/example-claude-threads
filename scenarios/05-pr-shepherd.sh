#!/usr/bin/env bash
#
# Scenario 5: PR Shepherd - Automated PR Fixing
#
# This scenario demonstrates PR Shepherd functionality:
# - Watch a PR for CI failures or review comments
# - Automatically create fix threads in isolated worktrees
# - Push fixes and update PR
#
# Prerequisites:
# - GitHub CLI (gh) installed and authenticated
# - PR must exist in the repository
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 5: PR Shepherd Demo ==="
echo ""

# Check prerequisites
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

if ! command -v gh &>/dev/null; then
    echo "Warning: GitHub CLI (gh) not found"
    echo "PR Shepherd requires gh for full functionality"
    echo ""
fi

# Show current PR status
echo "Current PR watches:"
"$CT" pr status || echo "(no PRs being watched)"
echo ""

# Show help for PR commands
echo "PR Shepherd Commands:"
echo ""
echo "  Watch a PR:"
echo "    ct pr watch 123                  # Watch PR #123"
echo "    ct pr watch 123 --auto-fix       # Auto-fix CI failures"
echo "    ct pr watch 123 --auto-review    # Auto-respond to reviews"
echo ""
echo "  Manage watches:"
echo "    ct pr status                     # Show all watched PRs"
echo "    ct pr unwatch 123                # Stop watching PR #123"
echo "    ct pr check 123                  # Check PR status now"
echo ""
echo "  Run as daemon:"
echo "    ct pr daemon                     # Background daemon mode"
echo "    ct pr daemon --interval 60       # Check every 60 seconds"
echo ""

# Example: Create a test PR and watch it
echo "Example workflow:"
echo ""
echo "  1. Create a feature branch and PR:"
echo "     git checkout -b feature/new-calc-method"
echo "     # make changes"
echo "     git commit -m 'Add new method'"
echo "     gh pr create --title 'Add new method'"
echo ""
echo "  2. Watch the PR for CI/review issues:"
echo "     ct pr watch <pr-number> --auto-fix"
echo ""
echo "  3. PR Shepherd will:"
echo "     - Monitor CI status"
echo "     - Create fix threads in worktrees when CI fails"
echo "     - Respond to review comments"
echo "     - Push fixes automatically"
echo ""

# Demonstrate creating a thread that would fix CI
echo "Creating an example issue-fixer thread..."
FIX_THREAD=$("$CT" thread create "ci-fix-example" \
    --mode automatic \
    --context '{
        "type": "ci-fix",
        "error": "TypeError: multiply() takes 2 positional arguments but 3 were given",
        "file": "src/calculator.py",
        "line": 15
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "example-thread")
echo "Created: $FIX_THREAD"

echo ""
echo "=== Scenario 5 Info Complete ==="
echo ""
echo "To try PR Shepherd with a real PR:"
echo "  1. Create a PR in this repository"
echo "  2. Run: ct pr watch <pr-number>"
echo "  3. Watch the magic happen!"
echo ""
