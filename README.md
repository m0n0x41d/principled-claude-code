# Principled Claude Code

Implementation of the [First Principles Framework (FPF)](https://github.com/ailev/FPF) for Claude Code.

FPF is a systems engineering methodology built on double-loop cycles: a problem factory (problematization, characterization, building variant portfolios) and a solution factory (selecting a point on the Pareto front, implementation, verification). See the [FPF repository](https://github.com/ailev/FPF) for the full methodology.

This project implements FPF as a **tier-scaled, constraint-based** profile for Claude Code:

- **Task tiers** (T1-T4) scale ceremony proportionally — trivial fixes get zero overhead, architectural decisions get full pipeline
- **Constraint declarations** enforce creative quality (≥3 hypotheses, ≥3 variants, novel options) not just process compliance
- **Layered context** — compact CLAUDE.md (~4KB) + skills loaded on demand + reference files searched but not loaded

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
│       ├── fpf-sota/            # SoTA harvesting + strategy
│       ├── fpf-variants/        # Solution variant generation (NQD)
│       ├── fpf-selection/       # Qualitative Pareto selection
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

The profile declares 10 quality constraints (C1-C10) that hooks check:

| # | Constraint | Tier | Enforcement |
|---|-----------|------|-------------|
| C1 | Problem before solution | T2+ | Hook blocks source edits without PROB/ANOM-* |
| C2 | ≥3 hypotheses | T3+ | Hook greps PROB-* files |
| C3 | Trade-off axes stated | T3+ | Hook greps PROB-* files |
| C4 | ≥3 variants before selection | T3+ | Hook greps SPORT-* files |
| C5 | ≥1 novel variant | T3+ | Hook greps SPORT-* files |
| C6 | Evidence with commands+outputs | T2+ | Hook checks EVID-* existence |
| C7 | DRR for irreversible decisions | T3+ | Advisory |
| C8 | Selection policy before applying | T3+ | Hook greps SEL-* files |
| C9 | SoTA + strategy before variants | T4 | Hook checks SOTA-*/STRAT-* |
| C10 | Session worklog | All | Gate 0 hard block |

## Requirements

- `git` (for the installer)
- `jq` (used by hooks)
- Claude Code CLI

## Uninstall

```bash
rm -f CLAUDE.md
rm -rf .claude .fpf
```

## License

MIT
