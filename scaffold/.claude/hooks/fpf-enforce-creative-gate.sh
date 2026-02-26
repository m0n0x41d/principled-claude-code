#!/usr/bin/env bash
# FPF creative-side enforcement — PreToolUse hook for Write and Edit
#
# TIER-AWARE enforcement when implementing source code
# without having framed the problem or generated variants.
#
# Reads .fpf/.session-tier to determine enforcement level:
#   T1/T2: no creative checks (trivial/localized)
#   T3+:   hard enforcement of creative quality
#
# Problem framing thresholds (edits without PROB/ANOM):
#   ≥5:  advisory reminder (all tiers)
#   ≥8:  HARD BLOCK for T3+ — must frame problem before continuing
#
# Variant generation thresholds (edits without SPORT):
#   ≥10: advisory reminder (all tiers)
#   ≥15: HARD BLOCK for T3+ — must generate variants
#
# Creative quality checks for T3+ (HARD BLOCK):
#   - PROB-* must have ≥3 hypotheses (not just ≥2)
#   - PROB-* must mention trade-off/tension
#   - SPORT-* must have ≥3 variants
#   - STRAT-* must have invalidation conditions (T4 only)
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
source "$FPF_DIR/config.sh" 2>/dev/null || true
COUNTER_FILE="$FPF_DIR/.source-edit-count"
TIER_FILE="$FPF_DIR/.session-tier"

# Trivial session bypass
if [ -f "$FPF_DIR/.trivial-session" ]; then
    exit 0
fi

# Read session tier (default T3 if not set)
TIER=$(cat "$TIER_FILE" 2>/dev/null || echo "T3")

# T1/T2: no creative checks at all
case "$TIER" in
    T1|T2) exit 0 ;;
esac

# Read current edit count
EDIT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")

# Below threshold — allow silently
if [ "$EDIT_COUNT" -lt "${FPF_EDIT_PROB_WARN:-5}" ]; then
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

# --- Check: problem framing existence ---
PROB_COUNT=0
ANOM_COUNT=0
if [ -d "$FPF_DIR/anomalies" ]; then
    PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null | wc -l | tr -d ' ')
    ANOM_COUNT=$(find "$FPF_DIR/anomalies" -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$PROB_COUNT" -eq 0 ] && [ "$ANOM_COUNT" -eq 0 ]; then
    if [ "$EDIT_COUNT" -ge "${FPF_EDIT_PROB_BLOCK:-8}" ]; then
        emit "deny" "[C5] ${EDIT_COUNT} edits, no PROB/ANOM. Run /fpf-problem-framing."
    else
        emit "allow" "[WARN] ${EDIT_COUNT} edits without PROB/ANOM. Consider /fpf-problem-framing."
    fi
fi

# --- Check: problem framing QUALITY (HARD for T3+) ---
if [ "$PROB_COUNT" -gt 0 ] && [ "$EDIT_COUNT" -ge "${FPF_EDIT_PROB_WARN:-5}" ]; then
    for PROB_FILE in $(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null | sort -r); do
        HYP_COUNT=$(grep -cE '^\*{0,2}#*\s*H[0-9]|^H[0-9]' "$PROB_FILE" 2>/dev/null || echo "0")
        HAS_TRADEOFF=$(grep -ciE 'trade.?off|trade off|tension|competing|versus|vs\.' "$PROB_FILE" 2>/dev/null || echo "0")

        if [ "$HYP_COUNT" -lt 3 ]; then
            emit "deny" "[C1] PROB has ${HYP_COUNT} hypotheses, need ≥3. Add more to PROB."
        fi

        if [ "$HAS_TRADEOFF" -eq 0 ]; then
            emit "deny" "[C1] PROB has no trade-off axes. Add trade-offs or demote tier."
        fi
        break  # Check only the most recent PROB file
    done
fi

# --- Check: variant generation ---
if [ "$EDIT_COUNT" -ge "${FPF_EDIT_VARIANT_WARN:-10}" ]; then
    SPORT_COUNT=0
    if [ -d "$FPF_DIR/portfolios" ]; then
        SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [ "$SPORT_COUNT" -eq 0 ]; then
        if [ "$EDIT_COUNT" -ge "${FPF_EDIT_VARIANT_BLOCK:-15}" ]; then
            emit "deny" "[C2] ${EDIT_COUNT} edits, no SPORT. Run /fpf-variants."
        else
            emit "allow" "[WARN] ${EDIT_COUNT} edits without SPORT. Consider /fpf-variants."
        fi
    fi

    # --- Check: variant QUALITY (HARD for T3+) ---
    if [ "$SPORT_COUNT" -gt 0 ]; then
        for SPORT_FILE in $(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | sort -r); do
            VARIANT_COUNT=$(grep -cE '^\| V[0-9]|^#{1,4}\s*V[0-9]|^\*{1,2}V[0-9]|^[-*]\s*V[0-9]|^V[0-9][.:)]' "$SPORT_FILE" 2>/dev/null || echo "0")
            if [ "$VARIANT_COUNT" -lt 3 ]; then
                emit "deny" "[C2] SPORT has ${VARIANT_COUNT} variants, need ≥3."
            fi
            break
        done
    fi
fi

# --- Check: T4-specific: strategy invalidation conditions ---
if [ "$TIER" = "T4" ] && [ "$EDIT_COUNT" -ge "${FPF_EDIT_PROB_WARN:-5}" ]; then
    if [ -d "$FPF_DIR/decisions" ]; then
        for STRAT_FILE in $(find "$FPF_DIR/decisions" -name "STRAT-*.md" 2>/dev/null | sort -r); do
            HAS_INVALIDATION=$(grep -ciE 'invalidat|pivot|would cause' "$STRAT_FILE" 2>/dev/null || echo "0")
            if [ "$HAS_INVALIDATION" -eq 0 ]; then
                emit "deny" "[C4] STRAT has no invalidation conditions. Add pivot criteria."
            fi
            break
        done
    fi
fi

# All checks passed
exit 0
