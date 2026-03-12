#!/bin/bash

# -----------------------------------------------
# PETE ONCE — Human-in-the-loop single iteration
# Usage: ./pete/pete-once.sh
# -----------------------------------------------

echo ""
echo "🔍 Pete Once — single interactive iteration"
echo "----------------------------------------"

claude "$(cat pete/PROMPT.md)"
