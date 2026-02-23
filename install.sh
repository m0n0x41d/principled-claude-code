#!/usr/bin/env bash
set -euo pipefail

# FPF (First Principles Framework) installer for Claude Code
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/m0n0x41d/principled-claude-code/main/install.sh | bash
#   # or install into a specific directory:
#   curl -fsSL https://raw.githubusercontent.com/m0n0x41d/principled-claude-code/main/install.sh | bash -s -- /path/to/project

REPO_URL="https://github.com/m0n0x41d/principled-claude-code.git"
BRANCH="main"

# --- Colors (disabled if not a terminal) ---
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

info()  { printf "${BLUE}[info]${RESET}  %s\n" "$*"; }
ok()    { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[warn]${RESET}  %s\n" "$*"; }
err()   { printf "${RED}[error]${RESET} %s\n" "$*" >&2; }
die()   { err "$@"; exit 1; }

# --- Prompt helper (works even when piped from curl) ---
prompt_user() {
    local question="$1"
    local default="${2:-}"
    local reply

    # When piped from curl, stdin is the script. Read from /dev/tty instead.
    if [ -t 0 ]; then
        printf "${BOLD}%s${RESET} " "$question"
        read -r reply
    elif [ -e /dev/tty ]; then
        printf "${BOLD}%s${RESET} " "$question" >/dev/tty
        read -r reply </dev/tty
    else
        # Non-interactive, no tty available — use default
        reply="$default"
    fi

    echo "${reply:-$default}"
}

# --- Dependency check ---
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "'$1' is required but not found. Please install it and retry."
}

require_cmd git
require_cmd jq

# --- Parse arguments ---
TARGET_DIR="${1:-.}"
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo ""
printf "${BOLD}FPF — First Principles Framework for Claude Code${RESET}\n"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "Target directory: $TARGET_DIR"
echo ""

# --- Clone repo to temp directory ---
TMPDIR_REPO="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_REPO"' EXIT

info "Downloading FPF scaffold..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR_REPO" 2>/dev/null \
    || die "Failed to clone repository. Check your network connection."

SCAFFOLD_DIR="$TMPDIR_REPO/scaffold"
[ -d "$SCAFFOLD_DIR" ] || die "Scaffold directory not found in repository."

ok "Downloaded successfully."
echo ""

# --- Detect existing Claude/FPF artifacts ---
CLAUDE_ARTIFACTS=()

[ -f "$TARGET_DIR/CLAUDE.md" ]    && CLAUDE_ARTIFACTS+=("CLAUDE.md")
[ -d "$TARGET_DIR/.claude" ]      && CLAUDE_ARTIFACTS+=(".claude")
[ -d "$TARGET_DIR/.fpf" ]         && CLAUDE_ARTIFACTS+=(".fpf")

# --- Handle conflicts ---
BACKUP_DIR=""

if [ ${#CLAUDE_ARTIFACTS[@]} -gt 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    warn "Existing Claude/FPF artifacts detected:"
    for artifact in "${CLAUDE_ARTIFACTS[@]}"; do
        printf "  • %s\n" "$artifact"
    done
    echo ""

    CHOICE=$(prompt_user "[B]ackup and replace, [O]verride (lose existing), or [C]ancel? [B/o/c]:" "b")
    CHOICE="$(echo "$CHOICE" | tr '[:upper:]' '[:lower:]')"

    case "$CHOICE" in
        b|backup)
            TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
            BACKUP_DIR="$TARGET_DIR/.backup/$TIMESTAMP"
            mkdir -p "$BACKUP_DIR"

            info "Backing up to .backup/$TIMESTAMP/"

            for artifact in "${CLAUDE_ARTIFACTS[@]}"; do
                src="$TARGET_DIR/$artifact"
                dst="$BACKUP_DIR/$artifact"
                if [ -d "$src" ]; then
                    cp -R "$src" "$dst"
                else
                    cp "$src" "$dst"
                fi
                ok "  Backed up: $artifact"
            done
            echo ""
            ;;
        o|override)
            warn "Overriding existing artifacts (no backup)."
            echo ""
            ;;
        c|cancel)
            info "Installation cancelled."
            exit 0
            ;;
        *)
            die "Unknown choice: '$CHOICE'. Expected b, o, or c."
            ;;
    esac
fi

# --- Copy scaffold files ---
info "Installing FPF scaffold..."

CREATED=0
OVERWRITTEN=0
HOOKS_EXEC=0

while IFS= read -r -d '' src_file; do
    rel="${src_file#"$SCAFFOLD_DIR/"}"

    # Skip junk
    case "$(basename "$src_file")" in
        .DS_Store) continue ;;
    esac

    dst="$TARGET_DIR/$rel"
    existed=false
    [ -e "$dst" ] && existed=true

    # Create parent directories
    mkdir -p "$(dirname "$dst")"

    # Copy file preserving metadata
    cp -p "$src_file" "$dst"

    # Make hook scripts executable
    case "$rel" in
        .claude/hooks/*.sh)
            chmod +x "$dst"
            HOOKS_EXEC=$((HOOKS_EXEC + 1))
            ;;
    esac

    if $existed; then
        OVERWRITTEN=$((OVERWRITTEN + 1))
    else
        CREATED=$((CREATED + 1))
    fi
done < <(find "$SCAFFOLD_DIR" -type f -print0 | sort -z)

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "FPF installed successfully!"
echo ""
printf "  Files created:      %d\n" "$CREATED"
printf "  Files overwritten:  %d\n" "$OVERWRITTEN"
printf "  Hooks made exec:    %d\n" "$HOOKS_EXEC"

if [ -n "$BACKUP_DIR" ]; then
    printf "  Backup location:    %s\n" "$BACKUP_DIR"
fi

echo ""
printf "${BOLD}Target:${RESET} %s\n" "$TARGET_DIR"
echo ""
echo "What was installed:"
echo "  CLAUDE.md              — FPF project instructions"
echo "  .claude/skills/*       — FPF slash commands (/fpf-core, /fpf-evidence, ...)"
echo "  .claude/hooks/*        — Mechanical enforcement hooks"
echo "  .claude/settings.json  — Hook configuration"
echo "  .fpf/*                 — FPF artifact workspace + templates"
echo ""
echo "Next steps:"
echo "  1. Review CLAUDE.md and adjust for your project"
echo "  2. Start a Claude Code session — Gate 0 will activate automatically"
echo "  3. Hooks enforce FPF gates mechanically (no manual discipline needed)"
echo ""
