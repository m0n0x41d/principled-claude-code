#!/usr/bin/env bash
# FPF Gate 0 enforcement — PreToolUse hook for side-effect tools
#
# Blocks Bash, Task, WebFetch, WebSearch unless sentinel exists.
# Read-only research (Read, Glob, Grep) is ALLOWED without sentinel
# so that lightweight research sessions are not blocked.
#
# Hook type: PreToolUse (matcher: Bash|Task|WebFetch|WebSearch)

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
source "$FPF_DIR/config.sh" 2>/dev/null || true
SENTINEL="$FPF_DIR/.session-active"

# Check sentinel file exists and is not stale (< 12 hours old)
if [ -f "$SENTINEL" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -lt ${FPF_SENTINEL_MAX_AGE:-43200} ]; then
        exit 0
    fi
fi

# No valid sentinel — block the tool call
REASON="[G0] Run /fpf-core then /fpf-worklog."

jq -n --arg reason "$REASON" '{
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason
    }
}'
