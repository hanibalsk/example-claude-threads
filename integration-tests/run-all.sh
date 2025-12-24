#!/usr/bin/env bash
#
# Integration Test Runner for claude-threads
#
# Runs all integration tests with timing and results summary.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CT="$PROJECT_DIR/.claude-threads/bin/ct"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
PASSED=0
FAILED=0
SKIPPED=0

# Logging
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; ((PASSED++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $*"; ((FAILED++)); }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $*"; ((SKIPPED++)); }

# Timer
start_timer() { START_TIME=$(date +%s); }
elapsed() { echo $(($(date +%s) - START_TIME)); }

# Header
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  claude-threads Integration Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check prerequisites
log_info "Checking prerequisites..."
if [ ! -x "$CT" ]; then
    echo "Error: ct not found at $CT"
    echo "Run install.sh first"
    exit 1
fi
log_info "ct found: $CT"
echo ""

# Clean up before tests
log_info "Cleaning up previous test data..."
cd "$PROJECT_DIR"
sqlite3 .claude-threads/threads.db "DELETE FROM threads WHERE name LIKE 'test-%'" 2>/dev/null || true
sqlite3 .claude-threads/threads.db "DELETE FROM events WHERE source LIKE 'test-%'" 2>/dev/null || true
log_info "Cleanup complete"
echo ""

# Run individual test scripts
run_test() {
    local test_script="$1"
    local test_name="$(basename "$test_script" .sh)"

    echo ""
    echo "┌─────────────────────────────────────────────────────"
    echo "│ Test: $test_name"
    echo "└─────────────────────────────────────────────────────"

    start_timer

    if bash "$test_script"; then
        log_pass "$test_name ($(elapsed)s)"
    else
        log_fail "$test_name ($(elapsed)s)"
    fi
}

# Run all test scripts
for test_script in "$SCRIPT_DIR"/test-*.sh; do
    if [ -f "$test_script" ]; then
        run_test "$test_script"
    fi
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "  ${GREEN}Passed:${NC}  $PASSED"
echo -e "  ${RED}Failed:${NC}  $FAILED"
echo -e "  ${YELLOW}Skipped:${NC} $SKIPPED"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
