---
name: fpf-selection
description: Perform qualitative Pareto analysis on variants, apply explicit selection policy, record stepping-stone bets. Invoke after variant generation.
argument-hint: "[selection-context]"
---

## Prerequisites
- SPORT-* with NQD-characterized variants
- CHR-* with indicators and comparison rules
- PROB-* with acceptance criteria

## Output
`.fpf/decisions/SEL-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Selection policy stated BEFORE applying — not post-hoc rationalized
- **C2:** Dominance table complete — every variant on every indicator
- **C3:** Pareto front identified
- **C4:** ≥1 stepping-stone bet if any non-dominant variant has potential
- **C5:** "What would change this" section filled
- **C6:** Missing inputs (portfolio, passport, problem card) flagged explicitly

## Format
```markdown
# Selection Record
- **ID:** SEL-...  **Portfolio:** SPORT-...  **Passport:** CHR-...

## Selection policy
(stated before applying)

## Dominance table
| Variant | Indicator 1 | Indicator 2 | ... | Dominated by |

## Pareto front
...

## Decision
Selected: V[N]. Rationale. Sacrifices.

## Stepping-stone bets
| Variant | Why preserve | Condition to reconsider |

## What would change this
...
```
