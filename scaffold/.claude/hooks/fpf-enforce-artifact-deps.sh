#!/usr/bin/env bash
# FPF artifact dependency enforcement — PreToolUse hook for Write and Edit
#
# Hard-denies creating downstream artifacts without upstream dependencies:
#   - STRAT-* requires SOTA-* (strategy requires SoTA survey)
#   - SPORT-* requires PROB/ANOM-* + CHR-* + STRAT-* (STRAT only for T4)
#   - SEL-* requires SPORT-* with ≥3 variants
#   - PPORT-* requires PROB/ANOM-*
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

# --- Check: SPORT-* requires PROB/ANOM + CHR + STRAT (session-scoped or recent) ---
if echo "$FILE_PATH" | grep -qE '/portfolios/SPORT-'; then
    SESSION_ID="${CLAUDE_SESSION_ID:-}"
    SESSION_PREFIX="${SESSION_ID:0:8}"

    # Problem framing — check session-scoped first, then recent (<12h)
    PROB_COUNT=0
    ANOM_COUNT=0
    CROSS_SESSION_PROB=false
    if [ -d "$FPF_DIR/anomalies" ]; then
        if [ -n "$SESSION_PREFIX" ] && [ "$SESSION_PREFIX" != "" ]; then
            PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            ANOM_COUNT=$(find "$FPF_DIR/anomalies" -name "ANOM-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$PROB_COUNT" -eq 0 ] && [ "$ANOM_COUNT" -eq 0 ]; then
            CROSS_SESSION_PROB=true
            PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" -mmin -720 2>/dev/null | wc -l | tr -d ' ')
            ANOM_COUNT=$(find "$FPF_DIR/anomalies" -name "ANOM-*.md" -mmin -720 2>/dev/null | wc -l | tr -d ' ')
        fi
    fi
    if [ "$PROB_COUNT" -eq 0 ] && [ "$ANOM_COUNT" -eq 0 ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create solution portfolio (SPORT-*) without a problem framing. MUST invoke /fpf-problem-framing first. Without a framed problem, variant generation has no acceptance spec."
    fi

    # Cross-session fallback: verify content references an existing problem card ID
    if [ "$CROSS_SESSION_PROB" = true ]; then
        CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')
        if [ -n "$CONTENT" ]; then
            REF_FOUND=false
            for ARTIFACT_FILE in $(find "$FPF_DIR/anomalies" \( -name "PROB-*.md" -o -name "ANOM-*.md" \) -mmin -720 2>/dev/null); do
                ARTIFACT_ID=$(basename "$ARTIFACT_FILE" .md)
                if echo "$CONTENT" | grep -qF "$ARTIFACT_ID"; then
                    REF_FOUND=true
                    break
                fi
            done
            if [ "$REF_FOUND" = false ]; then
                deny "[FPF DEPENDENCY BLOCK] Solution portfolio (SPORT-*) does not reference any existing problem card ID (PROB-*/ANOM-*). Cross-session artifacts MUST explicitly link to upstream dependencies."
            fi
        fi
    fi

    # Characterization — session-scoped or recent
    CHR_COUNT=0
    if [ -d "$FPF_DIR/characterizations" ]; then
        if [ -n "$SESSION_PREFIX" ] && [ "$SESSION_PREFIX" != "" ]; then
            CHR_COUNT=$(find "$FPF_DIR/characterizations" -name "CHR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$CHR_COUNT" -eq 0 ]; then
            CHR_COUNT=$(find "$FPF_DIR/characterizations" -name "CHR-*.md" -mmin -720 2>/dev/null | wc -l | tr -d ' ')
        fi
    fi
    if [ "$CHR_COUNT" -eq 0 ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create solution portfolio (SPORT-*) without a characterization passport. MUST invoke /fpf-characterize first."
    fi

    # Strategy — required for T4 only (T3 can generate variants without formal strategy)
    SESSION_TIER=""
    if [ -f "$FPF_DIR/.session-tier" ]; then
        SESSION_TIER=$(cat "$FPF_DIR/.session-tier" | tr -d '[:space:]')
    fi
    if [ "$SESSION_TIER" = "T4" ]; then
        STRAT_COUNT=0
        if [ -d "$FPF_DIR/decisions" ]; then
            if [ -n "$SESSION_PREFIX" ] && [ "$SESSION_PREFIX" != "" ]; then
                STRAT_COUNT=$(find "$FPF_DIR/decisions" -name "STRAT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            fi
            if [ "$STRAT_COUNT" -eq 0 ]; then
                STRAT_COUNT=$(find "$FPF_DIR/decisions" -name "STRAT-*.md" -mmin -720 2>/dev/null | wc -l | tr -d ' ')
            fi
        fi
        if [ "$STRAT_COUNT" -eq 0 ]; then
            deny "[FPF DEPENDENCY BLOCK] T4 session: cannot create solution portfolio (SPORT-*) without a strategy card. MUST invoke /fpf-strategize or /fpf-sota first."
        fi
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

# --- Check: PPORT-* requires PROB/ANOM-* (can't manage portfolio without problems) ---
if echo "$FILE_PATH" | grep -qE '/portfolios/PPORT-'; then
    PROB_COUNT=0
    ANOM_COUNT=0
    if [ -d "$FPF_DIR/anomalies" ]; then
        PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null | wc -l | tr -d ' ')
        ANOM_COUNT=$(find "$FPF_DIR/anomalies" -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$PROB_COUNT" -eq 0 ] && [ "$ANOM_COUNT" -eq 0 ]; then
        deny "[FPF DEPENDENCY BLOCK] Cannot create problem portfolio (PPORT-*) without problem cards. MUST invoke /fpf-problem-framing first."
    fi
fi

# All checks passed
exit 0
