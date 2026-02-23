# Anomaly Record

- **ID:** ANOM-…
- **Status:** Open | In progress | Resolved | Archived
- **Created:** YYYY-MM-DD
- **Transformer (who/what is changing things):** …
- **Bounded context:** …
- **Lifecycle state:** Explore | Shape | Evidence | Operate

---

## 1) Problem framing (the anomaly)

Describe the anomaly as precisely as possible.

- Current behavior (what happens):
- Expected behavior (what should happen):
- Why it matters (impact):

---

## 2) Run-time observations (facts)

List observations that are **run-time facts** (logs, traces, measurements, reproduced steps).

- Observation 1:
- Observation 2:

> Keep assumptions separate; do not mix “I think” with “I observed”.

---

## 3) Constraints & invariants

What must remain true?

- Safety/security constraints:
- Backward compatibility constraints:
- Performance/latency constraints:
- Interface invariants:

---

## 4) Hypotheses (Abduction)

Generate multiple plausible hypotheses. New hypotheses start **provisional**.

### H1 (L0): …
Plausibility lens:
- Parsimony:
- Explanatory power:
- Consistency with known facts:
- Falsifiability:

### H2 (L0): …
Plausibility lens:
- Parsimony:
- Explanatory power:
- Consistency with known facts:
- Falsifiability:

### H3 (L0): …
Plausibility lens:
- Parsimony:
- Explanatory power:
- Consistency with known facts:
- Falsifiability:

---

## 5) Prime candidate hypothesis

Select one hypothesis as the prime candidate (still provisional).

- Prime hypothesis:
- Why this one (briefly):

---

## 6) Consequences & predictions (Deduction)

If the prime hypothesis is true, what logically follows?

- Prediction 1 (testable):
- Prediction 2 (testable):
- Prediction 3 (testable):

**Falsifiers (what would prove it wrong):**
- Falsifier 1:
- Falsifier 2:

---

## 7) Evidence plan (Induction)

Minimum viable tests to discriminate hypotheses.

- Test 1 (cheap first):
  - What it measures:
  - How to run:
  - Expected result if hypothesis is true:
  - Evidence record to create/link: `.fpf/evidence/...`

- Test 2:
- Test 3:

---

## 8) What would change my mind?

Explicitly list what evidence would cause you to switch hypotheses or revise the model.

---

## 9) Links

- Code locations:
- Docs/specs:
- Issues/PRs:
- Evidence records:
- Decision records (DRR):

