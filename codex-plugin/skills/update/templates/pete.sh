#!/bin/bash

# -----------------------------------------------
# THE PETE LOOP (Codex edition)
# Usage: ./pete/pete.sh <max_iterations> [subfolder]
# Example: ./pete/pete.sh 15
# Example: ./pete/pete.sh 15 v2
# -----------------------------------------------

set -uo pipefail

trap 'echo ""; echo "🛑 Pete Loop interrupted."; kill 0; exit 130' INT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "${1:-}" ]; then
  echo "Usage: ./pete/pete.sh <max_iterations> [subfolder]"
  echo "Example: ./pete/pete.sh 15"
  echo "Example: ./pete/pete.sh 15 v2"
  exit 1
fi

MAX_ITERATIONS=$1
SUBFOLDER="${2:-}"

if [ -n "$SUBFOLDER" ]; then
  PROMPT_FILE="$SCRIPT_DIR/$SUBFOLDER/PROMPT.md"
else
  PROMPT_FILE="$SCRIPT_DIR/PROMPT.md"
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ PROMPT.md not found at: $PROMPT_FILE"
  exit 1
fi

LAST_MSG_FILE=$(mktemp)
trap 'rm -f "$LAST_MSG_FILE"' EXIT

echo ""
if [ -n "$SUBFOLDER" ]; then
  echo "🚀 Pete Loop starting — max $MAX_ITERATIONS iterations [run: $SUBFOLDER]"
else
  echo "🚀 Pete Loop starting — max $MAX_ITERATIONS iterations"
fi
echo "========================================"

for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo ""
  echo "🔄 Iteration $i of $MAX_ITERATIONS"
  echo "----------------------------------------"

  codex --ask-for-approval never exec \
    --sandbox workspace-write \
    --output-last-message "$LAST_MSG_FILE" \
    "$(cat "$PROMPT_FILE")" >/dev/null 2>&1 || true

  LAST_MSG=$(cat "$LAST_MSG_FILE" 2>/dev/null || echo "")

  if [[ "$LAST_MSG" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo "✅ Pete Loop complete after $i iteration(s)!"
    exit 0
  fi

  if [[ "$LAST_MSG" == *"<promise>BLOCKED</promise>"* ]]; then
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
