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
SENTINEL="$FPF_DIR/.session-active"

# Check sentinel file exists and is not stale (< 12 hours old)
if [ -f "$SENTINEL" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -lt 43200 ]; then
        exit 0
    fi
fi

# No valid sentinel — block the tool call
REASON="[FPF GATE 0 BLOCK] Cannot use ${TOOL_NAME} before session initialization. Read/Glob/Grep are allowed for lightweight research, but ${TOOL_NAME} requires /fpf-core first, then /fpf-worklog <goal>."

jq -n --arg reason "$REASON" '{
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason
    }
}'
