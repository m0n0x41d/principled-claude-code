---
name: fpf-core
description: FPF baseline and session bootstrap. MUST be auto-invoked at the start of any non-trivial task. Activates ADI cycle, lifecycle states, strict distinctions, and evidence discipline. After invoking this, MUST immediately invoke /fpf-worklog.
---

You are working in an **FPF-enabled** repository. Apply these rules *by default*.

## When to use this skill (auto-invoke -- do not wait for user)
**MUST** invoke `/fpf-core` proactively:
- At the start of ANY non-trivial task (multi-file changes, debugging, design work, refactors, audits, research).
- When the user asks for "deep analysis", "first principles", "system thinking", or "why".
- When you feel ambiguity, naming drift, or "process" confusion.
- Before declaring something "done" or "correct".

## Session sentinel (mechanical gate)
Immediately upon invocation, **MUST** write the sentinel file that unlocks source code modifications:

```
Write file: .fpf/.session-active
Content: session_id=<CLAUDE_SESSION_ID> activated=<ISO8601 timestamp>
```

Without this sentinel, the PreToolUse hook blocks all Write/Edit calls to files outside `.fpf/`.
This makes Gate 0 compliance **mechanically enforced**, not advisory.

## Mandatory chain after invocation
After `/fpf-core` activates and the sentinel is written, you **MUST** immediately invoke `/fpf-worklog <goal>` if no worklog exists for this session. Do NOT proceed to read code, run commands, or launch subagents until the worklog is created. This is Gate 0 from CLAUDE.md.

## Core operating rules (FPF in practice)

### 1) ADI: Propose -> Analyze -> Test
For non-trivial work, run the loop explicitly:

1. **Abduction (Propose):**
   - Frame the anomaly/problem clearly.
   - Generate **multiple** hypotheses (>=3 when possible).
   - Mark new claims as **provisional** (start at low assurance).

2. **Deduction (Analyze):**
   - Derive consequences/predictions.
   - Identify what would falsify the hypothesis.
   - Check for internal contradictions.

3. **Induction (Test):**
   - Test predictions against reality (tests, benchmarks, logs, experiments).
   - Record evidence as an artifact (don't just "feel" confident).

### 2) Lifecycle state awareness
Always state the current state of the workstream/artifact:

**Explore -> Shape -> Evidence -> Operate**

- Explore: generate options/hypotheses (abduction-heavy)
- Shape: commit to a prime hypothesis and formalize it (deduction-heavy)
- Evidence: test it (induction-heavy)
- Operate: deploy/monitor; keep evidence fresh

### 3) Strict distinctions (anti-category-error guardrails)
Avoid these common collapses:

- **Plan vs reality:** A plan/spec is not evidence that execution happened.
- **Object vs description vs carrier:** the repo is a *carrier*; code/docs are *descriptions*; running systems are *objects*.
- **Role / Capability / Method / MethodDescription / Work / WorkPlan:**
  - Role: "who/what is acting in context"
  - Capability: "ability to perform"
  - Method: "abstract way-of-doing"
  - MethodDescription: "the recipe/spec of the method" (code/docs)
  - Work: "this specific execution/run"
  - WorkPlan: "schedule/intention for work"

If someone says "process", resolve it: do they mean MethodDescription, WorkPlan, or Work?

### 4) Evidence discipline (and freshness)
If you claim "it works", link to:
- test results,
- benchmark output,
- logs,
- reproduction steps,
- or other concrete evidence.

Include a **validity window** when evidence can go stale, and note when it should be refreshed.

### 5) Cross-context alignment requires explicit bridges
If multiple modules/repos use different terms:
- update `.fpf/glossary/glossary.md`
- create a bridge card in `.fpf/glossary/bridges/`

Do not assume sameness across contexts without an explicit mapping.

## Output conventions (for answers and logs)
When writing analysis to the user or to `.fpf/*`, separate:

- **Design-time (Plan & Model)**
- **Run-time (Actions & Observations)**

This prevents plan/reality conflation and makes the work auditable.

## Additional resources (local)
- Quick reference: `quickref.md`
- Full spec (reference): `reference/FPF-Spec.md`
