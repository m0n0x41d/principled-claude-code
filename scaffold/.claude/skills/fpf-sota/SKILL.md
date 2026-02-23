---
name: fpf-sota
description: Survey existing approaches and produce a strategy card (method family bet). Think through what exists before choosing where to search. MUST invoke for architectural decisions before variant generation.
argument-hint: "[problem-or-domain]"
---

## What this skill IS

This is **strategic research**, not a literature review. You are mapping the landscape of existing approaches to decide WHERE to search for solutions. The output is a **bet on a method family** — an explicit, auditable commitment to which class of approach you'll explore variants within.

**Two distinct acts here:**
1. **SoTA survey** — what exists? what works? what are the trade-offs?
2. **Strategizing** — which method family do we bet on, and why?

Strategizing is NOT variant selection. It's scoping the search space.

## Output
1. SoTA palette: `.fpf/characterizations/SOTA-${CLAUDE_SESSION_ID}--<slug>.md`
2. Strategy card: `.fpf/decisions/STRAT-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** ≥2 distinct traditions/approaches surveyed
- **C2:** Search scope bounded — state what was and wasn't searched
- **C3:** Claims tagged with F-G-R
- **C4:** Bridge matrix with CL 0-3 between traditions (not informal labels)
- **C5:** Gaps identified — what no tradition covers
- **C6:** Strategy card states explicit method family bet with rationale
- **C7:** Invalidation conditions — what would cause a pivot to different family
- **C8:** Output actionable — clear implications for variant generation axes

## Format — SOTA-*
```markdown
# SoTA Palette
- **ID:** SOTA-...  **Problem:** PROB-...

## Discovery scope
- Searched: (what sources, terms, docs)
- Not searched: (what was scoped out and why)

## Traditions
### T1: [name]
Description. Key claims (F/G/R). Strengths. Weaknesses.
### T2: [name]
...

## Bridge matrix
| | T1 | T2 | ... |
(CL 0-3 with loss notes)

## Gaps
(what no tradition covers)

## Implications for variants
(actionable guidance for solution generation)
```

## Format — STRAT-*
```markdown
# Strategy Card
- **ID:** STRAT-...  **Problem:** PROB-...  **SoTA:** SOTA-...

## Method family bet
Bet on: [family]. Rationale: (why this family over others)

## Admissibility check
(does this family satisfy PROB-* constraints?)

## Variant generation axes
(diversity dimensions within chosen family — what will differ between variants)

## Invalidation conditions
(what evidence or constraint change would cause a pivot)
```
