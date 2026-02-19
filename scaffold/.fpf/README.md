# .fpf/ — First Principles Framework workspace

This directory stores **FPF artifacts** for this repository/workspace.

It is meant to make reasoning **auditable**:
hypotheses → predictions → tests → evidence → decisions.

## Folders

- `templates/` — templates to copy/fill
- `anomalies/` — anomaly records (problem framing + hypotheses + predictions)
- `decisions/` — Decision Rationale Records (DRRs)
- `evidence/` — evidence records (tests, benchmarks, experiments)
- `glossary/` — shared vocabulary and cross-context bridge cards
- `worklog/` — per-session logs (plan vs reality)

## Recommended practice

- Commit `templates/`, `decisions/`, `glossary/`, `anomalies/`, and `evidence/`.
- Consider ignoring `worklog/` if it contains local/private notes.

Use the Skills in `.claude/skills/` to generate these artifacts consistently.

