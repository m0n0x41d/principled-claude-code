---
name: fpf-problem-framing
description: Create an FPF Anomaly Record (problem framing + multiple hypotheses + predictions + test plan). MUST be invoked for debugging, investigation, unclear requirements, or any "why is this happening?" task.
argument-hint: "[topic-or-short-title]"
---

## Goal
Create a **written** Anomaly Record under `.fpf/anomalies/` that captures:

- the anomaly/problem (framed precisely),
- run-time observations (facts),
- constraints/invariants,
- multiple hypotheses (abduction),
- predictions (deduction),
- a concrete test/evidence plan (induction).

This is "thinking through writing".

## Output
Create a new file:

- `.fpf/anomalies/ANOM-${CLAUDE_SESSION_ID}--<slug>.md`

Use the template:

- `.fpf/templates/anomaly-record.md`

If the user passed arguments, use them to derive `<slug>` and the title.
If not, derive a short slug from the current task.

## Procedure (ADI)
1) **Abduction**
- Write the anomaly in one crisp paragraph.
- List at least **3** plausible hypotheses.
- For each hypothesis, add a plausibility lens:
  - parsimony,
  - explanatory power,
  - consistency with known facts,
  - falsifiability.

2) **Deduction**
- Select a **prime candidate** hypothesis (still provisional).
- Derive predictions:
  - what should be observed if true?
  - what should *not* be observed?
  - what would falsify it?
- Note dependencies and implications.

3) **Induction**
- Define the **minimum viable tests** to discriminate hypotheses.
- Prefer cheap tests first.
- Link to where evidence will be recorded (`.fpf/evidence/...`).

## Quality bar
- Separate **run-time observations** (facts) from **design-time assumptions**.
- If you are uncertain, say so explicitly and propose how to reduce uncertainty.
- Keep the record actionable: it should tell a future reader what to do next.
