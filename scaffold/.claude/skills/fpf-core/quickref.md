# FPF quick reference (for day-to-day project work)

For full definitions: `reference/FPF-Spec.md`.

---

## The shift: engineer as principal

In a world of cheap solution generation (AI agents generate many variants instantly), the scarce resource is **problem design**. You are the principal — your job is to design problems, strategize approaches, manage portfolios, and verify claims. Both the problem factory and solution factory are **creative acts**.

---

## Three coupled factories (FPF primary architecture)

FPF runs three coupled infinite loops — not a linear pipeline:

**Factory 1 — Problem factory (creativity: designing problems):**
Observe → Characterize → Frame problem → Manage portfolio → **acceptance spec**

**Factory 2 — Solution factory (creativity: generating and selecting solutions):**
Acceptance spec → Survey SoTA → **Strategize** → Generate variants → Select → Implement → Verify → Record decision

**Factory 3 — Factory of factories (meta: organizational development):**
Observe cycle friction → Characterize process quality → Improve tools/skills/workflows → Measure lead time + quality + verification cost

The third factory develops the first two. When the workflow itself is the bottleneck — that's a Factory 3 problem.

Both creativity (designing problems, generating variants, surveying SoTA) and assurance
(evidence, audit trail, F-G-R) are first-class concerns. Neither is subordinated to the other.

Templates are **thinking tools** (conceptual forms) — filling them IS the reasoning, not documentation that happens after.

### Feedback loop
The factories are coupled. Evidence feeds back into problems:
- Refuted hypothesis → update PROB-*, recharacterize
- New capabilities from stepping stones → new ANOM-*
- Failed approach → reframe the problem
- Process friction → Factory 3 problem

> **Problematization is a creative discipline.** In a world of cheap solution generation,
> the one who designs the right problems wins. Don't just react to anomalies —
> proactively frame problems for new features, design decisions, and opportunities.

---

## The ADI loop (Canonical Reasoning Cycle)

