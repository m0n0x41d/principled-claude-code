---
name: fpf-evidence
description: Plan and record evidence (tests/benchmarks/experiments) to validate or verify a claim. MUST be invoked before stating "this works", "this is correct", or when promoting confidence.
argument-hint: "[claim-or-short-title]"
---

## Goal
Turn a claim into an **evidence-backed** statement.

This skill produces an Evidence Record under `.fpf/evidence/` and (when possible) runs the smallest viable test/measurement.

## Output
Create a new file:

- `.fpf/evidence/EVID-${CLAUDE_SESSION_ID}--<slug>.md`

Use the template:

- `.fpf/templates/evidence-record.md`

## Procedure
1) **Define the claim**
- Write the claim under test in one sentence.
- Link it to:
  - a hypothesis in an anomaly record, or
  - a decision in a DRR.

2) **Deduce predictions**
- What should be true if the claim holds?
- What result would falsify it?

3) **Design the harness**
Pick the smallest credible check, e.g.:
- unit/integration tests
- type checks / linters
- reproducible benchmarks
- runtime traces/logs
- minimal simulation

4) **Run the check (run-time)**
- Run commands needed to generate evidence (ask permission when required).
- Record:
  - exact commands,
  - environment details,
  - commit/revision,
  - raw outputs (or links to them).

5) **Interpret conservatively**
- Label result: corroborated / refuted / inconclusive.
- Update confidence conservatively.
- Add `valid_until` if evidence can go stale.

## Quality bar
- Evidence must correspond to a *deduced prediction*, not a vague "feels good".
- Keep raw output or provide reproduction steps.
- Don't hide failures -- refutations are valuable.
