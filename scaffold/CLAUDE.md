# Project instructions (FPF-enabled)

This repository uses the **First Principles Framework (FPF)** as its operating system for reasoning and project work.

Your job as Claude Code in this repo is not only to edit code, but to keep an *auditable trail of thought*:
hypotheses -> consequences -> tests -> evidence -> decisions.

The project provides:
- `.claude/skills/*` -- FPF Skills (each is a `/slash-command`)
- `.fpf/*` -- a workspace for FPF artifacts and logs

---

## MANDATORY FPF WORKFLOW (hard gates -- not optional)

These are **preconditions**, not suggestions. Violating them produces unauditable work.

### Gate 0: Session start -- BEFORE any other work

1. **MUST** invoke `/fpf-core` to activate FPF rules.
2. **MUST** invoke `/fpf-worklog <goal>` to create or append a session log.
3. **MUST NOT** read code, run commands, launch subagents, or start any research until Gates 0.1 and 0.2 are complete.

**Why:** Without a worklog, everything you do is ephemeral chat. The worklog is the carrier for the audit trail. No worklog = no trail = no FPF compliance.

### Gate 1: Investigation / debugging / audit work

4. **MUST** invoke `/fpf-problem-framing <topic>` before proposing hypotheses in chat.
5. **MUST NOT** write hypotheses, root-cause analysis, or investigative conclusions only in chat -- they **MUST** be written to `.fpf/anomalies/`.

**Why:** Hypotheses in chat disappear on context compaction. Anomaly records persist and are referenceable.

### Gate 2: Claims of correctness or completion

6. **MUST** invoke `/fpf-evidence <claim>` before stating "this works", "this is correct", "verified", or any equivalent.
7. **MUST NOT** claim L2 confidence without a corresponding evidence record in `.fpf/evidence/`.

**Why:** "I checked and it works" is not evidence. An evidence record with commands, outputs, and interpretation is.

### Gate 3: Non-trivial decisions

8. **MUST** invoke `/fpf-decision-record <decision>` for any architectural, product, or process decision that would be costly to undo.
9. **MUST NOT** make such decisions inline in chat without a DRR.

**Why:** Chat-only decisions create memory drift. DRRs create accountability and make reversals cheaper.

### Gate 4: New or drifting terminology

10. **MUST** invoke `/fpf-glossary <terms>` when encountering naming inconsistency, introducing new domain terms, or finding overloaded words.

**Why:** If terms drift, reasoning collapses. The glossary is the naming contract.

### Gate 5: Session end -- BEFORE stopping

11. **MUST** invoke `/fpf-review` before ending any non-trivial session.
12. **MUST NOT** end a session without an updated worklog entry.

**Why:** The review gate catches missing artifacts, untested claims, and open threads. Without it, sessions end with false confidence.

---

## Self-check: Am I complying?

Before each substantive action, ask:

1. Does a worklog exist for this session? If no -> Gate 0.
2. Am I investigating/debugging? If yes -> Gate 1 (anomaly record exists?).
3. Am I about to claim something works? If yes -> Gate 2 (evidence record exists?).
4. Am I making a decision with alternatives? If yes -> Gate 3 (DRR exists?).
5. Am I using a term that might mean different things? If yes -> Gate 4.
6. Am I about to stop? If yes -> Gate 5.

---

## Where to write FPF artifacts

Write all FPF artifacts under `.fpf/`:

- `.fpf/anomalies/` -- anomaly records (problem framing + hypotheses + predictions)
- `.fpf/decisions/` -- Decision Rationale Records (DRRs)
- `.fpf/evidence/` -- evidence records (tests/benchmarks/experiments)
- `.fpf/glossary/` -- glossary + bridges (cross-context naming alignment)
- `.fpf/worklog/` -- session logs (plan vs reality)

Use templates from `.fpf/templates/`.

---

## Default stance

### 1) Run the ADI cycle for non-trivial work
For anything beyond a trivial edit, follow the canonical loop:

- **Abduction:** propose multiple plausible hypotheses; select a prime candidate; mark new claims as *provisional*.
- **Deduction:** derive consequences / predictions / invariants. Define what would falsify the hypothesis.
- **Induction:** test against reality (run tests, measure, inspect runtime behavior) and record evidence.

### 2) Track lifecycle state
Tag the current state of the artifact/workstream:

**Explore -> Shape -> Evidence -> Operate**

Don't do "Evidence work" on a hypothesis you have not shaped into falsifiable predictions.

### 3) Maintain strict distinctions (avoid category errors)
Do not blur these:

- **Design-time** vs **run-time** (plan/spec vs execution/observations)
- **Object** vs **description** vs **carrier** (the thing vs what we say about it vs where it's stored)
- **Role / Capability / Method / MethodDescription / Work / WorkPlan**
  (avoid the overloaded word "process" -- resolve it explicitly)

### 4) Evidence is a first-class artifact
When you claim "this works" or "this is correct", produce or reference evidence:
tests, benchmarks, logs, reproducible commands, or external validation.

### 5) Cross-context consistency requires explicit bridges
If multiple repos/modules use different vocabulary for the same concept, do not wing it.
Update the glossary and create bridge cards.

---

## Output style

When answering the user, separate:

- **Design-time (Plan & Model)**
- **Run-time (Actions & Observations)**

This prevents "plan/reality conflation" and makes the work auditable.

---

## CRITICAL CONSTRAINTS

### NEVER
- Skip Gate 0 (worklog) at session start
- Write hypotheses or investigation results only in chat without `.fpf/anomalies/` records
- Claim L2 confidence without an evidence record
- Make architectural decisions without a DRR
- End a non-trivial session without `/fpf-review`
- Describe work instead of doing it
- Optimize for speed at the expense of audit trail

### ALWAYS
- State lifecycle stage (Explore/Shape/Evidence/Operate) before deep analysis
- Mark confidence + scope on technical claims
- Write artifacts to `.fpf/` DURING work, not retroactively after being caught
- Invoke skills proactively -- do not wait for the user to type `/fpf-*`
- Prefer persistent artifacts (`.fpf/` files) over ephemeral chat for anything referenceable
