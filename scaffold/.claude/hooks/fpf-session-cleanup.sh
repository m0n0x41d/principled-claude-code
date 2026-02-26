#!/usr/bin/env bash
# FPF session cleanup — SessionStart hook
#
# Removes stale sentinel files from previous sessions.
# This ensures each new session must pass Gate 0 fresh.
#
# Hook type: SessionStart
# Exit 0 always (informational, never blocks)

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
FPF_DIR="$PROJECT_DIR/.fpf"
source "$FPF_DIR/config.sh" 2>/dev/null || true

# Remove sentinel only if stale (>12h) or from a different session
SENTINEL="$FPF_DIR/.session-active"
if [ -f "$SENTINEL" ]; then
    SENTINEL_SESSION=$(grep -o 'session_id=[^ ]*' "$SENTINEL" 2>/dev/null | cut -d= -f2)
    if [ "$SENTINEL_SESSION" = "${CLAUDE_SESSION_ID:-}" ]; then
        rm -f "$SENTINEL"  # Same session restarting
    else
        # Different session — check if stale
        if [[ "$(uname)" == "Darwin" ]]; then
            FILE_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL") ))
        else
            FILE_AGE=$(( $(date +%s) - $(stat -c %Y "$SENTINEL") ))
        fi
        if [ "$FILE_AGE" -ge "${FPF_SENTINEL_MAX_AGE:-43200}" ]; then
            rm -f "$SENTINEL"  # Stale from old session
        fi
        # Otherwise: active concurrent session, leave sentinel alone
    fi
fi

# Remove stale source edit counter from previous session
rm -f "$FPF_DIR/.source-edit-count"

# Remove stale session tier from previous session
rm -f "$FPF_DIR/.session-tier"

# Remove stale trivial-session marker
rm -f "$FPF_DIR/.trivial-session"

# Remove reminder cooldown state
rm -f "$FPF_DIR/.reminder-state"

# Remove review-done marker
rm -f "$FPF_DIR/.review-done"

# Warn about global CLAUDE.md workflow overlap (stdout → injected as session context)
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    if grep -qiE 'First Principles Framework|FPF|fpf-core|fpf-worklog|\.fpf/anomalies|PROB-\*|EVID-\*' "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
        echo "[FPF] Global CLAUDE.md has FPF overlap. Project profile supersedes it."
    fi
fi

exit 0
