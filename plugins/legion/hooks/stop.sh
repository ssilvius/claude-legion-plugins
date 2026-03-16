#!/bin/bash
# Legion Stop hook: prompt the agent to reflect before closing
# Uses a CWD-based temp marker to prevent re-fires within the same session
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
  exit 0
fi

REPO=$(basename "$CWD")

# Prevent re-fires: marker is based on CWD hash so each agent session gets one prompt
MARKER="/tmp/legion-reflected-$(echo "$CWD" | md5 -q 2>/dev/null || echo "$CWD" | md5sum 2>/dev/null | cut -d' ' -f1)"
if [ -f "$MARKER" ]; then
  exit 0
fi

# Create marker. SessionStart hook cleans these up on next session.
touch "$MARKER"

jq -n --arg reason "Before you stop, reflect on this session. What would you tell another agent who hits this same problem tomorrow? Store your reflection with: legion reflect --repo $REPO --text '<your reflection here>'

Also before leaving: (1) If you recalled or consulted reflections that helped this session, boost them: legion boost --id <id>. (2) If you have unresolved questions another agent could answer, signal them: legion signal --repo $REPO --to <agent> --verb question --note '<your question>'" '{
  "decision": "block",
  "reason": $reason
}'
