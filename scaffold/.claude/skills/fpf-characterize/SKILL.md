---
name: fpf-characterize
description: Define the characteristic space — what could matter, how to measure it, how to compare. Think through what "better" means before generating or comparing anything.
argument-hint: "[domain-or-comparison-context]"
---

## What this skill IS

This is **defining what matters**, not listing metrics. You are constructing the space in which problems and solutions live — deciding which dimensions exist, how they're measured, and what trade-offs are possible. Without this, NQD characterization and Pareto analysis have no basis.

**Work through the template.** The characteristic space IS the lens through which you see the problem. Different spaces → different solutions look good.

## Output
- Passport: `.fpf/characterizations/CHR-${CLAUDE_SESSION_ID}--<slug>.md`
- Cards (optional): `.fpf/characterizations/CHRC-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Every characteristic has scale type (ordinal/interval/ratio) and polarity (↑/↓/target)
- **C2:** 1-3 active indicators selected from full space (not all characteristics are indicators)
- **C3:** Each indicator has threshold/target, baseline, reproducible measurement method
- **C4:** Comparison rules unambiguous — another agent could apply them mechanically
- **C5:** Measurement methods are reproducible (specify exact commands/tools)
- **C6:** Characteristic cards for non-trivial indicators include validity window

## Format
```markdown
# Characterization Passport
- **ID:** CHR-...  **Context:** ...

## Characteristic space
| # | Characteristic | Scale | Polarity | Unit |
(all dimensions that COULD matter)

## Active indicators (selected for this comparison)
| # | Indicator | Target | Baseline | Measurement method |
(1-3 selected — these drive NQD Q-dimension in SPORT-*)

## Comparison rules
- Dominance policy: (e.g., "V1 dominates V2 if better on all indicators")
- Tie-breaking: (e.g., "if tied on indicators, prefer higher N then D_p")
- Normalization: (if indicators have different scales)

## Acceptance criteria
(what "good enough" means — feeds into PROB-* acceptance spec)
```
