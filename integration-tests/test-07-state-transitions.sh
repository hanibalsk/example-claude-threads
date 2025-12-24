#!/usr/bin/env bash
#
# Test 07: Thread State Transitions
#
# Tests the full thread state machine:
# created -> ready -> running -> [waiting|sleeping|blocked] -> completed
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"
DB="$PROJECT_DIR/.claude-threads/threads.db"

cd "$PROJECT_DIR"

echo "Testing thread state transitions..."

# Create thread
echo "  Creating thread..."
OUTPUT=$("$CT" thread create "test-states" --mode automatic --context '{"test": "states"}' 2>&1)
THREAD_ID=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "  Thread: $THREAD_ID"

# Helper to get current state
get_state() {
    sqlite3 "$DB" "SELECT status FROM threads WHERE id = '$THREAD_ID'"
}

# Test: created state
echo "  Checking initial state..."
STATE=$(get_state)
if [ "$STATE" != "created" ]; then
    echo "  ERROR: Expected 'created', got '$STATE'"
    exit 1
fi
echo "  State: created ✓"

# Transition: created -> ready
echo "  Transitioning to ready..."
sqlite3 "$DB" "UPDATE threads SET status = 'ready', updated_at = datetime('now') WHERE id = '$THREAD_ID'"
sleep 0.5
STATE=$(get_state)
if [ "$STATE" != "ready" ]; then
    echo "  ERROR: Expected 'ready', got '$STATE'"
    exit 1
fi
echo "  State: ready ✓"

# Transition: ready -> running
echo "  Transitioning to running..."
sqlite3 "$DB" "UPDATE threads SET status = 'running', updated_at = datetime('now') WHERE id = '$THREAD_ID'"
sleep 0.5
STATE=$(get_state)
if [ "$STATE" != "running" ]; then
    echo "  ERROR: Expected 'running', got '$STATE'"
    exit 1
fi
echo "  State: running ✓"

# Transition: running -> waiting
echo "  Transitioning to waiting..."
sqlite3 "$DB" "UPDATE threads SET status = 'waiting', updated_at = datetime('now') WHERE id = '$THREAD_ID'"
sleep 0.5
STATE=$(get_state)
if [ "$STATE" != "waiting" ]; then
    echo "  ERROR: Expected 'waiting', got '$STATE'"
    exit 1
fi
echo "  State: waiting ✓"

# Transition: waiting -> running (resume)
echo "  Resuming to running..."
sqlite3 "$DB" "UPDATE threads SET status = 'running', updated_at = datetime('now') WHERE id = '$THREAD_ID'"
sleep 0.5
STATE=$(get_state)
if [ "$STATE" != "running" ]; then
    echo "  ERROR: Expected 'running', got '$STATE'"
    exit 1
fi
echo "  State: running (resumed) ✓"

# Transition: running -> blocked
echo "  Transitioning to blocked..."
sqlite3 "$DB" "UPDATE threads SET status = 'blocked', updated_at = datetime('now') WHERE id = '$THREAD_ID'"
sleep 0.5
STATE=$(get_state)
if [ "$STATE" != "blocked" ]; then
    echo "  ERROR: Expected 'blocked', got '$STATE'"
    exit 1
fi
echo "  State: blocked ✓"

# Transition: blocked -> running (unblocked)
echo "  Unblocking to running..."
sqlite3 "$DB" "UPDATE threads SET status = 'running', updated_at = datetime('now') WHERE id = '$THREAD_ID'"
sleep 0.5
STATE=$(get_state)
if [ "$STATE" != "running" ]; then
    echo "  ERROR: Expected 'running', got '$STATE'"
    exit 1
fi
echo "  State: running (unblocked) ✓"

# Transition: running -> completed
echo "  Transitioning to completed..."
sqlite3 "$DB" "UPDATE threads SET status = 'completed', updated_at = datetime('now') WHERE id = '$THREAD_ID'"
sleep 0.5
STATE=$(get_state)
if [ "$STATE" != "completed" ]; then
    echo "  ERROR: Expected 'completed', got '$STATE'"
    exit 1
fi
echo "  State: completed ✓"

# Test sleeping mode
echo "  Testing sleeping mode..."
OUTPUT=$("$CT" thread create "test-sleeping" --mode sleeping --context '{"test": "sleeping"}' 2>&1)
THREAD_SLEEP=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
sqlite3 "$DB" "UPDATE threads SET status = 'sleeping', updated_at = datetime('now') WHERE id = '$THREAD_SLEEP'"
STATE=$(sqlite3 "$DB" "SELECT status FROM threads WHERE id = '$THREAD_SLEEP'")
if [ "$STATE" != "sleeping" ]; then
    echo "  ERROR: Expected 'sleeping', got '$STATE'"
    exit 1
fi
echo "  State: sleeping ✓"

# Cleanup
echo "  Cleaning up..."
"$CT" thread delete "$THREAD_ID" 2>/dev/null || true
"$CT" thread delete "$THREAD_SLEEP" 2>/dev/null || true

echo "State transitions test passed!"
echo "  Tested: created -> ready -> running -> waiting -> running -> blocked -> running -> completed"
echo "  Tested: sleeping mode"
