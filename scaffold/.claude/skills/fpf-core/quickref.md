# FPF quick reference — concepts for day-to-day work

For full definitions: `reference/FPF-Spec.md`. For operating procedures: see individual skill files.

---

## Characterization and NQD

### Characterization passport (CHR-\*)
Defines the characteristic space for comparing variants:
- Characteristics: all dimensions that could matter
- Indicators: 1–3 selected characteristics with thresholds (not just direction)
- Comparison rules: parity, normalization, dominance policy
- Acceptance criteria: what "good enough" means

### NQD characterization (for solution AND problem variants)
- **N (Novelty):** How different from existing/obvious approaches?
- **Q (Utility):** Multi-dimensional — one value per CHR indicator. NOT a single ordinal. **Never collapse to single score.**
- **D_c (Constraint fit):** Eligibility gate — Fail = eliminated before dominance
- **D_p (Diversity):** Portfolio-level coverage. Tie-breaker.

**Pipeline order:** Eligibility (D_c = Pass) → Dominance (Q per indicator, Pareto) → Tie-breakers (N, D_p).

---

## WLNK (Weakest Link)

System reliability = min(component reliabilities). When combining parts, the weakest component bounds the whole.

- **When proposing architecture:** identify the weakest link — the component, assumption, or dependency that limits overall quality
- **When comparing variants:** a variant whose weakest link is weaker than another's is dominated on that axis
- **When aggregating claims:** F_eff = min(F), R_eff = min(R). Aggregation never improves reliability beyond the weakest input

## MONO (Monoeliminability)

Added complexity must justify new weak links. When adding components, abstractions, or dependencies:

- **State the new weak link** introduced by the addition
- **Compare against the current weakest link** — if the new component is weaker than the existing weakest, it degrades the system
- **Justify or simplify** — either the benefit demonstrably improves the system above its current WLNK, or remove the complexity
- **Prefer fewer components** when benefit is comparable — three similar lines beat a premature abstraction (this is the formal principle behind "avoid over-engineering")

---

## BLP (Bitter Lesson Preference)

At comparable budget and confidence, prefer the method with better scaling slopes (more data, more compute, more freedom → better results). General + scalable beats hand-tuned + narrow.

- **Scale-Audit:** before choosing a method, check how it improves with more resources
- **Elasticity Class:** growing / plateau / declining — look at slopes, not current values
- **When tied on Q:** prefer the method with better scaling trajectory

---

## Parity (fair comparison)

Before comparing variants, ensure fair conditions:
- **Same time window** and data cutoff for all variants
- **Same budget** (compute, time, attempts)
- **Same measurement procedure** (version, protocol, seed-set)
- **Explicit normalization** — no hidden aggregation into single score
- **Minimum 2 repetitions** with recorded variance

---

## Anti-Goodhart discipline

Distinguish three roles for characteristics:

| Role | What it is | Example |
|------|-----------|---------|
| **Observation indicator** | Monitored, not optimized | Latency p99, error rate |
| **Acceptance criterion** | Hard constraint (pass/fail) | Security compliance, backward compat |
| **Optimization target** | Actively moved this cycle (1-3 max) | Throughput, time-to-first-byte |

Observation indicators that AREN'T optimization targets serve as anti-Goodhart watchdogs. If optimizing target X degrades indicator Y — that's a signal to stop.

---

## F-G-R assurance model

- **F (Formality):** informal | structured | formalizable | proof-grade. F_eff = min.
- **G (ClaimScope):** set-valued contexts, NOT ordinal. Enumerate specific conditions.
- **R (Reliability):** [0, 1] conservative. R_raw = min. Cross-context: R_eff = max(0, R_raw − Φ(CL_min)).

---

## CL scale (congruence levels)

| CL | Name | Meaning | Allowed use |
|----|------|---------|-------------|
| 0 | Opposed | Terms conflict | None |
| 1 | Comparable | Same domain, different framing | Naming-only |
| 2 | Translatable | Systematic mapping with known loss | Role assignment |
| 3 | Near-identity | Negligible loss in this context | Type-structure reuse |

Counter-example required for CL ≤ 2; explain absence for CL = 3.

---

## Lifecycle states

| State | Core activity | ADI phase | Assurance | Transition trigger |
|-------|--------------|-----------|-------------------|--------------------|
| **Explore** | Generate options/hypotheses | Abduction | L0 | Prime hypothesis → Shape |
| **Shape** | Formalize one direction | Deduction | L0→L1 | Predictions defined → Evidence |
| **Evidence** | Validate/verify | Induction | L1→L2 | Claims tested → Operate |
| **Operate** | Deploy + monitor | Continuous | L2 (maintained) | Evidence decay → Explore |

Transitions MUST be sequential. Skipping requires explicit justification.

---

## Evidence chains

```
Claim → Prediction → Test/method → Evidence record (EVID-*) → Result
```

Each link references a specific artifact ID.

---

## Archive vs portfolio

Two structural concepts that apply to BOTH problems and solutions:
- **Archive** — everything considered, tested, seen (full backlog + memory). Persistent.
- **Portfolio** — selected for this period (active bets, budgeted, with owners). Managed.

PROB-\* files in `anomalies/` = problem archive. PPORT-\* = problem portfolio.
SPORT-\* variants = solution archive. "Active portfolio" section in SPORT-\* = solution portfolio.
Ritual: regularly remove dominated items from portfolio to archive; add 1–2 stepping stones.

---

## Trust debt (valid_until expiry)

Every artifact with valid_until accumulates **trust debt** after expiry. When debt exceeds budget:
- **Refresh** — re-verify (run tests again, re-measure, update)
- **Deprecate** — lower status, restrict use, flag as stale
- **Waive** — temporarily accept risk with explicit justification and deadline

Trust debt is an indicator, not a punishment. It triggers processes (re-problematization, re-measurement).

---

## Where to write things

- `.fpf/anomalies/` — ANOM-\*, PROB-\*
- `.fpf/characterizations/` — CHR-\*, CHRC-\*, SOTA-\*
- `.fpf/decisions/` — DRR-\*, SEL-\*, STRAT-\*
- `.fpf/evidence/` — EVID-\*
- `.fpf/glossary/` — glossary + bridges
- `.fpf/portfolios/` — PPORT-\*, SPORT-\*
- `.fpf/worklog/` — session logs
