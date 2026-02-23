---
name: fpf-variants
description: Create an FPF Solution Portfolio — generate >=3 distinct variants, characterize each with NQD (Novelty, Utility, Constraint fit, Diversity), and select an active portfolio. Invoke after problem framing produces an acceptance spec or when facing architectural choices.
argument-hint: "[problem-or-decision-context]"
---

## Goal
Create a **solution portfolio** under `.fpf/portfolios/` that:

- generates at least 3 genuinely distinct variants,
- characterizes each with NQD against the characterization passport,
- identifies stepping stones,
- selects an active portfolio for further development.

## Output
Create a new file:

- `.fpf/portfolios/SPORT-${CLAUDE_SESSION_ID}--<slug>.md`

Use template:

- `.fpf/templates/solution-portfolio.md`

If the user passed arguments, use them to derive `<slug>` and the title.
If not, derive a short slug from the current context.

## Procedure

1) **Gather inputs**
- Locate the problem card (PROB-\*) or anomaly record (ANOM-\*) that defines the problem.
- Locate the characterization passport (CHR-\*) that defines the indicators.
- Read the acceptance spec from the problem card.
- If no characterization passport exists, invoke `/fpf-characterize` first.
- If a SoTA palette (SOTA-\*) exists for this problem, use it as input for variant generation.
- If no SoTA exists and the problem involves choosing between known approaches (architecture, libraries, design patterns), invoke `/fpf-sota` first.

2) **Generate variants (minimum 3)**
- State the generation method (brainstorm, decomposition, analogical transfer, constraint relaxation, etc.).
- Ensure genuine diversity — variants must differ in approach, not just in parameters.
- Include at least one genuinely novel variant (not the obvious incremental option).
- Document what constraints were applied during generation.

3) **NQD characterization for each variant**
- **D_c (Constraint fit):** Does it satisfy all hard constraints from the problem card? Pass/Fail. **Eligibility gate — Fail = eliminated before dominance analysis.**
- **Q (Utility):** How well does it address acceptance spec indicators? Reference the characterization passport. **Primary dominance characteristic.**
- **N (Novelty):** How different from existing/obvious approaches? Low/Med/High. **Tie-breaker.**
- **D_p (Diversity contribution):** How much does it diversify the portfolio? Low/Med/High. **Tie-breaker.**

Pipeline: Eligibility (D_c = Pass) → Dominance (Q) → Tie-breakers (N, D_p).

4) **Identify stepping stones**
- Which variants, even if not dominant, could enable future progress?
- What would be lost by discarding them?

5) **Select active portfolio**
- Choose variants for further development/evaluation.
- State rationale per the problem card's acceptance criteria.
- Note what evidence is needed next for each active variant.

## Quality bar
- Minimum 3 variants — no exceptions. If you can only think of 2, the problem is under-explored.
- NQD characterization references characterization passport indicators, not ad-hoc criteria.
- At least one variant is genuinely novel (not a minor tweak of the obvious approach).
- Stepping stones are identified and their value articulated.
- Variant descriptions are concrete enough to evaluate — not "do it better".
