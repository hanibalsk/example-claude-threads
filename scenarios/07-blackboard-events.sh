#!/usr/bin/env bash
#
# Scenario 7: Blackboard Pattern - Event-Driven Coordination
#
# This scenario demonstrates the blackboard pattern for thread coordination:
# - Threads communicate via events, not direct messages
# - Events are stored in the database and can be queried
# - Threads react to events they're interested in
#
# Common event types:
# - TASK_STARTED, TASK_COMPLETED, TASK_FAILED
# - REVIEW_REQUESTED, REVIEW_COMPLETED
# - PR_CREATED, PR_MERGED
# - CUSTOM events for your workflow
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 7: Blackboard Events Demo ==="
echo ""

# Check prerequisites
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

# Show current events
echo "Current blackboard events:"
"$CT" event list 2>/dev/null || echo "(no events yet)"
echo ""

# Post a custom event
echo "Posting a custom event..."
"$CT" event post "DEMO_STARTED" '{
    "scenario": "blackboard-demo",
    "timestamp": "'$(date -Iseconds)'",
    "user": "'$(whoami)'"
}' 2>/dev/null || echo "(event posted)"

# Create a producer thread
echo ""
echo "Creating producer thread..."
PRODUCER=$("$CT" thread create "event-producer" \
    --mode automatic \
    --context '{
        "role": "producer",
        "events_to_emit": ["DATA_READY", "PROCESSING_COMPLETE"],
        "task": "Generate some data and emit events"
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "producer-thread")
echo "Producer: $PRODUCER"

# Create a consumer thread
echo ""
echo "Creating consumer thread..."
CONSUMER=$("$CT" thread create "event-consumer" \
    --mode semi-auto \
    --context '{
        "role": "consumer",
        "events_to_watch": ["DATA_READY"],
        "task": "Wait for DATA_READY event and process it"
    }' \
    2>&1 | sed 's/\x1b\[[0-9;]*m//g' | grep "^Thread created:" | awk '{print $3}' || echo "consumer-thread")
echo "Consumer: $CONSUMER"

# Show events again
echo ""
echo "Events after thread creation:"
"$CT" event list 2>/dev/null || echo "(checking events...)"

# Explain the pattern
echo ""
echo "=== Blackboard Pattern Explained ==="
echo ""
echo "1. Producer threads emit events:"
echo "   ct event post FEATURE_COMPLETED '{\"file\": \"calc.py\"}'"
echo ""
echo "2. Consumer threads watch for events:"
echo "   ct event list --type FEATURE_COMPLETED"
echo ""
echo "3. Events include:"
echo "   - Type (e.g., TASK_COMPLETED)"
echo "   - Data (JSON payload)"
echo "   - Thread ID (who emitted it)"
echo "   - Timestamp"
echo ""
echo "4. Thread templates can specify reactions:"
echo "   reactions:"
echo "     - event: FEATURE_COMPLETED"
echo "       action: start_review"
echo ""

# Event commands
echo "=== Event Commands ==="
echo ""
echo "  ct event list                    # List all events"
echo "  ct event list --type <type>      # Filter by type"
echo "  ct event list --thread <id>      # Filter by thread"
echo "  ct event post <type> <data>      # Post new event"
echo "  ct event clear                   # Clear old events"
echo ""

echo "=== Scenario 7 Info Complete ==="
echo ""
