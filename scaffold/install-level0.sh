#!/usr/bin/env bash
set -euo pipefail

# Level 0 — FPF tweakcc integration installer
# Applies FPF-modified system prompts to Claude Code via tweakcc.
#
# Usage:
#   ./scaffold/install-level0.sh          # install prompts + apply patches
#   ./scaffold/install-level0.sh --check  # dry-run: verify versions only
#   ./scaffold/install-level0.sh --diff   # show diffs between scaffold and installed prompts
#   ./scaffold/install-level0.sh --copy   # copy prompts only (don't apply patches)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/.level0-versions"
PROMPTS_DIR="$SCRIPT_DIR/tweakcc-prompts"

# ---------------------------------------------------------------------------
# Load pinned versions
# ---------------------------------------------------------------------------
if [[ ! -f "$VERSIONS_FILE" ]]; then
  echo "ERROR: $VERSIONS_FILE not found. Are you running from the repo root?" >&2
  exit 1
fi
source "$VERSIONS_FILE"

# ---------------------------------------------------------------------------
# Detect tweakcc prompt directory
# ---------------------------------------------------------------------------
detect_tweakcc_dir() {
  local candidates=(
    "$HOME/.tweakcc/system-prompts"
    "$HOME/.claude/tweakcc/system-prompts"
  )
  if [[ -n "${XDG_CONFIG_HOME:-}" ]]; then
    candidates+=("$XDG_CONFIG_HOME/tweakcc/system-prompts")
  fi
  for dir in "${candidates[@]}"; do
    if [[ -d "$dir" ]]; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Version checks
# ---------------------------------------------------------------------------
check_versions() {
  local ok=true

  # Claude Code version
  if ! command -v claude &>/dev/null; then
    echo "ERROR: claude not found in PATH" >&2
    ok=false
  else
    local cc_version
    cc_version="$(claude --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    if [[ "$cc_version" != "$CLAUDE_CODE_VERSION" ]]; then
      echo "WARNING: Claude Code version mismatch: installed=$cc_version, expected=$CLAUDE_CODE_VERSION" >&2
      echo "  Prompts are tested against $CLAUDE_CODE_VERSION. Other versions may work but are not validated." >&2
      ok=false
    else
      echo "OK: Claude Code $cc_version"
    fi
  fi

  # tweakcc prompt directory
  local tweakcc_dir
  if tweakcc_dir="$(detect_tweakcc_dir)"; then
    local count
    count="$(ls "$tweakcc_dir"/*.md 2>/dev/null | wc -l | tr -d ' ')"
    echo "OK: tweakcc prompts at $tweakcc_dir ($count files)"
  else
    echo "ERROR: tweakcc system-prompts directory not found." >&2
    echo "  Run 'npx tweakcc@$TWEAKCC_VERSION --apply' first to generate prompt files." >&2
    ok=false
  fi

  # Scaffold prompts exist
  local scaffold_count
  scaffold_count="$(ls "$PROMPTS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$scaffold_count" -eq 0 ]]; then
    echo "ERROR: No prompt files in $PROMPTS_DIR" >&2
    ok=false
  else
    echo "OK: $scaffold_count FPF prompt files in scaffold"
  fi

  if [[ "$ok" == true ]]; then
    echo ""
    echo "All checks passed."
    return 0
  else
    echo ""
    echo "Some checks failed. Review warnings above."
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Diff mode
# ---------------------------------------------------------------------------
show_diffs() {
  local tweakcc_dir
  tweakcc_dir="$(detect_tweakcc_dir)" || {
    echo "ERROR: tweakcc prompts not found. Run 'npx tweakcc@$TWEAKCC_VERSION --apply' first." >&2
    exit 1
  }

  local has_diff=false
  for scaffold_file in "$PROMPTS_DIR"/*.md; do
    local basename
    basename="$(basename "$scaffold_file")"
    local installed="$tweakcc_dir/$basename"

    if [[ ! -f "$installed" ]]; then
      echo "--- $basename: NOT FOUND in tweakcc (will be added)"
      has_diff=true
      continue
    fi

    if ! diff -q "$installed" "$scaffold_file" &>/dev/null; then
      echo "=== $basename ==="
      diff -u "$installed" "$scaffold_file" || true
      echo ""
      has_diff=true
    fi
  done

  if [[ "$has_diff" == false ]]; then
    echo "No differences. Scaffold prompts match installed versions."
  fi
}

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------
install_prompts() {
  local tweakcc_dir
  tweakcc_dir="$(detect_tweakcc_dir)" || {
    echo "ERROR: tweakcc prompts not found." >&2
    echo "Run these steps first:" >&2
    echo "  1. npx tweakcc@$TWEAKCC_VERSION" >&2
    echo "  2. npx tweakcc@$TWEAKCC_VERSION --apply" >&2
    exit 1
  }

  echo "Installing FPF Level 0 prompts..."
  echo "  Source: $PROMPTS_DIR"
  echo "  Target: $tweakcc_dir"
  echo ""

  local copied=0
  for scaffold_file in "$PROMPTS_DIR"/*.md; do
    local basename
    basename="$(basename "$scaffold_file")"
    local target="$tweakcc_dir/$basename"

    if [[ -f "$target" ]] && diff -q "$target" "$scaffold_file" &>/dev/null; then
      echo "  SKIP: $basename (already up to date)"
      continue
    fi

    cp "$scaffold_file" "$target"
    echo "  COPY: $basename"
    copied=$((copied + 1))
  done

  echo ""
  if [[ "$copied" -eq 0 ]]; then
    echo "Nothing to update — all prompts already match."
  else
    echo "Copied $copied file(s)."
  fi
}

# ---------------------------------------------------------------------------
# Apply tweakcc patches
# ---------------------------------------------------------------------------
apply_patches() {
  echo ""
  echo "Applying tweakcc patches to Claude Code..."
  if ! command -v npx &>/dev/null; then
    echo "ERROR: npx not found. Install Node.js 18+ first." >&2
    return 1
  fi
  npx "tweakcc@$TWEAKCC_VERSION" --apply
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "${1:-install}" in
  --check)
    check_versions
    ;;
  --diff)
    show_diffs
    ;;
  --copy)
    check_versions || {
      echo ""
      read -rp "Continue anyway? [y/N] " confirm
      [[ "$confirm" =~ ^[yY]$ ]] || exit 1
    }
    echo ""
    install_prompts
    echo ""
    echo "Prompts copied. Run 'npx tweakcc@$TWEAKCC_VERSION --apply' to patch cli.js."
    ;;
  install|"")
    check_versions || {
      echo ""
      read -rp "Continue anyway? [y/N] " confirm
      [[ "$confirm" =~ ^[yY]$ ]] || exit 1
    }
    echo ""
    install_prompts
    echo ""
    read -rp "Apply tweakcc patches to Claude Code now? [Y/n] " apply_confirm
    if [[ ! "$apply_confirm" =~ ^[nN]$ ]]; then
      apply_patches
    else
      echo "Skipped. Run 'npx tweakcc@$TWEAKCC_VERSION --apply' when ready."
    fi
    ;;
  *)
    echo "Usage: $0 [--check | --diff | --copy | install]" >&2
    exit 1
    ;;
esac
