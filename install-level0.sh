#!/usr/bin/env bash
set -euo pipefail

# Level 0 — FPF tweakcc integration installer (curl-compatible wrapper)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/m0n0x41d/principled-claude-code/main/install-level0.sh | bash
#
# This script:
#   1. Clones the repo to a temp directory
#   2. Runs scaffold/install-level0.sh from the clone
#   3. Cleans up the temp directory automatically

REPO_URL="https://github.com/m0n0x41d/principled-claude-code.git"
BRANCH="main"

# --- Colors (disabled if not a terminal) ---
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' BLUE='' RED='' BOLD='' RESET=''
fi

info()  { printf "${BLUE}[info]${RESET}  %s\n" "$*"; }
ok()    { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
err()   { printf "${RED}[error]${RESET} %s\n" "$*" >&2; }
die()   { err "$@"; exit 1; }

# --- Dependency check ---
command -v git >/dev/null 2>&1 || die "'git' is required but not found."

# --- Clone repo to temp directory ---
TMPDIR_REPO="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_REPO"' EXIT

info "Downloading FPF Level 0 installer..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR_REPO" 2>/dev/null \
    || die "Failed to clone repository. Check your network connection."

ok "Downloaded."
echo ""

INSTALLER="$TMPDIR_REPO/scaffold/install-level0.sh"
[ -f "$INSTALLER" ] || die "scaffold/install-level0.sh not found in repository."

chmod +x "$INSTALLER"

# Run the scaffold installer (not exec — trap must fire for cleanup)
bash "$INSTALLER" "$@"
EXIT_CODE=$?

# trap cleanup runs on EXIT automatically
exit $EXIT_CODE
