---
name: fpf-variants
description: Explore the solution space by generating ≥3 genuinely distinct variants within the chosen method family. Think through alternatives using the portfolio template as scaffolding.
argument-hint: "[problem-or-decision-context]"
---

## What this skill IS

This is **creative solution exploration**, not box-checking. You are exploring the solution space — generating diverse alternatives, characterizing trade-offs, identifying stepping stones. The goal is NOT to produce 3 trivially different options — it's to map the landscape of possible approaches.

**Work through the template as scaffolding.** Generate variants BY filling the template, not in chat first.

## Prerequisites
- PROB-* or ANOM-* exists with acceptance spec
- STRAT-* exists with method family bet (if missing: invoke `/fpf-sota` first)
- CHR-* exists with comparison indicators (if missing: invoke `/fpf-characterize` first)

## Generation guidance

**Diversity strategies (pick at least one):**
- **Decomposition:** Break the problem into sub-problems, solve each differently
- **Analogical:** Import patterns from different domains/stacks
- **Constraint relaxation:** What if we dropped constraint X? What becomes possible?
- **Inversion:** Solve the opposite problem. What if we optimized for a different indicator?
- **Extreme points:** What's the simplest possible? Most sophisticated? Most unusual?

**Test for genuine distinctness:** If two variants differ only in a parameter value or minor implementation detail, they are NOT distinct. Distinct means different trade-off profiles — different points on the Pareto front.

**Stepping stones matter:** A variant that isn't the best today but opens new search spaces (new tools, new data, new interfaces) has option value. Don't discard it — mark it as a stepping stone.

## Output
`.fpf/portfolios/SPORT-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Minimum 3 variants — no exceptions
- **C2:** Variants must be genuinely distinct (different trade-off profiles, not parameter tweaks)
- **C3:** ≥1 variant must be non-obvious (not the incremental improvement everyone would try first)
- **C4:** All variants within the method family from STRAT-*
- **C5:** NQD per CHR indicators: D_c (eligibility) → Q per indicator (multi-dimensional, not single ordinal) → N, D_p (tie-breakers)
- **C6:** Stepping stones identified — non-dominant variants with future option value
- **C7:** Active portfolio selected with rationale per acceptance criteria

## Format
```markdown
# Solution Portfolio
- **ID:** SPORT-...  **Problem:** PROB-...  **Strategy:** STRAT-...

## Generation method
- Method: (decomposition|analogical|constraint-relaxation|inversion|extreme-points)
- Diversity strategy: (how did you ensure genuine distinctness?)

## Variants
### V1: [name]
Description. Trade-off profile.
- D_c: Pass/Fail
- Q: [per CHR indicator — e.g., "latency: Low, maintainability: High, cost: Med"]
- N: Low/Med/High
- D_p: Low/Med/High

### V2: [name]
...

### V3: [name]
...

## Stepping stones
| Variant | Opens what future space | Risk of discarding |

## Active portfolio
| Priority | Variant | Rationale | Next action |
```
