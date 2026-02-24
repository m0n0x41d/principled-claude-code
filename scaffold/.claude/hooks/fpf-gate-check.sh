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
WORKLOG_DIR="$FPF_DIR/worklog"
EVIDENCE_DIR="$FPF_DIR/evidence"
ANOMALIES_DIR="$FPF_DIR/anomalies"
DECISIONS_DIR="$FPF_DIR/decisions"
PORTFOLIOS_DIR="$FPF_DIR/portfolios"
CHAR_DIR="$FPF_DIR/characterizations"
COUNTER_FILE="$FPF_DIR/.source-edit-count"

SESSION_ID="${CLAUDE_SESSION_ID:-}"
SUBSTANTIVE_TOOL_THRESHOLD=10

INPUT=$(cat)

TOOL_USES=$(echo "$INPUT" | jq -r '.tool_use_count // 0' 2>/dev/null || echo "0")
if [ "$TOOL_USES" -lt 3 ]; then
    exit 0
fi

if [ -z "$SESSION_ID" ]; then
    SESSION_ID="NOSESSION"
fi
SESSION_PREFIX="${SESSION_ID:0:8}"

WARNINGS=""

# --- Helper: session-scoped evidence check ---
check_session_evidence() {
    if [ -d "$EVIDENCE_DIR" ]; then
        if [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
            SESSION_EVIDENCE=$(find "$EVIDENCE_DIR" -name "EVID-${SESSION_PREFIX}*" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$SESSION_EVIDENCE" -gt 0 ]; then return 0; fi
        fi
        RECENT_EVIDENCE=$(find "$EVIDENCE_DIR" -name "EVID-*.md" -mmin -720 2>/dev/null | wc -l | tr -d ' ')
        if [ "$RECENT_EVIDENCE" -gt 0 ]; then return 0; fi
    fi
    return 1
}

# --- Check 1: Worklog exists ---
WORKLOG_EXISTS=false
SESSION_WORKLOG=""
if [ -d "$WORKLOG_DIR" ]; then
    if [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
        SESSION_WORKLOG=$(find "$WORKLOG_DIR" -name "session-${SESSION_ID}.md" 2>/dev/null | head -1)
    fi
    if [ -z "$SESSION_WORKLOG" ]; then
        SESSION_WORKLOG=$(find "$WORKLOG_DIR" -name "session-*.md" -mmin -720 2>/dev/null | sort -r | head -1)
    fi
    if [ -n "$SESSION_WORKLOG" ]; then WORKLOG_EXISTS=true; fi
fi
if [ "$WORKLOG_EXISTS" = false ]; then
    WARNINGS="${WARNINGS}[GATE 0] No session worklog found. Invoke /fpf-review.\n"
fi

# --- Check 2: Source edits → evidence ---
SOURCE_EDITS=0
if [ -f "$COUNTER_FILE" ]; then
    SOURCE_EDITS=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
fi
if [ "$SOURCE_EDITS" -gt 0 ]; then
    if ! check_session_evidence; then
        WARNINGS="${WARNINGS}[GATE 2] ${SOURCE_EDITS} source file(s) modified but no evidence record. Invoke /fpf-evidence before ending.\n"
    fi
fi

# --- Check 3: Substantive session → evidence ---
if [ "$SOURCE_EDITS" -eq 0 ] && [ "$TOOL_USES" -ge "$SUBSTANTIVE_TOOL_THRESHOLD" ]; then
    if ! check_session_evidence; then
        WARNINGS="${WARNINGS}[GATE 2] Substantive session (${TOOL_USES} tool uses) with no evidence record. If you made claims, invoke /fpf-evidence.\n"
    fi
fi

# --- Check 4: Worklog completeness ---
if [ "$WORKLOG_EXISTS" = true ] && [ -n "$SESSION_WORKLOG" ]; then
    if grep -q '^- TBD$' "$SESSION_WORKLOG" 2>/dev/null; then
        WARNINGS="${WARNINGS}[WORKLOG] Worklog has unresolved TBD entries. Update before ending.\n"
    fi
fi

# --- Check 5: SPORT-* → SEL-* ---
if [ -d "$PORTFOLIOS_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    SPORT_COUNT=$(find "$PORTFOLIOS_DIR" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SPORT_COUNT" -gt 0 ]; then
        SEL_COUNT=0
        if [ -d "$DECISIONS_DIR" ]; then
            SEL_COUNT=$(find "$DECISIONS_DIR" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$SEL_COUNT" -eq 0 ]; then
            WARNINGS="${WARNINGS}[GATE] Solution portfolio exists but no selection record. Invoke /fpf-selection.\n"
        fi
    fi
fi

# --- Check 6: PROB-* with acceptance spec → CHR-* ---
if [ -d "$ANOMALIES_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    for PROB_FILE in $(find "$ANOMALIES_DIR" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null); do
        if grep -q 'Acceptance spec' "$PROB_FILE" 2>/dev/null; then
            CHR_COUNT=0
            if [ -d "$CHAR_DIR" ]; then
                CHR_COUNT=$(find "$CHAR_DIR" -name "CHR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
            fi
            if [ "$CHR_COUNT" -eq 0 ]; then
                WARNINGS="${WARNINGS}[GATE] Problem card with acceptance spec but no characterization. Invoke /fpf-characterize.\n"
                break
            fi
        fi
    done
fi

# --- Check 7: SEL-*/DRR-* F-G-R completeness ---
if [ -d "$DECISIONS_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    for DECISION_FILE in $(find "$DECISIONS_DIR" \( -name "SEL-${SESSION_PREFIX}*.md" -o -name "DRR-${SESSION_PREFIX}*.md" \) 2>/dev/null); do
        if grep -qE '^\*\*F \(Formality\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null || \
           grep -qE '^\*\*ClaimScope\(G\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null || \
           grep -qE '^\*\*R \(Reliability\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null; then
            WARNINGS="${WARNINGS}[GATE] $(basename "$DECISION_FILE") has empty F-G-R fields. Fill before ending.\n"
        fi
    done
fi

# --- Check 8: Architectural work → DRR required (Gate 3) ---
if [ -d "$DECISIONS_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    STRAT_COUNT=$(find "$DECISIONS_DIR" -name "STRAT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    SEL_COUNT=$(find "$DECISIONS_DIR" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    DRR_COUNT=$(find "$DECISIONS_DIR" -name "DRR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')

    if { [ "$STRAT_COUNT" -gt 0 ] || [ "$SEL_COUNT" -gt 0 ]; } && [ "$DRR_COUNT" -eq 0 ]; then
        WARNINGS="${WARNINGS}[GATE 3] Architectural artifacts (STRAT/SEL) exist but no decision record (DRR-*). Invoke /fpf-decision-record for non-trivial decisions.\n"
    fi
fi

# --- Check 9: Creative quality (advisory) ---
if [ -d "$ANOMALIES_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    for PROB_FILE in $(find "$ANOMALIES_DIR" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null); do
        HYP_COUNT=$(grep -cE '^\*{0,2}#*\s*H[0-9]|^H[0-9]' "$PROB_FILE" 2>/dev/null || echo "0")
        if [ "$HYP_COUNT" -lt 2 ]; then
            WARNINGS="${WARNINGS}[CREATIVE QUALITY] $(basename "$PROB_FILE") has <2 hypotheses. Consider enriching before closing.\n"
        fi
    done
fi
if [ -d "$PORTFOLIOS_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    for SPORT_FILE in $(find "$PORTFOLIOS_DIR" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null); do
        VARIANT_COUNT=$(grep -cE '^\| V[0-9]|^### V[0-9]' "$SPORT_FILE" 2>/dev/null || echo "0")
        if [ "$VARIANT_COUNT" -lt 3 ]; then
            WARNINGS="${WARNINGS}[CREATIVE QUALITY] $(basename "$SPORT_FILE") has <3 variants. Pareto front needs ≥3.\n"
        fi
    done
fi

# --- Check 10: Evidence valid_until completeness (all session evidence files) ---
if [ -d "$EVIDENCE_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    for EVID_FILE in $(find "$EVIDENCE_DIR" -name "EVID-${SESSION_PREFIX}*.md" 2>/dev/null); do
        if ! grep -qE 'valid_until:.*[0-9]' "$EVID_FILE" 2>/dev/null; then
            WARNINGS="${WARNINGS}[GATE 2] $(basename "$EVID_FILE") has empty or missing valid_until. Set an expiry date or justify perpetual validity.\n"
        fi
    done
fi

# --- Check 11: Refuted evidence → HARD feedback loop check ---
# The double-loop coupling: refuted evidence MUST feed back to problem factory.
# Check: if any EVID-* has "refuted", a PROB-* must have been modified AFTER that EVID-*.
if [ -d "$EVIDENCE_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
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
            WARNINGS="${WARNINGS}[FEEDBACK LOOP — HARD] Evidence shows refuted claim(s) but no problem card was updated afterward. The double-loop requires feeding refuted evidence back to the problem factory. Update PROB-* or create new ANOM-* before ending.\n"
        fi
    fi
fi

# --- Emit ---
if [ -n "$WARNINGS" ]; then
    echo -e "FPF session-end quality gate:\n" >&2
    echo -e "$WARNINGS" >&2
    echo "Fix these or invoke /fpf-review to close properly." >&2
    exit 2
fi

exit 0
