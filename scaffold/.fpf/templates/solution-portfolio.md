# Solution Portfolio

- **ID:** SPORT-…
- **Status:** Active | Archived
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Transformer:** …
- **Bounded context:** …
- **ClaimScope(G):** (set of contexts where this variant analysis applies)
- **Lifecycle state:** Explore | Shape | Evidence | Operate
- **Problem card:** `.fpf/anomalies/PROB-...`
- **Characterization passport:** `.fpf/characterizations/CHR-...`
- **Strategy card:** `.fpf/decisions/STRAT-...`

---

## 1) Variant generation method

- **Method:** (decomposition | analogical | constraint-relaxation | inversion | extreme-points)
- **Constraints applied during generation:** …
- **Deliberate diversity strategy:** (how did you ensure genuine distinctness — different trade-off profiles, not parameter tweaks?)

---

## 2) Variant archive

| # | Variant | Description | D_c | Q: [indicator 1] | Q: [indicator 2] | Q: [indicator 3] | N | D_p | Stepping-stone? | Status |
|---|---------|-------------|-----|-------------------|-------------------|-------------------|---|-----|-----------------|--------|
| V1 | … | … | Pass/Fail | (per CHR) | (per CHR) | (per CHR) | Low/Med/High | Low/Med/High | Yes / No | Active / Deferred / Eliminated |
| V2 | … | … | … | … | … | … | … | … | … | … |
| V3 | … | … | … | … | … | … | … | … | … | … |

### NQD reference

- **D_c (Constraint fit):** Eligibility gate. Fail = eliminated before dominance.
- **Q (Utility):** Multi-dimensional — one column per CHR indicator. NOT a single ordinal. Reference characterization passport for indicator definitions. **Primary dominance characteristics.**
- **N (Novelty):** How different from existing/obvious approaches? Tie-breaker.
- **D_p (Diversity):** Portfolio-level coverage. Tie-breaker.

**Pipeline:** Eligibility (D_c = Pass) → Dominance (Q per indicator, Pareto) → Tie-breakers (N, D_p).

**Never collapse Q to a single score.** Each indicator is a separate dimension of the Pareto front.

---

## 3) Stepping-stone identification

| Variant | Opens what future space | Why | Risk of discarding |
|---------|----------------------|-----|-------------------|
| … | … | … | … |

---

## 4) Active portfolio

| Priority | Variant | Rationale (per selection policy) | Next action |
|----------|---------|--------------------------------|-------------|
| 1 | … | … | … |
| 2 | … | … | … |

---

## 5) Links

- Problem card: `.fpf/anomalies/PROB-...`
- Characterization passport: `.fpf/characterizations/CHR-...`
- Strategy card: `.fpf/decisions/STRAT-...`
- Selection record: `.fpf/decisions/SEL-...`
- Evidence records: `.fpf/evidence/...`
