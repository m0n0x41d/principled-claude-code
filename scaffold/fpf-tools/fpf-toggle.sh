#!/usr/bin/env bash
# FPF global toggle — enable or disable FPF across all Claude Code sessions.
# Installed to: ~/.fpf/fpf-toggle.sh
# Usage: fpf-toggle.sh [status|enable|disable]

set -euo pipefail

FPF_DIR="$HOME/.fpf"
CONFIG="$FPF_DIR/config.json"
STATE_FILE="$FPF_DIR/global-state"
ARCHIVE="$FPF_DIR/archive"
CLAUDE_USER_DIR="$HOME/.claude"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf "[info]  %s\n" "$*"; }
ok()    { printf "[ok]    %s\n" "$*"; }
warn()  { printf "[warn]  %s\n" "$*"; }
err()   { printf "[error] %s\n" "$*" >&2; }
die()   { err "$@"; exit 1; }

# Safe temp file (avoids /tmp collisions)
safe_tmp() { mktemp "${TMPDIR:-/tmp}/fpf-toggle.XXXXXX"; }

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
command -v jq >/dev/null 2>&1 || die "jq is required but not found. Install it: https://jqlang.github.io/jq/download/"

# ---------------------------------------------------------------------------
# State readers
# ---------------------------------------------------------------------------
current_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "ENABLED"
    fi
}

get_scope() {
    if [ -f "$CONFIG" ]; then
        jq -r '.scope // "project"' "$CONFIG"
    else
        echo "project"
    fi
}

is_level0() {
    if [ -f "$CONFIG" ]; then
        jq -e '.level0 == true' "$CONFIG" >/dev/null 2>&1
    else
        return 1
    fi
}

get_project_paths() {
    if [ -f "$CONFIG" ]; then
        jq -r '.projects[].path // empty' "$CONFIG" 2>/dev/null || true
    fi
}

# ---------------------------------------------------------------------------
# CLAUDE.md management (physical move for all registered projects)
# ---------------------------------------------------------------------------
archive_claude_md() {
    local projects
    projects="$(get_project_paths)"
    [ -z "$projects" ] && return 0

    while IFS= read -r project_path; do
        [ -z "$project_path" ] && continue
        local claude_md="$project_path/CLAUDE.md"
        [ -f "$claude_md" ] || continue

        local phash
        phash="$(printf '%s' "$project_path" | shasum -a 256 | cut -c1-12)"
        mkdir -p "$ARCHIVE/project-$phash"
        info "  [$phash] Archiving CLAUDE.md"
        mv "$claude_md" "$ARCHIVE/project-$phash/CLAUDE.md"
    done <<< "$projects"
}

restore_claude_md() {
    local projects
    projects="$(get_project_paths)"
    [ -z "$projects" ] && return 0

    while IFS= read -r project_path; do
        [ -z "$project_path" ] && continue

        local phash
        phash="$(printf '%s' "$project_path" | shasum -a 256 | cut -c1-12)"
        local archived="$ARCHIVE/project-$phash/CLAUDE.md"
        [ -f "$archived" ] || continue

        info "  [$phash] Restoring CLAUDE.md"
        mv "$archived" "$project_path/CLAUDE.md"
    done <<< "$projects"
}

# ---------------------------------------------------------------------------
# Status
# ---------------------------------------------------------------------------
cmd_status() {
    local state scope
    state="$(current_state)"
    scope="$(get_scope)"

    echo ""
    echo "FPF Global State"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  State:  $state"
    echo "  Scope:  $scope"

    if is_level0; then
        echo "  Level0: true (tweakcc integration active)"
    else
        echo "  Level0: false"
    fi

    local projects
    projects="$(get_project_paths)"
    if [ -n "$projects" ]; then
        echo ""
        echo "  Registered projects:"
        while IFS= read -r p; do
            echo "    • $p"
        done <<< "$projects"
    fi

    echo ""

    if [ "$state" = "DISABLED" ]; then
        echo "  FPF is currently DISABLED."
        echo "  Skills and hooks are archived at $ARCHIVE"
        echo "  Run: bash ~/.fpf/fpf-toggle.sh enable"
    else
        echo "  FPF is currently ENABLED."
        echo "  Run: bash ~/.fpf/fpf-toggle.sh disable"
    fi
    echo ""
}

# ---------------------------------------------------------------------------
# Settings.json: remove FPF hook entries (shared by both scopes)
# ---------------------------------------------------------------------------
strip_fpf_from_settings() {
    local settings="$1"
    [ -f "$settings" ] || return 0

    info "  Removing FPF hook entries from settings.json..."
    local tmp
    tmp="$(safe_tmp)"
    jq 'if .hooks then .hooks |= with_entries(
          .value |= map(
            .hooks |= map(select(.command | test("fpf-") | not))
          ) | map(select(.hooks | length > 0))
        ) else . end' \
        "$settings" > "$tmp" \
        && mv "$tmp" "$settings" \
        || { rm -f "$tmp"; warn "Failed to clean settings.json"; }
}