### Abduction — *Propose*
- Frame the anomaly/problem in one sentence.
- Generate multiple hypotheses (don't prematurely converge).
- Mark the prime hypothesis as *provisional*.

### Deduction — *Analyze*
- Derive predictions and invariants.
- Define falsifiers (what evidence would prove you wrong?).
- Identify dependencies and second-order effects.

### Induction — *Test*
- Run tests / experiments / measurements that correspond to deduced predictions.
- Record the evidence and update confidence conservatively.

---

## Lifecycle states (state machine, B.5.1)

**Explore → Shape → Evidence → Operate**

| State | Core activity | ADI phase | Typical assurance | Transition trigger |
|-------|--------------|-----------|-------------------|--------------------|
| **Explore** | Generate options/hypotheses (wide search) | Abduction | L0 | Prime hypothesis selected → Shape |
| **Shape** | Formalize one direction (blueprint/architecture) | Deduction | L0→L1 | Falsifiable predictions defined → Evidence |
| **Evidence** | Validate/verify (tests, measurements) | Induction | L1→L2 | Claims tested, evidence recorded → Operate |
| **Operate** | Deploy + monitor + refresh evidence | Continuous | L2 (maintained) | Evidence decay or anomaly → back to Explore |

Transitions MUST be sequential (CC-B5.1.2). Skipping a state requires explicit justification.

---

## Characterization and NQD

### Characterization passport (CHR-\*)
Defines the characteristic space for comparing variants:
- Characteristics: all dimensions that could matter
- Indicators: 1–3 selected characteristics with thresholds (not just direction)
- Comparison rules: parity, normalization, dominance policy
- Acceptance criteria: what "good enough" means

### NQD characterization (for solution variants)
- **N (Novelty):** How different from existing/obvious approaches?
- **Q (Utility):** Multi-dimensional — one value per CHR indicator. NOT a single ordinal. **Never collapse to single score.**
- **D_c (Constraint fit):** Eligibility gate — Fail = eliminated before dominance
- **D_p (Diversity):** Portfolio-level coverage. Tie-breaker.

**Pipeline order:** Eligibility (D_c = Pass) → Dominance (Q per indicator, Pareto) → Tie-breakers (N, D_p).

> **Simplification scope:** This implementation covers the operational core of NQD-CAL (C.18) and E/E-LOG (C.19).
> See FPF-Spec.md §C.18, §C.19 for the full machinery.

---

## SoTA harvesting

**When:** Before variant generation for problems where existing approaches exist.

**Procedure (simplified from G.2):**
1. Discovery: survey ≥2 traditions via web search, docs, codebase analysis
2. Claim distillation: extract key claims with F-G-R tags
3. Bridge matrix: tradition×tradition with CL levels and loss notes
4. Gap analysis: what no tradition covers, fundamental disagreements
5. Feed to variants: implications for solution design
6. **Strategize:** identify method families, assess admissibility, state the bet

**Invoke:** `/fpf-sota` — produces `SOTA-*` and `STRAT-*`

---

## Strategizing (method family bet) — FIRST-CLASS CREATIVE ACT

**Strategizing ≠ SoTA survey.** They are two distinct acts (slide 20):
- **Problematization** = what problem to solve (problem factory)
- **Strategizing** = what class of method to bet on (solution factory entry point)

**When:** After SoTA survey, before variant generation. Can be invoked independently via `/fpf-sota` step 6 or by creating STRAT-\* directly.

**What it is:** Choosing *which class of approach* to bet on. "We'll explore variants within [family X] because [reason]." This is NOT picking a specific solution — it's scoping the search space.

**Artifact:** `STRAT-*` in `.fpf/decisions/`

**Why it matters:** Without it, variant generation is either unfocused (all possible approaches) or implicitly strategic (method family chosen but not documented). Explicit bet = auditable and reversible.

---

## Portfolio management

### Problem portfolio (PPORT-\*)
- Archive all known problems (open, deferred, resolved)
- State selection rule **before** applying it
- Check diversification: domain coverage, explore/exploit balance, stepping-stones
- Apply goldilocks filter: defer trivial and impossible problems

### Solution portfolio (SPORT-\*)
- Generate ≥3 genuinely distinct variants
- Characterize each with NQD (Q per CHR indicator, not single ordinal)
- Identify stepping stones (non-dominant variants that open new search spaces)

---

## Selection operations

### Selection record (SEL-\*)
- Dominance analysis: qualitative Pareto on indicator values (multi-dimensional Q)
- Selection policy: stated **before** applying
- Stepping-stone bets: 1–2 non-dominant variants worth preserving
- "What would change": conditions that would reverse the selection

---

## Strict distinctions (common traps)

### Plan vs reality
- A design doc is not a successful deployment.
- A TODO is not completed work.
- A "should" statement is not evidence.

### Object vs description vs carrier
- Repo/PDF/wiki: carriers
- Specs/docs/code: descriptions (epistemes)
- Running software / deployed infra: objects/systems

### Role / Capability / Method / MethodDescription / Work / WorkPlan
When someone says "process", resolve it explicitly.

---

## Evidence mindset

When you say "this is true", prefer one of:
- a deterministic check (type check, static analysis)
- a unit/integration test
- a reproducible benchmark
- a runtime trace/log with reproduction steps

**Feedback:** If evidence refutes → feed back to problem factory. Update PROB-* or create new ANOM-*.

---

## BLP (Bitter Lesson Preference)

At comparable budget and confidence, prefer the method with better scaling slopes (more data, more compute, more freedom → better results). General + scalable beats hand-tuned + narrow.

- **Scale-Audit:** before choosing a method, check how it improves with more resources
- **Elasticity Class:** growing / plateau / declining — look at slopes, not current values
- **When tied on Q:** prefer the method with better scaling trajectory

See FPF-Spec.md §D.10 for full BLP pattern.

---

## Parity (fair comparison)

Before comparing variants, ensure fair conditions:

- **Same time window** and data cutoff for all variants
- **Same budget** (compute, time, attempts)
- **Same measurement procedure** (version, protocol, seed-set)
- **Explicit normalization** — no hidden aggregation into single score
- **Minimum 2 repetitions** with recorded variance

Use the Parity Plan template (`.fpf/templates/parity-plan.md`) for structured comparisons.

---

## Anti-Goodhart discipline

Distinguish three roles for characteristics (slide 16):

| Role | What it is | Example |
|------|-----------|---------|
| **Observation indicator** | Monitored, not optimized | Latency p99, error rate |
| **Acceptance criterion** | Hard constraint (pass/fail) | Security compliance, backward compat |
| **Optimization target** | Actively moved this cycle (1-3 max) | Throughput, time-to-first-byte |

Observation indicators that AREN'T optimization targets serve as anti-Goodhart watchdogs. If optimizing target X degrades indicator Y — that's a signal to stop.

---

## Explore/exploit policy (simplified from E/E-LOG, C.19)

- **Explore widely:** architectural decisions, new domains, unfamiliar. Full pipeline.
- **Exploit quickly:** localized bugs, known patterns, clear fixes. Fewer variants.
- **Default when uncertain:** explore.
- **Stepping-stone discipline:** preserve 1-2 non-dominant variants even when exploiting.
- **Trivial session:** write `.fpf/.trivial-session` to bypass creative gates entirely.

---

## F-G-R assurance model

- **F (Formality):** informal | structured | formalizable | proof-grade. F_eff = min.
- **G (ClaimScope):** set-valued contexts, NOT ordinal. Enumerate specific conditions.
- **R (Reliability):** [0, 1] conservative. R_raw = min. Cross-context: R_eff = max(0, R_raw − Φ(CL_min)).

---

## CL scale (congruence levels, F.9)

| CL | Name | Meaning | Allowed use |
|----|------|---------|-------------|
| 0 | Opposed | Terms conflict | None |
| 1 | Comparable | Same domain, different framing | Naming-only |
| 2 | Translatable | Systematic mapping with known loss | Role assignment |
| 3 | Near-identity | Negligible loss in this context | Type-structure reuse |

Counter-example required for CL ≤ 2; explain absence for CL = 3.

---

## Evidence chains

```
Claim → Prediction → Test/method → Evidence record (EVID-*) → Result
```

Each link references a specific artifact ID.

---

## Where to write things

- `.fpf/anomalies/` — ANOM-\*, PROB-\*
- `.fpf/characterizations/` — CHR-\*, CHRC-\*, SOTA-\*
- `.fpf/decisions/` — DRR-\*, SEL-\*, STRAT-\*
- `.fpf/evidence/` — EVID-\*
- `.fpf/glossary/` — glossary + bridges
- `.fpf/portfolios/` — PPORT-\*, SPORT-\*
- `.fpf/worklog/` — session logs
