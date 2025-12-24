#!/usr/bin/env bash
#
# Scenario 3: Full Orchestrator Demo
#
# This scenario runs the full orchestrator daemon
# managing multiple threads automatically.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 3: Orchestrator Demo ==="
echo ""

# Check orchestrator status
echo "Checking orchestrator status..."
"$CT" orchestrator status || true

# Start orchestrator in background
echo ""
echo "Starting orchestrator..."
"$CT" orchestrator start

sleep 2

# Create multiple threads
echo ""
echo "Creating threads..."

# Thread 1: Implement subtraction
"$CT" thread create "dev-subtract" \
    --mode automatic \
    --context '{"task": "implement subtract method"}' \
    >/dev/null

# Thread 2: Implement multiplication
"$CT" thread create "dev-multiply" \
    --mode automatic \
    --context '{"task": "implement multiply method"}' \
    >/dev/null

# Thread 3: Implement division
"$CT" thread create "dev-divide" \
    --mode automatic \
    --context '{"task": "implement divide method"}' \
    >/dev/null

echo "Created 3 developer threads"

# List threads
echo ""
echo "Thread status:"
"$CT" thread list

# Show orchestrator status
echo ""
echo "Orchestrator status:"
"$CT" orchestrator status

echo ""
echo "=== Orchestrator Running ==="
echo ""
echo "Commands:"
echo "  ct thread list          - List all threads"
echo "  ct thread status <id>   - Show thread details"
echo "  ct event list           - View blackboard events"
echo "  ct orchestrator stop    - Stop orchestrator"
echo ""
echo "Logs: tail -f $PROJECT_DIR/.claude-threads/logs/orchestrator.log"
