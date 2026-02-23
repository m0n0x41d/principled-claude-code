#!/usr/bin/env bash
# FPF artifact dependency enforcement — PreToolUse hook for Write and Edit
#
# Hard-denies creating downstream artifacts without upstream dependencies:
#   - SPORT-* (solution portfolios) require at least one CHR-* (characterization)
#   - SPORT-* (solution portfolios) require at least one STRAT-* (strategy card)
#   - SEL-* (selection records) require at least one SPORT-* (solution portfolio)
#
# Hook type: PreToolUse (matcher: Write|Edit)
# Exit 0 with JSON permissionDecision = allow/deny

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# If no file path (shouldn't happen for Write/Edit), allow
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
SESSION_ID="${CLAUDE_SESSION_ID:-}"

# Extract short prefix for file matching (first 8 chars of UUID)
SESSION_PREFIX="${SESSION_ID:0:8}"

# --- Check: SPORT-* requires CHR-* ---
if echo "$FILE_PATH" | grep -qE '/portfolios/SPORT-'; then
    CHR_COUNT=0
    if [ -d "$FPF_DIR/characterizations" ]; then
        CHR_COUNT=$(find "$FPF_DIR/characterizations" -name "CHR-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [ "$CHR_COUNT" -eq 0 ]; then
        REASON="[FPF DEPENDENCY BLOCK] Cannot create solution portfolio (SPORT-*) without a characterization passport. You MUST invoke /fpf-characterize first to create a CHR-* in .fpf/characterizations/. The characterization defines what indicators to compare variants against — without it, variant generation has no basis."

        jq -n --arg reason "$REASON" '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": $reason
            }
        }'
        exit 0
    fi

    # Also check for strategy card (STRAT-*)
    STRAT_COUNT=0
    if [ -d "$FPF_DIR/decisions" ]; then
        STRAT_COUNT=$(find "$FPF_DIR/decisions" -name "STRAT-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [ "$STRAT_COUNT" -eq 0 ]; then
        REASON="[FPF DEPENDENCY BLOCK] Cannot create solution portfolio (SPORT-*) without a strategy card. You MUST invoke /fpf-sota first — it now produces both a SoTA palette (SOTA-*) and a strategy card (STRAT-*) in .fpf/decisions/. The strategy card states which method family to bet on — without it, variant generation has no strategic direction."

        jq -n --arg reason "$REASON" '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": $reason
            }
        }'
        exit 0
    fi
fi

# --- Check: SEL-* requires SPORT-* ---
if echo "$FILE_PATH" | grep -qE '/decisions/SEL-'; then
    SPORT_COUNT=0
    if [ -d "$FPF_DIR/portfolios" ]; then
        SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [ "$SPORT_COUNT" -eq 0 ]; then
        REASON="[FPF DEPENDENCY BLOCK] Cannot create selection record (SEL-*) without a solution portfolio. You MUST invoke /fpf-variants first to create a SPORT-* in .fpf/portfolios/. Selection requires characterized variants to choose from."

        jq -n --arg reason "$REASON" '{
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": $reason
            }
        }'
        exit 0
    fi
fi

# All checks passed — allow
exit 0
