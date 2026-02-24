# Project instructions (FPF-enabled)

**This profile supersedes any global CLAUDE.md workflow instructions.** The execution model here is **coupled double-loop factories**, not a linear pipeline. If your global config says "Understand → Plan → Implement → Verify" — that's overridden by the factory cycles below.

This repository uses the **[First Principles Framework (FPF)](https://github.com/ailev/FPF)** for reasoning and project work.

**The shift:** In a world of cheap solution generation, the bottleneck is **problem design, not solution delivery**. You are the principal; AI agents are your workforce. You run three coupled factories:

1. **Problem factory** (creative: problematization) — designs problems with acceptance specs
2. **Solution factory** (creative: strategizing + variant generation) — generates, selects, and verifies solutions
3. **Factory of factories** (meta) — improves the first two; when the workflow itself is the bottleneck, that's a Factory 3 problem

Both creativity and assurance are first-class — neither is subordinated. Templates are thinking tools — filling them IS the reasoning, not post-hoc documentation.

---

## §1 — Assess task tier

| Tier | Signal | Examples |
|------|--------|----------|
| **T1 Trivial** | Single-file, obvious fix, no trade-offs | Typo, syntax fix, log line, config tweak |
| **T2 Localized** | Clear cause, limited blast radius | Bug with known root cause, simple refactor, add test |
| **T3 Substantive** | Trade-offs exist, multiple approaches possible | Feature, multi-file change, design decision, complex bug |
| **T4 Architectural** | Cross-cutting, irreversible, system-level | Tech choice, API design, migration, system redesign |

**Default when uncertain: T3.** Promote to T4 if cross-cutting or irreversible. Demote to T2 if single hypothesis works.

---

## §2 — T1 Protocol (trivial)

Direct action. No artifacts. No gates. Write `.fpf/.trivial-session` after Gate 0 to bypass creative checks.

---

## §3 — T2 Protocol (localized)

1. `/fpf-core` → `/fpf-worklog`
2. Frame: ANOM-\* (quick anomaly record — observations, 1-2 hypotheses, test plan)
3. Fix
4. Verify: EVID-\* (commands + outputs, corroborated/refuted)

---

## §4 — T3 Protocol (substantive)

**Problem factory:**
1. `/fpf-core` → `/fpf-worklog`
2. `/fpf-problem-framing` → PROB-\* (≥3 hypotheses, trade-off axes, goldilocks assessment, acceptance spec)
3. `/fpf-characterize` → CHR-\* (characteristic space, indicators, comparison rules)
4. If multiple problems: `/fpf-problem-portfolio` → PPORT-\*

**Solution factory:**
5. `/fpf-variants` → SPORT-\* (≥3 genuinely distinct variants, NQD per CHR indicators, stepping stones)
6. `/fpf-selection` → SEL-\* (Pareto analysis, policy stated before applying, stepping-stone bets)
7. Implement
8. `/fpf-evidence` → EVID-\* (predictions before testing, commands + outputs, F-G-R)
9. If irreversible: `/fpf-decision-record` → DRR-\*

**Feedback:** Evidence refutes → update PROB-\*. Stepping stones open possibilities → new ANOM-\*.

---

## §5 — T4 Protocol (architectural)

Everything in T3, plus:
1. `/fpf-sota` → SOTA-\* (≥2 traditions, bridge matrix with CL 0-3, gaps)
2. `/fpf-strategize` → STRAT-\* (method family bet, invalidation conditions, variant generation axes)

Insert after step 2 of T3 (problem framing) and before step 5 (variant generation).

---

## §6 — Constraints (all tiers)

**Creative constraints (T3+, enforced by hooks):**
- C1: PROB-\* MUST contain ≥3 hypotheses with trade-off axes
- C2: SPORT-\* MUST contain ≥3 genuinely distinct variants
- C3: Selection policy MUST be stated before applying
- C4: STRAT-\* MUST state invalidation conditions (T4)

**Assurance constraints (T2+, enforced by hooks):**
- C5: No source edits without PROB/ANOM-\* (Gate 1, blocked at ≥8 edits)
- C6: No "works"/"verified"/L2 claims without EVID-\* (Gate 2)
- C7: EVID-\* MUST contain commands + outputs + valid_until
- C8: Non-trivial/irreversible decisions require DRR-\* (Gate 3)

**Session discipline:**
- C9: `/fpf-core` + `/fpf-worklog` before any side-effect tools (Gate 0)
- C10: `/fpf-review` before ending non-trivial sessions (Gate 5)

**Cross-cutting:**
- `/fpf-glossary` for naming inconsistency or new terms (Gate 4)
- Separate Design-time (Plan & Model) from Run-time (Actions & Observations)

---

## §7 — Core principles

**ADI cycle:** Abduction (frame, hypothesize) → Deduction (predict, define falsifiers) → Induction (test, record evidence).

**Lifecycle:** Explore → Shape → Evidence → Operate. State current stage.

**Strict distinctions:** Plan ≠ reality. Object ≠ description ≠ carrier. Resolve "process" → Role | Capability | Method | Work | WorkPlan.

**F-G-R:** F (Formality, ordinal, min). G (ClaimScope, set-valued, NOT ordinal). R (Reliability, [0,1], min).

**CL 0-3:** 0=Opposed, 1=Comparable, 2=Translatable, 3=Near-identity. Counter-example required for CL≤2.

**NQD:** Never collapse to single score. Q references CHR indicators (multi-dimensional). N and D_p are tie-breakers. Hold the Pareto front. Applies to both solution AND problem portfolios.

**BLP:** At comparable budgets, prefer the method with better scaling slopes. General + scalable beats hand-tuned + narrow.

**Parity:** Fair comparison requires equal conditions. Use Parity Plan before comparing variants.

**Anti-Goodhart:** Distinguish observation indicators, acceptance criteria (hard constraints), and optimization targets (1-3 max). Monitoring what you don't optimize prevents reward hacking.

**E/E policy:** Explore for architectural/unfamiliar; exploit for known patterns. Default: explore. Always preserve 1-2 stepping stones.

---

## §8 — Artifacts & skills

| Directory | Artifacts |
|-----------|-----------|
| `.fpf/anomalies/` | ANOM-\*, PROB-\* |
| `.fpf/characterizations/` | CHR-\*, CHRC-\*, SOTA-\* |
| `.fpf/decisions/` | DRR-\*, SEL-\*, STRAT-\* |
| `.fpf/evidence/` | EVID-\* |
| `.fpf/glossary/` | glossary.md, BRIDGE-\* |
| `.fpf/portfolios/` | PPORT-\*, SPORT-\* |
| `.fpf/worklog/` | session logs |

Skills in `.claude/skills/`. Templates in `.fpf/templates/`.

FPF skills are modular (`fpf-*` prefix). Additional skill sets can coexist in `.claude/skills/` — avoid competing workflow orchestration, but domain-specific extensions are welcome.
