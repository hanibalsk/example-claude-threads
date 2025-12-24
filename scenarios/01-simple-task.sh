#!/usr/bin/env bash
#
# Scenario 1: Simple Single-Thread Task
#
# This scenario demonstrates a single automatic thread
# executing a simple task.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 1: Simple Task ==="
echo ""

# Check if ct is available
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

# Create a simple task thread
echo "Creating thread..."
CREATE_OUTPUT=$("$CT" thread create "simple-task-$(date +%s)" \
    --mode automatic \
    --context '{"task": "Add subtract method to calculator"}' \
    2>&1)

# Extract thread ID - look for line starting with "Thread created:" (not the log line with INFO)
# Strip ANSI codes first, then extract
THREAD_ID=$(echo "$CREATE_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')

echo "Thread created: $THREAD_ID"
echo ""

# Show thread status
echo ""
echo "Thread status:"
"$CT" thread status "$THREAD_ID"

# Start the thread
echo ""
echo "Starting thread..."
"$CT" thread start "$THREAD_ID"

# Monitor for a bit
echo ""
echo "Monitoring thread (5 seconds)..."
sleep 5

# Show final status
echo ""
echo "Final status:"
"$CT" thread status "$THREAD_ID"

echo ""
echo "=== Scenario 1 Complete ==="
