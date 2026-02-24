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
        emit "deny" "[FPF CREATIVE BLOCK] ${EDIT_COUNT} source edits without framing the problem. MUST invoke /fpf-problem-framing before continuing. (If trivial, write .fpf/.trivial-session to bypass.)"
    else
        emit "allow" "[FPF CREATIVE REMINDER] ${EDIT_COUNT} source edits without framing the problem. Consider /fpf-problem-framing."
    fi
fi

# --- Check: problem framing QUALITY (advisory) ---
if [ "$PROB_COUNT" -gt 0 ] && [ "$EDIT_COUNT" -ge 5 ]; then
    for PROB_FILE in $(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null); do
        HYP_COUNT=$(grep -cE '^### H[0-9]|^H[0-9]' "$PROB_FILE" 2>/dev/null || echo "0")
        HAS_TRADEOFF=$(grep -ciE 'trade.?off|trade off|tension|competing' "$PROB_FILE" 2>/dev/null || echo "0")
        if [ "$HYP_COUNT" -lt 2 ]; then
            emit "allow" "[FPF CREATIVE QUALITY] $(basename "$PROB_FILE") has <2 hypotheses. Problematization requires ≥2 hypotheses to avoid premature convergence."
        fi
        if [ "$HAS_TRADEOFF" -eq 0 ]; then
            emit "allow" "[FPF CREATIVE QUALITY] $(basename "$PROB_FILE") has no trade-off axes mentioned. If there's no trade-off, it's not on a frontier."
        fi
        break  # Check only the first PROB file to avoid spam
    done
fi

# --- Check: variant generation ---
if [ "$EDIT_COUNT" -ge 10 ]; then
    SPORT_COUNT=0
    if [ -d "$FPF_DIR/portfolios" ]; then
        SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [ "$SPORT_COUNT" -eq 0 ]; then
        if [ "$EDIT_COUNT" -ge 15 ]; then
            emit "deny" "[FPF CREATIVE BLOCK] ${EDIT_COUNT} source edits without generating solution variants. MUST invoke /fpf-variants to generate ≥3 alternatives. (If exploiting a known pattern, write .fpf/.trivial-session.)"
        else
            emit "allow" "[FPF CREATIVE REMINDER] ${EDIT_COUNT} source edits without generating variants. Consider /fpf-variants to generate ≥3 alternatives."
        fi
    fi

    # --- Check: variant QUALITY (advisory) ---
    if [ "$SPORT_COUNT" -gt 0 ]; then
        for SPORT_FILE in $(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null); do
            VARIANT_COUNT=$(grep -cE '^\| V[0-9]' "$SPORT_FILE" 2>/dev/null || echo "0")
            if [ "$VARIANT_COUNT" -lt 3 ]; then
                emit "allow" "[FPF CREATIVE QUALITY] $(basename "$SPORT_FILE") has <3 variants. Generate ≥3 genuinely distinct variants for a real Pareto front."
            fi
            break
        done
    fi
fi

# All checks passed
exit 0
