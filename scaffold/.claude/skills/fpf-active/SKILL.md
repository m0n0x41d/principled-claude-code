---
name: fpf-active
description: >
  FPF global toggle and status. Check whether FPF is enabled or disabled globally.
  Enable or disable FPF across all Claude Code sessions. Triggers on "fpf status",
  "fpf on", "fpf off", "enable fpf", "disable fpf", "is fpf active", "/fpf-active".
---

# FPF Active — Global Toggle

## What this skill does

This skill manages the FPF global on/off switch. FPF can be enabled or disabled globally
across all Claude Code sessions. When disabled, skills are physically archived, hooks
stop running, and CLAUDE.md is moved out — FPF becomes invisible until re-enabled.

**This skill itself is never toggled.** It lives at `~/.claude/skills/fpf-active/` permanently
and remains available whether FPF is enabled or disabled.

## Usage

Invoke with one of:
- `/fpf-active` — show status
- `/fpf-active status` — show status
- `/fpf-active enable` — enable FPF globally
- `/fpf-active disable` — disable FPF globally

## How to execute

### Step 1: Read current state

Use the Read tool to read these files (they may not exist yet):
- `~/.fpf/global-state` — contains `ENABLED` or `DISABLED`
- `~/.fpf/config.json` — contains scope, level0 flag, registered projects

### Step 2: Display status

Report:
- **State:** ENABLED / DISABLED / NOT INSTALLED
- **Scope:** user / project
- **Level0:** true/false (tweakcc integration)
- **Config path:** `~/.fpf/config.json`
- **Toggle script:** `~/.fpf/fpf-toggle.sh`
- List registered project paths from config.json

### Step 3: For enable/disable actions

Run the toggle script using the Bash tool:

```bash
bash ~/.fpf/fpf-toggle.sh [enable|disable]
```

The script handles all file moves (skills, hooks, settings.json, CLAUDE.md) and tweakcc restore/apply.

### Step 4: After toggling

Always remind the user:
> **Restart your Claude Code session** for the change to take effect.
> Skills and hooks are only loaded at session start.

If the toggle script is not found:
> `~/.fpf/fpf-toggle.sh` not found. FPF may not be installed or was installed without
> the toggle infrastructure. Re-run the installer to fix this.
