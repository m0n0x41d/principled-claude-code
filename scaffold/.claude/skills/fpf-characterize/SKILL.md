---
name: fpf-characterize
description: Create an FPF Characterization Passport — define the characteristic space, select indicators, and set comparison rules. MUST be invoked before defining acceptance criteria or comparing variants.
argument-hint: "[domain-or-comparison-context]"
---

## Goal
Create a **characterization passport** under `.fpf/characterizations/` that defines:

- the full characteristic space (what could matter),
- the active indicator set (what we will actually measure),
- comparison rules (how variants will be compared),
- acceptance criteria (what "good enough" means).

Optionally create **characteristic cards** for indicators that need detailed definition.

## Output
Create new files:

- `.fpf/characterizations/CHR-${CLAUDE_SESSION_ID}--<slug>.md` (passport)
- `.fpf/characterizations/CHRC-${CLAUDE_SESSION_ID}--<slug>.md` (per characteristic card, as needed)

Use templates:

- `.fpf/templates/characterization-passport.md`
- `.fpf/templates/characteristic-card.md`

If the user passed arguments, use them to derive `<slug>` and the title.
If not, derive a short slug from the current task context.

## Procedure

1) **Define CharacteristicSpace**
- List all characteristics relevant to the comparison context.
- For each: name, scale type, unit, polarity.
- Be comprehensive — include characteristics you might not measure.

2) **Indicatorize (select active indicators)**
- From the full space, select 1–3 characteristics as active indicators.
- For each indicator, define:
  - Threshold or target value (not just direction).
  - Baseline (current measured or estimated value).
  - Measurement method (how to obtain a value).

3) **Define comparison rules**
- Specify the comparator set (what is being compared).
- Define parity rules (what must be equal for fair comparison).
- Define normalization if scales differ.
- Define dominance policy (when does A beat B).

4) **Write acceptance criteria**
- What must any acceptable variant satisfy?
- These criteria flow into the problem card's acceptance spec.

5) **Create characteristic cards** (if needed)
- For any indicator where the measurement method is non-trivial, create a CHRC-\* card.
- Include validity/refresh constraints and CSLC binding.

## Quality bar
- Every characteristic in the space has scale type and polarity defined.
- Every indicator has a threshold or target, not just "higher is better".
- Comparison rules are unambiguous — a different agent could apply them.
- Measurement methods are reproducible.
- If a characteristic card is created, it includes a validity window.
