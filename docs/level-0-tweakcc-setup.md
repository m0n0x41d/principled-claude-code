# Level 0 — System-Level FPF Integration via tweakcc

> **Status:** Experimental. Tested with Claude Code **2.1.52** + tweakcc **4.0.8**.
> Last updated: 2026-02-25.

## What this is

FPF operates at two levels:

| Level | Mechanism | Fragility | Who it's for |
|-------|-----------|-----------|--------------|
| **Layer 1** (default) | CLAUDE.md + hooks + skills | Survives CC updates | Everyone |
| **Level 0** (this guide) | tweakcc system prompt patches + toolsets | Likely to break on CC updates | Claude Code hackers |

**Layer 1** is what you get out of the box with this repository. It works by putting instructions in CLAUDE.md, enforcing gates via hooks, and providing structured thinking via skills. This is safe, portable, and CC-update-compatible.

**Level 0** goes deeper. It uses [tweakcc](https://github.com/Piebald-AI/tweakcc) to modify Claude Code's **system prompts** — the built-in instructions that shape how the model thinks, plans, summarizes, and delegates. This is more powerful but fragile: every CC update can break patches.

## Why Level 0 matters

Layer 1 instructions in CLAUDE.md compete for the model's attention with Anthropic's own system prompts. When there's a conflict (e.g., your CLAUDE.md says "always generate 3 hypotheses" but the system prompt says "get to the point quickly"), the system prompt often wins because it's structurally prioritized.

Level 0 resolves this by modifying the system prompts themselves. Key benefits:

1. **Context compaction preserves FPF state.** When the context window fills up and CC summarizes the conversation, the default summarizer doesn't know about PROB-*, EVID-*, or active gates. After compaction, the model "forgets" the FPF session. A modified compaction prompt preserves tier, stage, hypotheses, and artifact references.

2. **Plan mode speaks FPF natively.** CC's 5-phase plan mode (explore → design → review → plan → exit) maps well onto FPF's T3-T4 protocol. Modifying the plan mode prompt makes it use FPF vocabulary and produce FPF artifacts directly.

3. **Toolsets enforce gates structurally.** Layer 1 hooks can be denied by the user. tweakcc toolsets make tools *invisible* to the model — a research-only toolset physically removes Write/Edit/Bash, not just blocks them with a hook.

4. **Subagent models match FPF's BLP principle.** You can set Plan agents to Opus (deeper reasoning for T3-T4 problem framing) and Explore agents to Haiku (fast, cheap codebase scanning).

5. **Confidence labels in the system prompt.** Instead of relying on CLAUDE.md to inject "mark L0-L2 on claims," the tone/style system prompt itself can require it.

## Prerequisites

- macOS or Linux
- Node.js 18+ and npm/pnpm
- Claude Code installed (npm or native binary)
- This repository (principled-claude-code) cloned and Layer 1 working

## Critical: Disable Claude Code auto-updates

**You must disable auto-updates before proceeding.** tweakcc patches are applied to a specific version of Claude Code's compiled JavaScript. When CC auto-updates, it overwrites the patched files with a fresh version, destroying all modifications.

```bash
# Check your current CC version (pin this)
claude --version
```

To disable auto-updates, add this to your **user-level** settings (`~/.claude/settings.json`):

```json
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

If the file already has other settings, merge the `env` block into it. Alternatively, if you prefer to keep updates but on a delayed schedule (one week behind, skipping regressed versions), use:

```json
{
  "autoUpdatesChannel": "stable"
}
```

After disabling auto-updates, you should keep track of releases to groom your FOMO:
- CC releases: [npmjs.com/@anthropic-ai/claude-code](https://www.npmjs.com/package/@anthropic-ai/claude-code)
- tweakcc releases: [github.com/Piebald-AI/tweakcc/releases](https://github.com/Piebald-AI/tweakcc/releases)
- This repository for updated prompt modifications
- Update manually when all three are compatible

**Why this trade-off is worth it:** A stable, deeply-tuned setup beats a frequently-updating generic one — as long as you control the update cadence.

## Installation

### Step 1: Install tweakcc

```bash
npx tweakcc@4.0.8
```

This launches the interactive TUI. On first run it will:
- Detect your CC installation
- Create config at `~/.tweakcc/` (or `~/.claude/tweakcc/`)
- Download system prompt data for your CC version
- Apply default patches

Let it finish, then exit the TUI.

### Step 2: Apply initial tweakcc patches

```bash
npx tweakcc@4.0.8 --apply
```

This creates 160+ editable prompt markdown files in `~/.tweakcc/system-prompts/` and applies binary patches. You'll see some `✗` failures for cosmetic patches (patchesAppliedIndication, worktreeMode) — these don't affect system prompt patching.

### Step 3: Copy FPF-modified prompts

This repository ships pre-modified prompt files in `scaffold/tweakcc-prompts/`. These are full replacements — they overwrite the originals.

```bash
# From the principled-claude-code repo root:
./scaffold/install-level0.sh
```

Or manually: `cp scaffold/tweakcc-prompts/*.md ~/.tweakcc/system-prompts/`

The install script also supports `--check` (verify versions only) and `--diff` (show what would change).

This overwrites 7 prompt files with FPF-aware versions:

| File | What changes |
|------|-------------|
| `system-prompt-context-compaction-summary.md` | Preserves FPF state (tier, stage, ADI phase, Pareto front, artifacts, gates) + design-time/run-time split |
| `agent-prompt-conversation-summarization.md` | Adds section 9 (FPF Session State) with ADI phase tracking and Pareto front status |
| `system-prompt-tone-and-style.md` | Adds reliability + scope labels (L0-L2, this-project/this-stack/universal) + Strict Distinction guard |
| `system-reminder-plan-mode-is-active-5-phase.md` | FPF Integration: ADI-aligned phases, NQD (hold Pareto front), Parity, BLP, Anti-Goodhart |
| `system-prompt-doing-tasks.md` | Adds Strict Distinction: plan ≠ evidence, spec ≠ capability, work plan ≠ work done |
| `agent-prompt-task-tool.md` | Subagents structure findings as evidence with parity and WLNK awareness |
| `agent-prompt-explore.md` | Explore agent organizes findings along FPF dimensions + WLNK in architecture mapping |

### Step 4: Re-apply patches with modified prompts

```bash
npx tweakcc@4.0.8 --apply
```

This time tweakcc will patch cli.js with your FPF-modified prompts. You should see character count changes for the modified files (e.g. "42 more chars").

### Step 5: Verify

```bash
claude
```

Start a session and verify:
- FPF gates still work (hooks are independent of tweakcc)
- Enter plan mode — the plan workflow should mention FPF Integration
- In a long session, check that context compaction preserves FPF state

## What's Modified and Why

The prompt files in `scaffold/tweakcc-prompts/` are full copies of the originals with targeted FPF additions. Diffs are minimal and surgical — we don't rewrite Anthropic's prompts, we extend them.

**Context compaction** (the biggest win): When the context window fills up, CC summarizes the conversation and drops old messages. Without modification, this summary loses all FPF state — which tier you're on, which artifacts exist, which hypotheses are alive. The modified prompt adds an "FPF Session State" section that preserves tier, stage, ADI phase, Pareto front status, and design-time vs run-time distinction across compaction events.

**Conversation summarization**: Same idea but for the detailed summary agent. Adds section 9 with FPF artifact inventory, ADI phase per hypothesis, and Pareto front tracking.

**Tone and style**: Adds reliability labels (L0/L1/L2) with separate scope annotations (this-project/this-stack/universal) — these are independent dimensions per FPF-Spec.md's F-G-R model. Also adds a Strict Distinction guard: distinguish plans from evidence, specs from capabilities.

**Plan mode**: Adds an "FPF Integration" block before Phase 1 that maps CC's 5 phases to the ADI cycle (Abduction → Deduction → Induction). Includes: NQD (hold the Pareto front, don't collapse to single winner), Parity (ensure fair comparison), BLP (justify hand-tuned over general), Anti-Goodhart (separate monitoring from optimization targets). All template variables preserved intact.

**Doing tasks**: Adds one line reinforcing the Strict Distinction: a spec is not proof of capability, a work plan is not evidence of work done.

**Task tool and Explore agent**: Adds parity, WLNK, and prediction-before-testing awareness. Minimal intrusion, activated only when FPF context is passed in the delegation prompt.

To see the exact diffs, compare `scaffold/tweakcc-prompts/*.md` against `~/.tweakcc/system-prompts/*.md` after a fresh `npx tweakcc --apply` (before copying our files).

---

## Toolset Configuration (Optional)

tweakcc can define toolsets that restrict which tools the model sees. This provides structural enforcement stronger than hooks.

Run `npx tweakcc@4.0.8` and navigate to "Toolsets" to configure:

### Research-Only Toolset

For FPF's "problem factory" phase where you want pure investigation without edits:

```json
{
  "name": "fpf-research",
  "allowedTools": [
    "Read", "Glob", "Grep", "WebFetch", "WebSearch",
    "Task", "AskUserQuestion", "Skill", "ToolSearch"
  ]
}
```

### Full Toolset (default)

For implementation phases:

```json
{
  "name": "fpf-full",
  "allowedTools": "*"
}
```

### Switching between toolsets

Once configured, use `/toolset fpf-research` before problem framing and `/toolset fpf-full` before implementation. You can also set `fpf-research` as the plan mode toolset in tweakcc config, so entering plan mode automatically restricts tools.

## Subagent Model Configuration (Optional)

Navigate to "Subagent models" in tweakcc to configure:

| Agent | Recommended model | Rationale |
|-------|------------------|-----------|
| Plan | `claude-opus-4-6` | Deeper reasoning for T3-T4 problem framing and architectural decisions |
| Explore | `claude-haiku-4-5-20251001` | Fast, cheap codebase scanning — BLP principle |
| General-purpose | (leave default) | Inherits from main model |

This aligns with FPF's BLP (Better Learning/scaling Properties) principle: use the most capable model where reasoning depth matters, and the cheapest model where speed matters.

## Applying Patches

After making modifications:

```bash
npx tweakcc@4.0.8 --apply
```

tweakcc will:
1. Read your modified markdown files
2. Find the corresponding strings in CC's compiled JavaScript
3. Replace them with your versions
4. Report which prompts were patched and character count changes

Verify patches were applied:

```bash
# Start Claude Code — you should see "tweakcc patches applied" in the startup
claude
```

## Maintaining Your Setup

### When Claude Code updates

If you accidentally update CC (or want to update intentionally):

1. Check the new CC version: `claude --version`
2. Check tweakcc compatibility: see [tweakcc releases](https://github.com/Piebald-AI/tweakcc/releases)
3. Update tweakcc if needed: `npx tweakcc@latest`
4. Re-sync prompts: tweakcc will detect version changes and offer to merge your modifications with the new prompt versions
5. Re-apply: `npx tweakcc --apply`
6. Test: start a Claude Code session and verify FPF gates work

### When this repository updates

Check [principled-claude-code releases](https://github.com/user/principled-claude-code/releases) for updated prompt modifications. The modifications in this guide are pinned to specific CC/tweakcc versions and may need adjustment.

### Conflict resolution

When both you and Anthropic have modified the same prompt, tweakcc shows a diff and lets you merge. Generally:
- Anthropic's structural changes (new template variables, reorganized sections) should be accepted
- Your FPF additions should be re-applied on top
- If a prompt was completely rewritten by Anthropic, re-read it before adding FPF content

## Version Compatibility Matrix

| principled-claude-code | Claude Code | tweakcc | Status |
|----------------------|-------------|---------|--------|
| current (main) | 2.1.52 | 4.0.8 | Tested |

These versions are also pinned in `scaffold/.level0-versions`. The install script checks them before applying.

This matrix will be updated as new versions are validated. Do not assume forward compatibility — always check before updating any component.

## Troubleshooting

### "Prompts file not found for Claude Code vX.Y.Z"

```
✖ Error downloading system prompts:
  Prompts file not found for Claude Code v2.1.55.
  This version was released within the past day or so
  and will be supported within a few hours.

⚠ System prompts not available – skipping system prompt customizations
```

This is the **version drift race condition** — your CC version is newer than the prompt data tweakcc has available. It happens when CC auto-updates (or you update manually) before tweakcc's prompt database catches up. Binary patches (toolsets, UI tweaks, subagent models) will still apply, but all system prompt modifications are skipped.

What to do:
1. **Wait.** tweakcc typically adds prompt support within hours of a CC release. Check [tweakcc releases](https://github.com/Piebald-AI/tweakcc/releases) or run `npx tweakcc@latest --apply` later.
2. **Pin harder.** This is exactly why we recommend disabling auto-updates. If you pinned CC and tweakcc to known-compatible versions from the matrix above, this won't happen.
3. **Don't panic.** Layer 1 (CLAUDE.md + hooks + skills) still works fine without system prompt patches. You lose Level 0 depth but FPF itself keeps functioning.

### "Could not find system prompt X in cli.js"

The prompt's regex pattern doesn't match your CC version. This usually means CC was updated. Check `claude --version` against the compatibility matrix.

### Some patches show ✖ failures

Binary patches like `patchesAppliedIndication`, `worktreeMode`, or `getReactVar` may fail on certain CC builds (especially native binary vs npm installs). These are cosmetic/feature patches unrelated to system prompt modifications. If the system prompt patches applied successfully, FPF Level 0 is working.

### Patches applied but behavior unchanged

Some prompts are conditionally loaded. For example, plan mode prompts only activate when you enter plan mode. The compaction prompt only fires during context compaction (long sessions).

### tweakcc config directory

tweakcc stores its config and prompt files in one of:
- `~/.tweakcc/` (default/legacy)
- `~/.claude/tweakcc/` (Claude ecosystem alignment)
- `$XDG_CONFIG_HOME/tweakcc/` (XDG compliance)

Check which is active: the TUI shows the config path at the top.

### Rolling back

To restore vanilla CC without patches:

```bash
npx tweakcc@4.0.8
# Select "Restore original Claude Code"
```

This restores from backup without touching your config or modified prompts.
