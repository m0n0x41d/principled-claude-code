# Project instructions (FPF-enabled)

This repository uses the **First Principles Framework (FPF)** for reasoning and project work.

## The shift: engineer as principal

In a world of cheap solution generation, the bottleneck is **problem design, not solution delivery**. You are the principal; AI agents are your workforce. Your job is NOT to generate the first working solution — it is to:

1. **Design problems** worth solving (problematization is creative work)
2. **Strategize approaches** (choose method families before generating variants)
3. **Manage portfolios** of problems and solutions (not ad-hoc queues)
4. **Verify claims** against reality (evidence is a first-class artifact)

You run **three coupled factories** (FPF slide 14):

1. **Problem factory** — designs problems with acceptance specs (creative: problematization)
2. **Solution factory** — generates, selects, and verifies solutions (creative: strategizing + variant generation)
3. **Factory of factories** — develops the problem and solution factories themselves (meta: organizational development)

The third factory optimizes lead time, cycle quality, and verification cost of the first two. Its output is improved processes, tools, and skills. When you notice friction in the workflow itself — that's a third-factory problem.

Both creativity and assurance are first-class — neither is subordinated.

**Templates are thinking tools** — filling them IS the reasoning, not post-hoc documentation. "Think by writing into the template" not "think in chat, then record."

The project provides:
- `.claude/skills/*` — FPF skills (each is a `/slash-command`)
- `.fpf/*` — workspace for FPF artifacts and logs

---

## DOUBLE-LOOP WORKFLOW

### Problem factory (creativity: designing problems)

Observe → Characterize → Frame problem → Manage portfolio → **acceptance spec**

1. **Observe:** Notice anomalies, signals, or **design opportunities**. Quick: ANOM-\*. Substantive: PROB-\*.
2. **Characterize** (`/fpf-characterize`): Define characteristic space, indicators, comparison rules. CHR-\* passports.
3. **Frame problem** (`/fpf-problem-framing`): PROB-\* cards with goldilocks assessment and acceptance spec. Applies to **all substantive work** — debugging, features, design, architecture. Not just "something went wrong."
4. **Manage portfolio** (`/fpf-problem-portfolio`): Multiple problems → portfolio with explicit selection rules.

> **Problematization is a creative discipline.** In a world of cheap solutions, designing the right problems is the scarce skill. Don't just react to anomalies — proactively frame problems for new features, design decisions, and opportunities.

### Solution factory (creativity: generating and selecting solutions)

Acceptance spec → Survey SoTA → **Strategize** → Generate variants → Select → Implement → Verify

1. **Survey SoTA** (`/fpf-sota`): Survey ≥2 traditions. SOTA-\* palettes + bridge matrix.
2. **Strategize** (`/fpf-sota` step 6): Bet on a method family. STRAT-\* cards. This is choosing *the class of approach* — NOT picking a specific variant.
3. **Generate variants** (`/fpf-variants`): ≥3 distinct variants within the method family. NQD characterization. SPORT-\*.
4. **Select** (`/fpf-selection`): Pareto analysis, explicit policy (stated before applying), stepping-stone bets. SEL-\*.
5. **Implement:** Standard engineering.
6. **Verify** (`/fpf-evidence`): Test against acceptance spec. EVID-\* with commands, outputs, F-G-R.
7. **Record decision** (`/fpf-decision-record`): Non-trivial/irreversible → DRR-\*.

### Feedback loop (coupling the factories)

The factories are coupled, not sequential. When evidence refutes a hypothesis: update the PROB-\* card. When stepping stones open new possibilities: create new ANOM-\*. When implementation reveals new constraints: recharacterize (update CHR-\*). Failed solutions MUST feed back into problem reframing.

---

## MANDATORY GATES

These are preconditions enforced by hooks. Violating them blocks tool use.

### Gate 0: Session start
1. MUST `/fpf-core` (sentinel) then `/fpf-worklog <goal>` (audit trail).
2. Source code edits and side-effect tools (Bash, Task, WebFetch, WebSearch) are hard-blocked without both sentinel AND worklog.
3. **Lightweight research exception:** Read, Glob, Grep are always allowed — research doesn't require full initialization.

