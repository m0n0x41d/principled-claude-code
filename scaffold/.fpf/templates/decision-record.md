# Decision Rationale Record (DRR)

- **ID:** DRR-…
- **Status:** Proposed | Accepted | Deprecated
- **Date:** YYYY-MM-DD
- **Decision owner / Transformer:** …
- **Bounded context:** …
- **ClaimScope(G):** (set of contexts where this decision applies — set-valued per USM A.2.6)
- **DesignRunTag:** design-time | run-time (is this decision about architecture/spec or about deployment/execution?)
- **Related anomaly record(s):** `.fpf/anomalies/...`
- **Related evidence record(s):** `.fpf/evidence/...`
- **Review trigger:** (date or condition)

---

## 1) Decision

Write the decision as a crisp statement.

---

## 2) Context

- What problem are we solving?
- What constraints apply?
- What non-goals are explicitly out of scope?

---

## 3) Options considered

### Option A: …
Pros:
Cons:
Risks:
Notes:

### Option B: …
Pros:
Cons:
Risks:
Notes:

### Option C: Do nothing / defer
Pros:
Cons:
Risks:
Notes:

---

## 4) Decision rationale

Why this option?

- Key trade-offs:
- Assumptions:
- Dependencies:

---

## 5) Consequences

### Expected benefits
- …

### Costs / risks
- …

### Second-order effects
- …

---

## 6) Rollback / migration plan

If we need to reverse this, what is the plan?

---

## 7) Acceptance criteria & evidence

What must be true after implementation?

- Acceptance criterion 1:
  - How we measure:
  - Evidence:

- Acceptance criterion 2:

**Validity window (`valid_until`):**
- If evidence can go stale, specify when it needs refresh.

### Evidence chain

Link claims to evidence through explicit chains:

| Claim | Prediction | Test / method | Evidence record | Result |
|-------|-----------|---------------|-----------------|--------|
| … | … | … | `EVID-...` | Corroborated / Refuted / Inconclusive |
| … | … | … | `EVID-...` | … |

---

## 8) Assurance summary

- **F (Formality):** formality of the analysis supporting this decision (informal | structured | formalizable | proof-grade)
- **G (ClaimScope):** contexts where this decision applies (set-valued — enumerate conditions; same as metadata ClaimScope(G))
- **R (Reliability):** 0–1 estimate for this decision holding
- **CL (if cross-context):** if options come from different bounded contexts, state CL (0-3) and apply penalty to R

---

## 9) Notes

Anything that future maintainers will curse you for not writing down.

