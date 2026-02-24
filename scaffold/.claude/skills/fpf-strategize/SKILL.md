---
name: fpf-strategize
description: Bet on a method family — choose WHICH CLASS of approach to explore, not which specific solution. First-class creative act. MUST invoke for T4 architectural work before variant generation.
argument-hint: "[problem-or-domain]"
---

## What this skill IS

This is **strategic betting**, not variant selection. You are choosing which class of approach to bet on — scoping the search space for variant generation. "We'll explore variants within [family X] because [reason]."

**Strategizing ≠ SoTA survey.** SoTA maps the landscape; strategizing bets on a region.
**Strategizing ≠ variant selection.** Strategy scopes the family; selection picks from generated variants.

## Prerequisites
- PROB-* or ANOM-* exists with acceptance spec
- SOTA-* exists (if missing: invoke `/fpf-sota` first)

## Output
`.fpf/decisions/STRAT-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** ≥2 candidate method families evaluated
- **C2:** Each family assessed for admissibility against PROB-* constraints
- **C3:** Primary bet stated with rationale (why this family over others)
- **C4:** Variant generation axes defined (what will differ between variants within this family)
- **C5:** Invalidation conditions stated (what would cause a pivot to different family)
- **C6:** Links to PROB-* and SOTA-*
- **C7:** Scaling-Law Lens (SLL): for each family, state how it scales with more resources (compute/data/time). Elasticity class: growing | plateau | declining. At comparable budgets, prefer the family with better scaling slopes (BLP — Bitter Lesson Preference).

## Format
```markdown
# Strategy Card
- **ID:** STRAT-...  **Problem:** PROB-...  **SoTA:** SOTA-...

## Candidate families
| # | Family | Admissible? | Scaling (SLL) | Key risks |
| F1 | ... | Y/N | growing/plateau/declining | ... |
| F2 | ... | Y/N | growing/plateau/declining | ... |

## Bet
Primary: [family]. Rationale: ...

## Variant generation axes
(diversity dimensions within chosen family)

## Invalidation conditions
(what would cause a pivot)
```
