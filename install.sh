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

# --- Scope prompt ---
echo "Install FPF skills and hooks:"
echo "  [1] Per-project (default) — installed in this project's .claude/ directory"
echo "  [2] Globally — installed in ~/.claude/, visible in all your projects"
echo "      Enables clean global enable/disable via /fpf-active"
echo ""
SCOPE_CHOICE=$(prompt_user "Choice [1/2]:" "1")
case "$SCOPE_CHOICE" in
    2) INSTALL_SCOPE="user" ;;
    *) INSTALL_SCOPE="project" ;;
esac
info "Scope: $INSTALL_SCOPE"
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

# --- Set up ~/.fpf/ state infrastructure (always, regardless of scope) ---
FPF_STATE_DIR="$HOME/.fpf"
FPF_CONFIG="$FPF_STATE_DIR/config.json"
FPF_STATE_FILE="$FPF_STATE_DIR/global-state"
CLAUDE_USER_DIR="$HOME/.claude"

info "Setting up FPF state directory at ~/.fpf/ ..."
mkdir -p "$FPF_STATE_DIR/archive/skills" "$FPF_STATE_DIR/archive/hooks"

# Install toggle script
cp -p "$SCAFFOLD_DIR/fpf-tools/fpf-toggle.sh" "$FPF_STATE_DIR/fpf-toggle.sh"
chmod +x "$FPF_STATE_DIR/fpf-toggle.sh"
ok "  Installed ~/.fpf/fpf-toggle.sh"

# Install fpf-active skill (always user-scope, never toggled)
mkdir -p "$CLAUDE_USER_DIR/skills/fpf-active"
cp -p "$SCAFFOLD_DIR/.claude/skills/fpf-active/SKILL.md" \
    "$CLAUDE_USER_DIR/skills/fpf-active/SKILL.md"
ok "  Installed ~/.claude/skills/fpf-active/"

# Write/update config.json
INSTALL_TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
if [ ! -f "$FPF_CONFIG" ]; then
    printf '{"version":1,"scope":"%s","level0":false,"projects":[]}\n' \
        "$INSTALL_SCOPE" > "$FPF_CONFIG"
else
    # Update scope in existing config
    jq --arg scope "$INSTALL_SCOPE" '.scope = $scope' "$FPF_CONFIG" \
        > /tmp/fpf-config-tmp.json && mv /tmp/fpf-config-tmp.json "$FPF_CONFIG"
fi

# Write initial state
if [ ! -f "$FPF_STATE_FILE" ]; then
    echo "ENABLED" > "$FPF_STATE_FILE"
fi

ok "  Wrote ~/.fpf/config.json (scope: $INSTALL_SCOPE)"
echo ""

# --- Copy scaffold files (scope-conditional) ---
info "Installing FPF scaffold..."

CREATED=0
OVERWRITTEN=0
HOOKS_EXEC=0

