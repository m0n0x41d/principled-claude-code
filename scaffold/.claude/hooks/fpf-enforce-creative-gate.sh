#!/usr/bin/env bash
# FPF creative quality enforcement — PreToolUse hook for Write|Edit
#
# ADVISORY (allow + message). Checks creative quality constraints:
# - C2: PROB-* must have ≥3 hypotheses
# - C4: SPORT-* must have ≥3 variants
# - C5: SPORT-* must have ≥1 novel variant
# Also reminds about problem framing after ≥5 source edits.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Only check source files
case "$FILE_PATH" in
    */.fpf/* | */.claude/*)
        exit 0
        ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
COUNTER_FILE="$FPF_DIR/.source-edit-count"
EDIT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")

# Below threshold — allow silently
if [ "$EDIT_COUNT" -lt 5 ]; then
    exit 0
fi

REASON=""

# Check: source edits without problem framing
PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" -o -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PROB_COUNT" -eq 0 ]; then
    REASON="[FPF C1] ${EDIT_COUNT} source edits without problem framing. /fpf-problem-framing"
fi

# Check: ≥10 edits without variants
if [ "$EDIT_COUNT" -ge 10 ]; then
    SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SPORT_COUNT" -eq 0 ] && [ -z "$REASON" ]; then
        REASON="[FPF C4] ${EDIT_COUNT} source edits without variant generation. /fpf-variants"
    fi
fi

# Check creative quality on existing artifacts
if [ -d "$FPF_DIR/anomalies" ]; then
    for PROB_FILE in $(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null); do
        H_COUNT=$(grep -cE '^H[0-9]' "$PROB_FILE" 2>/dev/null || echo "0")
        if [ "$H_COUNT" -lt 3 ] && [ -z "$REASON" ]; then
            REASON="[FPF C2] $(basename "$PROB_FILE") has ${H_COUNT} hypotheses (need ≥3)."
            break
        fi
    done
fi

if [ -d "$FPF_DIR/portfolios" ]; then
    for SPORT_FILE in $(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null); do
        V_COUNT=$(grep -cE '^### V[0-9]' "$SPORT_FILE" 2>/dev/null || echo "0")
        if [ "$V_COUNT" -lt 3 ] && [ -z "$REASON" ]; then
            REASON="[FPF C4] $(basename "$SPORT_FILE") has ${V_COUNT} variants (need ≥3)."
            break
        fi
        NOVEL_COUNT=$(grep -ciE 'novel' "$SPORT_FILE" 2>/dev/null || echo "0")
        if [ "$NOVEL_COUNT" -eq 0 ] && [ -z "$REASON" ]; then
            REASON="[FPF C5] $(basename "$SPORT_FILE") has no novel variant marked."
            break
        fi
    done
fi

if [ -n "$REASON" ]; then
    jq -n --arg reason "$REASON" '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow",
            "permissionDecisionReason": $reason
        }
    }'
    exit 0
fi

exit 0
