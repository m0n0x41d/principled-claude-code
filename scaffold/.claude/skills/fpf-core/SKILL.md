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

## Mandatory chain
After sentinel: invoke `/fpf-worklog <goal>` if no worklog exists. Do NOT proceed until worklog is created.

## FPF operating principles

### ADI cycle (for non-trivial work)
1. **Abduction:** Frame problem. Generate ≥3 hypotheses. Mark claims provisional.
2. **Deduction:** Derive predictions. Define falsification conditions.
3. **Induction:** Test against reality. Record evidence as artifact.

### Lifecycle states
**Explore** (generate options) → **Shape** (commit to hypothesis, formalize) → **Evidence** (test, measure) → **Operate** (deploy, monitor). State current state. Sequential — don't skip.

### Strict distinctions
- **Plan vs reality:** spec ≠ evidence of execution
- **Object vs description vs carrier:** running system ≠ code/docs ≠ repo
- Resolve "process" → Role | Capability | Method | MethodDescription | Work | WorkPlan

### Evidence discipline
"It works" requires: test results, benchmark output, logs, or reproduction steps. Include validity window. F-G-R: Formality (min), ClaimScope G (set-valued), Reliability (min). Cross-context: R_eff = max(0, R_raw − Φ(CL_min)).

### Cross-context alignment
Different vocabularies → glossary update + bridge card. CL 0-3 (0=Opposed, 1=Comparable, 2=Translatable, 3=Near-identity). Counter-examples required for CL≤2.

### E/E policy
- **Explore widely:** T4 tasks, new domains, unfamiliar problems
- **Exploit quickly:** T2 tasks, known patterns, clear fixes
- **Default:** explore when uncertain. Preserve 1-2 stepping stones.

## Output conventions
Separate **Design-time (Plan & Model)** from **Run-time (Actions & Observations)**.
