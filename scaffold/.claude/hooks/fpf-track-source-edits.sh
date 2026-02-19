#!/usr/bin/env bash
# FPF source edit tracker — PostToolUse hook for Write and Edit
#
# Counts source code modifications (files outside .fpf/ and .claude/)
# so the Stop hook can enforce Gate 2: if source edits happened,
# an evidence record must exist before session end.
#
# Hook type: PostToolUse (matcher: Write|Edit)
# Exit 0 always (tracking only, never blocks)

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path, nothing to track
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Only count source files (not .fpf/ or .claude/ artifacts)
case "$FILE_PATH" in
    */.fpf/* | */.claude/*)
        exit 0
        ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
COUNTER_FILE="$PROJECT_DIR/.fpf/.source-edit-count"

# Increment counter (create if missing)
CURRENT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
echo $(( CURRENT + 1 )) > "$COUNTER_FILE"

exit 0
