# Characterization Passport

- **ID:** CHR-…
- **Status:** Draft | Active | Archived
- **Created:** YYYY-MM-DD
- **Transformer:** …
- **Bounded context:** …
- **ClaimScope(G):** (set of contexts where this characterization applies — set-valued per USM A.2.6)
- **Temporal scope:** (what version/time period does this characterization cover? No implicit "latest" — per Γ_time)
- **Lifecycle state:** Explore | Shape | Evidence | Operate
- **Related problem card(s):** `.fpf/anomalies/PROB-...`

---

## 1) Characteristic space

Define the full set of characteristics relevant to comparing variants in this context.

| # | Characteristic | Scale type | Unit | Polarity | Card |
|---|---------------|-----------|------|----------|------|
| 1 | … | Nominal / Ordinal / Interval / Ratio | … | Higher-better / Lower-better / Target | `.fpf/characterizations/CHRC-...` |
| 2 | … | … | … | … | … |
| 3 | … | … | … | … | … |

> List all characteristics that matter, not just the ones you will measure.
> The subset selected for active measurement becomes the indicator set below.

---

## 2) Indicators (selected characteristics)

Select 1–3 characteristics from the space above as active indicators for this comparison cycle.

| Indicator | Characteristic # | Role | Threshold / target | Baseline | Measurement method |
|-----------|-----------------|------|-------------------|----------|-------------------|
| I1 | … | Observation / Acceptance / Optimization | … | … | … |
| I2 | … | Observation / Acceptance / Optimization | … | … | … |
| I3 | … | Observation / Acceptance / Optimization | … | … | … |

Anti-Goodhart: Observation indicators not targeted for optimization serve as watchdogs.
Optimization targets: 1-3 max per cycle. Acceptance = hard pass/fail gates.

---

## 3) Comparison rules

- **Comparator set:** (what is being compared — e.g., solution variants, system configurations)
- **Parity rule:** (which indicators must be equal or within tolerance for fair comparison)
- **Normalization:** (how different scales are made comparable, if needed)
- **Dominance policy:** (when does variant A dominate variant B — e.g., "better on all indicators" or "better on majority with no worse than X% on any")

---

## 4) Acceptance criteria

What must a variant satisfy to be considered acceptable (not just dominant)?

- Criterion 1:
- Criterion 2:
- Criterion 3:

> These criteria flow into the problem card's acceptance spec.
> A variant can be Pareto-dominant but still fail acceptance if it misses a threshold.

---

## 5) Links

- Characteristic cards: `.fpf/characterizations/CHRC-...`
- Problem card: `.fpf/anomalies/PROB-...`
- Solution portfolio: `.fpf/portfolios/SPORT-...`
- Evidence records: `.fpf/evidence/...`
