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

# ---------------------------------------------------------------------------
# Status
# ---------------------------------------------------------------------------
cmd_status() {
    local state
    state="$(current_state)"
    local scope
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

    if [ "$scope" = "project" ] && [ -f "$CONFIG" ]; then
        local projects
        projects="$(jq -r '.projects[].path // empty' "$CONFIG" 2>/dev/null || true)"
        if [ -n "$projects" ]; then
            echo ""
            echo "  Registered projects:"
            while IFS= read -r p; do
                echo "    • $p"
            done <<< "$projects"
        fi
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
# Disable — user scope
# ---------------------------------------------------------------------------
disable_user_scope() {
    info "Disabling FPF (user scope)..."

    mkdir -p "$ARCHIVE/skills" "$ARCHIVE/hooks"

    # Archive fpf-* skills except fpf-active
    if [ -d "$CLAUDE_USER_DIR/skills" ]; then
        for d in "$CLAUDE_USER_DIR/skills/fpf-"*/; do
            [ -d "$d" ] || continue
            bname="$(basename "$d")"
            [ "$bname" = "fpf-active" ] && continue
            info "  Archiving skill: $bname"
            mv "$d" "$ARCHIVE/skills/"
        done
    fi

    # Archive fpf-* hooks
    if [ -d "$CLAUDE_USER_DIR/hooks" ]; then
        for f in "$CLAUDE_USER_DIR/hooks/fpf-"*.sh; do
            [ -f "$f" ] || continue
            bname="$(basename "$f")"
            info "  Archiving hook: $bname"
            mv "$f" "$ARCHIVE/hooks/"
        done
    fi

    # Surgical settings.json cleanup: remove fpf-* hook entries
    local settings="$CLAUDE_USER_DIR/settings.json"
    if [ -f "$settings" ] && [ -f "$ARCHIVE/user-settings-fpf.json" ]; then
        info "  Removing FPF hook entries from settings.json..."
        # Remove hook commands that reference fpf- scripts
        jq 'if .hooks then .hooks |= with_entries(
              .value |= map(
                .hooks |= map(select(.command | test("fpf-") | not))
              ) | map(select(.hooks | length > 0))
            ) else . end' \
            "$settings" > /tmp/fpf-settings-clean.json \
            && mv /tmp/fpf-settings-clean.json "$settings"
    elif [ -f "$settings" ]; then
        # No saved FPF contribution — strip all fpf- references
        info "  Removing FPF hook entries from settings.json (no saved contribution)..."
        jq 'if .hooks then .hooks |= with_entries(
              .value |= map(
                .hooks |= map(select(.command | test("fpf-") | not))
              ) | map(select(.hooks | length > 0))
            ) else . end' \
            "$settings" > /tmp/fpf-settings-clean.json \
            && mv /tmp/fpf-settings-clean.json "$settings"
    fi

    ok "User-scope FPF skills and hooks archived."
}

# ---------------------------------------------------------------------------
# Disable — project scope
# ---------------------------------------------------------------------------
disable_project_scope() {
    info "Disabling FPF (project scope)..."

    mkdir -p "$ARCHIVE/skills" "$ARCHIVE/hooks"

    if [ ! -f "$CONFIG" ]; then
        warn "No config.json found — nothing to disable."
        return
    fi

    local projects
    projects="$(jq -r '.projects[].path // empty' "$CONFIG" 2>/dev/null || true)"

    if [ -z "$projects" ]; then
        warn "No registered projects in config.json."
        return
    fi

    while IFS= read -r project_path; do
        [ -z "$project_path" ] && continue

        # Generate a stable hash for the project path
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

        # Archive settings.json (project settings.json is purely FPF)
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

    local scope
    scope="$(get_scope)"

    if [ "$scope" = "user" ]; then
        disable_user_scope
    else
        disable_project_scope
    fi

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
    if [ -d "$ARCHIVE/skills" ]; then
        for d in "$ARCHIVE/skills/fpf-"*/; do
            [ -d "$d" ] || continue
            bname="$(basename "$d")"
            info "  Restoring skill: $bname"
            mv "$d" "$CLAUDE_USER_DIR/skills/"
        done
    fi

    # Restore archived hooks
    if [ -d "$ARCHIVE/hooks" ]; then
        for f in "$ARCHIVE/hooks/fpf-"*.sh; do
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
            jq -s '
              def deep_merge(a; b):
                if (a | type) == "object" and (b | type) == "object" then
                  reduce (b | keys[]) as $k (a; .[$k] = deep_merge(a[$k]; b[$k]))
                elif (a | type) == "array" and (b | type) == "array" then
                  (a + b) | unique
                else b end;
              deep_merge(.[0]; .[1])
            ' "$settings" "$saved" > /tmp/fpf-settings-merged.json \
                && mv /tmp/fpf-settings-merged.json "$settings"
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
    projects="$(jq -r '.projects[].path // empty' "$CONFIG" 2>/dev/null || true)"

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

    local scope
    scope="$(get_scope)"

    if [ "$scope" = "user" ]; then
        enable_user_scope
    else
        enable_project_scope
    fi

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
