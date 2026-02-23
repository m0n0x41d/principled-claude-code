# Selection Record

- **ID:** SEL-…
- **Status:** Proposed | Accepted | Superseded
- **Date:** YYYY-MM-DD
- **Transformer:** …
- **Bounded context:** …
- **ClaimScope(G):** (set of contexts where this selection holds — set-valued per USM A.2.6)
- **Lifecycle state:** Shape | Evidence | Operate
- **Solution portfolio:** `.fpf/portfolios/SPORT-...`
- **Characterization passport:** `.fpf/characterizations/CHR-...`
- **Problem card:** `.fpf/anomalies/PROB-...`

---

## 1) Selection policy

State the selection policy **before** applying it. The policy must be explicit enough that a different agent could apply it to the same data and reach a similar conclusion.

- **Policy:** …
- **Tie-breaking rule:** (what happens when variants are non-dominated by each other?)
- **Stepping-stone weight:** (how much does stepping-stone potential influence selection?)

---

## 2) Dominance analysis

Qualitative Pareto analysis: for each pair of variants, determine dominance.

| Variant | I1 | I2 | I3 | Dominated by | Dominates |
|---------|----|----|------|-------------|-----------|
| V1 | … | … | … | — | V3 |
| V2 | … | … | … | — | — |
| V3 | … | … | … | V1 | — |

- **Pareto front:** (list non-dominated variants)
- **Clearly dominated:** (list variants that are dominated and why)

---

## 3) Selection

- **Selected variant(s):** …
- **Rationale (applying stated policy):** …
- **What was sacrificed:** (what the selected variant is worse at compared to alternatives)

---

## 4) Assurance

- **F (Formality):** formality of the dominance analysis (informal | structured | formalizable | proof-grade)
- **G (ClaimScope):** contexts where this selection applies (set-valued — enumerate conditions)
- **R (Reliability):** 0–1 estimate for the selection holding
- **CL (if cross-context):** if variants come from different bounded contexts, state CL (0-3) and apply penalty to R

---

## 5) Stepping-stone bets

Record 1–2 non-dominant but promising variants that are worth preserving or revisiting.

| Variant | Why preserve | Condition to reconsider | Cost of preservation |
|---------|-------------|----------------------|---------------------|
| … | … | … | … |

---

## 6) What would change this selection?

- New information that would favor a different variant:
- Changes in indicators/thresholds:
- Evidence that would invalidate the selected variant:
- Time horizon change (short-term vs long-term shift):

---

## 7) Links

- Solution portfolio: `.fpf/portfolios/SPORT-...`
- Characterization passport: `.fpf/characterizations/CHR-...`
- Problem card: `.fpf/anomalies/PROB-...`
- Evidence records: `.fpf/evidence/...`
- DRR (if escalated): `.fpf/decisions/DRR-...`