# ---------------------------------------------------------------------------
# Disable — user scope
# ---------------------------------------------------------------------------
disable_user_scope() {
    info "Disabling FPF (user scope)..."

    mkdir -p "$ARCHIVE/skills/user" "$ARCHIVE/hooks/user"

    # Archive fpf-* skills except fpf-active
    if [ -d "$CLAUDE_USER_DIR/skills" ]; then
        for d in "$CLAUDE_USER_DIR/skills/fpf-"*/; do
            [ -d "$d" ] || continue
            bname="$(basename "$d")"
            [ "$bname" = "fpf-active" ] && continue
            info "  Archiving skill: $bname"
            mv "$d" "$ARCHIVE/skills/user/"
        done
    fi

    # Archive fpf-* hooks
    if [ -d "$CLAUDE_USER_DIR/hooks" ]; then
        for f in "$CLAUDE_USER_DIR/hooks/fpf-"*.sh; do
            [ -f "$f" ] || continue
            bname="$(basename "$f")"
            info "  Archiving hook: $bname"
            mv "$f" "$ARCHIVE/hooks/user/"
        done
    fi

    strip_fpf_from_settings "$CLAUDE_USER_DIR/settings.json"

    ok "User-scope FPF skills and hooks archived."
}

# ---------------------------------------------------------------------------
# Disable — project scope
# ---------------------------------------------------------------------------
disable_project_scope() {
    info "Disabling FPF (project scope)..."

    if [ ! -f "$CONFIG" ]; then
        warn "No config.json found — nothing to disable."
        return
    fi

    local projects
    projects="$(get_project_paths)"

    if [ -z "$projects" ]; then
        warn "No registered projects in config.json."
        return
    fi

    while IFS= read -r project_path; do
        [ -z "$project_path" ] && continue

        local phash
        phash="$(printf '%s' "$project_path" | shasum -a 256 | cut -c1-12)"
        local skill_archive="$ARCHIVE/skills/project-$phash"
        local hook_archive="$ARCHIVE/hooks/project-$phash"
        local settings_archive="$ARCHIVE/project-$phash"
        mkdir -p "$skill_archive" "$hook_archive" "$settings_archive"

        local proj_claude="$project_path/.claude"

        # Archive fpf-* skills
        if [ -d "$proj_claude/skills" ]; then
            for d in "$proj_claude/skills/fpf-"*/; do
                [ -d "$d" ] || continue
                bname="$(basename "$d")"
                info "  [$phash] Archiving skill: $bname"
                mv "$d" "$skill_archive/"
            done
        fi

        # Archive fpf-* hooks
        if [ -d "$proj_claude/hooks" ]; then
            for f in "$proj_claude/hooks/fpf-"*.sh; do
                [ -f "$f" ] || continue
                bname="$(basename "$f")"
                info "  [$phash] Archiving hook: $bname"
                mv "$f" "$hook_archive/"
            done
        fi

        # Archive settings.json
        if [ -f "$proj_claude/settings.json" ]; then
            info "  [$phash] Archiving settings.json"
            mv "$proj_claude/settings.json" "$settings_archive/settings.json"
        fi

        ok "  Project archived: $project_path"
    done <<< "$projects"
}

# ---------------------------------------------------------------------------
# Disable (main)
# ---------------------------------------------------------------------------
cmd_disable() {
    local state
    state="$(current_state)"
    if [ "$state" = "DISABLED" ]; then
        info "FPF is already disabled."
        return 0
    fi

    local scope errors=0
    scope="$(get_scope)"

    if [ "$scope" = "user" ]; then
        disable_user_scope || errors=$((errors + 1))
    else
        disable_project_scope || errors=$((errors + 1))
    fi

    # Archive CLAUDE.md from all registered projects
    archive_claude_md || errors=$((errors + 1))

    # tweakcc full restore
    if is_level0; then
        info "Restoring tweakcc system prompts..."
        if command -v npx >/dev/null 2>&1; then
            npx tweakcc --restore 2>/dev/null \
                && ok "tweakcc restored." \
                || warn "tweakcc restore failed — run 'npx tweakcc --restore' manually."
        else
            warn "npx not found — run 'npx tweakcc --restore' manually."
        fi
    fi

    if [ "$errors" -gt 0 ]; then
        warn "Completed with $errors error(s). State NOT changed — review output above."
        return 1
    fi

    echo "DISABLED" > "$STATE_FILE"
    ok "FPF disabled."
    echo ""
    echo "  Restart your Claude Code session for the change to take effect."
    echo "  Re-enable with: bash ~/.fpf/fpf-toggle.sh enable"
    echo ""
}

