#!/usr/bin/env bash
#
# Scenario 10: Full Development Pipeline
#
# This scenario demonstrates a complete development pipeline:
# - Story implementation in worktree
# - Automated testing
# - Code review
# - PR creation
# - CI monitoring with PR Shepherd
# - Merge on success
#
# This is the "gold standard" workflow for autonomous development.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 10: Full Development Pipeline ==="
echo ""

# Check prerequisites
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

# Check for gh CLI
HAS_GH=false
if command -v gh &>/dev/null; then
    HAS_GH=true
    echo "✅ GitHub CLI available"
else
    echo "⚠️  GitHub CLI not found (PR features limited)"
fi
echo ""

# Start services
echo "Starting services..."
"$CT" orchestrator start 2>/dev/null || true
"$CT" api start 2>/dev/null || true
sleep 2

echo ""
echo "=== Pipeline Stages ==="
echo ""

# Stage 1: Create developer thread with worktree
echo "Stage 1: Creating developer thread..."
DEV_THREAD=$("$CT" thread create "pipeline-dev" \
    --mode automatic \
    --worktree \
    --context '{
        "stage": "development",
        "task": "Add factorial function to calculator",
        "requirements": "calc.factorial(5) returns 120",
        "tdd": true,
        "pipeline": {
            "next_stage": "review",
            "on_complete": "emit DEVELOPMENT_COMPLETE"
        }
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "pipeline-dev")
echo "  Developer: $DEV_THREAD"

# Stage 2: Create reviewer thread (waits for DEVELOPMENT_COMPLETE)
echo ""
echo "Stage 2: Creating reviewer thread..."
REV_THREAD=$("$CT" thread create "pipeline-review" \
    --mode semi-auto \
    --context '{
        "stage": "review",
        "watch_event": "DEVELOPMENT_COMPLETE",
        "focus": ["code quality", "test coverage", "security"],
        "pipeline": {
            "next_stage": "pr",
            "on_approve": "emit REVIEW_APPROVED",
            "on_reject": "emit REVIEW_CHANGES_REQUESTED"
        }
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "pipeline-review")
echo "  Reviewer: $REV_THREAD"

# Stage 3: Create PR manager thread (waits for REVIEW_APPROVED)
echo ""
echo "Stage 3: Creating PR manager thread..."
PR_THREAD=$("$CT" thread create "pipeline-pr" \
    --mode automatic \
    --context '{
        "stage": "pr",
        "watch_event": "REVIEW_APPROVED",
        "actions": ["create PR", "monitor CI", "fix failures", "merge on success"],
        "pipeline": {
            "on_merge": "emit PIPELINE_COMPLETE",
            "on_failure": "emit PIPELINE_FAILED"
        }
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "pipeline-pr")
echo "  PR Manager: $PR_THREAD"

# Show pipeline status
echo ""
echo "=== Pipeline Threads ==="
"$CT" thread list

# Show worktrees
echo ""
echo "=== Worktrees ==="
"$CT" worktree list 2>/dev/null || echo "(checking worktrees...)"

# Explain the pipeline
echo ""
echo "=== Pipeline Flow ==="
echo ""
echo "  ┌─────────────┐"
echo "  │  Developer  │──────────────────────────────┐"
echo "  │   Thread    │  Works in isolated worktree  │"
echo "  └──────┬──────┘                              │"
echo "         │ DEVELOPMENT_COMPLETE                │"
echo "         ▼                                     │"
echo "  ┌─────────────┐                              │"
echo "  │  Reviewer   │                              │"
echo "  │   Thread    │                              │"
echo "  └──────┬──────┘                              │"
echo "         │ REVIEW_APPROVED                     │"
echo "         ▼                                     │"
echo "  ┌─────────────┐                              │"
echo "  │ PR Manager  │◄─────────────────────────────┘"
echo "  │   Thread    │  Creates PR from worktree branch"
echo "  └──────┬──────┘"
echo "         │"
echo "         ▼"
echo "  ┌─────────────┐"
echo "  │ PR Shepherd │  Monitors CI, fixes failures"
echo "  │  (daemon)   │"
echo "  └──────┬──────┘"
echo "         │ CI passes + reviews approved"
echo "         ▼"
echo "  ┌─────────────┐"
echo "  │   MERGED    │  PIPELINE_COMPLETE event"
echo "  └─────────────┘"
echo ""

# Commands
echo "=== Pipeline Commands ==="
echo ""
echo "  Start the pipeline:"
echo "    ct thread start $DEV_THREAD"
echo ""
echo "  Monitor progress:"
echo "    ct thread list"
echo "    ct event list"
echo "    ct pr status"
echo ""
echo "  View logs:"
echo "    tail -f $PROJECT_DIR/.claude-threads/logs/orchestrator.log"
echo ""

echo "=== Scenario 10 Setup Complete ==="
echo ""
echo "To run the full pipeline:"
echo "  1. Start: ct thread start $DEV_THREAD"
echo "  2. Watch: ct event list (in another terminal)"
echo "  3. Events will trigger subsequent stages automatically"
echo ""
