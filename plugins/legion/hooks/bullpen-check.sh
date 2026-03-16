#!/bin/bash
# Legion PreToolUse hook: notify agent when there are unread board posts
# Only injects context when there is something to read.
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
  exit 0
fi

REPO=$(basename "$CWD")

# Check board for unread posts
BOARD_COUNT=$(legion bullpen --count --repo "$REPO" 2>/dev/null)
if [ -n "$BOARD_COUNT" ]; then
  jq -n --arg reason "[Legion] ${BOARD_COUNT}. Run legion bullpen --repo ${REPO} to read them." '{
    "decision": "allow",
    "reason": $reason
  }'
else
  exit 0
fi
