# FPF quick reference (for day-to-day project work)

This is a **pragmatic** quickref. For deeper definitions and the full pattern language,
see `reference/FPF-Spec.md`.

---

## Two coupled factories (primary framing)

FPF runs two coupled infinite loops — not a linear pipeline:

**Problem factory (creativity: designing problems):**
Observe → Characterize → Frame problem → Manage portfolio → **acceptance spec**

**Solution factory (creativity: generating and selecting solutions):**
Acceptance spec → Survey SoTA → **Strategize** → Generate variants → Select → Implement → Verify → Record decision

Both creativity (designing problems, generating variants, surveying SoTA) and assurance
(evidence, audit trail, F-G-R) are first-class concerns. Neither is subordinated to the other.

Templates are **thinking tools** (conceptual forms) — filling them IS the reasoning,
not documentation that happens after reasoning. "Thinking by writing."

The problem factory outputs an acceptance spec. The solution factory consumes it.
Neither loop is optional — skipping the problem factory means solving undefined problems;
skipping the solution factory means accepting the first idea without comparison.

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
Every artifact MUST be tagged with its current state (CC-B5.1.1).

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
- **Q (Utility):** How well does it address acceptance spec indicators?
- **D_c (Constraint fit):** Does it satisfy hard constraints? (eligibility gate — Fail = eliminated before dominance)
- **D_p (Diversity):** How much does it diversify the portfolio?

**Pipeline order:** Eligibility (D_c = Pass) → Dominance (Q components) → Tie-breakers (N, D_p).

> **Simplification scope:** This implementation covers the operational core of NQD-CAL (C.18) and E/E-LOG (C.19).
> Scoped out for Claude Code: Surprise characteristic, Illumination gauge, ε-dominance,
> EmitterPolicy/InsertionPolicy formal references, archive/cell structure, DescriptorMap versioning,
> DedupThreshold, scale-probe machinery (SLL C.18.1), formal BLP (C.19.1).
> These are research-grade mechanisms — for Claude Code agent work, the simplified NQD table
> with explicit selection policy and stepping-stone identification is sufficient.
> See FPF-Spec.md §C.18, §C.19 for the full machinery.

---

## Portfolio management

### Problem portfolio (PPORT-\*)
- Archive all known problems (open, deferred, resolved)
- State selection rule **before** applying it
- Check diversification: domain coverage, explore/exploit balance, stepping-stones

### Solution portfolio (SPORT-\*)
- Generate ≥3 genuinely distinct variants
- Characterize each with NQD
- Identify stepping stones (promising non-dominant variants)

---

## Selection operations

### Selection record (SEL-\*)
- Dominance analysis: qualitative Pareto on indicator values
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
- Role: "actor mask in context"
- Capability: "can do"
- Method: "how (abstract)"
- MethodDescription: "the recipe"
- WorkPlan: "when/by whom we intend to run"
- Work: "what happened this time"

When someone says "process", resolve it explicitly.

---

## Evidence mindset

When you say "this is true", prefer one of:
- a deterministic check (type check, static analysis)
- a unit/integration test
- a reproducible benchmark
- a runtime trace/log with reproduction steps

Capture:
- exact command(s)
- environment (OS, versions)
- commit hash / revision
- result summary
- validity window (`valid_until`) if it can go stale

---

## Conservative confidence (weakest link)

Avoid optimistic roll-ups.
If a claim depends on multiple sub-claims, the overall reliability is bounded by the weakest piece.

---

## Where to write things

- `.fpf/anomalies/` — anomaly records (ANOM-\*) + problem cards (PROB-\*)
- `.fpf/characterizations/` — characterization passports (CHR-\*) + characteristic cards (CHRC-\*)
- `.fpf/decisions/` — decision rationale records (DRR-\*) + selection records (SEL-\*)
- `.fpf/evidence/` — evidence records (EVID-\*)
- `.fpf/glossary/` — glossary + bridges
- `.fpf/portfolios/` — problem portfolios (PPORT-\*) + solution portfolios (SPORT-\*)
- `.fpf/worklog/` — session logs

Templates live in `.fpf/templates/`.

---

## F-G-R assurance model

Every evidence record and decision record must carry F-G-R:

