#!/usr/bin/env bash
# FPF session-end quality gate — Stop hook
#
# Checks four conditions before allowing session end:
#   1. Session-specific worklog exists (matches CLAUDE_SESSION_ID)
#   2. If source edits happened, session-specific evidence record must exist (Gate 2)
#   3. If substantive session (>= 10 tool uses), evidence record must exist (Gate 2)
#   4. Worklog Results section must not contain TBD (completeness)
#
# All checks are SESSION-SCOPED: artifacts from a previous session today
# do NOT satisfy checks for the current session. This prevents the
# same-day continuation bypass (past failure #2).
#
# Hook type: Stop (fires when Claude finishes responding)
# Exit 0 = allow, Exit 2 = block with feedback

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
WORKLOG_DIR="$FPF_DIR/worklog"
EVIDENCE_DIR="$FPF_DIR/evidence"
COUNTER_FILE="$FPF_DIR/.source-edit-count"

# Session ID — used to scope checks to THIS session only
SESSION_ID="${CLAUDE_SESSION_ID:-}"

# Threshold for "substantive session" — review/audit/investigation
# sessions that read many files but edit none still need evidence.
SUBSTANTIVE_TOOL_THRESHOLD=10

# Read stop input
INPUT=$(cat)

# Only enforce for non-trivial sessions (>= 3 tool uses)
TOOL_USES=$(echo "$INPUT" | jq -r '.tool_use_count // 0' 2>/dev/null || echo "0")
if [ "$TOOL_USES" -lt 3 ]; then
    exit 0
fi

# If no session ID available, fall back to time-based checks
if [ -z "$SESSION_ID" ]; then
    SESSION_ID="NOSESSION"
fi

# Extract short prefix for file matching (first 8 chars of UUID)
SESSION_PREFIX="${SESSION_ID:0:8}"

WARNINGS=""

