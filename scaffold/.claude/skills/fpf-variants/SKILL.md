---
name: fpf-variants
description: Generate ≥3 distinct solution variants with NQD characterization. Invoke after problem framing produces acceptance spec or when facing choices.
argument-hint: "[problem-or-decision-context]"
---

## Prerequisites
- PROB-* or ANOM-* exists with acceptance spec
- STRAT-* exists with method family bet (if T3+, invoke `/fpf-sota` first if missing)
- CHR-* exists if comparing options (invoke `/fpf-characterize` first if missing)

## Output
`.fpf/portfolios/SPORT-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Minimum 3 variants — no exceptions
- **C2:** Variants must be genuinely distinct (different approach, not parameter tweaks)
- **C3:** ≥1 variant must be novel (not the obvious incremental option)
- **C4:** All variants within the method family from STRAT-*
- **C5:** NQD pipeline: D_c (eligibility gate, Pass/Fail) → Q (utility, primary) → N, D_p (tie-breakers)
- **C6:** Stepping stones identified — non-dominant variants with future option value
- **C7:** Active portfolio selected with rationale per acceptance criteria

## Format
```markdown
# Solution Portfolio
- **ID:** SPORT-...  **Problem:** PROB-...  **Strategy:** STRAT-...

## Generation method
- Method: (brainstorm|decomposition|analogical|constraint-relaxation)
- Diversity strategy: ...

## Variants
### V1: [name]
Description. D_c: Pass/Fail. Q: Low/Med/High. N: Low/Med/High. D_p: Low/Med/High.

### V2: [name]
...

### V3: [name]
...

## Stepping stones
| Variant | Stepping-stone to | Risk of discarding |

## Active portfolio
| Priority | Variant | Rationale | Next action |
```