- **F (Formality):** informal | structured | formalizable | proof-grade
  - Ordinal scale. F_eff = min_i F_i (weakest link caps the whole chain).
  - Simplified from F0-F9 (C.2.3). For formal methods work, use the full scale from FPF-Spec.md.
- **G (ClaimScope):** set of contexts/conditions where the claim holds
  - Set-valued (USM A.2.6). NOT an ordinal level — enumerate specific contexts.
  - Example: `G = {Node.js ≥18, Linux/macOS, single-process deployment}`
- **R (Reliability):** [0, 1] estimate, conservative
  - R_raw = min_i R_i (weakest link). If cross-context: R_eff = max(0, R_raw − Φ(CL_min)).

---

## USM (Unified Scope Mechanism)

- **ClaimScope(G):** where a claim holds — set of contexts, not a level. Every evidence record and decision record must specify G.
- **WorkScope:** where a capability applies — similarly set-valued.
- **Serial composition:** when chaining claims across contexts, the effective scope is the intersection of individual scopes.
- **Cross-context penalty:** if evidence crosses bounded contexts with CL < 3, apply R penalty via Φ(CL_min).

---

## CL scale (congruence levels, F.9)

| CL | Name | Meaning | Allowed use |
|----|------|---------|-------------|
| 0 | Opposed | Terms conflict; using one in place of the other is wrong | None |
| 1 | Comparable | Same domain, different framing | Naming-only |
| 2 | Translatable | Systematic mapping with known loss | Role assignment |
| 3 | Near-identity | Negligible loss in this context | Type-structure reuse |

- CL penalties affect R only (not F or G).
- Counter-example required for CL ≤ 2; explain absence for CL = 3.
- Bridge cards must use this scale, not legacy labels (Exact/Equivalent/Approximate/Metaphor).

---

## Explore/exploit policy (simplified from E/E-LOG, C.19)

Not all work needs the same search breadth. Adjust by context:

- **Explore widely:** architectural decisions, new domains, library selection, unfamiliar problem spaces. Use `/fpf-sota`, generate ≥3 diverse variants, full Pareto analysis.
- **Exploit quickly:** localized bugs, trivial code changes, well-understood refactors, previously-solved patterns. Fewer variants, known patterns, direct fix.
- **Default when uncertain:** explore. Premature exploitation is more costly than one extra generation cycle.
- **Stepping-stone discipline:** even when exploiting, preserve 1-2 non-dominant variants for future work.

> **Simplification scope:** Full C.19 includes EmitterPolicy profiles (UCB, Thompson, BO-EI),
> formal explore_share/temperature/wild_bet_quota parameters, rebalance periods,
> named lenses (Barbell, Spike-first, Safety-first, Platform-option, Heterogeneity-first).
> For Claude Code agent work, the explore/exploit heuristic above is sufficient.

---

## SoTA harvesting

**When:** Before variant generation for problems where existing approaches exist (architecture, libraries, design patterns).

**Procedure (simplified from G.2):**
1. Discovery: survey ≥2 traditions via web search, docs, codebase analysis
2. Claim distillation: extract key claims with F-G-R tags
3. Bridge matrix: tradition×tradition with CL levels and loss notes
4. Gap analysis: what no tradition covers, fundamental disagreements
5. Feed to variants: implications for solution design
6. **Strategize:** identify method families, assess admissibility, state the bet

**Invoke:** `/fpf-sota` — produces `SOTA-*` in `.fpf/characterizations/` and `STRAT-*` in `.fpf/decisions/`

---

## Strategizing (method family bet)

**When:** After SoTA survey, before variant generation. Distinct from variant selection.

**What it is:** Choosing *which class of approach* to bet on. "We'll explore variants within [family X] because [reason]." This is NOT picking a specific solution — it's scoping the search space for variant generation.

**Artifact:** `STRAT-*` in `.fpf/decisions/` — captures candidate families, admissibility, the bet, and invalidation conditions.

**Why it matters:** Without it, variant generation is either unfocused (exploring all possible approaches at once) or implicitly strategic (method family chosen but not documented). Making the bet explicit makes it auditable and reversible.

---

## Evidence chains

Structured claim→evidence links (required in decision records, recommended in problem cards):

```
Claim → Prediction → Test/method → Evidence record (EVID-*) → Result
```

Each link references a specific artifact ID. The chain makes the reasoning auditable:
who claimed what, what prediction was derived, how it was tested, what was observed.