# ---------------------------------------------------------------------------
# Enable — user scope
# ---------------------------------------------------------------------------
enable_user_scope() {
    info "Enabling FPF (user scope)..."

    mkdir -p "$CLAUDE_USER_DIR/skills" "$CLAUDE_USER_DIR/hooks"

    # Restore archived skills
    if [ -d "$ARCHIVE/skills/user" ]; then
        for d in "$ARCHIVE/skills/user/fpf-"*/; do
            [ -d "$d" ] || continue
            bname="$(basename "$d")"
            info "  Restoring skill: $bname"
            mv "$d" "$CLAUDE_USER_DIR/skills/"
        done
    fi

    # Restore archived hooks
    if [ -d "$ARCHIVE/hooks/user" ]; then
        for f in "$ARCHIVE/hooks/user/fpf-"*.sh; do
            [ -f "$f" ] || continue
            bname="$(basename "$f")"
            info "  Restoring hook: $bname"
            mv "$f" "$CLAUDE_USER_DIR/hooks/"
            chmod +x "$CLAUDE_USER_DIR/hooks/$bname"
        done
    fi

    # Restore FPF hook entries in settings.json
    local settings="$CLAUDE_USER_DIR/settings.json"
    local saved="$ARCHIVE/user-settings-fpf.json"
    if [ -f "$saved" ]; then
        info "  Restoring FPF hook config in settings.json..."
        if [ -f "$settings" ]; then
            local tmp
            tmp="$(safe_tmp)"
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
            ' "$settings" "$saved" > "$tmp" \
                && mv "$tmp" "$settings" \
                || { rm -f "$tmp"; warn "Failed to merge settings.json"; }
        else
            cp "$saved" "$settings"
        fi
    fi

    ok "User-scope FPF skills and hooks restored."
}

# ---------------------------------------------------------------------------
# Enable — project scope
# ---------------------------------------------------------------------------
enable_project_scope() {
    info "Enabling FPF (project scope)..."

    if [ ! -f "$CONFIG" ]; then
        warn "No config.json found — cannot restore project files."
        return
    fi

    local projects
    projects="$(get_project_paths)"

    if [ -z "$projects" ]; then
        warn "No registered projects in config.json."
        return
    fi

    while IFS= read -r project_path; do
        [ -z "$project_path" ] && continue

        local phash
        phash="$(printf '%s' "$project_path" | shasum -a 256 | cut -c1-12)"
        local skill_archive="$ARCHIVE/skills/project-$phash"
        local hook_archive="$ARCHIVE/hooks/project-$phash"
        local settings_archive="$ARCHIVE/project-$phash"

        local proj_claude="$project_path/.claude"
        mkdir -p "$proj_claude/skills" "$proj_claude/hooks"

        # Restore skills
        if [ -d "$skill_archive" ]; then
            for d in "$skill_archive/fpf-"*/; do
                [ -d "$d" ] || continue
                bname="$(basename "$d")"
                info "  [$phash] Restoring skill: $bname"
                mv "$d" "$proj_claude/skills/"
            done
        fi

        # Restore hooks
        if [ -d "$hook_archive" ]; then
            for f in "$hook_archive/fpf-"*.sh; do
                [ -f "$f" ] || continue
                bname="$(basename "$f")"
                info "  [$phash] Restoring hook: $bname"
                mv "$f" "$proj_claude/hooks/"
                chmod +x "$proj_claude/hooks/$bname"
            done
        fi

        # Restore settings.json
        if [ -f "$settings_archive/settings.json" ]; then
            info "  [$phash] Restoring settings.json"
            mv "$settings_archive/settings.json" "$proj_claude/settings.json"
        fi

        ok "  Project restored: $project_path"
    done <<< "$projects"
}

# ---------------------------------------------------------------------------
# Enable (main)
# ---------------------------------------------------------------------------
cmd_enable() {
    local state
    state="$(current_state)"
    if [ "$state" = "ENABLED" ]; then
        info "FPF is already enabled."
        return 0
    fi

    local scope errors=0
    scope="$(get_scope)"

    if [ "$scope" = "user" ]; then
        enable_user_scope || errors=$((errors + 1))
    else
        enable_project_scope || errors=$((errors + 1))
    fi

    # Restore CLAUDE.md to all registered projects
    restore_claude_md || errors=$((errors + 1))

    # Re-apply tweakcc (level0)
    if is_level0; then
        info "Re-applying tweakcc system prompts..."
        if command -v npx >/dev/null 2>&1; then
            npx tweakcc --apply 2>/dev/null \
                && ok "tweakcc applied." \
                || warn "tweakcc apply failed — run 'npx tweakcc --apply' manually."
        else
            warn "npx not found — run 'npx tweakcc --apply' manually."
        fi
    fi

    if [ "$errors" -gt 0 ]; then
        warn "Completed with $errors error(s). State NOT changed — review output above."
        return 1
    fi

    echo "ENABLED" > "$STATE_FILE"
    ok "FPF enabled."
    echo ""
    echo "  Restart your Claude Code session for the change to take effect."
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "${1:-status}" in
    status)  cmd_status ;;
    enable)  cmd_enable ;;
    disable) cmd_disable ;;
    *)
        echo "Usage: $0 [status|enable|disable]" >&2
        exit 1
        ;;
esac
