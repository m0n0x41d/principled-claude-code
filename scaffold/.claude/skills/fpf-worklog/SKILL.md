---
name: fpf-worklog
description: Create or append session work log. MUST be invoked at session start (Gate 0 chain) before any substantive work.
argument-hint: "[session-goal]"
---

## Output
`.fpf/worklog/session-${CLAUDE_SESSION_ID}.md`

## Constraints
- **C1:** Log MUST separate design-time (plan) from run-time (observations)
- **C2:** Each step MUST record: planned action, actual action, outcome
- **C3:** MUST link to any artifacts created (PROB-*, EVID-*, DRR-*)
- **C4:** MUST have "Open threads / TODO" section
- **C5:** Don't write a diary — write an audit trail

## Format
```markdown
# Work Log — Session
- **Session ID:** ...
- **Started:** YYYY-MM-DD
- **Goal(s):** ...
- **Scope:** ...

## Design-time (Plan & Model)
- Current state:
- Intended changes:
- Assumptions:

## Run-time (Actions & Observations)
### Step N — ...
- Planned:
- Did:
- Observed:
- Files changed:

## Open threads / TODO
- ...
```
