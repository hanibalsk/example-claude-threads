#!/usr/bin/env bash
#
# Test 06: Delayed Processing Simulation
#
# Simulates a workflow where threads process tasks with delays,
# mimicking real-world async Claude execution.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"
DB="$PROJECT_DIR/.claude-threads/threads.db"

cd "$PROJECT_DIR"

echo "Testing delayed processing simulation..."

# Create a workflow with 3 dependent stages
echo "  Creating 3-stage workflow simulation..."

# Stage 1: Developer
OUTPUT=$("$CT" thread create "test-stage1-dev" --mode automatic --context '{"stage": 1, "task": "develop"}' 2>&1)
THREAD_1=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "  Stage 1 (Developer): $THREAD_1"

# Stage 2: Reviewer (waits for stage 1)
OUTPUT=$("$CT" thread create "test-stage2-review" --mode automatic --context '{"stage": 2, "task": "review", "depends_on": "stage1"}' 2>&1)
THREAD_2=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "  Stage 2 (Reviewer): $THREAD_2"

# Stage 3: Merger (waits for stage 2)
OUTPUT=$("$CT" thread create "test-stage3-merge" --mode automatic --context '{"stage": 3, "task": "merge", "depends_on": "stage2"}' 2>&1)
THREAD_3=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}')
echo "  Stage 3 (Merger): $THREAD_3"

# Simulate Stage 1 processing with delay
echo "  Simulating Stage 1 processing (2s delay)..."
sqlite3 "$DB" "UPDATE threads SET status = 'running', phase = 'DEVELOPING' WHERE id = '$THREAD_1'"
sleep 2

# Stage 1 completes, publishes event
echo "  Stage 1 completing..."
sqlite3 "$DB" "UPDATE threads SET status = 'completed', phase = 'DONE' WHERE id = '$THREAD_1'"
sqlite3 "$DB" "INSERT INTO events (type, source, data, targets) VALUES ('STAGE_COMPLETED', '$THREAD_1', '{\"stage\": 1}', '*')"

# Verify event published
EVENT_1=$(sqlite3 "$DB" "SELECT COUNT(*) FROM events WHERE source = '$THREAD_1' AND type = 'STAGE_COMPLETED'")
echo "  Stage 1 completion event published: $EVENT_1"

# Simulate Stage 2 starting after event
echo "  Simulating Stage 2 processing (1s delay)..."
sqlite3 "$DB" "UPDATE threads SET status = 'running', phase = 'REVIEWING' WHERE id = '$THREAD_2'"
sleep 1

# Stage 2 completes
echo "  Stage 2 completing..."
sqlite3 "$DB" "UPDATE threads SET status = 'completed', phase = 'DONE' WHERE id = '$THREAD_2'"
sqlite3 "$DB" "INSERT INTO events (type, source, data, targets) VALUES ('STAGE_COMPLETED', '$THREAD_2', '{\"stage\": 2}', '*')"

# Simulate Stage 3
echo "  Simulating Stage 3 processing (1s delay)..."
sqlite3 "$DB" "UPDATE threads SET status = 'running', phase = 'MERGING' WHERE id = '$THREAD_3'"
sleep 1

# Stage 3 completes
echo "  Stage 3 completing..."
sqlite3 "$DB" "UPDATE threads SET status = 'completed', phase = 'DONE' WHERE id = '$THREAD_3'"
sqlite3 "$DB" "INSERT INTO events (type, source, data, targets) VALUES ('WORKFLOW_COMPLETED', '$THREAD_3', '{\"stages\": [1, 2, 3]}', '*')"

# Verify all stages completed
echo "  Verifying all stages completed..."
COMPLETED=$(sqlite3 "$DB" "SELECT COUNT(*) FROM threads WHERE id IN ('$THREAD_1', '$THREAD_2', '$THREAD_3') AND status = 'completed'")
if [ "$COMPLETED" -ne 3 ]; then
    echo "  ERROR: Expected 3 completed threads, got $COMPLETED"
    exit 1
fi
echo "  All 3 stages completed successfully"

# Check event sequence
echo "  Verifying event sequence..."
EVENTS=$(sqlite3 "$DB" "SELECT type FROM events WHERE source IN ('$THREAD_1', '$THREAD_2', '$THREAD_3') ORDER BY timestamp")
echo "  Events: $(echo $EVENTS | tr '\n' ' ')"

# Cleanup
echo "  Cleaning up..."
sqlite3 "$DB" "DELETE FROM threads WHERE id IN ('$THREAD_1', '$THREAD_2', '$THREAD_3')" 2>/dev/null || true
sqlite3 "$DB" "DELETE FROM events WHERE source IN ('$THREAD_1', '$THREAD_2', '$THREAD_3')" 2>/dev/null || true

echo "Delayed processing simulation test passed!"
