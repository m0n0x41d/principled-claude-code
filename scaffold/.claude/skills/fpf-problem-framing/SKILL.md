---
name: fpf-problem-framing
description: Create an FPF problem framing artifact — anomaly record (ANOM-*) or problem card (PROB-*). MUST invoke for debugging, new features, design decisions, or any substantive work. Problematization is creative discipline.
argument-hint: "[topic-or-short-title]"
---

## Auto-invoke triggers
- Debugging or investigating anomaly
- Designing new feature or capability
- Facing architecture or design decision
- Requirements unclear or ambiguous
- Starting substantive work without a defined problem

## Scope assessment
- **Quick (ANOM-*):** Localized bug, single hypothesis likely, fix straightforward
- **Substantive (PROB-*):** Multiple approaches, trade-offs exist, needs variant generation

When in doubt → start as ANOM-*, promote to PROB-* if complexity emerges.

## Output
- ANOM: `.fpf/anomalies/ANOM-${CLAUDE_SESSION_ID}--<slug>.md`
- PROB: `.fpf/anomalies/PROB-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Problem statement in ≤1 paragraph (signal, current state, desired state, impact)
- **C2:** ≥3 hypotheses for PROB-* (each with parsimony + explanatory power + falsifiability)
- **C3:** Prime hypothesis selected with predictions (what would confirm/falsify)
- **C4:** Minimum viable test plan defined
- **C5:** PROB-* MUST have goldilocks assessment (measurability, reversibility, stepping-stone, trade-off axes)
- **C6:** PROB-* MUST have acceptance spec (indicators, criteria, baseline, required evidence)
- **C7:** Separate observations (facts) from assumptions (design-time)

## Format — ANOM-*
```markdown
# Anomaly Record
- **ID:** ANOM-...  **Status:** Open  **Created:** YYYY-MM-DD

## What happened
(signal + observations)

## Hypotheses
H1: ...
H2: ...

## Prime hypothesis + predictions
...

## Test plan
...
```

## Format — PROB-*
```markdown
# Problem Card
- **ID:** PROB-...  **Status:** Open  **Created:** YYYY-MM-DD
- **Lifecycle state:** Explore|Shape|Evidence|Operate

## Problem statement
- **Signal:** ...  **Current:** ...  **Desired:** ...  **Impact:** ...

## Constraints
...

## Hypotheses
H1: ... (parsimony, explanatory power, falsifiability)
H2: ...
H3: ...

## Prime hypothesis + predictions
...

## Goldilocks assessment
- Measurability:  - Reversibility:  - Stepping-stone:  - Trade-off axes:

## Acceptance spec
- Indicators:  - Criteria:  - Baseline:  - Required evidence:

## What would change this problem?
...
```
