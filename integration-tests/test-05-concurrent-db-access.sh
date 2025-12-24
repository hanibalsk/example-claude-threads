#!/usr/bin/env bash
#
# Test 05: Concurrent Database Access
#
# Tests SQLite WAL mode with concurrent reads and writes.
# Verifies database integrity under concurrent access.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"
DB="$PROJECT_DIR/.claude-threads/threads.db"

cd "$PROJECT_DIR"

echo "Testing concurrent database access..."

# Verify WAL mode is enabled
echo "  Checking WAL mode..."
JOURNAL_MODE=$(sqlite3 "$DB" "PRAGMA journal_mode;" 2>/dev/null || echo "unknown")
echo "  Journal mode: $JOURNAL_MODE"
if [ "$JOURNAL_MODE" != "wal" ]; then
    echo "  WARNING: WAL mode not enabled, concurrent access may be limited"
fi

# Create temp file for tracking
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Concurrent writers
echo "  Starting 5 concurrent writers..."
for i in $(seq 1 5); do
    (
        for j in $(seq 1 10); do
            "$CT" thread create "test-concurrent-w$i-$j" --mode automatic --context '{"writer": '$i', "seq": '$j'}' 2>&1 >/dev/null
            echo "w$i-$j" >> "$TEMP_DIR/writes.log"
        done
    ) &
done

# Concurrent readers
echo "  Starting 3 concurrent readers..."
for i in $(seq 1 3); do
    (
        for j in $(seq 1 20); do
            "$CT" thread list 2>&1 >/dev/null
            echo "r$i-$j" >> "$TEMP_DIR/reads.log"
            sleep 0.1
        done
    ) &
done

# Wait for all
echo "  Waiting for concurrent operations..."
wait

sleep 2

# Count results
WRITE_COUNT=$(wc -l < "$TEMP_DIR/writes.log" 2>/dev/null | tr -d ' ' || echo "0")
READ_COUNT=$(wc -l < "$TEMP_DIR/reads.log" 2>/dev/null | tr -d ' ' || echo "0")
echo "  Write operations completed: $WRITE_COUNT"
echo "  Read operations completed: $READ_COUNT"

# Verify expected writes
EXPECTED_WRITES=50
if [ "$WRITE_COUNT" -lt "$EXPECTED_WRITES" ]; then
    echo "  WARNING: Expected $EXPECTED_WRITES writes, got $WRITE_COUNT"
fi

# Verify database integrity
echo "  Checking database integrity..."
INTEGRITY=$(sqlite3 "$DB" "PRAGMA integrity_check;" 2>/dev/null || echo "error")
if [ "$INTEGRITY" != "ok" ]; then
    echo "  ERROR: Database integrity check failed: $INTEGRITY"
    exit 1
fi
echo "  Database integrity: OK"

# Count threads in DB
DB_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM threads WHERE name LIKE 'test-concurrent-%'" 2>/dev/null || echo "0")
echo "  Threads in database: $DB_COUNT"

# Cleanup
echo "  Cleaning up..."
sqlite3 "$DB" "DELETE FROM threads WHERE name LIKE 'test-concurrent-%'" 2>/dev/null || true

echo "Concurrent database access test passed!"
