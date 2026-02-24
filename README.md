# Principled Claude Code

An [FPF (First Principles Framework)](https://github.com/ailev/FPF) profile for Claude Code — making AI agents do **problem design and strategic creativity**, not just solution delivery.

**The shift:** In a world of cheap solution generation, the bottleneck is problem quality. This profile implements FPF's coupled double-loop factories:

- **Problem factory** (creative) — problematize → characterize → frame → portfolio → acceptance spec
- **Solution factory** (creative) — SoTA → strategize → generate variants → select from Pareto front → implement → verify
- **Factory of factories** (meta) — improve the first two when the workflow itself is the bottleneck

Both creativity and assurance are first-class — neither is subordinated. Templates are thinking tools; filling them IS the reasoning.

Implemented as a **tier-scaled, constraint-based** profile:

- **Task tiers** (T1-T4) scale ceremony proportionally — trivial fixes get zero overhead, architectural decisions get full pipeline
- **Constraint declarations** enforce creative quality (≥3 hypotheses, ≥3 variants, explicit strategy bets) not just process compliance
- **Layered context** — compact CLAUDE.md (~4KB) + skills loaded on demand + reference files searched but not loaded

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

## Task tiers

The core design principle: **scale rigor to task size**.

| Tier | Examples | Protocol |
|------|----------|----------|
| **T1 Trivial** | Typo, syntax fix, quick answer | Direct action. No artifacts. |
| **T2 Localized** | Bug with clear cause, simple refactor | ANOM-* → fix → EVID-* |
| **T3 Substantive** | Feature, multi-file change, design decision | Full problem factory → solution factory |
| **T4 Architectural** | System design, tech choice, cross-cutting | T3 + SoTA survey + strategy card |

## What gets installed

```
your-project/
├── CLAUDE.md                    # FPF instructions (~4KB, tier-based)
├── .claude/
│   ├── settings.json            # Hook configuration
│   ├── hooks/                   # Mechanical gate enforcement
│   └── skills/                  # FPF slash commands
│       ├── fpf-core/            # Session bootstrap + FPF rules
│       ├── fpf-worklog/         # Session logging
│       ├── fpf-review/          # End-of-session quality gate
│       ├── fpf-problem-framing/ # Anomaly records + problem cards
│       ├── fpf-characterize/    # Characterization passports
│       ├── fpf-problem-portfolio/ # Problem portfolio management
│       ├── fpf-sota/            # SoTA harvesting (survey existing approaches)
│       ├── fpf-strategize/      # Method family bet (first-class creative act)
│       ├── fpf-variants/        # Solution variant generation (NQD)
│       ├── fpf-selection/       # Qualitative Pareto selection
│       ├── fpf-parity/          # Fair comparison conditions (parity plan)
│       ├── fpf-evidence/        # Evidence records
│       ├── fpf-decision-record/ # Decision rationale records
│       └── fpf-glossary/        # Terminology + bridges
└── .fpf/                        # FPF artifact workspace
    ├── anomalies/               # ANOM-*, PROB-*
    ├── characterizations/       # CHR-*, CHRC-*, SOTA-*
    ├── decisions/               # DRR-*, SEL-*, STRAT-*
    ├── evidence/                # EVID-*
    ├── glossary/                # Terms + bridges
    ├── portfolios/              # PPORT-*, SPORT-*
    ├── worklog/                 # Session logs
    └── templates/               # Compact templates for all artifact types
```

## Constraints (enforced mechanically)

10 constraints matching CLAUDE.md §6 — creative, assurance, and session discipline:

| # | Constraint | Type | Tier | Enforcement |
|---|-----------|------|------|-------------|
| C1 | PROB-\* ≥3 hypotheses with trade-off axes | Creative | T3+ | Hook blocks source edits |
| C2 | SPORT-\* ≥3 genuinely distinct variants | Creative | T3+ | Hook blocks source edits |
| C3 | Selection policy stated before applying | Creative | T3+ | Skill-enforced |
| C4 | STRAT-\* invalidation conditions | Creative | T4 | Hook blocks source edits |
| C5 | No source edits without PROB/ANOM-\* | Assurance | T2+ | Hook blocks at ≥8 edits (Gate 1) |
| C6 | No L2 claims without EVID-\* | Assurance | T2+ | Stop hook (Gate 2) |
| C7 | EVID-\* commands + outputs + valid\_until | Assurance | T2+ | Stop hook (Gate 2) |
| C8 | Non-trivial/irreversible → DRR-\* | Assurance | T3+ | Stop hook (Gate 3) |
| C9 | /fpf-core + /fpf-worklog before side effects | Session | All | Hook blocks tools (Gate 0) |
| C10 | /fpf-review before ending | Session | T2+ | Stop hook (Gate 5) |

## Requirements

- `git` (for the installer)
- `jq` (used by hooks)
- Claude Code CLI

## Uninstall

```bash
rm -f CLAUDE.md
rm -rf .claude .fpf
```

## Context budget

This profile owns the full Claude Code session context. CLAUDE.md (~5KB) is always loaded; skills (~2-3KB each) load on demand.

**If you have a global `~/.claude/CLAUDE.md`** with FPF-compatible rules (lifecycle states, WLNK/MONO, confidence levels), there will be overlap. Consider removing the duplicated sections from your global file when using this project profile.

**Do not add parallel frameworks** alongside this profile — context is a finite budget, and competing instruction sets degrade both.

## License

MIT
