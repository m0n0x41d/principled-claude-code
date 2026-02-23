# .fpf/ — First Principles Framework workspace

This directory stores **FPF artifacts** for this repository/workspace.

It is meant to make reasoning **generative and auditable**:
problematize → characterize → generate variants → select from Pareto front → implement → verify.
Both the creative side (portfolios, SoTA surveys, variant generation) and the assurance side
(evidence records, F-G-R tracking, audit trail) produce artifacts here.

## Folders

- `templates/` — templates to copy/fill
- `anomalies/` — anomaly records (problem framing + hypotheses + predictions)
- `characterizations/` — characterization passports + characteristic cards
- `decisions/` — Decision Rationale Records (DRRs) and selection records
- `evidence/` — evidence records (tests, benchmarks, experiments)
- `glossary/` — shared vocabulary and cross-context bridge cards
- `portfolios/` — problem portfolios (PPORT-\*) and solution portfolios (SPORT-\*)
- `worklog/` — per-session logs (plan vs reality)

## Recommended practice

- Commit `templates/`, `decisions/`, `glossary/`, `anomalies/`, `evidence/`, `characterizations/`, and `portfolios/`.
- Consider ignoring `worklog/` if it contains local/private notes.

Use the Skills in `.claude/skills/` to generate these artifacts consistently.

