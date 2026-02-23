#!/usr/bin/env bash
# FPF prompt reminder — UserPromptSubmit hook
# Injects brief reminders about missing artifacts.
# Exit 0 with stdout = injected context.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SENTINEL="$PROJECT_DIR/.fpf/.session-active"

# Check sentinel freshness
if [ -f "$SENTINEL" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
        FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
    else
        FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
    fi

    if [ "$FILE_AGE" -lt 43200 ]; then
        # Session active — check for missing artifact chains
        FPF_DIR="$PROJECT_DIR/.fpf"
        REMINDERS=""

        # Source edits without problem framing (C1)
        EDIT_COUNT=$(cat "$FPF_DIR/.source-edit-count" 2>/dev/null || echo "0")
        PROB_ANY=$(find "$FPF_DIR/anomalies" -name "PROB-*.md" -o -name "ANOM-*.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$EDIT_COUNT" -ge 3 ] && [ "$PROB_ANY" -eq 0 ]; then
            REMINDERS="${REMINDERS}[FPF C1] Source edits without problem framing. /fpf-problem-framing\n"
        fi

        # SPORT without SEL
        SPORT_ANY=$(find "$FPF_DIR/portfolios" -name "SPORT-*.md" 2>/dev/null | wc -l | tr -d ' ')
        SEL_ANY=$(find "$FPF_DIR/decisions" -name "SEL-*.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$SPORT_ANY" -gt 0 ] && [ "$SEL_ANY" -eq 0 ]; then
            REMINDERS="${REMINDERS}[FPF C8] Solution portfolio without selection. /fpf-selection\n"
        fi

        # SPORT without SoTA (C9)
        SOTA_ANY=$(find "$FPF_DIR/characterizations" -name "SOTA-*.md" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$SPORT_ANY" -gt 0 ] && [ "$SOTA_ANY" -eq 0 ]; then
            REMINDERS="${REMINDERS}[FPF C9] Variants without SoTA survey. /fpf-sota\n"
        fi

        if [ -n "$REMINDERS" ]; then
            echo -e "$REMINDERS"
        fi
        exit 0
    fi
fi

# No sentinel — brief reminder
echo "[FPF GATE 0] Session not initialized. /fpf-core then /fpf-worklog <goal>. All tools blocked until sentinel exists."
exit 0
