---
name: fpf-sota
description: Survey existing approaches and produce a strategy card (method family bet). Think through what exists before choosing where to search. MUST invoke for architectural decisions before variant generation.
argument-hint: "[problem-or-domain]"
---

## What this skill IS

This is **strategic research**, not a literature review. You are mapping the landscape of existing approaches to understand what exists and what works. The output is a **SoTA palette** — a structured survey of traditions, their trade-offs, and gaps.

**After SoTA survey:** invoke `/fpf-strategize` to bet on a method family. Strategizing is a separate first-class creative act.

## Output
SoTA palette: `.fpf/characterizations/SOTA-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** ≥2 distinct traditions/approaches surveyed
- **C2:** Search scope bounded — state what was and wasn't searched
- **C3:** Claims tagged with F-G-R
- **C4:** Bridge matrix with CL 0-3 between traditions (not informal labels)
- **C5:** Gaps identified — what no tradition covers
- **C6:** Output actionable — clear implications for variant generation axes
- **C7:** After completing SOTA-*, invoke `/fpf-strategize` to create STRAT-*

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

## Next step
Invoke /fpf-strategize to create STRAT-* based on this survey.
```
