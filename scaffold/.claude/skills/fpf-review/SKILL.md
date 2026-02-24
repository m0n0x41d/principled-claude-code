---
name: fpf-review
description: End-of-session quality gate. Verify the creative and assurance pipeline — not just artifacts. MUST invoke before ending any non-trivial session.
---

## What this skill IS

This is a **quality review of both creative work and assurance**, not just an artifact checklist. Check:
- Did you design the problem or just react to symptoms?
- Did you explore alternatives or jump to the first solution?
- Did evidence feed back into problem reframing?
- Are there stepping stones worth preserving?

## Procedure

1. **Restate objective** — what was requested, what "done" means

2. **Check creative pipeline** (problem factory):
   - Was the problem designed proactively or reactively?
   - Does a goldilocks assessment exist? Is the problem feasible-but-hard?
   - Were alternatives to the problem framing considered?
   - If evidence refuted claims: was the problem reframed?

3. **Check solution pipeline** (solution factory):
   - Was SoTA surveyed (for architectural work)?
   - Was a method family bet made explicitly (STRAT-*)?
   - Were ≥3 genuinely distinct variants generated?
   - Was selection explicit (policy before applying)?
   - Were stepping stones preserved?

4. **Check artifacts** — tier-appropriate:
   - T2+: ANOM/PROB-* if investigative, EVID-* if claims made
   - T3+: SPORT-* if options evaluated, SEL-* if choice made, DRR-* if irreversible
   - T4: SOTA-* and STRAT-* if architectural
   - All: worklog updated

5. **Check feedback loop**:
   - Did any evidence show "refuted"? If yes → was PROB-* updated?
   - Did stepping stones get recorded for future work?

6. **Check Factory 3 (process improvement)**:
   - Was there friction in the FPF workflow itself? (gates too strict/loose, templates too heavy, missing skills)
   - If yes → create ANOM-* with process friction description for future improvement
   - Did any hook block you incorrectly? Did any template feel wrong for the task?
   - Process friction is a Factory 3 problem — record it, don't just tolerate it

7. **Run minimum verification** — smallest test that reduces risk

8. **Report** — completed items, evidence links, remaining risks, open threads (including Factory 3 observations)

## Output
- Update `.fpf/worklog/session-${CLAUDE_SESSION_ID}.md` with final summary
- Report to user: what was done, what's verified, what's left

## Sentinel cleanup
After review, delete `.fpf/.session-active`.
