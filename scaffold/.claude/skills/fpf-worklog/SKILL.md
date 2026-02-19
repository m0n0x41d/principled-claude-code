---
name: fpf-worklog
description: Create or append a session Work Log (plan vs reality, commands run, observations, links to decisions and evidence). MUST be invoked at session start before any substantive work.
argument-hint: "[session-goal]"
---

## Goal
Keep a lightweight but auditable record of what happened in this session.

This prevents plan/reality conflation and makes later debugging/refactoring dramatically easier.

## Output
Create or append:

- `.fpf/worklog/session-${CLAUDE_SESSION_ID}.md`

Use the template:

- `.fpf/templates/worklog.md`

If the user passed arguments, record them as the session goal(s).

## Procedure
1) Start the log with:
- session goal(s),
- repo/module scope,
- assumptions.

2) For each major step, capture:
- **planned** action (design-time),
- **executed** action (run-time),
- outcome/observations,
- files changed,
- commands run,
- links to DRRs/evidence/anomalies.

3) Keep a short "Open threads / TODO" section.

## Quality bar
- Don't write a diary; write an audit trail.
- Prefer links over prose where possible.
- Keep plan vs reality separate.
