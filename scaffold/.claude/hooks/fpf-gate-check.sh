#!/usr/bin/env bash
# FPF session-end quality gate — Stop hook
#
# Checks before allowing session end:
#   1. Session worklog exists
#   2. Source edits → evidence record required (Gate 2)
#   3. Substantive session (≥10 tools) → evidence record required
#   4. Worklog has no TBD entries
#   5. SPORT-* → SEL-* required
#   6. PROB-* with acceptance spec → CHR-* required
#   7. SEL-*/DRR-* → F-G-R fields filled
#   8. Architectural work (STRAT/SEL) → DRR-* required (Gate 3)
#   9. Refuted evidence → problem reframing reminder (feedback loop)
#
# Hook type: Stop
# Exit 0 = allow, Exit 2 = block with feedback

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
source "$FPF_DIR/config.sh" 2>/dev/null || true

# If /fpf-review was already run, trust it and allow session end
if [ -f "$FPF_DIR/.review-done" ]; then
    exit 0
fi
WORKLOG_DIR="$FPF_DIR/worklog"
EVIDENCE_DIR="$FPF_DIR/evidence"
ANOMALIES_DIR="$FPF_DIR/anomalies"
DECISIONS_DIR="$FPF_DIR/decisions"
PORTFOLIOS_DIR="$FPF_DIR/portfolios"
CHAR_DIR="$FPF_DIR/characterizations"
COUNTER_FILE="$FPF_DIR/.source-edit-count"

SESSION_ID="${CLAUDE_SESSION_ID:-}"
SUBSTANTIVE_TOOL_THRESHOLD="${FPF_SUBSTANTIVE_TOOL_THRESHOLD:-10}"

INPUT=$(cat)

TOOL_USES=$(echo "$INPUT" | jq -r '.tool_use_count // 0' 2>/dev/null || echo "0")
if [ "$TOOL_USES" -lt "${FPF_MIN_TOOL_USES:-3}" ]; then
    exit 0
fi

if [ -z "$SESSION_ID" ] || [ "$SESSION_ID" = "NOSESSION" ]; then
    SESSION_PREFIX=""
else
    SESSION_PREFIX="${SESSION_ID:0:8}"
fi

WARNINGS=""

