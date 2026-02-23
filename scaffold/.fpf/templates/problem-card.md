# Problem Card

- **ID:** PROB-…
- **Status:** Open | In progress | Resolved | Archived
- **Created:** YYYY-MM-DD
- **Transformer:** …
- **Bounded context:** …
- **Lifecycle state:** Explore | Shape | Evidence | Operate
- **Related anomaly record(s):** `.fpf/anomalies/ANOM-...`

---

## 1) Problem statement

- **Signal:** (what triggered awareness — anomaly, stakeholder request, observation)
- **Current state:** (what is happening now)
- **Desired state:** (what should be happening)
- **Impact:** (consequences of the gap between current and desired)

---

## 2) Constraints

- Safety / security constraints:
- Backward compatibility constraints:
- Performance / latency constraints:
- Resource constraints (time, budget, people):
- Interface invariants:

---

## 3) Goldilocks assessment

Evaluate whether this problem is well-sized for productive work.

- **Measurability:** (can progress be measured? how?)
- **Reversibility:** (can attempted solutions be undone? at what cost?)
- **Stepping-stone potential:** (does solving this enable solving other problems?)
- **Trade-off axes:** (what tensions exist — e.g., speed vs correctness, generality vs simplicity?)

> A "goldilocks" problem is measurable, partially reversible, and opens stepping stones.
> Too vague = unworkable. Too narrow = no leverage. Too irreversible = too risky to explore.

---

## 4) Acceptance spec (contract for solution factory)

This section defines what the solution factory must deliver. It is the interface between the problem factory and the solution factory.

- **Indicators:** (from characterization passport — which indicators matter?)
  - Indicator 1: … (reference: `CHR-...`, threshold: …)
  - Indicator 2: … (reference: `CHR-...`, threshold: …)
- **Acceptance criteria:** (what "solved" means in measurable terms)
  - Criterion 1:
  - Criterion 2:
- **Baseline:** (current measured values for each indicator)
- **Required evidence:** (what type of evidence must accompany any proposed solution)
  - Evidence type: Verification | Validation
  - Minimum formality: informal | structured | formalizable
- **Evidence chain requirement:** (what claim→evidence→test chain must be completed)
  - Claim: … → Prediction: … → Test: … → Evidence record: `EVID-...` → Required result: …

---

## 5) What would change this problem?

- New information that would reframe the problem:
- Changes in constraints that would make it trivial:
- Changes in constraints that would make it unsolvable:

---

## 6) Links

- Anomaly records: `.fpf/anomalies/ANOM-...`
- Characterization passport: `.fpf/characterizations/CHR-...`
- Problem portfolio: `.fpf/portfolios/PPORT-...`
- Solution portfolio: `.fpf/portfolios/SPORT-...`
- Evidence records: `.fpf/evidence/...`
