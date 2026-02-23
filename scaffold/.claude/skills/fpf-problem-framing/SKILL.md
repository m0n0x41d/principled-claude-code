---
name: fpf-problem-framing
description: Think through a problem by working through the problem card template. Design what problem you're solving and how you'll know it's solved. MUST invoke for debugging, new features, design decisions, or any substantive work.
argument-hint: "[topic-or-short-title]"
---

## What this skill IS

This is **creative problem design**, not paperwork. You are designing the problem — choosing what to solve, defining what "solved" means, identifying trade-off axes. In a world of cheap solution generation, this is the scarce skill.

**Work through the template as scaffolding for your thinking.** Don't think in chat and fill the template afterward — the template IS the thinking tool.

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
**Graduation criteria:** If you find yourself writing ≥3 hypotheses, or the fix isn't obvious, promote to PROB-*.

## Creative problem design guidance

**Framing matters more than solving.** A well-framed problem makes the solution factory efficient. A poorly-framed problem produces noise regardless of how many variants you generate.

**Ask these while filling the template:**
- Is this a goldilocks problem? (feasible-but-hard, not trivial, not impossible)
- What's the zone of proximal development? (what can be solved with known methods but isn't obvious?)
- What trade-off axes exist? (if there's no trade-off, it's not on the frontier)
- Could reframing this problem open new solution spaces?
- What stepping stones might this produce even if the direct solution fails?

**Reframing moves:** If the initial framing feels too narrow or too broad:
- Split: one problem into multiple with different trade-off axes
- Merge: related symptoms into a single root-cause problem
- Invert: "prevent X" → "enable Y"; "fix bug" → "redesign for correctness"
- Zoom out: from symptom to system property
- Zoom in: from vague goal to specific measurable indicator

## Output
- ANOM: `.fpf/anomalies/ANOM-${CLAUDE_SESSION_ID}--<slug>.md`
- PROB: `.fpf/anomalies/PROB-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Problem statement in ≤1 paragraph (signal, current state, desired state, impact)
- **C2:** ≥3 hypotheses for PROB-* (each with parsimony + explanatory power + falsifiability)
- **C3:** Prime hypothesis selected with predictions (what would confirm/falsify)
- **C4:** Minimum viable test plan defined
- **C5:** PROB-* MUST have goldilocks assessment (measurability, reversibility, stepping-stone potential, trade-off axes)
- **C6:** PROB-* MUST have acceptance spec (indicators from CHR-*, criteria, baseline, required evidence)
- **C7:** Separate observations (facts) from assumptions (design-time)

## Format — ANOM-*
```markdown
# Anomaly Record
- **ID:** ANOM-...  **Status:** Open  **Created:** YYYY-MM-DD

## What happened
(signal + observations — facts only, assumptions separate)

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
- Measurability: (can you verify a solution without guessing?)
- Reversibility: (what's the blast radius if wrong?)
- Stepping-stone potential: (does solving this open new solution spaces?)
- Trade-off axes: (what competing goals exist?)

## Acceptance spec
- Indicators: (from CHR-* passport)
- Criteria: (what "good enough" means)
- Baseline: (current measured state)
- Required evidence: (what EVID-* must show)

## What would change this problem?
...
```
