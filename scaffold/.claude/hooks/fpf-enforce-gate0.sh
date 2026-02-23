#!/usr/bin/env bash
# FPF Gate 0 enforcement — PreToolUse hook for Write and Edit
#
# Blocks source code modifications unless:
#   1. Session sentinel exists and is fresh (< 12 hours)
#   2. Session worklog exists (Gate 0.2)
#
# Allowed without checks:
#   - Writes to .fpf/ (FPF artifacts)
#   - Writes to .claude/ (settings/skills)
#
# Hook type: PreToolUse (matcher: Write|Edit)

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
SENTINEL="$FPF_DIR/.session-active"

# Always allow writes to .fpf/ and .claude/
case "$FILE_PATH" in
    .fpf/* | */.fpf/* | .claude/* | */.claude/*)
        exit 0
        ;;
esac

deny() {
    jq -n --arg reason "$1" '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": $reason
        }
    }'
    exit 0
}

# Check sentinel exists and is fresh (< 12 hours)
if [ -f "$SENTINEL" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -ge 43200 ]; then
        deny "[FPF GATE 0 BLOCK] Session sentinel is stale (>12h). Invoke /fpf-core to start a new session."
    fi
else
    deny "[FPF GATE 0 BLOCK] Cannot modify source code before session initialization. MUST invoke /fpf-core first, then /fpf-worklog <goal>."
fi

# Sentinel fresh — also check worklog exists (Gate 0.2)
SESSION_ID="${CLAUDE_SESSION_ID:-}"
WORKLOG=""
if [ -n "$SESSION_ID" ]; then
    WORKLOG=$(find "$FPF_DIR/worklog" -name "session-${SESSION_ID}.md" 2>/dev/null | head -1)
fi
if [ -z "$WORKLOG" ]; then
    # Fallback: any recent worklog
    WORKLOG=$(find "$FPF_DIR/worklog" -name "session-*.md" -mmin -720 2>/dev/null | sort -r | head -1)
fi
if [ -z "$WORKLOG" ]; then
    deny "[FPF GATE 0.2 BLOCK] Session sentinel exists but no worklog. MUST invoke /fpf-worklog <goal> to create the audit trail before modifying source code."
fi

# All checks passed
exit 0
