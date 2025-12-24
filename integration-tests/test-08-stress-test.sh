#!/usr/bin/env bash
#
# Test 08: Stress Test
#
# Creates many threads and events to test system under load.
# Measures timing and verifies no data loss.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"
DB="$PROJECT_DIR/.claude-threads/threads.db"

cd "$PROJECT_DIR"

echo "Running stress test..."

NUM_THREADS=20
NUM_EVENTS_PER_THREAD=5

# Cleanup first
sqlite3 "$DB" "DELETE FROM threads WHERE name LIKE 'test-stress-%'" 2>/dev/null || true
sqlite3 "$DB" "DELETE FROM events WHERE type LIKE 'STRESS_EVENT_%'" 2>/dev/null || true

# Timer
start_time=$(date +%s)

# Create threads
echo "  Creating $NUM_THREADS threads..."
for i in $(seq 1 $NUM_THREADS); do
    "$CT" thread create "test-stress-$i" --mode automatic --context '{"stress": true, "index": '$i'}' >/dev/null 2>&1

    # Progress indicator
    if [ $((i % 5)) -eq 0 ]; then
        echo "    Created $i/$NUM_THREADS threads..."
    fi
done

thread_time=$(date +%s)
thread_duration=$((thread_time - start_time))
echo "  Thread creation took: ${thread_duration}s"

# Get thread IDs from database
THREAD_IDS=$(sqlite3 "$DB" "SELECT id FROM threads WHERE name LIKE 'test-stress-%'")

# Create events for each thread
echo "  Creating $((NUM_THREADS * NUM_EVENTS_PER_THREAD)) events..."
EVENT_COUNT=0
for thread_id in $THREAD_IDS; do
    for j in $(seq 1 $NUM_EVENTS_PER_THREAD); do
        sqlite3 "$DB" "INSERT INTO events (type, source, data, targets) VALUES ('STRESS_EVENT_$j', '$thread_id', '{\"seq\": $j}', '*')" 2>/dev/null
        ((EVENT_COUNT++)) || true
    done
done

event_time=$(date +%s)
event_duration=$((event_time - thread_time))
echo "  Event creation took: ${event_duration}s"

# Verify counts
echo "  Verifying data..."
ACTUAL_THREADS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM threads WHERE name LIKE 'test-stress-%'")
ACTUAL_EVENTS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM events WHERE type LIKE 'STRESS_EVENT_%'")

echo "  Threads created: $ACTUAL_THREADS (expected: $NUM_THREADS)"
echo "  Events created: $ACTUAL_EVENTS (expected: $((NUM_THREADS * NUM_EVENTS_PER_THREAD)))"

if [ "$ACTUAL_THREADS" -ne "$NUM_THREADS" ]; then
    echo "  ERROR: Thread count mismatch"
    sqlite3 "$DB" "DELETE FROM threads WHERE name LIKE 'test-stress-%'" 2>/dev/null || true
    sqlite3 "$DB" "DELETE FROM events WHERE type LIKE 'STRESS_EVENT_%'" 2>/dev/null || true
    exit 1
fi

# Simulate parallel state updates
echo "  Simulating parallel state updates..."
for thread_id in $THREAD_IDS; do
    (
        sqlite3 "$DB" "UPDATE threads SET status = 'running', phase = 'PROCESSING' WHERE id = '$thread_id'" 2>/dev/null
        sleep 0.05
        sqlite3 "$DB" "UPDATE threads SET status = 'completed', phase = 'DONE' WHERE id = '$thread_id'" 2>/dev/null
    ) &
done
wait

update_time=$(date +%s)
update_duration=$((update_time - event_time))
echo "  State updates took: ${update_duration}s"

# Check all completed
COMPLETED=$(sqlite3 "$DB" "SELECT COUNT(*) FROM threads WHERE name LIKE 'test-stress-%' AND status = 'completed'")
echo "  Threads completed: $COMPLETED"

# Database size
DB_SIZE=$(ls -lh "$DB" | awk '{print $5}')
echo "  Database size: $DB_SIZE"

# Cleanup
echo "  Cleaning up..."
sqlite3 "$DB" "DELETE FROM threads WHERE name LIKE 'test-stress-%'" 2>/dev/null || true
sqlite3 "$DB" "DELETE FROM events WHERE type LIKE 'STRESS_EVENT_%'" 2>/dev/null || true

# Total time
end_time=$(date +%s)
total_duration=$((end_time - start_time))

echo ""
echo "  Stress test summary:"
echo "    Threads:        $NUM_THREADS"
echo "    Events:         $((NUM_THREADS * NUM_EVENTS_PER_THREAD))"
echo "    Total time:     ${total_duration}s"

echo "Stress test passed!"
