# Project instructions (FPF-enabled)

This repository uses the **First Principles Framework (FPF)** as its operating system for reasoning and project work.

Your job as Claude Code in this repo is not only to edit code, but to run two coupled loops:
a **problem factory** that produces well-characterized problems with acceptance specs,
and a **solution factory** that generates, selects, implements, and verifies solutions.

The project provides:
- `.claude/skills/*` -- FPF Skills (each is a `/slash-command`)
- `.fpf/*` -- a workspace for FPF artifacts and logs

---

## DOUBLE-LOOP WORKFLOW (primary framing)

FPF work proceeds through two coupled factories. The problem factory outputs an **acceptance spec** that the solution factory consumes.

### Problem factory

Observe → Characterize → Frame problem → Manage portfolio → **Output: acceptance spec**

1. **Observe:** Notice anomalies, signals, stakeholder requests. Quick investigations produce ANOM-\* records.
2. **Characterize** (`/fpf-characterize`): Define the characteristic space — what could matter, what will be measured, how variants will be compared. Produces CHR-\* passports.
3. **Frame problem** (`/fpf-problem-framing`): For substantive problems, produce PROB-\* cards with goldilocks assessment and acceptance spec referencing the characterization passport.
4. **Manage portfolio** (`/fpf-problem-portfolio`): When multiple problems exist, manage them as a portfolio with explicit selection rules and diversification checks. Produces PPORT-\* records.

The problem factory's output is an **acceptance spec** — a contract that tells the solution factory exactly what "solved" means.

### Solution factory

Acceptance spec → Generate variants → Select → Implement → Verify → Record decision

1. **Generate variants** (`/fpf-variants`): Produce ≥3 genuinely distinct solution variants. Characterize each with NQD (Novelty, Utility, Constraint fit, Diversity). Produces SPORT-\* portfolios.
2. **Select** (`/fpf-selection`): Perform qualitative Pareto analysis. Apply an explicit selection policy (stated before applying). Record stepping-stone bets. Produces SEL-\* records.
3. **Implement:** Write code, make changes. Standard engineering work.
4. **Verify** (`/fpf-evidence`): Test claims against the acceptance spec. Produce EVID-\* records with commands, outputs, and interpretation.
5. **Record decision** (`/fpf-decision-record`): For non-trivial or irreversible decisions, create DRR-\* records with options, rationale, and rollback plans.

---

## MANDATORY GATES (enforcement within the loops)

These are **preconditions**, not suggestions. Violating them produces unauditable work.

### Gate 0: Session start -- BEFORE any other work

1. **MUST** invoke `/fpf-core` to activate FPF rules.
2. **MUST** invoke `/fpf-worklog <goal>` to create or append a session log.
3. **MUST NOT** read code, run commands, launch subagents, or start any research until Gates 0.1 and 0.2 are complete.

**Why:** Without a worklog, everything you do is ephemeral chat. The worklog is the carrier for the audit trail. No worklog = no trail = no FPF compliance.

### Gate 1: Investigation / debugging / audit work

4. **MUST** invoke `/fpf-problem-framing <topic>` before proposing hypotheses in chat.
5. **MUST NOT** write hypotheses, root-cause analysis, or investigative conclusions only in chat -- they **MUST** be written to `.fpf/anomalies/`.

**Why:** Hypotheses in chat disappear on context compaction. Anomaly records and problem cards persist and are referenceable.

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

Before each substantive action, ask — grouped by the two factories:

**Session discipline:**
1. Does a worklog exist for this session? If no → Gate 0.
2. Am I about to stop? If yes → Gate 5 (`/fpf-review`).

**Problem factory (problematization → characterization → acceptance spec):**
3. Am I investigating/debugging? If yes → does an anomaly record or problem card exist? (Gate 1)
4. Am I defining acceptance criteria or comparing options? If yes → does a characterization passport exist?
5. Are there multiple active problems? If yes → is the portfolio managed with an explicit selection rule?

**Solution factory (SoTA → variants → select → implement → verify):**
6. Am I facing an architectural/design choice with known approaches? If yes → was SoTA surveyed (`/fpf-sota`)?
7. Am I jumping to a solution? If yes → were ≥3 variants generated first?
8. Am I choosing between options? If yes → was the selection explicit (policy stated before applying)?
9. Am I about to claim something works? If yes → does an evidence record exist? (Gate 2)
10. Am I making a non-trivial decision? If yes → does a DRR exist? (Gate 3)

