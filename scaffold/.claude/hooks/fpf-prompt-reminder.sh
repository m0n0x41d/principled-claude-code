#!/usr/bin/env bash
# FPF Session Start reminder hook
#
# Fires on UserPromptSubmit. If no sentinel: inject Gate 0 reminder.
# If sentinel exists: check for missing artifacts and inject targeted reminders.
#
# Hook type: UserPromptSubmit

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SENTINEL="$PROJECT_DIR/.fpf/.session-active"

# If sentinel exists and is fresh (< 12 hours), check for gaps
if [ -f "$SENTINEL" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -lt 43200 ]; then
        FPF_DIR="$PROJECT_DIR/.fpf"
        SESSION_ID="${CLAUDE_SESSION_ID:-}"
        SESSION_PREFIX="${SESSION_ID:0:8}"
        REMINDERS=""

        # PROB-* without CHR-*
        if [ -d "$FPF_DIR/anomalies" ] && [ -d "$FPF_DIR/characterizations" ]; then
            PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            CHR_COUNT=$(find "$FPF_DIR/characterizations" -name "CHR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$PROB_COUNT" -gt 0 ] && [ "$CHR_COUNT" -eq 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Problem card exists but no characterization. Consider /fpf-characterize before generating variants.\n"
            fi
        fi

        # SPORT-* without SEL-*
        if [ -d "$FPF_DIR/portfolios" ] && [ -d "$FPF_DIR/decisions" ]; then
            SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            SEL_COUNT=$(find "$FPF_DIR/decisions" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$SPORT_COUNT" -gt 0 ] && [ "$SEL_COUNT" -eq 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Solution portfolio exists but no selection record. Consider /fpf-selection.\n"
            fi
        fi

        # Multiple problems without portfolio
        if [ -d "$FPF_DIR/anomalies" ]; then
            ANOM_PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "*-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            PPORT_COUNT=0
            if [ -d "$FPF_DIR/portfolios" ]; then
                PPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "PPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            fi
            if [ "$ANOM_PROB_COUNT" -gt 1 ] && [ "$PPORT_COUNT" -eq 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Multiple problem records but no problem portfolio. Consider /fpf-problem-portfolio.\n"
            fi
        fi

        # Source edits without problem framing
        COUNTER_FILE="$FPF_DIR/.source-edit-count"
        EDIT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
        PROB_ANY=0
        ANOM_ANY=0
        if [ -d "$FPF_DIR/anomalies" ]; then
            PROB_ANY=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null | wc -l | tr -d ' ')
            ANOM_ANY=$(find "$FPF_DIR/anomalies" -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$EDIT_COUNT" -ge 3 ] && [ "$PROB_ANY" -eq 0 ] && [ "$ANOM_ANY" -eq 0 ]; then
            REMINDERS="${REMINDERS}[FPF CREATIVE] Source edits but no problem framed. What problem are you solving? /fpf-problem-framing — problematization is creative, not bureaucracy.\n"
        fi

        # SPORT without SoTA
        SOTA_COUNT=0
        if [ -d "$FPF_DIR/characterizations" ]; then
            SOTA_COUNT=$(find "$FPF_DIR/characterizations" -name "SOTA-*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        SPORT_ANY=0
        if [ -d "$FPF_DIR/portfolios" ]; then
            SPORT_ANY=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$SPORT_ANY" -gt 0 ] && [ "$SOTA_COUNT" -eq 0 ]; then
            REMINDERS="${REMINDERS}[FPF CREATIVE] Variants generated without SoTA survey. Consider /fpf-sota — survey what exists before strategizing.\n"
        fi

        # Feedback loop: refuted evidence without problem update
        if [ -d "$FPF_DIR/evidence" ]; then
            REFUTED=$( (grep -rl 'Result:.*refuted' "$FPF_DIR/evidence/" 2>/dev/null || true) | wc -l | tr -d ' ')
            if [ "$REFUTED" -gt 0 ]; then
                REMINDERS="${REMINDERS}[FPF FEEDBACK] Refuted evidence exists. Did you feed this back to the problem factory? Update PROB-* or create new ANOM-*.\n"
            fi
        fi

        # Legacy CL labels
        if [ -d "$FPF_DIR/glossary/bridges" ]; then
            BAD_BRIDGES=$( (grep -rl 'Exact\|Equivalent\|Approximate\|Metaphor' "$FPF_DIR/glossary/bridges/" 2>/dev/null || true) | wc -l | tr -d ' ')
            if [ "$BAD_BRIDGES" -gt 0 ]; then
                REMINDERS="${REMINDERS}[FPF] Bridge cards using legacy CL labels. Update to CL 0-3.\n"
            fi
        fi

        if [ -n "$REMINDERS" ]; then
            echo -e "$REMINDERS"
        fi
        exit 0
    fi
fi

# No sentinel — inject Gate 0 reminder
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
