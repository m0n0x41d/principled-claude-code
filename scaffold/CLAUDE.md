# FPF-enabled project

Two coupled factories: **problem factory** (observe → frame → acceptance spec) and **solution factory** (SoTA → strategize → variants → select → implement → verify). Both creativity and assurance are first-class — neither is subordinated.

Templates are thinking tools — filling them IS the reasoning, not documentation after.

Skills: `/fpf-core` `/fpf-worklog` `/fpf-problem-framing` `/fpf-characterize` `/fpf-sota` `/fpf-variants` `/fpf-selection` `/fpf-evidence` `/fpf-decision-record` `/fpf-review` `/fpf-glossary` `/fpf-problem-portfolio`

Artifacts: `.fpf/` — `anomalies/` `characterizations/` `decisions/` `evidence/` `glossary/` `portfolios/` `worklog/`

---

## Step 1: Assess task tier

| Tier | Examples | Protocol |
|------|----------|----------|
| **T1** | Typo, syntax fix, quick answer, trivial config | Direct action. No artifacts. |
| **T2** | Bug with clear cause, simple refactor, localized fix | ANOM-* → fix → EVID-* |
| **T3** | Feature, multi-file change, design decision | Full pipeline (below) |
| **T4** | System design, tech choice, cross-cutting concern | T3 + SoTA survey + strategy |

**Escalation:** Start low, escalate when complexity emerges. When uncertain, prefer higher tier.
**Anti-collapse:** "Everything is trivial" is a system failure. If you're choosing T1 more than twice in a row for different tasks, reassess.

---

## Step 2: Follow tier protocol

### T1 — Just do it
No ceremony. Direct action. No gates except Gate 0.

### T2 — Localized
1. ANOM-* in `.fpf/anomalies/` — what happened, hypothesis, fix plan
2. Fix it
3. EVID-* in `.fpf/evidence/` — what you ran, what you saw

### T3 — Full pipeline

**Problem factory:**
1. `/fpf-problem-framing` → PROB-* with ≥3 hypotheses, trade-off axes, acceptance spec
2. `/fpf-characterize` if comparing options or defining acceptance criteria

**Solution factory:**
3. `/fpf-variants` → ≥3 genuinely distinct variants, NQD-characterized
4. `/fpf-selection` → select with explicit policy (stated before applying)
5. Implement
6. `/fpf-evidence` → verify claims against acceptance spec
7. `/fpf-decision-record` for non-trivial or irreversible decisions

### T4 — Architectural
All of T3, plus:
- `/fpf-sota` BEFORE variants → survey existing approaches, produce STRAT-* with method family bet
- Variants explore diversity WITHIN the chosen method family

---

## Constraints (quality bar)

| # | Constraint | Tier | Hook-checkable |
|---|-----------|------|----------------|
| C1 | Problem before solution: PROB/ANOM-* before source edits | T2+ | file existence |
| C2 | ≥3 hypotheses in problem cards | T3+ | grep `H[1-3]` |
| C3 | Trade-off axes stated | T3+ | grep `[Tt]rade-off` |
| C4 | ≥3 distinct variants before selection | T3+ | grep `V[1-3]` |
| C5 | ≥1 novel variant (not just incremental tweaks) | T3+ | grep `[Nn]ovel` |
| C6 | Evidence with commands + outputs for "it works" claims | T2+ | file + content |
| C7 | DRR-* for irreversible decisions | T3+ | file existence |
| C8 | Selection policy stated before applying | T3+ | grep `[Pp]olicy` |
| C9 | SoTA survey + STRAT-* before variant generation | T4 | file existence |
| C10 | Session worklog exists and updated | All | file existence |

---

## Session gates (mechanically enforced)

**Gate 0 (start):** `/fpf-core` → writes sentinel → `/fpf-worklog <goal>`. All tools blocked until sentinel exists. No exceptions.

**Gate 5 (end):** `/fpf-review` before stopping. Worklog updated.

---

## Principles (compact — details in `/fpf-core`)

- **ADI cycle:** Abduction (propose ≥3 hypotheses) → Deduction (derive predictions, define falsification) → Induction (test, record evidence).
- **Lifecycle:** Explore → Shape → Evidence → Operate. State current state. Don't skip.
- **Strict distinctions:** Plan ≠ reality. Object ≠ description ≠ carrier. Resolve "process" → Method | MethodDescription | Work | WorkPlan.
- **Evidence is first-class:** Claims need EVID-* with F-G-R. G is set-valued. F_eff = min(F_i). R_raw = min(R_i).
- **E/E policy:** Explore widely (T4). Exploit quickly (T2). Default: explore when uncertain.
- **Creativity is first-class:** Problematization is creative discipline — design the problem before solving it. Don't wait for breakage.
- **Bridges for cross-context:** CL 0-3. Counter-examples required for CL≤2.
