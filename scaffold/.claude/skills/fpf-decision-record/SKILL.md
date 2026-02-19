---
name: fpf-decision-record
description: Write a Decision Rationale Record (DRR) capturing options, decision, rationale, risks, evidence, and review triggers. MUST be invoked for architectural/product/process decisions that are costly to undo.
argument-hint: "[decision-title-or-short-slug]"
---

## Goal
Create a **Decision Rationale Record (DRR)** under `.fpf/decisions/`.

A DRR is not "extra documentation" -- it is the artifact that prevents memory drift and makes reasoning auditable.

## Output
Create a new file:

- `.fpf/decisions/DRR-${CLAUDE_SESSION_ID}--<slug>.md`

Use the template:

- `.fpf/templates/decision-record.md`

If the user passed arguments, use them to derive `<slug>` and the title.

## Procedure
1) **Context**
- State the bounded context (what this applies to).
- Link to any related anomaly record(s) in `.fpf/anomalies/`.
- List constraints and acceptance criteria.

2) **Options**
- Enumerate real alternatives (including "do nothing").
- For each option: costs, risks, second-order effects.

3) **Decision**
- Declare the chosen option.
- Explain *why* (trade-offs and reasoning).

4) **Evidence & assurance**
- If the decision relies on claims that need testing, link to (or create) evidence records in `.fpf/evidence/`.
- Note what would cause a revisit.

5) **Rollback / migration**
- If this decision might be reversed, write a rollback plan or migration path.

## Quality bar
- Be explicit about assumptions.
- Keep it falsifiable: what future evidence would invalidate this decision?
- Prefer conservative claims; avoid confidence inflation.
