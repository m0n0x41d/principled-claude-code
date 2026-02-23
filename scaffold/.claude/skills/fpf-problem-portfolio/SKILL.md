---
name: fpf-problem-portfolio
description: Create or update an FPF Problem Portfolio — manage the set of active problems with explicit selection rules and diversification checks. Invoke when managing multiple problems, prioritizing work, or planning cycles.
argument-hint: "[portfolio-scope-or-context]"
---

## Goal
Create or update a **problem portfolio** under `.fpf/portfolios/` that:

- inventories all known problems (archive),
- defines an explicit selection rule (stated before applying),
- selects the active portfolio (problems being worked now),
- checks diversification (domain coverage, explore/exploit balance).

## Output
Create or update:

- `.fpf/portfolios/PPORT-${CLAUDE_SESSION_ID}--<slug>.md`

Use template:

- `.fpf/templates/problem-portfolio.md`

If the user passed arguments, use them to derive `<slug>` and the title.
If not, derive a short slug from the current context.

## Procedure

1) **Gather archive**
- Scan `.fpf/anomalies/` for existing ANOM-\* and PROB-\* records.
- Include resolved, deferred, and open problems.
- For each: note ID, title, source, domain, status, and stepping-stone potential.

2) **Define selection rule**
- State the explicit policy for selecting problems into the active portfolio.
- Include capacity (how many problems can be active simultaneously).
- Include review cadence (when to re-evaluate).
- **The rule must be stated before applying it** — no post-hoc rationalization.

3) **Select active portfolio**
- Apply the selection rule to the archive.
- For each selected problem, note why it was selected (per the stated policy).
- Assign priorities.

4) **Diversification check**
- Domain coverage: are we concentrated in one area?
- Explore/exploit balance: how many are exploratory vs known-approach?
- Stepping-stone coverage: do any active problems unlock deferred ones?
- Risk concentration: is the risk profile balanced?

## Quality bar
- Selection rule is stated before selection — not rationalized after.
- Archive is complete — no hidden or forgotten problems.
- At least one active problem has stepping-stone potential (if the archive has any).
- Diversification check is honest — flags imbalances even if intentional.
- Each active problem references an existing PROB-\* or ANOM-\* record.