**Cross-cutting:**
11. Am I using a term that might mean different things? If yes → Gate 4 (`/fpf-glossary`).

---

## Where to write FPF artifacts

Write all FPF artifacts under `.fpf/`:

- `.fpf/anomalies/` -- anomaly records (ANOM-\*) and problem cards (PROB-\*)
- `.fpf/characterizations/` -- characterization passports (CHR-\*) and characteristic cards (CHRC-\*)
- `.fpf/decisions/` -- Decision Rationale Records (DRR-\*) and selection records (SEL-\*)
- `.fpf/evidence/` -- evidence records (EVID-\*)
- `.fpf/glossary/` -- glossary + bridges (cross-context naming alignment)
- `.fpf/portfolios/` -- problem portfolios (PPORT-\*) and solution portfolios (SPORT-\*)
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

**Explore → Shape → Evidence → Operate**

Don't do "Evidence work" on a hypothesis you have not shaped into falsifiable predictions.

### 3) Maintain strict distinctions (avoid category errors)
Do not blur these:

- **Design-time** vs **run-time** (plan/spec vs execution/observations). Evidence and decision records carry a **DesignRunTag** — never mix design-time claims with run-time observations in the same assurance tuple.
- **Object** vs **description** vs **carrier** (the thing vs what we say about it vs where it's stored)
- **Role / Capability / Method / MethodDescription / Work / WorkPlan**
  (avoid the overloaded word "process" -- resolve it explicitly)

### 4) Evidence is a first-class artifact
When you claim "this works" or "this is correct", produce or reference evidence:
tests, benchmarks, logs, reproducible commands, or external validation.

### 5) Cross-context consistency requires explicit bridges
If multiple repos/modules use different vocabulary for the same concept, do not wing it.
Update the glossary and create bridge cards.

### 6) Generate before selecting
When facing a choice, generate ≥3 distinct variants before selecting.
Characterize variants against a characterization passport. Select explicitly.

### 7) Manage portfolios, not ad-hoc lists
When multiple problems or solutions exist, manage them as portfolios with explicit selection rules, not as ad-hoc priority lists.

### 8) Track F-G-R on evidence and decisions
Every evidence record and decision must have Formality, ClaimScope(G), and Reliability.
G is set-valued (list specific contexts/conditions), not an ordinal level.
F_eff = min(F_i). R_raw = min(R_i). If cross-context: R_eff = max(0, R_raw − Φ(CL_min)).

### 9) Use CL 0-3 for bridges
Bridge cards use the spec CL scale: 0=Opposed, 1=Comparable, 2=Translatable, 3=Near-identity.
CL penalties affect R only (not F or G). Always provide counter-examples for CL≤2.

### 10) Explore/exploit awareness (E/E policy)
Not all work needs the same level of generation. Adjust search breadth to context:

- **Explore widely** (many variants, SoTA survey, diverse hypotheses): architectural decisions, new domain entry, library/framework selection, design pattern choices, unfamiliar problem spaces.
- **Exploit quickly** (fewer variants, known patterns, direct fix): localized bugs with clear cause, trivial code changes, well-understood refactors, previously-solved problem patterns.
- **Default:** when uncertain, explore. Premature exploitation (jumping to the first solution) is more costly than spending one extra cycle generating alternatives.
- **Stepping-stone bets:** even when exploiting, preserve 1-2 non-dominant variants as stepping stones for future work.

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
- Select without a portfolio and an explicit selection policy
- Define acceptance criteria without a characterization passport
- Jump to a single solution without generating ≥3 variants
- Assign CL without a counter-example (CL≤2) or explain absence (CL=3)
- Use bridge cards with legacy CL labels (Exact/Equivalent/Approximate/Metaphor)

### ALWAYS
- State lifecycle stage (Explore/Shape/Evidence/Operate) before deep analysis
- Mark confidence + scope on technical claims
- Write artifacts to `.fpf/` DURING work, not retroactively after being caught
- Invoke skills proactively -- do not wait for the user to type `/fpf-*`
- Prefer persistent artifacts (`.fpf/` files) over ephemeral chat for anything referenceable
- Generate ≥3 variants before selecting (for substantive choices)
- Record stepping-stone bets when selecting between variants
- State selection policy before applying it
- Fill F-G-R in evidence records and decision records (G must be set-valued)
- Survey existing approaches (`/fpf-sota`) before generating variants for architectural decisions
