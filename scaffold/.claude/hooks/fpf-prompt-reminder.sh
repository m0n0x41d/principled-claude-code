#!/usr/bin/env bash
# FPF Session Start reminder hook
#
# This hook fires on UserPromptSubmit and injects a reminder about FPF
# workflow if the session sentinel doesn't exist yet. Works alongside
# the PreToolUse hard gate (fpf-enforce-gate0.sh).
#
# Hook type: UserPromptSubmit
# Exit 0 with stdout = inject context into Claude's prompt processing

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SENTINEL="$PROJECT_DIR/.fpf/.session-active"

# If sentinel exists and is fresh (< 6 hours), session is initialized
if [ -f "$SENTINEL" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -lt 21600 ]; then
        exit 0
    fi
fi

# No sentinel — inject reminder
cat <<'REMINDER'
[FPF GATE 0 — SESSION NOT INITIALIZED]

The session sentinel (.fpf/.session-active) does not exist.
ALL tool use (Read, Write, Edit, Glob, Grep, Bash, Task, WebFetch, WebSearch)
is BLOCKED by PreToolUse hooks until you complete Gate 0:

  1. MUST invoke /fpf-core (this writes the sentinel and unblocks all tools)
  2. MUST invoke /fpf-worklog <goal> (this creates the audit trail)
  3. Only then may you begin ANY work — reading, searching, editing, commands

This is a MECHANICAL gate, not advisory. Tool calls outside .fpf/ and .claude/
will be denied with an error until the sentinel exists.

There are NO exceptions. Not for "trivial questions", not for "just research",
not for "quick looks". Initialize first, work second.
REMINDER

exit 0
