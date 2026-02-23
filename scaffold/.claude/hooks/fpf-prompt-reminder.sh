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
        # Session is active — check for missing artifacts and inject reminders
        FPF_DIR="$PROJECT_DIR/.fpf"
        SESSION_ID="${CLAUDE_SESSION_ID:-}"
        SESSION_PREFIX="${SESSION_ID:0:8}"
        REMINDERS=""

        # Check: PROB-* exists but no CHR-*
        if [ -d "$FPF_DIR/anomalies" ] && [ -d "$FPF_DIR/characterizations" ]; then
            PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            CHR_COUNT=$(find "$FPF_DIR/characterizations" -name "CHR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$PROB_COUNT" -gt 0 ] && [ "$CHR_COUNT" -eq 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Problem card exists but no characterization. Consider /fpf-characterize before generating variants.\n"
            fi
        fi

        # Check: SPORT-* exists but no SEL-*
        if [ -d "$FPF_DIR/portfolios" ] && [ -d "$FPF_DIR/decisions" ]; then
            SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            SEL_COUNT=$(find "$FPF_DIR/decisions" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$SPORT_COUNT" -gt 0 ] && [ "$SEL_COUNT" -eq 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Solution portfolio exists but no selection record. Consider /fpf-selection.\n"
            fi
        fi

        # Check: Multiple ANOM-*/PROB-* but no PPORT-*
        if [ -d "$FPF_DIR/anomalies" ]; then
            ANOM_PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "*-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            PPORT_COUNT=0
            if [ -d "$FPF_DIR/portfolios" ]; then
                PPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "PPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            fi
            if [ "$ANOM_PROB_COUNT" -gt 1 ] && [ "$PPORT_COUNT" -eq 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Multiple anomaly/problem records but no problem portfolio. Consider /fpf-problem-portfolio.\n"
            fi
        fi

        # Check: Bridge cards without CL 0-3 field
        if [ -d "$FPF_DIR/glossary/bridges" ]; then
            BAD_BRIDGES=$(grep -rl 'Exact\|Equivalent\|Approximate\|Metaphor' "$FPF_DIR/glossary/bridges/" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$BAD_BRIDGES" -gt 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Bridge cards using legacy CL labels (Exact/Equivalent/Approximate/Metaphor). Update to CL 0-3 scale per F.9.\n"
            fi
        fi

        if [ -n "$REMINDERS" ]; then
            echo -e "$REMINDERS"
        fi
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
