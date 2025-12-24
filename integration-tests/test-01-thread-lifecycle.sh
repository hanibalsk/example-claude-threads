#!/usr/bin/env bash
#
# Test 01: Thread Lifecycle
#
# Tests basic thread operations: create, ready, status, delete
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

cd "$PROJECT_DIR"

echo "Testing thread lifecycle..."

# Create thread
echo "  Creating thread..."
OUTPUT=$("$CT" thread create "test-lifecycle" --mode automatic --context '{"test": true}' 2>&1)
THREAD_ID=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')

if [ -z "$THREAD_ID" ]; then
    echo "  ERROR: Failed to create thread"
    echo "  Output: $OUTPUT"
    exit 1
fi
echo "  Thread created: $THREAD_ID"

# Check status is 'created'
echo "  Checking initial status..."
STATUS=$("$CT" thread status "$THREAD_ID" 2>&1 | grep "^Status:" | awk '{print $2}')
if [ "$STATUS" != "created" ]; then
    echo "  ERROR: Expected status 'created', got '$STATUS'"
    exit 1
fi
echo "  Status: $STATUS (correct)"

# List should include thread
echo "  Verifying thread in list..."
if ! "$CT" thread list 2>&1 | grep -q "test-lifecycle"; then
    echo "  ERROR: Thread not found in list"
    exit 1
fi
echo "  Thread found in list"

# Delete thread
echo "  Deleting thread..."
"$CT" thread delete "$THREAD_ID" >/dev/null 2>&1

# Verify deleted
echo "  Verifying deletion..."
if "$CT" thread list 2>&1 | grep -q "$THREAD_ID"; then
    echo "  ERROR: Thread still exists after deletion"
    exit 1
fi
echo "  Thread deleted successfully"

echo "Thread lifecycle test passed!"
