# .fpf/ — First Principles Framework workspace

This directory stores **FPF artifacts** for this repository/workspace.

Two coupled factories produce artifacts here:
- **Problem factory** (creative): problematize → characterize → frame → portfolio → acceptance spec
- **Solution factory** (creative): SoTA → strategize → generate variants → select from Pareto front → implement → verify

Both creativity (designing problems, generating novel variants, surveying SoTA) and assurance
(evidence records, F-G-R tracking, audit trail) are first-class. Neither is subordinated.

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

