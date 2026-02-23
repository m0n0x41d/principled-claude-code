#!/usr/bin/env bash
# FPF artifact dependency enforcement — PreToolUse hook for Write and Edit
#
# Hard-denies creating downstream artifacts without upstream dependencies:
#   - STRAT-* requires SOTA-* (strategy requires SoTA survey)
#   - SPORT-* requires PROB/ANOM-* + CHR-* + STRAT-*
#   - SEL-* requires SPORT-* with ≥3 variants
#
# Hook type: PreToolUse (matcher: Write|Edit)
# Exit 0 with JSON permissionDecision = allow/deny

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"

deny() {
    jq -n --arg reason "$1" '{
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": $reason
        }
    }'
    exit 0
}

# --- Check: STRAT-* requires SOTA-* ---
if echo "$FILE_PATH" | grep -qE '/decisions/STRAT-'; then
    SOTA_COUNT=0
    if [ -d "$FPF_DIR/characterizations" ]; then
        SOTA_COUNT=$(find "$FPF_DIR/characterizations" -name "SOTA-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$SOTA_COUNT" -eq 0 ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create strategy card (STRAT-*) without a SoTA survey. MUST invoke /fpf-sota first to survey existing approaches. Strategy without SoTA is uninformed betting."
    fi
fi

# --- Check: SPORT-* requires PROB/ANOM + CHR + STRAT ---
if echo "$FILE_PATH" | grep -qE '/portfolios/SPORT-'; then
    # Problem framing
    PROB_COUNT=0
    ANOM_COUNT=0
    if [ -d "$FPF_DIR/anomalies" ]; then
        PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null | wc -l | tr -d ' ')
        ANOM_COUNT=$(find "$FPF_DIR/anomalies" -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$PROB_COUNT" -eq 0 ] && [ "$ANOM_COUNT" -eq 0 ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create solution portfolio (SPORT-*) without a problem framing. MUST invoke /fpf-problem-framing first. Without a framed problem, variant generation has no acceptance spec."
    fi

    # Characterization
    CHR_COUNT=0
    if [ -d "$FPF_DIR/characterizations" ]; then
        CHR_COUNT=$(find "$FPF_DIR/characterizations" -name "CHR-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$CHR_COUNT" -eq 0 ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create solution portfolio (SPORT-*) without a characterization passport. MUST invoke /fpf-characterize first."
    fi

    # Strategy
    STRAT_COUNT=0
    if [ -d "$FPF_DIR/decisions" ]; then
        STRAT_COUNT=$(find "$FPF_DIR/decisions" -name "STRAT-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$STRAT_COUNT" -eq 0 ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create solution portfolio (SPORT-*) without a strategy card. MUST invoke /fpf-sota first — it produces SOTA-* and STRAT-*."
    fi
fi

# --- Check: SEL-* requires SPORT-* with ≥3 variants ---
if echo "$FILE_PATH" | grep -qE '/decisions/SEL-'; then
    SPORT_FILE=""
    if [ -d "$FPF_DIR/portfolios" ]; then
        SPORT_FILE=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | head -1)
    fi

    if [ -z "$SPORT_FILE" ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create selection record (SEL-*) without a solution portfolio. MUST invoke /fpf-variants first."
    fi

    # Count variants: table rows starting with "| V" or headings "### V"
    VARIANT_COUNT=$(grep -cE '^\| V[0-9]|^### V[0-9]' "$SPORT_FILE" 2>/dev/null || echo "0")
    if [ "$VARIANT_COUNT" -lt 3 ]; then
        deny "[FPF DEPENDENCY BLOCK] Solution portfolio has only ${VARIANT_COUNT} variant(s), need ≥3. Update SPORT-* with more genuinely distinct variants before selecting."
    fi
fi

# All checks passed
exit 0
