#!/bin/bash

# -----------------------------------------------
# THE PETE LOOP
# Usage: ./pete/pete.sh <max_iterations>
# Example: ./pete/pete.sh 15
# -----------------------------------------------

set -uo pipefail

trap 'echo ""; echo "🛑 Pete Loop interrupted."; kill 0; exit 130' INT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${1:-}" ]; then
  echo "Usage: ./pete/pete.sh <max_iterations>"
  echo "Example: ./pete/pete.sh 15"
  exit 1
fi

MAX_ITERATIONS=$1

# -----------------------------------------------
# USAGE CHECK
# Queries your Claude Pro subscription limits
# before each iteration. Stops the loop if your
# 5-hour session usage exceeds 85%.
# -----------------------------------------------
check_usage() {
  TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | \
    python3 -c "import sys,json; print(json.load(sys.stdin)['claudeAiOauth']['accessToken'])" 2>/dev/null) || true

  if [ -z "${TOKEN:-}" ]; then
    echo "⚠️  Could not retrieve token — skipping usage check."
    return 0
  fi

  UTILIZATION=$(curl -s "https://api.anthropic.com/api/oauth/usage" \
    -H "Authorization: Bearer $TOKEN" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code/2.0.32" | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(d['five_hour']['utilization'])" 2>/dev/null) || true

  if [ -z "${UTILIZATION:-}" ]; then
    echo "⚠️  Could not parse usage data — skipping usage check."
    return 0
  fi

  echo "📊 5-hour session usage: ${UTILIZATION}%"

  if (( $(echo "$UTILIZATION > 85" | bc -l) )); then
    echo ""
    echo "🛑 Usage at ${UTILIZATION}% — stopping Pete Loop to avoid hitting limit."
    echo "   Wait for your 5-hour window to reset, then re-run."
    exit 1
  fi
}

# -----------------------------------------------
# MAIN LOOP
# -----------------------------------------------
echo ""
echo "🚀 Pete Loop starting — max $MAX_ITERATIONS iterations"
echo "========================================"

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo ""
  echo "🔄 Iteration $i of $MAX_ITERATIONS"
  echo "----------------------------------------"

  check_usage

  result=$(claude -p "$(cat "$SCRIPT_DIR/PROMPT.md")" --output-format text 2>&1) || true

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo "✅ Pete Loop complete after $i iteration(s)!"
    exit 0
  fi

  if [[ "$result" == *"<promise>BLOCKED</promise>"* ]]; then
    echo ""
    echo "⏸️  Pete Loop paused — all remaining tasks need human input."
    echo "   Check pete/human-todo.md, resolve each item, then re-run."
    exit 2
  fi

  echo ""
  echo "--- End of iteration $i ---"
  echo ""
done

echo ""
echo "⛔ Reached max iterations ($MAX_ITERATIONS) without completion."
echo "   Check pete/human-todo.md for blocked tasks."
echo "   Review pete/progress.txt and pete/plan.md, then re-run if needed."
exit 1
