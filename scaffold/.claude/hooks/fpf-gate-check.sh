#!/usr/bin/env bash
# FPF session-end quality gate — Stop hook
#
# Tier-aware checks before session end:
# - Worklog must exist (all tiers)
# - Source edits require evidence (T2+)
# - SPORT without SEL flagged (T3+)
#
# Exit 0 = allow, Exit 2 = block with feedback

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
WORKLOG_DIR="$FPF_DIR/worklog"
EVIDENCE_DIR="$FPF_DIR/evidence"
COUNTER_FILE="$FPF_DIR/.source-edit-count"
SESSION_ID="${CLAUDE_SESSION_ID:-}"
SESSION_PREFIX="${SESSION_ID:0:8}"

INPUT=$(cat)

# Only enforce for non-trivial sessions (>= 3 tool uses)
TOOL_USES=$(echo "$INPUT" | jq -r '.tool_use_count // 0' 2>/dev/null || echo "0")
if [ "$TOOL_USES" -lt 3 ]; then
    exit 0
fi

WARNINGS=""

# --- Check 1: Worklog exists (C10) ---
WORKLOG_EXISTS=false
if [ -d "$WORKLOG_DIR" ]; then
    if [ -n "$SESSION_ID" ]; then
        [ -f "$WORKLOG_DIR/session-${SESSION_ID}.md" ] && WORKLOG_EXISTS=true
    fi
    if [ "$WORKLOG_EXISTS" = false ]; then
        RECENT=$(find "$WORKLOG_DIR" -name "session-*.md" -mmin -720 2>/dev/null | head -1)
        [ -n "$RECENT" ] && WORKLOG_EXISTS=true
    fi
fi
if [ "$WORKLOG_EXISTS" = false ]; then
    WARNINGS="${WARNINGS}[C10] No session worklog. /fpf-review\n"
fi

# --- Check 2: Source edits require evidence (C6) ---
SOURCE_EDITS=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
if [ "$SOURCE_EDITS" -gt 0 ]; then
    EVID_FOUND=false
    if [ -d "$EVIDENCE_DIR" ]; then
        if [ -n "$SESSION_PREFIX" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
            [ "$(find "$EVIDENCE_DIR" -name "EVID-${SESSION_PREFIX}*" 2>/dev/null | wc -l | tr -d ' ')" -gt 0 ] && EVID_FOUND=true
        fi
        if [ "$EVID_FOUND" = false ]; then
            [ "$(find "$EVIDENCE_DIR" -name "EVID-*.md" -mmin -720 2>/dev/null | wc -l | tr -d ' ')" -gt 0 ] && EVID_FOUND=true
        fi
    fi
    if [ "$EVID_FOUND" = false ]; then
        WARNINGS="${WARNINGS}[C6] ${SOURCE_EDITS} source edits, no evidence record. /fpf-evidence\n"
    fi
fi

# --- Check 3: SPORT without SEL ---
if [ -d "$FPF_DIR/portfolios" ] && [ -n "$SESSION_PREFIX" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SPORT_COUNT" -gt 0 ]; then
        SEL_COUNT=0
        [ -d "$FPF_DIR/decisions" ] && SEL_COUNT=$(find "$FPF_DIR/decisions" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$SEL_COUNT" -eq 0 ]; then
            WARNINGS="${WARNINGS}[C8] Solution portfolio without selection record. /fpf-selection\n"
        fi
    fi
fi

# --- Emit ---
if [ -n "$WARNINGS" ]; then
    echo -e "FPF session-end checks:\n$WARNINGS" >&2
    echo "Fix or invoke /fpf-review." >&2
    exit 2
fi

exit 0
