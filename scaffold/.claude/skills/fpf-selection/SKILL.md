---
name: fpf-selection
description: Create an FPF Selection Record — perform qualitative Pareto analysis on characterized variants, apply an explicit selection policy, and record stepping-stone bets. Invoke after variant generation, when choosing between characterized options.
argument-hint: "[selection-context]"
---

## Goal
Create a **selection record** under `.fpf/decisions/` that:

- performs dominance analysis (qualitative Pareto) on characterized variants,
- applies an explicit selection policy (stated before applying),
- records stepping-stone bets (promising non-dominant variants),
- documents what would change the selection.

## Output
Create a new file:

- `.fpf/decisions/SEL-${CLAUDE_SESSION_ID}--<slug>.md`

Use template:

- `.fpf/templates/selection-record.md`

If the user passed arguments, use them to derive `<slug>` and the title.
If not, derive a short slug from the current context.

## Procedure

1) **Gather inputs**
- Locate the solution portfolio (SPORT-\*) with NQD-characterized variants.
- Locate the characterization passport (CHR-\*) with indicators and comparison rules.
- Locate the problem card (PROB-\*) with acceptance criteria.
- If any of these are missing, flag it — selection without inputs is guessing.

2) **Build dominance table**
- For each variant, evaluate against each indicator from the characterization passport.
- Determine pairwise dominance: A dominates B if A is better on all indicators (or per the dominance policy).
- Identify the Pareto front (non-dominated variants).
- Identify clearly dominated variants and explain why.

3) **Apply selection policy**
- **State the policy before applying it.** The policy must be explicit enough that a different agent could apply it.
- Apply the policy to the Pareto front.
- Record what was sacrificed — what the selected variant is worse at.

4) **Record stepping-stone bets**
- Identify 1–2 non-dominant but promising variants worth preserving.
- For each: why preserve, condition to reconsider, cost of preservation.
- Stepping-stone bets are cheap insurance against premature convergence.

5) **Document "what would change this selection"**
- New information that would favor a different variant.
- Changes in indicators or thresholds.
- Evidence that would invalidate the selected variant.
- Time horizon changes.

6) **Link to DRR if needed**
- If the selection has architectural or irreversible consequences, create a DRR via `/fpf-decision-record`.
- The selection record handles the comparison mechanics; the DRR handles the organizational commitment.

## Quality bar
- Selection policy is stated before applying — never post-hoc rationalized.
- Dominance table is complete — every variant evaluated on every indicator.
- Stepping-stone bets are recorded — at least one if any non-dominant variant has potential.
- "What would change" section is filled — not empty or pro-forma.
- If inputs (portfolio, passport, problem card) are missing, the record flags the gap explicitly.
