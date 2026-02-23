---
name: fpf-review
description: End-of-task quality gate. MUST be invoked before ending any session. Verify completion, ensure evidence exists for key claims, and confirm FPF artifacts (anomalies/decisions/glossary/worklog) are updated.
---

## Goal
Before stopping, run a lightweight **quality gate** so we don't ship hand-wavy work.

## Procedure
1) **Restate the objective**
- What was the user's request?
- What "done" means.

2) **Check FPF artifacts**
- Anomaly record or problem card exists if this was investigative/debugging work.
- Characterization passport exists if acceptance criteria were defined or variants were compared.
- Problem portfolio exists if multiple problems were discussed or prioritized.
- Solution portfolio exists if multiple options/approaches were evaluated.
- Selection record exists if a choice was made between characterized options.
- DRR exists if we made a non-trivial decision.
- Evidence records exist for any "this works" claims.
- Evidence records have F-G-R filled (not empty/placeholder). G must be set-valued (list of contexts), not a level.
- Bridge cards use CL 0-3 scale (not legacy labels like Exact/Equivalent/Approximate/Metaphor).
- If claims cross bounded contexts, CL penalties are applied to R (not F or G).
- SoTA palette exists if architectural alternatives were evaluated (library choices, design patterns, framework selection).
- Glossary updated if new terms were introduced or naming drift was resolved.
- Worklog updated for this session.

3) **Run the minimum viable verification**
- Run the smallest test suite or static checks that meaningfully reduce risk.
- If running is not possible, state what would need to be run and why.

4) **Report remaining risks**
- Any untested assumptions?
- Any incomplete migrations?
- Any evidence that might be stale soon (validity windows)?

## Output
- Update `.fpf/worklog/session-${CLAUDE_SESSION_ID}.md` with a final summary.
- Provide the user with a concise checklist-style report:
  - Completed items
  - Evidence links
  - Remaining risks / next steps

## Session sentinel cleanup
After the review is complete, **MUST** delete the session sentinel:

```
Delete file: .fpf/.session-active
```

This signals that the session ended properly through the review gate.
The SessionStart hook also cleans stale sentinels, but explicit cleanup is preferred.

## Quality bar
- Conservative: if evidence is missing, do not claim high confidence.
- Explicit: list what would change your mind.
