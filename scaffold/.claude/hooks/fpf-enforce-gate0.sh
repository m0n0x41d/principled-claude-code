#!/usr/bin/env bash
# FPF Gate 0 enforcement — PreToolUse hook for Write and Edit
#
# Blocks source code modifications unless /fpf-core has been invoked
# (indicated by the presence of .fpf/.session-active sentinel).
#
# Hook type: PreToolUse (matcher: Write|Edit)
# Exit 0 with JSON permissionDecision = allow/deny
#
# Allowed without sentinel:
#   - Writes to .fpf/ (FPF artifacts — skills need to create these)
#   - Writes to .claude/ (hook/settings modifications)
#
# Blocked without sentinel:
#   - All other file modifications (source code, tests, docs, etc.)

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path (shouldn't happen for Write/Edit), allow
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
SENTINEL="$FPF_DIR/.session-active"

# Always allow writes to .fpf/ and .claude/ directories
case "$FILE_PATH" in
    */.fpf/* | */.claude/*)
        exit 0
        ;;
esac

# Check sentinel file exists and is not stale (< 6 hours old)
if [ -f "$SENTINEL" ]; then
    # On macOS, use stat -f %m; on Linux, stat -c %Y
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -lt 21600 ]; then
        # Sentinel exists and is fresh — allow
        exit 0
    fi
fi

# No valid sentinel — block the tool call
REASON="[FPF GATE 0 BLOCK] Cannot modify source code before session initialization. You MUST invoke /fpf-core first, then /fpf-worklog <goal>. This creates the session sentinel that unblocks code modifications."

# Use structured JSON output for denial
jq -n --arg reason "$REASON" '{
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason
    }
}'
