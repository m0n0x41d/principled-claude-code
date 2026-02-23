---
name: fpf-sota
description: Survey existing approaches (SoTA) and produce strategy card (method family bet). MUST invoke for T4 architectural decisions before variant generation.
argument-hint: "[problem-or-domain]"
---

## Output
1. SoTA palette: `.fpf/characterizations/SOTA-${CLAUDE_SESSION_ID}--<slug>.md`
2. Strategy card: `.fpf/decisions/STRAT-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** ≥2 distinct traditions/approaches surveyed
- **C2:** Search scope bounded — state what was and wasn't searched
- **C3:** Claims tagged with F-G-R (Formality, ClaimScope, Reliability)
- **C4:** Bridge matrix with CL 0-3 between traditions (not informal labels)
- **C5:** Gaps identified — what no tradition covers
- **C6:** Strategy card states explicit method family bet with rationale
- **C7:** Invalidation conditions stated — what would cause a pivot
- **C8:** Output actionable — clear implications for variant generation axes

## Format — SOTA-*
```markdown
# SoTA Palette
- **ID:** SOTA-...  **Problem:** PROB-...

## Traditions
### T1: [name]
Description. Key claims (F/G/R). Strengths. Weaknesses.
### T2: [name]
...

## Bridge matrix
| | T1 | T2 | ... |
(CL 0-3 values)

## Gaps
...

## Implications for variants
...
```

## Format — STRAT-*
```markdown
# Strategy Card
- **ID:** STRAT-...  **Problem:** PROB-...  **SoTA:** SOTA-...

## Method family bet
Bet on: [family]. Rationale: ...

## Admissibility check
(against problem card constraints)

## Variant generation axes
(diversity dimensions within chosen family)

## Invalidation conditions
...
```
