#!/usr/bin/env bash
#
# Test 04: Thread Communication via Blackboard
#
# Simulates two threads communicating through the blackboard.
# Thread A publishes an event, Thread B should be able to see it.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

cd "$PROJECT_DIR"

echo "Testing thread communication via blackboard..."

# Create Thread A (producer)
echo "  Creating producer thread..."
OUTPUT_A=$("$CT" thread create "test-producer" --mode automatic --context '{"role": "producer"}' 2>&1)
THREAD_A=$(echo "$OUTPUT_A" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "  Producer thread: $THREAD_A"

# Create Thread B (consumer)
echo "  Creating consumer thread..."
OUTPUT_B=$("$CT" thread create "test-consumer" --mode automatic --context '{"role": "consumer"}' 2>&1)
THREAD_B=$(echo "$OUTPUT_B" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "  Consumer thread: $THREAD_B"

# Simulate Thread A publishing an event
echo "  Producer publishing event..."
sqlite3 .claude-threads/threads.db "INSERT INTO events (type, source, data, targets) VALUES ('TASK_COMPLETED', '$THREAD_A', '{\"task\": \"build\", \"status\": \"success\"}', '*')"

sleep 1

# Verify event can be seen
echo "  Verifying event visible..."
EVENT=$(sqlite3 .claude-threads/threads.db "SELECT type, source FROM events WHERE source = '$THREAD_A' AND type = 'TASK_COMPLETED' LIMIT 1")
if [ -z "$EVENT" ]; then
    echo "  ERROR: Event not found"
    "$CT" thread delete "$THREAD_A" 2>/dev/null || true
    "$CT" thread delete "$THREAD_B" 2>/dev/null || true
    exit 1
fi
echo "  Event found: $EVENT"

# Simulate Thread B polling and receiving the event
echo "  Simulating consumer poll..."
EVENTS_FOR_B=$(sqlite3 .claude-threads/threads.db "SELECT COUNT(*) FROM events WHERE (targets = '*' OR targets LIKE '%$THREAD_B%') AND processed = 0")
echo "  Events available for consumer: $EVENTS_FOR_B"

if [ "$EVENTS_FOR_B" -lt 1 ]; then
    echo "  WARNING: No events available for consumer thread"
fi

# Test direct message between threads
echo "  Testing direct message..."
sqlite3 .claude-threads/threads.db "INSERT INTO messages (from_thread, to_thread, type, content) VALUES ('$THREAD_A', '$THREAD_B', 'REQUEST', '{\"action\": \"review\"}')"

sleep 1

MSG_COUNT=$(sqlite3 .claude-threads/threads.db "SELECT COUNT(*) FROM messages WHERE to_thread = '$THREAD_B' AND read_at IS NULL")
echo "  Unread messages for consumer: $MSG_COUNT"

if [ "$MSG_COUNT" -lt 1 ]; then
    echo "  ERROR: Message not delivered"
    "$CT" thread delete "$THREAD_A" 2>/dev/null || true
    "$CT" thread delete "$THREAD_B" 2>/dev/null || true
    exit 1
fi

# Cleanup
echo "  Cleaning up..."
"$CT" thread delete "$THREAD_A" 2>/dev/null || true
"$CT" thread delete "$THREAD_B" 2>/dev/null || true
sqlite3 .claude-threads/threads.db "DELETE FROM events WHERE source IN ('$THREAD_A', '$THREAD_B')" 2>/dev/null || true
sqlite3 .claude-threads/threads.db "DELETE FROM messages WHERE from_thread = '$THREAD_A' OR to_thread = '$THREAD_B'" 2>/dev/null || true

echo "Thread communication test passed!"
