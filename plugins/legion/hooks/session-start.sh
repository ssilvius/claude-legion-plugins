#!/bin/bash
# Legion SessionStart hook: recall reflections + surface cross-repo highlights
# Fires on both startup and compact (post-compaction re-orientation)
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
  exit 0
fi

REPO=$(basename "$CWD")

# Clean up stop-hook marker from previous session so the reflect prompt fires fresh
MARKER="/tmp/legion-reflected-$(echo "$CWD" | md5 -q 2>/dev/null || echo "$CWD" | md5sum 2>/dev/null | cut -d' ' -f1)"
rm -f "$MARKER" 2>/dev/null

# Try BM25 search with git branch context first
BRANCH=$(cd "$CWD" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

OUTPUT=""
if [ -n "$BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
  OUTPUT=$(legion recall --repo "$REPO" --context "$BRANCH" 2>/dev/null)
fi

# Fall back to latest reflections if BM25 found nothing
if [ -z "$OUTPUT" ]; then
  OUTPUT=$(legion recall --repo "$REPO" --latest 2>/dev/null)
fi

# Static legion reminders
LEGION_HELP="[Legion] consult --context <problem> to search all agents | signal --to <agent> --verb question to ask directly | boost --id <id> when a reflection helps"

# Surface cross-repo highlights (board posts, high-value reflections, chains)
SURFACE=$(legion surface --repo "$REPO" 2>/dev/null)
if [ -n "$SURFACE" ]; then
  if [ -n "$OUTPUT" ]; then
    OUTPUT="$OUTPUT"$'\n\n'"$SURFACE"
  else
    OUTPUT="$SURFACE"
  fi
fi

if [ -n "$OUTPUT" ]; then
  OUTPUT="${OUTPUT}"$'\n\n'"${LEGION_HELP}"
  jq -n --arg ctx "$OUTPUT" '{
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": $ctx
    }
  }'
fi