if [ "$INSTALL_SCOPE" = "user" ]; then
    # User-scope: copy skills and hooks to ~/.claude/, not to TARGET_DIR/.claude/
    # Project artifacts (CLAUDE.md, .fpf/) still go to TARGET_DIR/

    # First pass: project artifacts (CLAUDE.md, .fpf/, fpf-tools/, install-level0.sh, .level0-versions)
    while IFS= read -r -d '' src_file; do
        rel="${src_file#"$SCAFFOLD_DIR/"}"
        case "$(basename "$src_file")" in
            .DS_Store) continue ;;
            FPF-Spec.md) continue ;;
        esac

        # Skip .claude/ contents (handled separately) and fpf-tools/
        case "$rel" in
            .claude/*) continue ;;
            fpf-tools/*) continue ;;
        esac

        dst="$TARGET_DIR/$rel"
        existed=false
        [ -e "$dst" ] && existed=true
        mkdir -p "$(dirname "$dst")"
        cp -p "$src_file" "$dst"

        if $existed; then OVERWRITTEN=$((OVERWRITTEN + 1))
        else CREATED=$((CREATED + 1)); fi
    done < <(find "$SCAFFOLD_DIR" -type f -print0 | sort -z)

    # Second pass: fpf-* skills (except fpf-active, already installed) → ~/.claude/skills/
    mkdir -p "$CLAUDE_USER_DIR/skills" "$CLAUDE_USER_DIR/hooks"

    # Save FPF hook config contribution for later restore
    FPF_HOOK_CONTRIBUTION="$FPF_STATE_DIR/archive/user-settings-fpf.json"
    if [ -f "$SCAFFOLD_DIR/.claude/settings.json" ]; then
        cp -p "$SCAFFOLD_DIR/.claude/settings.json" "$FPF_HOOK_CONTRIBUTION"
    fi

    while IFS= read -r -d '' src_file; do
        rel="${src_file#"$SCAFFOLD_DIR/"}"
        case "$(basename "$src_file")" in
            .DS_Store) continue ;;
            FPF-Spec.md) continue ;;
        esac

        case "$rel" in
            .claude/skills/fpf-*/*)
                skill_dir="$(echo "$rel" | cut -d/ -f3)"
                [ "$skill_dir" = "fpf-active" ] && continue  # already installed
                dst="$CLAUDE_USER_DIR/${rel#.claude/}"
                existed=false; [ -e "$dst" ] && existed=true
                mkdir -p "$(dirname "$dst")"
                cp -p "$src_file" "$dst"
                if $existed; then OVERWRITTEN=$((OVERWRITTEN + 1))
                else CREATED=$((CREATED + 1)); fi
                ;;
            .claude/hooks/fpf-*.sh)
                dst="$CLAUDE_USER_DIR/${rel#.claude/}"
                existed=false; [ -e "$dst" ] && existed=true
                mkdir -p "$(dirname "$dst")"
                cp -p "$src_file" "$dst"
                chmod +x "$dst"
                HOOKS_EXEC=$((HOOKS_EXEC + 1))
                if $existed; then OVERWRITTEN=$((OVERWRITTEN + 1))
                else CREATED=$((CREATED + 1)); fi
                ;;
        esac
    done < <(find "$SCAFFOLD_DIR" -type f -print0 | sort -z)

    # Merge FPF hook config into ~/.claude/settings.json
    SCAFFOLD_SETTINGS="$SCAFFOLD_DIR/.claude/settings.json"
    USER_SETTINGS="$CLAUDE_USER_DIR/settings.json"
    if [ -f "$SCAFFOLD_SETTINGS" ]; then
        mkdir -p "$CLAUDE_USER_DIR"
        if [ -f "$USER_SETTINGS" ]; then
            info "Merging FPF hook config into ~/.claude/settings.json ..."
            # Merge: for each hook event, append FPF entries (avoid duplicates by command)
            jq -s '
              def merge_hooks(base; fpf):
                reduce (fpf | keys[]) as $event (
                  base;
                  .[$event] = (
                    (.[$event] // []) +
                    (fpf[$event] | map(
                      . as $entry |
                      if (base[$event] // [] | map(.hooks[].command) | any(. == ($entry.hooks[0].command)))
                      then empty else $entry end
                    ))
                  )
                );
              .[0] as $base | .[1] as $fpf |
              $base | .hooks = merge_hooks($base.hooks // {}; $fpf.hooks // {})
            ' "$USER_SETTINGS" "$SCAFFOLD_SETTINGS" \
                > /tmp/fpf-settings-merged.json \
                && mv /tmp/fpf-settings-merged.json "$USER_SETTINGS"
            ok "Merged FPF hooks into ~/.claude/settings.json"
        else
            # No existing settings — adapt FPF settings for user-scope paths
            # (hooks use $CLAUDE_PROJECT_DIR which still works for project-scoped hooks,
            #  but for user-scope we reference hooks by absolute path)
            cp -p "$SCAFFOLD_SETTINGS" "$USER_SETTINGS"
            ok "Installed FPF hooks config to ~/.claude/settings.json"
        fi
    fi

else
    # Project-scope (default): current behavior — copy everything to TARGET_DIR/
    while IFS= read -r -d '' src_file; do
        rel="${src_file#"$SCAFFOLD_DIR/"}"

        # Skip fpf-active (installed user-scope) and fpf-tools/
        case "$rel" in
            .claude/skills/fpf-active/*) continue ;;
            fpf-tools/*) continue ;;
        esac

        # Skip junk and large reference files (downloaded separately)
        case "$(basename "$src_file")" in
            .DS_Store) continue ;;
            FPF-Spec.md) continue ;;
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

    # Register this project in config.json
    jq --arg path "$TARGET_DIR" --arg ts "$INSTALL_TIMESTAMP" \
        'if (.projects | map(.path) | any(. == $path)) then .
         else .projects += [{"path": $path, "installed_at": $ts}] end' \
        "$FPF_CONFIG" > /tmp/fpf-config-tmp.json \
        && mv /tmp/fpf-config-tmp.json "$FPF_CONFIG"
    ok "  Registered project in ~/.fpf/config.json"
fi

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ok "FPF installed successfully!"
echo ""
printf "  Files created:      %d\n" "$CREATED"
printf "  Files overwritten:  %d\n" "$OVERWRITTEN"
printf "  Hooks made exec:    %d\n" "$HOOKS_EXEC"

# --- Optional: download FPF reference spec ---
if [ "$INSTALL_SCOPE" = "user" ]; then
    FPF_SPEC_DIR="$CLAUDE_USER_DIR/skills/fpf-core/reference"
else
    FPF_SPEC_DIR="$TARGET_DIR/.claude/skills/fpf-core/reference"
fi
FPF_SPEC_FILE="$FPF_SPEC_DIR/FPF-Spec.md"
if [ ! -f "$FPF_SPEC_FILE" ]; then
    echo ""
    DOWNLOAD_SPEC=$(prompt_user "Download FPF reference spec (~3MB, searchable but never loaded into context)? [Y/n]:" "y")
    DOWNLOAD_SPEC="$(echo "$DOWNLOAD_SPEC" | tr '[:upper:]' '[:lower:]')"
    if [ "$DOWNLOAD_SPEC" != "n" ] && [ "$DOWNLOAD_SPEC" != "no" ]; then
        mkdir -p "$FPF_SPEC_DIR"
        FPF_SPEC_URL="https://raw.githubusercontent.com/m0n0x41d/principled-claude-code/main/scaffold/.claude/skills/fpf-core/reference/FPF-Spec.md"
        if curl -fsSL "$FPF_SPEC_URL" -o "$FPF_SPEC_FILE" 2>/dev/null; then
            ok "FPF spec downloaded to .claude/skills/fpf-core/reference/FPF-Spec.md"
        else
            warn "Could not download FPF spec. You can add it manually later."
        fi
    else
        info "Skipped FPF spec download. Add it later if needed for deep reference searches."
    fi
fi

if [ -n "$BACKUP_DIR" ]; then
    printf "  Backup location:    %s\n" "$BACKUP_DIR"
fi

echo ""
printf "${BOLD}Target:${RESET} %s\n" "$TARGET_DIR"
echo ""
echo "What was installed:"
echo "  CLAUDE.md              — FPF project instructions"
if [ "$INSTALL_SCOPE" = "user" ]; then
    echo "  ~/.claude/skills/*     — FPF slash commands (global, all projects)"
    echo "  ~/.claude/hooks/*      — Mechanical enforcement hooks (global)"
    echo "  ~/.claude/settings.json — Hook configuration (merged)"
else
    echo "  .claude/skills/*       — FPF slash commands (/fpf-core, /fpf-evidence, ...)"
    echo "  .claude/hooks/*        — Mechanical enforcement hooks"
    echo "  .claude/settings.json  — Hook configuration"
fi
echo "  .fpf/*                 — FPF artifact workspace + templates"
echo "  ~/.claude/skills/fpf-active/ — permanent FPF toggle (/fpf-active)"
echo "  ~/.fpf/                — FPF state and archive directory"
echo ""
echo "Next steps:"
echo "  1. Review CLAUDE.md and adjust for your project"
echo "  2. Start a Claude Code session — Gate 0 will activate automatically"
echo "  3. Hooks enforce FPF gates mechanically (no manual discipline needed)"
echo "  4. Use /fpf-active to enable or disable FPF globally at any time"
echo ""
