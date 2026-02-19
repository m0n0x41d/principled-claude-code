# Decision Rationale Record (DRR)

- **ID:** DRR-…
- **Status:** Proposed | Accepted | Deprecated
- **Date:** YYYY-MM-DD
- **Decision owner / Transformer:** …
- **Bounded context:** …
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

---

## 8) Notes

Anything that future maintainers will curse you for not writing down.

