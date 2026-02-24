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

# Remove stale sentinel — force fresh Gate 0 pass
rm -f "$FPF_DIR/.session-active"

# Remove stale source edit counter from previous session
rm -f "$FPF_DIR/.source-edit-count"

# Remove stale session tier from previous session
rm -f "$FPF_DIR/.session-tier"

# Remove stale trivial-session marker
rm -f "$FPF_DIR/.trivial-session"

exit 0