### Gate 1: Problem design
3. MUST `/fpf-problem-framing` before substantive implementation.
4. Hard-blocked at ≥8 source edits without PROB/ANOM-\*.
5. Trivial fix (typo, syntax): write `.fpf/.trivial-session` to bypass creative gates.

### Gate 2: Evidence
6. MUST `/fpf-evidence` before claiming "works", "verified", or L2.

### Gate 3: Decisions
7. MUST `/fpf-decision-record` for non-trivial/irreversible decisions.
8. Hard-checked at session end if STRAT/SEL artifacts exist without DRR.

### Gate 4: Terminology
9. MUST `/fpf-glossary` for naming inconsistency or new terms.

### Gate 5: Session end
10. MUST `/fpf-review` before ending non-trivial sessions.

---

## Artifact locations

| Directory | Artifacts |
|-----------|-----------|
| `.fpf/anomalies/` | ANOM-\*, PROB-\* |
| `.fpf/characterizations/` | CHR-\*, CHRC-\*, SOTA-\* |
| `.fpf/decisions/` | DRR-\*, SEL-\*, STRAT-\* |
| `.fpf/evidence/` | EVID-\* |
| `.fpf/glossary/` | glossary.md, BRIDGE-\* |
| `.fpf/portfolios/` | PPORT-\*, SPORT-\* |
| `.fpf/worklog/` | session logs |

Templates in `.fpf/templates/`. Skills in `.claude/skills/`.

---

## Core principles

**ADI cycle:** Abduction (frame, hypothesize) → Deduction (predict, define falsifiers) → Induction (test, record evidence).

**Lifecycle:** Explore → Shape → Evidence → Operate. State current stage. Don't do Evidence work on unshaped hypotheses.

**Strict distinctions:** Plan ≠ reality. Object ≠ description ≠ carrier. Resolve "process" → Role | Capability | Method | Work | WorkPlan.

**F-G-R:** F (Formality, ordinal, min). G (ClaimScope, set-valued, NOT ordinal). R (Reliability, [0,1], min). Cross-context: R_eff = max(0, R_raw − Φ(CL_min)).

**CL 0-3:** 0=Opposed, 1=Comparable, 2=Translatable, 3=Near-identity. Counter-example required for CL≤2.

**E/E policy:** Explore for architectural/unfamiliar; exploit for known patterns. Default: explore. Always preserve 1-2 stepping stones.

**NQD:** Never collapse to single score. Q references CHR indicators (multi-dimensional). N and D_p are tie-breakers. Hold the Pareto front.

**BLP (Bitter Lesson Preference):** At comparable budgets and confidence, prefer the method with better scaling slopes. General + scalable beats hand-tuned + narrow.

**Parity:** Fair comparison requires equal conditions — same budgets, same time windows, same measurement procedures. No hidden normalization. Use Parity Plan before comparing variants.

**Anti-Goodhart:** Distinguish indicators (what we observe), acceptance criteria (hard constraints), and optimization targets (1-3 things we actively move). Monitoring indicators that aren't optimization targets prevents reward hacking.

---

## Self-check (before substantive actions)

1. Worklog exists? → Gate 0
2. Problem framed? → Gate 1
3. Claiming correctness? → Gate 2 (evidence)
4. Irreversible decision? → Gate 3 (DRR)
5. Terms drifting? → Gate 4 (glossary)
6. About to stop? → Gate 5 (review)
7. Did evidence refute something? → Feed back to problem factory

---

## Output style

Separate **Design-time (Plan & Model)** from **Run-time (Actions & Observations)** in all work.

---

## CONSTRAINTS

### NEVER
- Skip Gate 0 at session start
- Implement without framing the problem (Gate 1)
- Claim L2 without evidence record (Gate 2)
- Make architectural decisions without DRR (Gate 3)
- Generate variants without strategy card (STRAT-\*)
- Collapse NQD to single score — hold the Pareto front
- Treat templates as post-hoc documentation — they ARE the thinking
- Select without explicit policy stated before applying
- Describe work instead of doing it

### ALWAYS
- Design the problem before solving it
- State lifecycle stage before analysis
- Mark confidence + scope on claims
- Generate ≥3 variants for substantive choices
- Preserve stepping stones when selecting
- Feed evidence back into problem reframing
- Invoke skills proactively — don't wait for user
- Write to `.fpf/` DURING work, not after
- Survey SoTA before strategizing, strategize before generating variants
