#!/usr/bin/env bash
# FPF prompt reminder hook — fires on UserPromptSubmit
#
# Each reminder fires AT MOST ONCE per session (cooldown via .fpf/.reminder-state).
# This prevents context bloat from repeated messages.
#
# Hook type: UserPromptSubmit

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
source "$FPF_DIR/config.sh" 2>/dev/null || true
SENTINEL="$FPF_DIR/.session-active"
REMINDER_STATE="$FPF_DIR/.reminder-state"

# Helper: emit reminder only if not already shown this session
remind_once() {
    local KEY="$1"
    local MSG="$2"
    if [ -f "$REMINDER_STATE" ] && grep -qF "$KEY" "$REMINDER_STATE" 2>/dev/null; then
        return  # Already shown
    fi
    echo "$KEY" >> "$REMINDER_STATE"
    echo "$MSG"
}

# No sentinel — Gate 0 reminder (always show, no cooldown for this one)
if [ ! -f "$SENTINEL" ]; then
    echo "[G0] Session not initialized. Run /fpf-core then /fpf-worklog."
    exit 0
fi

# Check sentinel freshness
if [[ "$(uname)" == "Darwin" ]]; then
    FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
else
    FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
fi
if [ "$FILE_AGE" -ge ${FPF_SENTINEL_MAX_AGE:-43200} ]; then
    echo "[G0] Stale session (>12h). Run /fpf-core."
    exit 0
fi

SESSION_ID="${CLAUDE_SESSION_ID:-}"
SESSION_PREFIX="${SESSION_ID:0:8}"

# PROB without CHR
if [ -d "$FPF_DIR/anomalies" ]; then
    PROB_COUNT=$(find "$FPF_DIR/anomalies" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    CHR_COUNT=0
    if [ -d "$FPF_DIR/characterizations" ]; then
        CHR_COUNT=$(find "$FPF_DIR/characterizations" -name "CHR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$PROB_COUNT" -gt 0 ] && [ "$CHR_COUNT" -eq 0 ]; then
        remind_once "no-chr" "[FPF] PROB exists, no CHR. Consider /fpf-characterize."
    fi
fi

# SPORT without SEL
if [ -d "$FPF_DIR/portfolios" ]; then
    SPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    SEL_COUNT=0
    if [ -d "$FPF_DIR/decisions" ]; then
        SEL_COUNT=$(find "$FPF_DIR/decisions" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$SPORT_COUNT" -gt 0 ] && [ "$SEL_COUNT" -eq 0 ]; then
        remind_once "no-sel" "[FPF] SPORT exists, no SEL. Consider /fpf-selection."
    fi
fi

# Multiple problems without portfolio
if [ -d "$FPF_DIR/anomalies" ]; then
    ANOM_PROB_COUNT=$(find "$FPF_DIR/anomalies" \( -name "PROB-${SESSION_PREFIX}*.md" -o -name "ANOM-${SESSION_PREFIX}*.md" \) 2>/dev/null | wc -l | tr -d ' ')
    PPORT_COUNT=0
    if [ -d "$FPF_DIR/portfolios" ]; then
        PPORT_COUNT=$(find "$FPF_DIR/portfolios" -name "PPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$ANOM_PROB_COUNT" -gt 1 ] && [ "$PPORT_COUNT" -eq 0 ]; then
        remind_once "no-pport" "[FPF] Multiple problems, no PPORT. Consider /fpf-problem-portfolio."
    fi
fi

# Source edits without problem framing
EDIT_COUNT=$(cat "$FPF_DIR/.source-edit-count" 2>/dev/null || echo "0")
PROB_ANY=0
ANOM_ANY=0
if [ -d "$FPF_DIR/anomalies" ]; then
    PROB_ANY=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" 2>/dev/null | wc -l | tr -d ' ')
    ANOM_ANY=$(find "$FPF_DIR/anomalies" -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$EDIT_COUNT" -ge 3 ] && [ "$PROB_ANY" -eq 0 ] && [ "$ANOM_ANY" -eq 0 ]; then
    remind_once "no-prob" "[FPF] ${EDIT_COUNT} edits, no PROB/ANOM. Consider /fpf-problem-framing."
fi

# SPORT without SoTA
SPORT_ANY=0
if [ -d "$FPF_DIR/portfolios" ]; then
    SPORT_ANY=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
SOTA_COUNT=0
if [ -d "$FPF_DIR/characterizations" ]; then
    SOTA_COUNT=$(find "$FPF_DIR/characterizations" -name "SOTA-*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$SPORT_ANY" -gt 0 ] && [ "$SOTA_COUNT" -eq 0 ]; then
    remind_once "no-sota" "[FPF] SPORT exists, no SOTA. Consider /fpf-sota."
fi

# Refuted evidence without problem update
if [ -d "$FPF_DIR/evidence" ]; then
    REFUTED=$( (grep -rl 'Result:.*refuted' "$FPF_DIR/evidence/" 2>/dev/null || true) | wc -l | tr -d ' ')
    if [ "$REFUTED" -gt 0 ]; then
        remind_once "refuted" "[FPF] Refuted EVID exists. Update PROB or create ANOM."
    fi
fi

# Legacy CL labels
if [ -d "$FPF_DIR/glossary/bridges" ]; then
    BAD_BRIDGES=$( (grep -rl 'Exact\|Equivalent\|Approximate\|Metaphor' "$FPF_DIR/glossary/bridges/" 2>/dev/null || true) | wc -l | tr -d ' ')
    if [ "$BAD_BRIDGES" -gt 0 ]; then
        remind_once "legacy-cl" "[FPF] Bridge cards using legacy CL labels. Update to CL 0-3."
    fi
fi

exit 0
