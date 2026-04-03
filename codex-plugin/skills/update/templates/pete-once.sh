#!/bin/bash

# -----------------------------------------------
# PETE ONCE — Human-in-the-loop single iteration (Codex edition)
# Usage: ./pete/pete-once.sh
# Usage: ./pete/pete-once.sh [subfolder]
# Example: ./pete/pete-once.sh
# Example: ./pete/pete-once.sh v2
# -----------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUBFOLDER="${1:-}"

if [ -n "$SUBFOLDER" ]; then
  PROMPT_FILE="$SCRIPT_DIR/$SUBFOLDER/PROMPT.md"
else
  PROMPT_FILE="$SCRIPT_DIR/PROMPT.md"
fi

if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ PROMPT.md not found at: $PROMPT_FILE"
  exit 1
fi

echo ""
echo "🔍 Pete Once — single interactive iteration"
if [ -n "$SUBFOLDER" ]; then
  echo "   Run: $SUBFOLDER"
fi
echo "----------------------------------------"

codex "$(cat "$PROMPT_FILE")"
