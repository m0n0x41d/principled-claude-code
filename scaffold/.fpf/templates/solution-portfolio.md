# Solution Portfolio

- **ID:** SPORT-…
- **Status:** Active | Archived
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Transformer:** …
- **Bounded context:** …
- **ClaimScope(G):** (set of contexts where this variant analysis applies — set-valued per USM A.2.6)
- **Lifecycle state:** Explore | Shape | Evidence | Operate
- **Problem card:** `.fpf/anomalies/PROB-...`
- **Characterization passport:** `.fpf/characterizations/CHR-...`

---

## 1) Variant generation method

How were variants generated? (e.g., brainstorm, systematic decomposition, literature review, analogical transfer, constraint relaxation)

- **Method:** …
- **Constraints applied during generation:** …
- **Deliberate diversity strategy:** (how did you ensure variants are genuinely different, not minor variations?)

---

## 2) Variant archive

| # | Variant | Description | D_c (Eligibility) | Q (Utility) | N (Novelty) | D_p (Diversity) | Stepping-stone? | Status |
|---|---------|-------------|-------------------|-------------|-------------|-----------------|-----------------|--------|
| V1 | … | … | Pass/Fail | Low/Med/High | Low/Med/High | Low/Med/High | Yes / No | Active / Deferred / Eliminated |
| V2 | … | … | … | … | … | … | … | … |
| V3 | … | … | … | … | … | … | … | … |

### NQD characterization reference

- **D_c (Constraint fit):** Does this variant satisfy all hard constraints from the problem card? **Eligibility gate: Fail = eliminated before dominance analysis.**
- **Q (Utility):** How well does this address the acceptance spec indicators? Reference characterization passport. **Primary dominance characteristic.**
- **N (Novelty):** How different is this from existing/obvious approaches? Low = incremental, High = paradigm shift. **Tie-breaker.**
- **D_p (Diversity contribution):** How much does adding this variant diversify the portfolio? Low = overlaps with others, High = covers new territory. **Tie-breaker.**

**Pipeline:** Eligibility (D_c = Pass) → Dominance (Q) → Tie-breakers (N, D_p).

---

## 3) Stepping-stone identification

Which variants, even if not immediately dominant, could enable future progress?

| Variant | Stepping-stone to | Why | Risk of discarding |
|---------|------------------|-----|-------------------|
| … | … | … | … |

---

## 4) Active portfolio

Variants selected for further development / evaluation.

| Priority | Variant | Rationale (per selection policy) | Next action |
|----------|---------|--------------------------------|-------------|
| 1 | … | … | … |
| 2 | … | … | … |

---

## 5) Links

- Problem card: `.fpf/anomalies/PROB-...`
- Characterization passport: `.fpf/characterizations/CHR-...`
- Selection record: `.fpf/decisions/SEL-...`
- Evidence records: `.fpf/evidence/...`
- Decision records: `.fpf/decisions/DRR-...`
