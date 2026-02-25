---
name: fpf-selection
description: Perform qualitative Pareto analysis on variants, apply explicit selection policy, record stepping-stone bets. Think through the trade-offs using the selection template.
argument-hint: "[selection-context]"
---

## What this skill IS

This is **deliberate choice with trade-off awareness**, not picking the obvious winner. You are mapping the Pareto front, stating your selection policy BEFORE applying it, and preserving stepping stones.

**Key discipline:** Never collapse NQD to a single score. Hold the Pareto front. State why you're choosing one point on the front over others.

## Prerequisites
- SPORT-* with NQD-characterized variants (≥3)
- CHR-* with indicators and comparison rules
- PROB-* with acceptance criteria
- If comparing variants with measurable indicators: PAR-* parity plan (invoke `/fpf-parity` first)

## Output
`.fpf/decisions/SEL-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Selection policy stated BEFORE applying — not post-hoc rationalized
- **C2:** Dominance table complete — every variant on every CHR indicator (multi-dimensional Q)
- **C3:** Pareto front identified (non-dominated variants)
- **C4:** ≥1 stepping-stone bet — non-dominant variant preserved with conditions to reconsider
- **C5:** "What would change this" section filled — what evidence or constraint shift would reverse selection
- **C6:** Missing inputs (portfolio, passport, problem card) flagged explicitly
- **C7:** WLNK comparison — dominance analysis MUST consider each variant's weakest link. A variant whose weakest link is weaker than another's is dominated on that axis.
- **C8:** MONO check — if the selected variant is more complex than alternatives (more components, more abstractions), state why the added complexity is justified given the new weak links it introduces.

## Format
```markdown
# Selection Record
- **ID:** SEL-...  **Portfolio:** SPORT-...  **Passport:** CHR-...
- **valid_until:** YYYY-MM-DD

## Admission conditions
(hard constraints — variants that fail these are eliminated before comparison: safety, compliance, cost ceiling, ...)

## Selection policy
(stated before applying — e.g., "maximize latency within cost constraint" or "learning value first")
- Main criterion: ...
- Tie-breakers (in order): ...
- Minimum trust level: (what counts as "sufficiently verified" for this selection)

## Dominance table
| Variant | [CHR indicator 1] | [CHR indicator 2] | ... | WLNK | N | D_p | Dominated by |

## Pareto front
(non-dominated variants)

## Decision
Selected: V[N]. Rationale. What was sacrificed. Why this point on the Pareto front.

## Stepping-stone bets
| Variant | Why preserve | What future space it opens | Condition to reconsider |

## MONO assessment
(If selected variant is more complex than alternatives: what new weak links, and why is added complexity justified?)

## What would change this
(what evidence, constraint change, or new information would reverse this selection)

## valid_until
(when does this selection go stale?)
```
