# Principled Claude Code

**First Principles Framework (FPF)** for Claude Code — structured reasoning, auditable decisions, evidence-based claims.

FPF turns Claude Code from a chat-and-edit tool into a disciplined engineering partner that maintains an audit trail: hypotheses → predictions → evidence → decisions.

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
├── CLAUDE.md                    # FPF project instructions (mandatory gates)
├── .claude/
│   ├── settings.json            # Hook configuration
│   ├── hooks/                   # Mechanical gate enforcement
│   │   ├── fpf-enforce-gate0.sh           # Blocks Write/Edit without sentinel
│   │   ├── fpf-enforce-gate0-research.sh  # Blocks Read/Glob/Grep/Bash/Task without sentinel
│   │   ├── fpf-gate-check.sh
│   │   ├── fpf-prompt-reminder.sh
│   │   ├── fpf-session-cleanup.sh
│   │   └── fpf-track-source-edits.sh
│   └── skills/                  # FPF slash commands
│       ├── fpf-core/
│       ├── fpf-decision-record/
│       ├── fpf-evidence/
│       ├── fpf-glossary/
│       ├── fpf-problem-framing/
│       ├── fpf-review/
│       └── fpf-worklog/
└── .fpf/                        # FPF artifact workspace
    ├── anomalies/               # Problem framing + hypotheses
    ├── decisions/               # Decision Rationale Records
    ├── evidence/                # Test/benchmark/experiment records
    ├── glossary/                # Term definitions + cross-context bridges
    ├── worklog/                 # Session logs (plan vs reality)
    └── templates/               # Templates for all artifact types
```

## How it works

FPF enforces five gates through hooks and skills:

| Gate | Trigger | Artifact |
|------|---------|----------|
| **0** | Session start | Worklog (`/fpf-worklog`) |
| **1** | Investigation/debugging | Anomaly record (`/fpf-problem-framing`) |
| **2** | Claims of correctness | Evidence record (`/fpf-evidence`) |
| **3** | Non-trivial decisions | Decision record (`/fpf-decision-record`) |
| **4** | New/drifting terminology | Glossary entry (`/fpf-glossary`) |
| **5** | Session end | Review (`/fpf-review`) |

Hooks enforce these mechanically — Claude cannot skip gates even if it wants to.

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
