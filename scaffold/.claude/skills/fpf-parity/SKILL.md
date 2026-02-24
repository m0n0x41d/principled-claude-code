---
name: fpf-parity
description: Ensure fair comparison conditions before evaluating variants. Produces PAR-* parity plan. SHOULD invoke before /fpf-selection when comparing ≥2 variants with measurable indicators.
argument-hint: "[comparison-context]"
---

## What this skill IS

This is **fairness assurance for comparisons**, not bureaucracy. Before declaring one variant better than another, you must ensure the comparison was fair — same budget, same data, same measurement procedure. Without parity, dominance claims are unreliable.

## When to invoke
- Before `/fpf-selection` when comparing variants with measurable indicators
- When comparing benchmark results across different conditions
- When a variant "won" but you're not sure the comparison was fair
- NOT needed for purely qualitative comparisons (e.g., architectural trade-offs)

## Output
`.fpf/characterizations/PAR-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** All candidates listed explicitly
- **C2:** Budget per candidate stated and equal (compute, time, attempts)
- **C3:** Environment identical or differences noted with impact assessment
- **C4:** Indicators from CHR-* referenced — no ad-hoc metrics
- **C5:** Minimum 2 repetitions with variance reported
- **C6:** No hidden aggregation — multi-dimensional results, not single score

## Format
```markdown
# Parity Plan
- **ID:** PAR-...  **CHR:** CHR-...  **Created:** YYYY-MM-DD

## Candidates
(A / B / C — what is being compared)

## Comparator
- Who compares: (role/agent performing the evaluation)
- Comparison method: (automated test | manual review | benchmark harness | ...)

## Equal conditions
- Time window: (same cutoff)
- Budget per candidate: (equal compute/time/attempts)
- Environment: (versions, hardware, config — identical or noted)
- Data/fixtures: (same dataset, same seed-set)

## Measurement
- Indicators: (from CHR-*, subset for this comparison)
- Repetitions: (≥2, with variance reporting)
- Normalization: (explicit rule or "none" with justification)
- Missing data: (how to handle "unknown"/"not measured" — exclude, impute, or flag)

## Result
- Non-dominated set: ...
- Eliminated and why: ...
- valid_until: YYYY-MM-DD
```
