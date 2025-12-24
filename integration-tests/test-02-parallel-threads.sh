#!/usr/bin/env bash
#
# Test 02: Parallel Thread Creation
#
# Tests creating multiple threads in parallel and verifying
# they all get created correctly.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

cd "$PROJECT_DIR"

echo "Testing parallel thread creation..."

# Clean up any leftover test threads first
DB="$PROJECT_DIR/.claude-threads/threads.db"
sqlite3 "$DB" "DELETE FROM threads WHERE name LIKE 'test-parallel-%'" 2>/dev/null || true

NUM_THREADS=5
THREAD_IDS=()

# Create threads in parallel
echo "  Creating $NUM_THREADS threads in parallel..."
for i in $(seq 1 $NUM_THREADS); do
    (
        OUTPUT=$("$CT" thread create "test-parallel-$i" \
            --mode automatic \
            --context "{\"index\": $i}" 2>&1)
        THREAD_ID=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
        echo "$THREAD_ID" >> /tmp/parallel-test-ids.$$
    ) &
done

# Wait for all to complete
wait
echo "  All creation jobs completed"

# Small delay to ensure DB commits
sleep 1

# Read created IDs
if [ -f /tmp/parallel-test-ids.$$ ]; then
    mapfile -t THREAD_IDS < /tmp/parallel-test-ids.$$
    rm -f /tmp/parallel-test-ids.$$
fi

echo "  Created ${#THREAD_IDS[@]} threads"

# Verify count
ACTUAL_COUNT=$("$CT" thread list 2>&1 | grep "test-parallel-" | wc -l | tr -d ' ')
echo "  Found $ACTUAL_COUNT threads in database"

if [ "$ACTUAL_COUNT" -ne "$NUM_THREADS" ]; then
    echo "  ERROR: Expected $NUM_THREADS threads, found $ACTUAL_COUNT"
    # Cleanup
    for id in "${THREAD_IDS[@]}"; do
        "$CT" thread delete "$id" 2>/dev/null || true
    done
    exit 1
fi

# Verify each thread exists in database
echo "  Verifying thread data in database..."
DB="$PROJECT_DIR/.claude-threads/threads.db"
for i in $(seq 1 $NUM_THREADS); do
    COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM threads WHERE name = 'test-parallel-$i'" 2>/dev/null || echo "0")
    if [ "$COUNT" -lt 1 ]; then
        echo "  ERROR: Thread test-parallel-$i not found in database"
        exit 1
    fi
done
echo "  All threads verified in database"

# Cleanup
echo "  Cleaning up..."
for id in "${THREAD_IDS[@]}"; do
    "$CT" thread delete "$id" 2>/dev/null || true
done

# Also cleanup by name pattern
sqlite3 .claude-threads/threads.db "DELETE FROM threads WHERE name LIKE 'test-parallel-%'" 2>/dev/null || true

echo "Parallel thread creation test passed!"