# --- Helper: session-scoped evidence check ---
check_session_evidence() {
    if [ -d "$EVIDENCE_DIR" ]; then
        if [ -n "$SESSION_PREFIX" ]; then
            SESSION_EVIDENCE=$(find "$EVIDENCE_DIR" -name "EVID-${SESSION_PREFIX}*" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$SESSION_EVIDENCE" -gt 0 ]; then return 0; fi
        fi
        RECENT_EVIDENCE=$(find "$EVIDENCE_DIR" -name "EVID-*.md" -mmin -${FPF_RECENT_ARTIFACT_WINDOW:-720} 2>/dev/null | wc -l | tr -d ' ')
        if [ "$RECENT_EVIDENCE" -gt 0 ]; then return 0; fi
    fi
    return 1
}

# --- Check 1: Worklog exists ---
WORKLOG_EXISTS=false
SESSION_WORKLOG=""
if [ -d "$WORKLOG_DIR" ]; then
    if [ -n "$SESSION_PREFIX" ]; then
        SESSION_WORKLOG=$(find "$WORKLOG_DIR" -name "session-${SESSION_ID}.md" 2>/dev/null | head -1)
    fi
    if [ -z "$SESSION_WORKLOG" ]; then
        SESSION_WORKLOG=$(find "$WORKLOG_DIR" -name "session-*.md" -mmin -${FPF_RECENT_ARTIFACT_WINDOW:-720} 2>/dev/null | sort -r | head -1)
    fi
    if [ -n "$SESSION_WORKLOG" ]; then WORKLOG_EXISTS=true; fi
fi
if [ "$WORKLOG_EXISTS" = false ]; then
    WARNINGS="${WARNINGS}[G0] No worklog. Run /fpf-review.\n"
fi

# --- Check 2: Source edits → evidence ---
SOURCE_EDITS=0
if [ -f "$COUNTER_FILE" ]; then
    SOURCE_EDITS=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
fi
if [ "$SOURCE_EDITS" -gt 0 ]; then
    if ! check_session_evidence; then
        WARNINGS="${WARNINGS}[G2] ${SOURCE_EDITS} edits, no EVID. Run /fpf-evidence.\n"
    fi
fi

# --- Check 3: Substantive session → evidence ---
if [ "$SOURCE_EDITS" -eq 0 ] && [ "$TOOL_USES" -ge "$SUBSTANTIVE_TOOL_THRESHOLD" ]; then
    if ! check_session_evidence; then
        WARNINGS="${WARNINGS}[G2] Substantive session, no EVID. Run /fpf-evidence if claims made.\n"
    fi
fi

# --- Check 4: Worklog completeness ---
if [ "$WORKLOG_EXISTS" = true ] && [ -n "$SESSION_WORKLOG" ]; then
    if grep -q '^- TBD$' "$SESSION_WORKLOG" 2>/dev/null; then
        WARNINGS="${WARNINGS}[WL] Worklog has TBD entries. Update before ending.\n"
    fi
fi

# --- Check 5: SPORT-* → SEL-* ---
if [ -d "$PORTFOLIOS_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    SPORT_COUNT=$(find "$PORTFOLIOS_DIR" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SPORT_COUNT" -gt 0 ]; then
        SEL_COUNT=0
        if [ -d "$DECISIONS_DIR" ]; then
            SEL_COUNT=$(find "$DECISIONS_DIR" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$SEL_COUNT" -eq 0 ]; then
            WARNINGS="${WARNINGS}[G] SPORT exists, no SEL. Run /fpf-selection.\n"
        fi
    fi
fi

# --- Check 6: PROB-* with acceptance spec → CHR-* ---
if [ -d "$ANOMALIES_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    for PROB_FILE in $(find "$ANOMALIES_DIR" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null); do
        if grep -qi 'acceptance.*spec\|acceptance criteria' "$PROB_FILE" 2>/dev/null; then
            CHR_COUNT=0
            if [ -d "$CHAR_DIR" ]; then
                CHR_COUNT=$(find "$CHAR_DIR" -name "CHR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            fi
            if [ "$CHR_COUNT" -eq 0 ]; then
                # Accept inline indicators as CHR substitute
                if ! grep -qiE 'threshold:|measurement:|indicator.*:' "$PROB_FILE" 2>/dev/null; then
                    WARNINGS="${WARNINGS}[G] PROB has acceptance spec but no CHR/inline indicators.\n"
                    break
                fi
            fi
        fi
    done
fi

# --- Check 7: SEL-*/DRR-* F-G-R completeness ---
if [ -d "$DECISIONS_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    for DECISION_FILE in $(find "$DECISIONS_DIR" \( -name "SEL-${SESSION_PREFIX}*.md" -o -name "DRR-${SESSION_PREFIX}*.md" \) 2>/dev/null); do
        if grep -qE '^\*\*F \(Formality\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null || \
           grep -qE '^\*\*ClaimScope ?\(G\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null || \
           grep -qE '^\*\*R \(Reliability\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null; then
            WARNINGS="${WARNINGS}[G] $(basename "$DECISION_FILE"): empty F-G-R. Fill before ending.\n"
        fi
    done
fi

# --- Check 8: Architectural work → DRR required (Gate 3) ---
if [ -d "$DECISIONS_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    STRAT_COUNT=$(find "$DECISIONS_DIR" -name "STRAT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    SEL_COUNT=$(find "$DECISIONS_DIR" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    DRR_COUNT=$(find "$DECISIONS_DIR" -name "DRR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')

    if { [ "$STRAT_COUNT" -gt 0 ] || [ "$SEL_COUNT" -gt 0 ]; } && [ "$DRR_COUNT" -eq 0 ]; then
        WARNINGS="${WARNINGS}[G3] STRAT/SEL exist, no DRR. Run /fpf-decision-record.\n"
    fi
fi

# --- Check 9: Creative quality (advisory) ---
if [ -d "$ANOMALIES_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    for PROB_FILE in $(find "$ANOMALIES_DIR" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null); do
        HYP_COUNT=$(grep -cE '^\*{0,2}#*\s*H[0-9]|^H[0-9]' "$PROB_FILE" 2>/dev/null || echo "0")
        if [ "$HYP_COUNT" -lt 3 ]; then
            WARNINGS="${WARNINGS}[C1] $(basename "$PROB_FILE"): <3 hypotheses.\n"
        fi
    done
fi
if [ -d "$PORTFOLIOS_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    for SPORT_FILE in $(find "$PORTFOLIOS_DIR" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null); do
        VARIANT_COUNT=$(grep -cE '^\| V[0-9]|^#{1,4}\s*V[0-9]|^\*{1,2}V[0-9]|^[-*]\s*V[0-9]|^V[0-9][.:)]' "$SPORT_FILE" 2>/dev/null || echo "0")
        if [ "$VARIANT_COUNT" -lt 3 ]; then
            WARNINGS="${WARNINGS}[C2] $(basename "$SPORT_FILE"): <3 variants.\n"
        fi
    done
fi

# --- Check 10: C3 — SEL-* must have selection policy stated before applying ---
if [ -d "$DECISIONS_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    for SEL_FILE in $(find "$DECISIONS_DIR" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null); do
        HAS_POLICY=$(grep -ciE 'selection policy|policy.*before|policy:' "$SEL_FILE" 2>/dev/null || echo "0")
        if [ "$HAS_POLICY" -eq 0 ]; then
            WARNINGS="${WARNINGS}[C3] $(basename "$SEL_FILE"): no selection policy.\n"
        fi
    done
fi

# --- Check 11: Evidence valid_until completeness (all session evidence files) ---
if [ -d "$EVIDENCE_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    for EVID_FILE in $(find "$EVIDENCE_DIR" -name "EVID-${SESSION_PREFIX}*.md" 2>/dev/null); do
        if ! grep -qE 'valid_until:.*[0-9]' "$EVID_FILE" 2>/dev/null; then
            WARNINGS="${WARNINGS}[C7] $(basename "$EVID_FILE"): no valid_until.\n"
        fi
        # C7: check that commands/procedure section has actual content
        if ! grep -qE '^```|^##\s*Procedure' "$EVID_FILE" 2>/dev/null; then
            WARNINGS="${WARNINGS}[C7] $(basename "$EVID_FILE"): no Procedure section.\n"
        fi
        # C7: check that raw outputs section has content
        if ! grep -qE '^##\s*Raw outputs' "$EVID_FILE" 2>/dev/null; then
            WARNINGS="${WARNINGS}[C7] $(basename "$EVID_FILE"): no Raw outputs section.\n"
        fi
    done
fi

# --- Check 11: Refuted evidence → HARD feedback loop check ---
# The double-loop coupling: refuted evidence MUST feed back to problem factory.
# Check: if any EVID-* has "refuted", a PROB-* must have been modified AFTER that EVID-*.
if [ -d "$EVIDENCE_DIR" ] && [ -n "$SESSION_PREFIX" ]; then
    REFUTED_FILES=$( (grep -rlE 'Result:.*refuted' "$EVIDENCE_DIR"/ 2>/dev/null || true) )
    if [ -n "$REFUTED_FILES" ]; then
        FEEDBACK_OK=false
        for REFUTED_FILE in $REFUTED_FILES; do
            if [[ "$(uname)" == "Darwin" ]]; then
                REFUTED_MTIME=$(stat -f %m "$REFUTED_FILE")
            else
                REFUTED_MTIME=$(stat -c %Y "$REFUTED_FILE")
            fi
            # Check if any PROB-* or ANOM-* was modified after the refutation
            if [ -d "$ANOMALIES_DIR" ]; then
                for PROB_FILE in $(find "$ANOMALIES_DIR" \( -name "PROB-*.md" -o -name "ANOM-*.md" \) 2>/dev/null); do
                    if [[ "$(uname)" == "Darwin" ]]; then
                        PROB_MTIME=$(stat -f %m "$PROB_FILE")
                    else
                        PROB_MTIME=$(stat -c %Y "$PROB_FILE")
                    fi
                    if [ "$PROB_MTIME" -ge "$REFUTED_MTIME" ]; then
                        FEEDBACK_OK=true
                        break 2
                    fi
                done
            fi
        done
        if [ "$FEEDBACK_OK" = false ]; then
            WARNINGS="${WARNINGS}[FB] Refuted EVID but no PROB/ANOM update. Feed back to problem factory.\n"
        fi
    fi
fi

# --- Check 13: C10 — /fpf-review before ending non-trivial sessions ---
TIER_FILE="$FPF_DIR/.session-tier"
SESSION_TIER=$(cat "$TIER_FILE" 2>/dev/null || echo "")
TRIVIAL_FILE="$FPF_DIR/.trivial-session"
if [ -n "$SESSION_TIER" ] && [ "$SESSION_TIER" != "T1" ] && [ ! -f "$TRIVIAL_FILE" ]; then
    # Check worklog for review summary (fpf-review updates worklog with final summary)
    REVIEW_DONE=false
    if [ "$WORKLOG_EXISTS" = true ] && [ -n "$SESSION_WORKLOG" ]; then
        if grep -qiE 'review summary|session review|fpf-review|Gate 5' "$SESSION_WORKLOG" 2>/dev/null; then
            REVIEW_DONE=true
        fi
    fi
    if [ "$REVIEW_DONE" = false ] && [ "$TOOL_USES" -ge "$SUBSTANTIVE_TOOL_THRESHOLD" ]; then
        WARNINGS="${WARNINGS}[C10] No /fpf-review. Run it before ending.\n"
    fi
fi

# --- Emit only the first warning to save context budget ---
if [ -n "$WARNINGS" ]; then
    FIRST=$(echo -e "$WARNINGS" | head -1)
    TOTAL=$(echo -e "$WARNINGS" | grep -c '^\[' || echo "0")
    echo "$FIRST (${TOTAL} issues total. Run /fpf-review to resolve.)" >&2
    exit 2
fi

exit 0
