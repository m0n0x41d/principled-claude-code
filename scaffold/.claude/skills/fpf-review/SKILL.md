---
name: fpf-review
description: End-of-session quality gate. MUST invoke before ending any non-trivial session. Verifies artifacts, evidence, and worklog.
---

## Procedure
1. **Restate objective** — what was requested, what "done" means
2. **Check artifacts** — for each tier-appropriate artifact type, verify it exists:
   - T2+: ANOM/PROB-* if investigative, EVID-* if claims made
   - T3+: SPORT-* if options evaluated, SEL-* if choice made, DRR-* if irreversible
   - T4: SOTA-* and STRAT-* if architectural
   - All: worklog updated
3. **Check quality constraints** — C1-C10 from CLAUDE.md satisfied
4. **Run minimum verification** — smallest test/check that reduces risk
5. **Report remaining risks** — untested assumptions, stale evidence, open threads

## Output
- Update `.fpf/worklog/session-${CLAUDE_SESSION_ID}.md` with final summary
- Provide user: completed items, evidence links, remaining risks

## Sentinel cleanup
After review, delete `.fpf/.session-active` to signal proper session end.
