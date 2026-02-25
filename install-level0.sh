#!/usr/bin/env bash
set -euo pipefail

# FPF Level 0 installer — tweakcc system prompt patching
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/m0n0x41d/principled-claude-code/main/install-level0.sh | bash
#   # or from a local clone:
#   ./install-level0.sh [--check | --diff | --copy]

REPO_URL="https://github.com/m0n0x41d/principled-claude-code.git"
BRANCH="main"

# --- Colors ---
if [ -t 1 ]; then
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
    BLUE='\033[0;34m' BOLD='\033[1m' RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

info()  { printf "${BLUE}[info]${RESET}  %s\n" "$*"; }
ok()    { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[warn]${RESET}  %s\n" "$*"; }
err()   { printf "${RED}[error]${RESET} %s\n" "$*" >&2; }
die()   { err "$@"; exit 1; }

prompt_user() {
    local question="$1" default="${2:-}" reply
    if [ -t 0 ]; then
        printf "${BOLD}%s${RESET} " "$question"
        read -r reply
    elif [ -e /dev/tty ]; then
        printf "${BOLD}%s${RESET} " "$question" >/dev/tty
        read -r reply </dev/tty
    else
        reply="$default"
    fi
    echo "${reply:-$default}"
}

# --- Locate scaffold files (local clone or download) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMPDIR_REPO=""

if [ -f "$SCRIPT_DIR/scaffold/.level0-versions" ] && [ -d "$SCRIPT_DIR/scaffold/tweakcc-prompts" ]; then
    # Running from local repo clone
    SCAFFOLD_DIR="$SCRIPT_DIR/scaffold"
else
    # Running via curl — clone to temp
    command -v git >/dev/null 2>&1 || die "'git' is required but not found."
    TMPDIR_REPO="$(mktemp -d)"
    trap 'rm -rf "$TMPDIR_REPO"' EXIT
    info "Downloading FPF Level 0 files..."
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR_REPO" 2>/dev/null \
        || die "Failed to clone repository."
    SCAFFOLD_DIR="$TMPDIR_REPO/scaffold"
    ok "Downloaded."
    echo ""
fi

VERSIONS_FILE="$SCAFFOLD_DIR/.level0-versions"
PROMPTS_DIR="$SCAFFOLD_DIR/tweakcc-prompts"

[ -f "$VERSIONS_FILE" ] || die "Version file not found: $VERSIONS_FILE"
[ -d "$PROMPTS_DIR" ]   || die "Prompts directory not found: $PROMPTS_DIR"

# shellcheck source=/dev/null
source "$VERSIONS_FILE"

echo ""
printf "${BOLD}FPF Level 0 — tweakcc System Prompt Patching${RESET}\n"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- Detect tweakcc prompt directory ---
detect_tweakcc_dir() {
    local candidates=(
        "$HOME/.tweakcc/system-prompts"
        "$HOME/.claude/tweakcc/system-prompts"
    )
    [ -n "${XDG_CONFIG_HOME:-}" ] && candidates+=("$XDG_CONFIG_HOME/tweakcc/system-prompts")
    for dir in "${candidates[@]}"; do
        [ -d "$dir" ] && echo "$dir" && return 0
    done
    return 1
}

# --- Version checks ---
check_versions() {
    local ok=true

    if ! command -v claude &>/dev/null; then
        err "claude not found in PATH"
        ok=false
    else
        local cc_version
        cc_version="$(claude --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        if [ "$cc_version" != "$CLAUDE_CODE_VERSION" ]; then
            warn "Claude Code version mismatch: installed=$cc_version, expected=$CLAUDE_CODE_VERSION"
            ok=false
        else
            ok "Claude Code $cc_version"
        fi
    fi

    local tweakcc_dir
    if tweakcc_dir="$(detect_tweakcc_dir)"; then
        local count
        count="$(find "$tweakcc_dir" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
        ok "tweakcc prompts at $tweakcc_dir ($count files)"
    else
        err "tweakcc system-prompts directory not found."
        info "Run 'npx tweakcc@$TWEAKCC_VERSION' then 'npx tweakcc@$TWEAKCC_VERSION --apply' first."
        ok=false
    fi

    local scaffold_count
    scaffold_count="$(find "$PROMPTS_DIR" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
    if [ "$scaffold_count" -eq 0 ]; then
        err "No prompt files in $PROMPTS_DIR"
        ok=false
    else
        ok "$scaffold_count FPF prompt files ready"
    fi

    echo ""
    if [ "$ok" = true ]; then
        ok "All checks passed."
        return 0
    else
        warn "Some checks failed. Review above."
        return 1
    fi
}

# --- Install prompts ---
install_prompts() {
    local tweakcc_dir
    tweakcc_dir="$(detect_tweakcc_dir)" || {
        err "tweakcc prompts not found."
        info "Run these steps first:"
        info "  1. npx tweakcc@$TWEAKCC_VERSION"
        info "  2. npx tweakcc@$TWEAKCC_VERSION --apply"
        exit 1
    }

    info "Installing FPF Level 0 prompts..."
    info "  Source: $PROMPTS_DIR"
    info "  Target: $tweakcc_dir"
    echo ""

    local copied=0
    for scaffold_file in "$PROMPTS_DIR"/*.md; do
        local base
        base="$(basename "$scaffold_file")"
        local target="$tweakcc_dir/$base"

        if [ -f "$target" ] && diff -q "$target" "$scaffold_file" &>/dev/null; then
            echo "  SKIP: $base (up to date)"
            continue
        fi

        cp "$scaffold_file" "$target"
        echo "  COPY: $base"
        copied=$((copied + 1))
    done

    echo ""
    if [ "$copied" -eq 0 ]; then
        ok "All prompts already up to date."
    else
        ok "Copied $copied file(s)."
    fi
}

# --- Show diffs ---
show_diffs() {
    local tweakcc_dir
    tweakcc_dir="$(detect_tweakcc_dir)" || die "tweakcc prompts not found."

    local has_diff=false
    for scaffold_file in "$PROMPTS_DIR"/*.md; do
        local base
        base="$(basename "$scaffold_file")"
        local installed="$tweakcc_dir/$base"

        if [ ! -f "$installed" ]; then
            echo "--- $base: NOT FOUND (will be added)"
            has_diff=true
            continue
        fi

        if ! diff -q "$installed" "$scaffold_file" &>/dev/null; then
            echo "=== $base ==="
            diff -u "$installed" "$scaffold_file" || true
            echo ""
            has_diff=true
        fi
    done

    $has_diff || ok "No differences. Prompts match."
}

# --- Apply patches ---
apply_patches() {
    echo ""
    info "Applying tweakcc patches to Claude Code..."
    command -v npx &>/dev/null || die "npx not found. Install Node.js 18+ first."
    npx "tweakcc@$TWEAKCC_VERSION" --apply
}

# --- Main ---
MODE="${1:-install}"

case "$MODE" in
    --check)
        check_versions
        ;;
    --diff)
        check_versions || true
        echo ""
        show_diffs
        ;;
    --copy)
        check_versions || {
            echo ""
            CONFIRM=$(prompt_user "Continue anyway? [y/N]:" "n")
            [[ "$CONFIRM" =~ ^[yY]$ ]] || exit 1
        }
        echo ""
        install_prompts
        echo ""
        info "Prompts copied. Run 'npx tweakcc@$TWEAKCC_VERSION --apply' to patch cli.js."
        ;;
    install|"")
        check_versions || {
            echo ""
            CONFIRM=$(prompt_user "Continue anyway? [y/N]:" "n")
            [[ "$CONFIRM" =~ ^[yY]$ ]] || exit 1
        }
        echo ""
        install_prompts
        echo ""
        APPLY=$(prompt_user "Apply tweakcc patches to Claude Code now? [Y/n]:" "y")
        if [[ ! "$APPLY" =~ ^[nN]$ ]]; then
            apply_patches
        else
            info "Skipped. Run 'npx tweakcc@$TWEAKCC_VERSION --apply' when ready."
        fi

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ok "FPF Level 0 installed."
        echo ""
        echo "What was patched:"
        echo "  • Context compaction preserves FPF state (tier, ADI phase, artifacts)"
        echo "  • Plan mode speaks FPF natively (hypotheses, Pareto, WLNK)"
        echo "  • Tone/style includes L0-L2 confidence labels and WLNK+MONO"
        echo "  • Subagent prompts are FPF-aware (evidence, parity, weakest link)"
        echo ""
        ;;
    *)
        echo "Usage: install-level0.sh [--check | --diff | --copy | install]" >&2
        exit 1
        ;;
esac