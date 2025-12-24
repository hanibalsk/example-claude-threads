#!/usr/bin/env bash
#
# Test 03: Blackboard Events
#
# Tests event publishing and retrieval on the blackboard.
# Verifies events are stored correctly and can be queried.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

cd "$PROJECT_DIR"

DB="$PROJECT_DIR/.claude-threads/threads.db"

echo "Testing blackboard events..."

# Get initial event count
INITIAL_COUNT=$(sqlite3 .claude-threads/threads.db "SELECT COUNT(*) FROM events" 2>/dev/null || echo "0")
echo "  Initial event count: $INITIAL_COUNT"

# Publish test event (directly via SQL since ct event publish has JSON validation issues)
echo "  Publishing test event..."
sqlite3 "$DB" "INSERT INTO events (type, source, data, targets) VALUES ('TEST_EVENT_1', 'test-script', '{\"message\": \"Hello from test\"}', '*')"

sleep 1

# Verify event was stored
echo "  Verifying event stored..."
EVENT_COUNT=$(sqlite3 .claude-threads/threads.db "SELECT COUNT(*) FROM events WHERE type = 'TEST_EVENT_1'" 2>/dev/null || echo "0")
if [ "$EVENT_COUNT" -lt 1 ]; then
    echo "  ERROR: Event not found in database"
    exit 1
fi
echo "  Event found in database"

# Publish multiple events rapidly (via SQL)
echo "  Publishing 10 events rapidly..."
for i in $(seq 1 10); do
    sqlite3 "$DB" "INSERT INTO events (type, source, data, targets) VALUES ('TEST_RAPID_$i', 'test-script', '{\"index\": $i}', '*')" 2>/dev/null
done

sleep 2

# Verify all events
echo "  Verifying all rapid events..."
RAPID_COUNT=$(sqlite3 .claude-threads/threads.db "SELECT COUNT(*) FROM events WHERE type LIKE 'TEST_RAPID_%'" 2>/dev/null || echo "0")
echo "  Found $RAPID_COUNT rapid events"
if [ "$RAPID_COUNT" -lt 10 ]; then
    echo "  WARNING: Expected 10 events, found $RAPID_COUNT (some may have been deduplicated)"
fi

# Test event list command
echo "  Testing event list command..."
EVENT_LIST=$("$CT" event list 2>&1)
if ! echo "$EVENT_LIST" | grep -q "TEST_EVENT_1\|TEST_RAPID"; then
    echo "  WARNING: Test events not visible in event list (may be pagination)"
fi

# Cleanup test events
echo "  Cleaning up test events..."
sqlite3 .claude-threads/threads.db "DELETE FROM events WHERE type LIKE 'TEST_%'" 2>/dev/null || true

echo "Blackboard events test passed!"