# --- Helper: check for session-scoped evidence records ---
# Looks for EVID files containing this session's ID prefix in the filename.
# Falls back to any recent EVID file if session ID is unavailable.
check_session_evidence() {
    if [ -d "$EVIDENCE_DIR" ]; then
        if [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
            # Prefer session-scoped match
            SESSION_EVIDENCE=$(find "$EVIDENCE_DIR" -name "EVID-${SESSION_PREFIX}*" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$SESSION_EVIDENCE" -gt 0 ]; then
                return 0
            fi
        fi
        # Fallback: any EVID file modified in last 6 hours (tighter than 24h)
        RECENT_EVIDENCE=$(find "$EVIDENCE_DIR" -name "EVID-*.md" -mmin -360 2>/dev/null | wc -l | tr -d ' ')
        if [ "$RECENT_EVIDENCE" -gt 0 ]; then
            return 0
        fi
    fi
    return 1
}

# --- Check 1: Session-specific worklog exists ---
WORKLOG_EXISTS=false
SESSION_WORKLOG=""
if [ -d "$WORKLOG_DIR" ]; then
    # First try session-scoped worklog
    if [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
        SESSION_WORKLOG=$(find "$WORKLOG_DIR" -name "session-${SESSION_ID}.md" 2>/dev/null | head -1)
    fi
    # Fallback: any recent worklog
    if [ -z "$SESSION_WORKLOG" ]; then
        SESSION_WORKLOG=$(find "$WORKLOG_DIR" -name "session-*.md" -mmin -360 2>/dev/null | sort -r | head -1)
    fi
    if [ -n "$SESSION_WORKLOG" ]; then
        WORKLOG_EXISTS=true
    fi
fi

if [ "$WORKLOG_EXISTS" = false ]; then
    WARNINGS="${WARNINGS}[GATE 0] No session worklog found for session ${SESSION_PREFIX}... in .fpf/worklog/. Invoke /fpf-review.\n"
fi

# --- Check 2: Source edits require evidence record (Gate 2) ---
SOURCE_EDITS=0
if [ -f "$COUNTER_FILE" ]; then
    SOURCE_EDITS=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
fi

if [ "$SOURCE_EDITS" -gt 0 ]; then
    if ! check_session_evidence; then
        WARNINGS="${WARNINGS}[GATE 2] ${SOURCE_EDITS} source file(s) modified but no evidence record for session ${SESSION_PREFIX}... found in .fpf/evidence/. Invoke /fpf-evidence before ending session.\n"
    fi
fi

# --- Check 3: Substantive session requires evidence (Gate 2, review path) ---
# Catches review/audit/investigation sessions that read many files,
# launch agents, and make claims — but never edit source code.
if [ "$SOURCE_EDITS" -eq 0 ] && [ "$TOOL_USES" -ge "$SUBSTANTIVE_TOOL_THRESHOLD" ]; then
    if ! check_session_evidence; then
        WARNINGS="${WARNINGS}[GATE 2] Substantive session (${TOOL_USES} tool uses) with no evidence record for session ${SESSION_PREFIX}... in .fpf/evidence/. If you made claims or conclusions, invoke /fpf-evidence. If this was purely exploratory with no claims, acknowledge and proceed.\n"
    fi
fi

# --- Check 4: Worklog Results section must not be TBD ---
if [ "$WORKLOG_EXISTS" = true ] && [ -n "$SESSION_WORKLOG" ]; then
    if grep -q '^- TBD$' "$SESSION_WORKLOG" 2>/dev/null; then
        WARNINGS="${WARNINGS}[WORKLOG] Worklog $(basename "$SESSION_WORKLOG") has unresolved TBD entries. Update with actual results before ending session.\n"
    fi
fi

# --- Check 5: SPORT-* exists but no SEL-* ---
PORTFOLIOS_DIR="$FPF_DIR/portfolios"
DECISIONS_DIR="$FPF_DIR/decisions"
if [ -d "$PORTFOLIOS_DIR" ]; then
    SPORT_COUNT=0
    if [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
        SPORT_COUNT=$(find "$PORTFOLIOS_DIR" -name "SPORT-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$SPORT_COUNT" -gt 0 ]; then
        SEL_COUNT=0
        if [ -d "$DECISIONS_DIR" ]; then
            SEL_COUNT=$(find "$DECISIONS_DIR" -name "SEL-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
        fi
        if [ "$SEL_COUNT" -eq 0 ]; then
            WARNINGS="${WARNINGS}[GATE] Solution portfolio exists but no selection record for session ${SESSION_PREFIX}... Invoke /fpf-selection before ending session.\n"
        fi
    fi
fi

# --- Check 6: PROB-* with acceptance spec but no CHR-* ---
ANOMALIES_DIR="$FPF_DIR/anomalies"
CHAR_DIR="$FPF_DIR/characterizations"
if [ -d "$ANOMALIES_DIR" ]; then
    if [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
        for PROB_FILE in $(find "$ANOMALIES_DIR" -name "PROB-${SESSION_PREFIX}*.md" 2>/dev/null); do
            if grep -q 'Acceptance spec' "$PROB_FILE" 2>/dev/null; then
                CHR_COUNT=0
                if [ -d "$CHAR_DIR" ]; then
                    CHR_COUNT=$(find "$CHAR_DIR" -name "CHR-${SESSION_PREFIX}*.md" 2>/dev/null | wc -l | tr -d ' ')
                fi
                if [ "$CHR_COUNT" -eq 0 ]; then
                    WARNINGS="${WARNINGS}[GATE] Problem card with acceptance spec but no characterization for session ${SESSION_PREFIX}... Invoke /fpf-characterize.\n"
                    break
                fi
            fi
        done
    fi
fi

# --- Check 7: SEL-*/DRR-* with empty F-G-R fields ---
if [ -d "$DECISIONS_DIR" ] && [ "$SESSION_PREFIX" != "NOSESSIO" ]; then
    for DECISION_FILE in $(find "$DECISIONS_DIR" \( -name "SEL-${SESSION_PREFIX}*.md" -o -name "DRR-${SESSION_PREFIX}*.md" \) 2>/dev/null); do
        if grep -qE '^\*\*F \(Formality\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null || \
           grep -qE '^\*\*ClaimScope\(G\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null || \
           grep -qE '^\*\*R \(Reliability\):\*\*\s*$' "$DECISION_FILE" 2>/dev/null; then
            WARNINGS="${WARNINGS}[GATE] $(basename "$DECISION_FILE") has empty F-G-R fields. Fill in Formality, ClaimScope(G), and Reliability before ending session.\n"
        fi
    done
fi

# --- Emit warnings or allow ---
if [ -n "$WARNINGS" ]; then
    echo -e "FPF session-end quality gate violations:\n" >&2
    echo -e "$WARNINGS" >&2
    echo "Fix these issues or invoke /fpf-review to close the session properly." >&2
    exit 2
fi

exit 0
