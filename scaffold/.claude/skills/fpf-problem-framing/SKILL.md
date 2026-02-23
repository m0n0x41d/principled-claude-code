---
name: fpf-problem-framing
description: Create an FPF Anomaly Record or Problem Card (problem framing + hypotheses + predictions + test plan). MUST be invoked for debugging, investigation, unclear requirements, or any "why is this happening?" task. For substantive problems, produces a Problem Card with goldilocks assessment and acceptance spec.
argument-hint: "[topic-or-short-title]"
---

## Goal
Create a **written** problem framing artifact under `.fpf/anomalies/` that captures:

- the anomaly/problem (framed precisely),
- run-time observations (facts),
- constraints/invariants,
- multiple hypotheses (abduction),
- predictions (deduction),
- a concrete test/evidence plan (induction).

For substantive problems: also produce a goldilocks assessment and an acceptance spec that bridges to the solution factory.

This is "thinking through writing".

## Output

**Quick investigation (anomaly):**
- `.fpf/anomalies/ANOM-${CLAUDE_SESSION_ID}--<slug>.md`
- Template: `.fpf/templates/anomaly-record.md`

**Substantive problem (problem card):**
- `.fpf/anomalies/PROB-${CLAUDE_SESSION_ID}--<slug>.md`
- Template: `.fpf/templates/problem-card.md`
- May also trigger `/fpf-characterize` for the acceptance spec.

If the user passed arguments, use them to derive `<slug>` and the title.
If not, derive a short slug from the current task.

## Procedure

### Step 0: Scope assessment

Determine whether this is a quick investigation or a substantive problem:

- **Quick investigation (ANOM-\*):** localized bug, single hypothesis likely, fix is straightforward. Use anomaly-record template. Proceed to Steps 1–3.
- **Substantive problem (PROB-\*):** multiple possible approaches, trade-offs exist, solution requires variant generation or architectural choice. Use problem-card template. Proceed to Steps 1–5.

When in doubt, start as ANOM-\* — it can be promoted to PROB-\* if complexity emerges.

### Step 1: Abduction
- Write the anomaly/problem in one crisp paragraph.
- List at least **3** plausible hypotheses.
- For each hypothesis, add a plausibility lens:
  - parsimony,
  - explanatory power,
  - consistency with known facts,
  - falsifiability.

### Step 2: Deduction
- Select a **prime candidate** hypothesis (still provisional).
- Derive predictions:
  - what should be observed if true?
  - what should *not* be observed?
  - what would falsify it?
- Note dependencies and implications.

### Step 3: Induction
- Define the **minimum viable tests** to discriminate hypotheses.
- Prefer cheap tests first.
- Link to where evidence will be recorded (`.fpf/evidence/...`).

### Step 4: Goldilocks assessment (PROB-\* only)
- **Measurability:** Can progress toward the desired state be measured? How?
- **Reversibility:** Can attempted solutions be undone? At what cost?
- **Stepping-stone potential:** Does solving this enable solving other problems?
- **Trade-off axes:** What tensions exist (speed vs correctness, generality vs simplicity)?

If the problem scores poorly on goldilocks (unmeasurable, irreversible, no stepping-stone value), flag this explicitly — it may need reframing before entering the solution factory.

### Step 5: Acceptance spec (PROB-\* only)
Write the contract that the solution factory must satisfy:

- **Indicators:** Reference a characterization passport (CHR-\*). If none exists, invoke `/fpf-characterize` to create one.
- **Acceptance criteria:** What "solved" means in measurable terms.
- **Baseline:** Current measured values for each indicator.
- **Required evidence:** What type and formality of evidence must accompany any proposed solution.

The acceptance spec is the interface between the problem factory and the solution factory. Without it, the solution factory is solving an undefined problem.

## Quality bar
- Separate **run-time observations** (facts) from **design-time assumptions**.
- If you are uncertain, say so explicitly and propose how to reduce uncertainty.
- Keep the record actionable: it should tell a future reader what to do next.
- For PROB-\* cards: goldilocks assessment is honest (flags bad sizing), acceptance spec references a characterization passport.
- Scope assessment (ANOM vs PROB) is explicit — not silently defaulted.
