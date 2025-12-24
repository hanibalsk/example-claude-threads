#!/usr/bin/env bash
#
# Scenario 6: Remote Connection - Multi-Instance Coordination
#
# This scenario demonstrates connecting Claude instances across projects:
# - Main orchestrator in one project
# - Remote Claude instance spawns threads
# - Threads work on remote project via API
#
# Use case: You have Claude open in project A, but want to spawn
# a development thread in project B without switching contexts.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

echo "=== Scenario 6: Remote Connection Demo ==="
echo ""

# Check prerequisites
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    exit 1
fi

# Start the API server
echo "Starting API server..."
"$CT" api start 2>/dev/null || true
sleep 2

# Check API status
echo ""
echo "API server status:"
"$CT" api status || echo "(API may already be running)"

# Show API configuration
echo ""
echo "API Configuration:"
if [ -f "$PROJECT_DIR/.claude-threads/config.yaml" ]; then
    grep -A5 "api:" "$PROJECT_DIR/.claude-threads/config.yaml" 2>/dev/null || echo "Using defaults"
fi

# Demonstrate API usage
echo ""
echo "=== Remote Connection Commands ==="
echo ""
echo "From Claude Code in another project, use:"
echo ""
echo "  1. Connect to this project's API:"
echo "     /ct-connect localhost:31337"
echo ""
echo "  2. Spawn a thread remotely:"
echo "     /ct-spawn \"Add logging to calculator\" --mode automatic"
echo ""
echo "  3. The spawned thread runs HERE (in this project)"
echo "     while you continue working in your original project"
echo ""

# Show API endpoints
echo "=== API Endpoints ==="
echo ""
echo "Base URL: http://localhost:31337"
echo ""
echo "Endpoints:"
echo "  GET  /health              - Health check"
echo "  GET  /threads             - List all threads"
echo "  POST /threads             - Create new thread"
echo "  GET  /threads/:id         - Get thread details"
echo "  POST /threads/:id/start   - Start a thread"
echo "  POST /threads/:id/stop    - Stop a thread"
echo "  GET  /events              - List blackboard events"
echo "  POST /events              - Post event to blackboard"
echo ""

# Test the API
echo "=== API Test ==="
echo ""
echo "Testing API health..."
if curl -s "http://localhost:31337/health" 2>/dev/null | grep -q "ok"; then
    echo "✅ API is responding"

    echo ""
    echo "Listing threads via API..."
    curl -s "http://localhost:31337/threads" 2>/dev/null | head -20
else
    echo "⚠️  API not responding (may need to start it)"
fi

echo ""
echo ""
echo "=== Scenario 6 Info Complete ==="
echo ""
echo "To use remote connection:"
echo "  1. Keep this project's API running: ct api start"
echo "  2. In another Claude Code session, use /ct-connect"
echo "  3. Spawn threads remotely with /ct-spawn"
echo ""
