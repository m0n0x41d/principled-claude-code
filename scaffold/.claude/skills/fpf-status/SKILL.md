---
name: fpf-status
description: Show current FPF session state — tier, edit count, artifacts, pending gates. Read-only diagnostic.
---

## What this skill IS

A **read-only diagnostic** that shows the current FPF session state at a glance. No artifacts created, no side effects. Use when you want to know "where am I in the FPF process?"

## Procedure

Read and report the following (use Read/Glob only):

1. **Session state:**
   - `.fpf/.session-active` — exists? fresh?
   - `.fpf/.session-tier` — current tier (T1/T2/T3/T4)
   - `.fpf/.trivial-session` — trivial bypass active?
   - `.fpf/.source-edit-count` — current edit count
   - `.fpf/.review-done` — review completed?

2. **Artifacts this session** (match session ID prefix):
   - PROB-*/ANOM-* in `.fpf/anomalies/`
   - CHR-* in `.fpf/characterizations/`
   - SOTA-* in `.fpf/characterizations/`
   - STRAT-*/SEL-*/DRR-* in `.fpf/decisions/`
   - SPORT-*/PPORT-* in `.fpf/portfolios/`
   - EVID-* in `.fpf/evidence/`
   - Worklog in `.fpf/worklog/`

3. **Pending gates** (what hooks will check next):
   - Gate 0: sentinel + worklog (done if both exist)
   - C5: PROB/ANOM needed if edits ≥ threshold
   - C1: PROB needs ≥3 hypotheses (check if exists)
   - C2: SPORT needs ≥3 variants (check if exists)
   - G2: EVID needed if source edits > 0
   - G3: DRR needed if STRAT/SEL exist
   - C10: /fpf-review needed before session end

4. **Config** (from `.fpf/config.sh`):
   - Edit thresholds, sentinel max age, artifact window

## Output format

Report as a concise table to the user. Example:

```
FPF Status — Session e00ed34f
Tier: T3 | Edits: 12 | Trivial: no

Artifacts:
  PROB-e00ed34f--feature.md     ✓ (3 hypotheses)
  CHR: none (inline in PROB)
  SPORT-e00ed34f--feature.md    ✓ (3 variants)
  SEL: none                     ← next step
  EVID: none                    ← needed before end

Pending: /fpf-selection → implement → /fpf-evidence → /fpf-review
```
