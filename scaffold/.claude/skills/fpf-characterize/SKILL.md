---
name: fpf-characterize
description: Define characteristic space, indicators, and comparison rules. MUST invoke before defining acceptance criteria or comparing variants.
argument-hint: "[domain-or-comparison-context]"
---

## Output
- Passport: `.fpf/characterizations/CHR-${CLAUDE_SESSION_ID}--<slug>.md`
- Cards (optional): `.fpf/characterizations/CHRC-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Every characteristic has scale type and polarity
- **C2:** 1-3 active indicators selected from full space
- **C3:** Each indicator has threshold/target, baseline, measurement method
- **C4:** Comparison rules unambiguous — another agent could apply them
- **C5:** Measurement methods are reproducible
- **C6:** Characteristic cards for non-trivial indicators include validity window

## Format
```markdown
# Characterization Passport
- **ID:** CHR-...  **Context:** ...

## Characteristic space
| # | Characteristic | Scale | Polarity | Unit |

## Active indicators
| # | Indicator | Target | Baseline | Measurement |

## Comparison rules
- Comparator set:
- Parity rules:
- Dominance policy:

## Acceptance criteria
...
```
