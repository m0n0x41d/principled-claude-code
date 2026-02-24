---
name: fpf-decision-record
description: Record non-trivial or irreversible decisions with options, rationale, risks, and rollback plan.
argument-hint: "[decision-title]"
---

## Output
`.fpf/decisions/DRR-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Bounded context stated
- **C2:** ≥2 real alternatives enumerated (including "do nothing")
- **C3:** Each option has costs, risks, second-order effects
- **C4:** Decision states what was chosen AND why (trade-offs explicit)
- **C5:** Evidence linked or gap flagged
- **C6:** Rollback/migration plan if decision might be reversed
- **C7:** What future evidence would invalidate this decision
- **C8:** Production-affecting decisions MUST have deployment plan (canary strategy, success indicators, emergency stop criteria)
- **C9:** valid_until set — decisions go stale as context changes. Set expiry date or "perpetual" with justification.
- **C10:** Link to PAR-* (parity report) and SEL-* (selection record) when they exist — decisions must be traceable to comparison evidence

## Format
```markdown
# Decision Record
- **ID:** DRR-...  **Created:** YYYY-MM-DD  **Context:** ...
- **F:** ...  **G:** {contexts}  **R:** 0-1
- **valid_until:** YYYY-MM-DD
- **Parity:** PAR-...  **Selection:** SEL-...

## Options
1. [option] — costs, risks, second-order effects
2. [option] — ...

## Decision
Chosen: [option]. Rationale: ...

## Evidence
...

## Rollback plan
...

## Deployment plan (if production-affecting)
- Canary strategy: ...
- Success indicators: ...
- Emergency stop criteria: ...

## Invalidation conditions
...
```
