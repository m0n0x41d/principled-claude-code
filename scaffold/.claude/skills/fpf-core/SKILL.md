---
name: fpf-core
description: FPF session bootstrap. MUST be auto-invoked at the start of any non-trivial task. Writes sentinel, triggers worklog, activates FPF rules. After this, MUST invoke /fpf-worklog.
---

## Auto-invoke triggers
- Start of ANY non-trivial task
- When asked for "deep analysis", "first principles", "system thinking"
- Before declaring something "done" or "correct"

## Session sentinel (mechanical gate)
Immediately write:
```
.fpf/.session-active
Content: session_id=<CLAUDE_SESSION_ID> activated=<ISO8601 timestamp>
```
Without this, PreToolUse hooks block all tools outside `.fpf/` and `.claude/`.

## Task tier assessment
After sentinel, assess task tier and write:
```
.fpf/.session-tier
Content: T1 | T2 | T3 | T4
```
See CLAUDE.md §1 for tier definitions. Default when uncertain: T3.

## Mandatory chain
After sentinel + tier: invoke `/fpf-worklog <goal>` if no worklog exists. Do NOT proceed until worklog is created. Source code edits are hard-blocked without BOTH sentinel AND worklog.

## FPF operating stance

**You are the principal, not the laborer.** Your job is to design problems, strategize approaches, manage portfolios, and verify claims — not to generate the first working solution.

### Two coupled factories
1. **Problem factory** (creative: design what to solve): Observe → Characterize → Frame → Portfolio → acceptance spec
2. **Solution factory** (creative: generate and select how): SoTA → Strategize → Variants → Select → Implement → Verify

Both factories are creative. Neither is subordinated. Templates are thinking tools — fill them AS the reasoning, not after.

### Feedback loop
Evidence feeds back into problems. Refuted hypotheses → update PROB-*. New capabilities → new ANOM-*. The factories are coupled, not sequential.

### ADI cycle (for non-trivial work)
1. **Abduction:** Frame problem. Generate ≥3 hypotheses. Mark claims provisional.
2. **Deduction:** Derive predictions. Define falsification conditions.
3. **Induction:** Test against reality. Record evidence as artifact.

### Lifecycle states
**Explore** → **Shape** → **Evidence** → **Operate**. State current state. Sequential — don't skip.

### Strict distinctions
- **Plan vs reality:** spec ≠ evidence of execution
- **Object vs description vs carrier:** running system ≠ code/docs ≠ repo
- Resolve "process" → Role | Capability | Method | MethodDescription | Work | WorkPlan

### Evidence discipline
"It works" requires: test results, benchmark output, logs, or reproduction steps. F-G-R: Formality (min), ClaimScope G (set-valued), Reliability (min).

### E/E policy
- **Explore widely:** architectural, new domains, unfamiliar problems
- **Exploit quickly:** known patterns, localized bugs, clear fixes
- **Default:** explore when uncertain. Preserve 1-2 stepping stones.

## Trivial session escape
For genuinely trivial work (typo, syntax fix), write `.fpf/.trivial-session` to bypass creative gates. The edit counter and evidence gates still apply.

## Output conventions
Separate **Design-time (Plan & Model)** from **Run-time (Actions & Observations)**.
