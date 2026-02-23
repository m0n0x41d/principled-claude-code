#!/usr/bin/env bash
# FPF Gate 0 enforcement — PreToolUse hook for research tools
#
# Blocks ALL substantive tool use (Read, Glob, Grep, Bash, Task,
# WebFetch, WebSearch) unless /fpf-core has been invoked (sentinel exists).
#
# This closes the loophole where Claude can do unlimited research
# without initializing FPF, then rationalize skipping Gate 0.
#
# Hook type: PreToolUse (matcher: Read|Glob|Grep|Bash|Task|WebFetch|WebSearch)
# Exit 0 with JSON permissionDecision = allow/deny
#
# Allowed without sentinel:
#   - Reads of .fpf/ files (skills need to read templates)
#   - Reads of .claude/ files (settings, skill definitions)
#
# Blocked without sentinel:
#   - All other reads, searches, commands, and subagent launches

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
PATTERN=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
SENTINEL="$FPF_DIR/.session-active"

# Allow reads/globs targeting .fpf/ or .claude/ (needed for skill bootstrapping)
if [ -n "$FILE_PATH" ]; then
    case "$FILE_PATH" in
        */.fpf/* | */.claude/*)
            exit 0
            ;;
    esac
fi

# For Glob: check if the path argument points to .fpf/ or .claude/
if [ "$TOOL_NAME" = "Glob" ] && [ -n "$FILE_PATH" ]; then
    case "$FILE_PATH" in
        */.fpf/* | */.claude/*)
            exit 0
            ;;
    esac
fi

# Check sentinel file exists and is not stale (< 12 hours old)
if [ -f "$SENTINEL" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -lt 43200 ]; then
        # Sentinel exists and is fresh — allow
        exit 0
    fi
fi

# No valid sentinel — block the tool call
REASON="[FPF GATE 0 BLOCK] Cannot use ${TOOL_NAME} before session initialization. You MUST invoke /fpf-core first (creates sentinel), then /fpf-worklog <goal> (creates audit trail). No research, no commands, no reading — initialize first."

jq -n --arg reason "$REASON" '{
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason
    }
}'
