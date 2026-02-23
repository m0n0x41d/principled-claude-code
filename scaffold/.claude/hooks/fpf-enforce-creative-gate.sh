#!/usr/bin/env bash
# FPF creative-side enforcement — PreToolUse hook for Write and Edit
#
# ESCALATING enforcement when implementing source code
# without having framed the problem or generated variants.
#
# Problem framing thresholds (edits without PROB/ANOM):
#   ≥5:  advisory reminder
#   ≥8:  HARD BLOCK — must frame problem before continuing
#
# Variant generation thresholds (edits without SPORT):
#   ≥10: advisory reminder
#   ≥15: HARD BLOCK — must generate variants
#
# Trivial session override: .fpf/.trivial-session bypasses all creative checks.
#
# Hook type: PreToolUse (matcher: Write|Edit)

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Only check source files (not .fpf/ or .claude/ artifacts)
case "$FILE_PATH" in
    .fpf/* | */.fpf/* | .claude/* | */.claude/*)
        exit 0
        ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
COUNTER_FILE="$FPF_DIR/.source-edit-count"

# Trivial session bypass
if [ -f "$FPF_DIR/.trivial-session" ]; then
    exit 0
fi

# Read current edit count
EDIT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")

# Below threshold — allow silently
if [ "$EDIT_COUNT" -lt 5 ]; then
    exit 0
fi

# Helper: emit JSON decision
emit() {
    local DECISION="$1"
    local REASON="$2"
    jq -n --arg decision "$DECISION" --arg reason "$REASON" '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": $decision,
            "permissionDecisionReason": $reason
        }
    }'
    exit 0
}

# --- Check: problem framing ---
PROB_COUNT=0
ANOM_COUNT=0
if [ -d "$FPF_DIR/anomalies" ]; then
    PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null | wc -l | tr -d ' ')
    ANOM_COUNT=$(find "$FPF_DIR/anomalies" -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$PROB_COUNT" -eq 0 ] && [ "$ANOM_COUNT" -eq 0 ]; then
    if [ "$EDIT_COUNT" -ge 8 ]; then
        emit "deny" "[FPF CREATIVE BLOCK] ${EDIT_COUNT} source edits without framing the problem. You are implementing without knowing what problem you're solving or how you'll know it's solved. MUST invoke /fpf-problem-framing before continuing. Problematization is creative discipline — design the problem, then solve it. (If this is truly trivial, write .fpf/.trivial-session to bypass.)"
    else
        emit "allow" "[FPF CREATIVE REMINDER] ${EDIT_COUNT} source edits without framing the problem. What problem are you solving? How will you know it's solved? Consider /fpf-problem-framing."
    fi
fi

# --- Check: variant generation ---
if [ "$EDIT_COUNT" -ge 10 ]; then
    SPORT_COUNT=0
    if [ -d "$FPF_DIR/portfolios" ]; then
        SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [ "$SPORT_COUNT" -eq 0 ]; then
        if [ "$EDIT_COUNT" -ge 15 ]; then
            emit "deny" "[FPF CREATIVE BLOCK] ${EDIT_COUNT} source edits without generating solution variants. You are deep into the first idea without exploring alternatives. MUST invoke /fpf-variants to generate ≥3 alternatives. (If exploiting a known pattern, write .fpf/.trivial-session.)"
        else
            emit "allow" "[FPF CREATIVE REMINDER] ${EDIT_COUNT} source edits without generating variants. Are you implementing the first idea? Consider /fpf-variants to generate ≥3 alternatives."
        fi
    fi
fi

# All checks passed
exit 0
