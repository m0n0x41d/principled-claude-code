# Principled Claude Code

Implementation of the [First Principles Framework (FPF)](https://github.com/ailev/FPF) for Claude Code.

FPF is a systems engineering methodology built on double-loop cycles: a problem factory (problematization, characterization, building variant portfolios) and a solution factory (selecting a point on the Pareto front, implementation, verification). See the [FPF repository](https://github.com/ailev/FPF) for the full methodology.

This project implements FPF as a **double-loop workflow** for Claude Code:

1. **Problem factory** — problematization, characterization, problem portfolios → produces acceptance specs.
2. **Solution factory** — SoTA harvesting, variant generation (NQD), Pareto selection, implementation, verification → produces tested solutions.

Both **creativity** (generating novel options, surveying existing approaches) and **assurance** (evidence records, audit trail, F-G-R tracking) are first-class concerns — neither is subordinated to the other.

## Install

Run this in your project directory:

```bash
curl -fsSL https://raw.githubusercontent.com/m0n0x41d/principled-claude-code/main/install.sh | bash
```

Or install into a specific directory:

```bash
curl -fsSL https://raw.githubusercontent.com/m0n0x41d/principled-claude-code/main/install.sh | bash -s -- /path/to/project
```

### Conflict handling

If the installer detects existing Claude artifacts (`CLAUDE.md`, `.claude/`, `.fpf/`), it will prompt you:

- **Backup** (default) — saves your existing files to `.backup/<timestamp>/` before installing
- **Override** — replaces existing files without backup
- **Cancel** — aborts installation

Your original configuration is never silently overwritten.

## What gets installed

```
your-project/
├── CLAUDE.md                    # FPF project instructions (double-loop workflow + gates)
├── .claude/
│   ├── settings.json            # Hook configuration
│   ├── hooks/                   # Mechanical gate enforcement
│   │   ├── fpf-enforce-gate0.sh           # Blocks Write/Edit without sentinel
│   │   ├── fpf-enforce-gate0-research.sh  # Blocks Read/Glob/Grep/Bash/Task without sentinel
│   │   ├── fpf-enforce-artifact-deps.sh   # Blocks SPORT-* without CHR-*, SEL-* without SPORT-*
│   │   ├── fpf-gate-check.sh
│   │   ├── fpf-prompt-reminder.sh
│   │   ├── fpf-session-cleanup.sh
│   │   └── fpf-track-source-edits.sh
│   └── skills/
│       │                        # ── Session discipline ──
│       ├── fpf-core/            # Session bootstrap + FPF rules
│       ├── fpf-worklog/         # Session logging (plan vs reality)
│       ├── fpf-review/          # End-of-session quality gate
│       │                        # ── Problem factory ──
│       ├── fpf-problem-framing/ # Anomaly records + problem cards
│       ├── fpf-characterize/    # Characterization passports + characteristic cards
│       ├── fpf-problem-portfolio/ # Problem portfolio management
│       │                        # ── Solution factory ──
│       ├── fpf-sota/            # SoTA harvesting (survey existing approaches)
│       ├── fpf-variants/        # Solution variant generation (NQD)
│       ├── fpf-selection/       # Qualitative Pareto selection
│       ├── fpf-evidence/        # Evidence records
│       ├── fpf-decision-record/ # Decision rationale records
│       │                        # ── Cross-cutting ──
│       └── fpf-glossary/        # Terminology + bridges
└── .fpf/                        # FPF artifact workspace
    ├── anomalies/               # Anomaly records (ANOM-*) + problem cards (PROB-*)
    ├── characterizations/       # Characterization passports (CHR-*), cards (CHRC-*), SoTA palettes (SOTA-*)
    ├── decisions/               # Decision records (DRR-*) + selection records (SEL-*)
    ├── evidence/                # Evidence records (EVID-*)
    ├── glossary/                # Term definitions + cross-context bridges
    ├── portfolios/              # Problem portfolios (PPORT-*) + solution portfolios (SPORT-*)
    ├── worklog/                 # Session logs (plan vs reality)
    └── templates/               # Templates for all artifact types
```

## How it works

The double-loop workflow is enforced through hooks and skills:

**Problem factory** (observe → characterize → frame → manage portfolio → acceptance spec):

| Step | Trigger | Skill | Artifact |
|------|---------|-------|----------|
| Observe | Anomaly detected | `/fpf-problem-framing` | ANOM-\* |
| Characterize | Before comparing options | `/fpf-characterize` | CHR-\*, CHRC-\* |
| Frame problem | Substantive problem identified | `/fpf-problem-framing` | PROB-\* |
| Manage portfolio | Multiple problems active | `/fpf-problem-portfolio` | PPORT-\* |

**Solution factory** (acceptance spec → variants → select → implement → verify → record):

| Step | Trigger | Skill | Artifact |
|------|---------|-------|----------|
| Survey SoTA | Before variant generation | `/fpf-sota` | SOTA-\* |
| Generate variants | Acceptance spec available | `/fpf-variants` | SPORT-\* |
| Select | Variants characterized | `/fpf-selection` | SEL-\* |
| Verify | Claiming correctness | `/fpf-evidence` | EVID-\* |
| Record decision | Non-trivial choice | `/fpf-decision-record` | DRR-\* |

**Session gates** (enforced mechanically via hooks):

| Gate | Trigger | Artifact |
|------|---------|----------|
| **0** | Session start | Worklog (`/fpf-worklog`) |
| **1** | Investigation/debugging | Anomaly record (`/fpf-problem-framing`) |
| **2** | Claims of correctness | Evidence record (`/fpf-evidence`) |
| **3** | Non-trivial decisions | Decision record (`/fpf-decision-record`) |
| **4** | New/drifting terminology | Glossary entry (`/fpf-glossary`) |
| **5** | Session end | Review (`/fpf-review`) |

Hooks enforce gates mechanically — Claude cannot skip gates even if it wants to.

## Requirements

- `git` (for the installer to clone the scaffold)
- Claude Code CLI

## Uninstall

Remove the installed files:

```bash
rm -f CLAUDE.md
rm -rf .claude .fpf
```

If you have backups, they remain in `.backup/` until you delete them.

## License

MIT
