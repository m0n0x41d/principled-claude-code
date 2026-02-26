# Project glossary

This file defines **canonical terms** for this repo/workspace.
If multiple repos exist in this workspace, treat each repo/module as a bounded context and
use Bridge Cards (`.fpf/glossary/bridges/`) to map between vocabularies.

---

## Term template

### <CanonicalTerm>
- **Aliases:** …
- **Bounded context:** …
- **Definition:** …
- **Examples (where used):**
  - `path/to/file.ext:line` — …
- **Non-examples / common confusions:** …
- **Related terms:** …

---

## Terms

### Bounded context
- **Aliases:** domain, context
- **Bounded context:** Meta
- **Definition:** A semantic scope in which terms have stable meaning and consistent acceptance criteria.

### Plan vs reality
- **Aliases:** design-time vs run-time
- **Bounded context:** Meta
- **Definition:** A discipline to keep the plan/spec separate from actual execution/observations. Plans are design-time artifacts; observations are run-time facts. Never mutate plans during execution — feed observations back via DRR or PROB updates.

### Role / Method / Work
- **Aliases:** process (overloaded, avoid)
- **Bounded context:** Meta
- **Definition:** A strict separation between who acts (Role), how it's done (Method/MethodDescription), and what happened this time (Work). "Process" is ambiguous — always resolve to one of these.

### ADI cycle
- **Aliases:** Abduction-Deduction-Induction
- **Bounded context:** Reasoning
- **Definition:** The canonical reasoning cycle. Abduction: frame problem, generate hypotheses. Deduction: derive predictions, define falsifiers. Induction: test against reality, record evidence. Maps to PROB→STRAT→EVID artifact flow.
- **Related terms:** Lifecycle states, F-G-R

### Lifecycle states
- **Aliases:** Explore → Shape → Evidence → Operate
- **Bounded context:** Reasoning
- **Definition:** Four sequential phases of work. Explore: survey problem/solution space. Shape: frame problem and design approach. Evidence: test claims. Operate: deploy and maintain. State current phase in problem cards.
- **Related terms:** ADI cycle

### NQD
- **Aliases:** Novelty-Quality-Diversity
- **Bounded context:** Portfolio management
- **Definition:** Multi-dimensional characterization for portfolios. N (Novelty): distance from known archive. Q (Quality): multi-dimensional score referencing CHR indicators — never collapse to single number, hold the Pareto front. D (Diversity): portfolio coverage across trade-off space. Applies to both problem portfolios (PPORT) and solution portfolios (SPORT). N and D are tie-breakers when Q is Pareto-equivalent.
- **Non-examples:** A single "score" or "ranking" is NOT NQD.
- **Related terms:** CHR, Pareto front, Anti-Goodhart

### WLNK
- **Aliases:** Weakest Link principle
- **Bounded context:** System reliability
- **Definition:** System reliability = min(component reliabilities). The weakest component bounds overall quality. When evaluating a solution, identify the weakest link — that's the system's actual reliability ceiling.
- **Related terms:** MONO

### MONO
- **Aliases:** Monoeliminability, composition justification
- **Bounded context:** System reliability
- **Definition:** When adding components or abstractions, the benefit must justify the new weak links introduced. Prefer simpler solutions unless added complexity demonstrably improves the system above its current weakest link. Every new dependency, layer, or abstraction is a potential new WLNK.
- **Related terms:** WLNK

### F-G-R
- **Aliases:** Formality-ClaimScope-Reliability tuple
- **Bounded context:** Assurance
- **Definition:** Trust calculus for claims. F (Formality): ordinal scale, aggregated via min — how rigorous is the evidence chain? G (ClaimScope): set-valued (NOT ordinal) — in what contexts does this claim apply? R (Reliability): [0,1], aggregated via min — how likely is the claim to hold? Every EVID-* and DRR-* must declare F-G-R.
- **Non-examples:** G is not "scope = high/medium/low" — it's a set of contexts.
- **Related terms:** CL 0-3, EVID-*

### CL 0-3
- **Aliases:** Congruence Level, compatibility level
- **Bounded context:** Cross-context translation
- **Definition:** Four-level ladder for mapping concepts across contexts. CL=0 (Opposed): terms intentionally contrastive, no reuse. CL=1 (Comparable): shared label but different meaning, naming-only reuse. CL=2 (Translatable): bounded loss, role assignment allowed. CL=3 (Near-identity): invariants match, full type-structure reuse. Counter-example REQUIRED for CL ≤ 2.
- **Related terms:** Bridge cards, F-G-R

### BLP
- **Aliases:** Bitter Lesson Preference
- **Bounded context:** Strategy
- **Definition:** At comparable budgets, prefer the method with better scaling slopes. General + scalable beats hand-tuned + narrow. Exception requires: (a) declared deontic constraint, or (b) scale-probe showing the heuristic dominates in the relevant scale window.
- **Related terms:** SLL, E/E policy

### Anti-Goodhart
- **Aliases:** Goodhart's Law antidote
- **Bounded context:** Measurement
- **Definition:** Distinguish three indicator categories: (1) Observation indicators — what we measure to understand. (2) Acceptance criteria — hard constraints, non-negotiable. (3) Optimization targets — 1-3 max, what we actively tune. Monitor what you don't optimize to prevent reward hacking. When a measure becomes a target, it ceases to be a good measure.
- **Related terms:** CHR, NQD

### E/E policy
- **Aliases:** Explore/Exploit governor
- **Bounded context:** Strategy
- **Definition:** Explore for architectural/unfamiliar problems (maximize diversity). Exploit for known patterns (refine within niche). Default: explore when uncertain. Always preserve 1-2 stepping stones from the explore phase — non-dominant variants with option value for future directions.
- **Related terms:** Stepping stones, NQD

### Stepping stones
- **Aliases:** option-value variants
- **Bounded context:** Portfolio management
- **Definition:** Non-dominant variants preserved because they open new search spaces or future possibilities, even if not the best choice today. At least 1 stepping stone must be preserved in every SEL-* record (C4 in fpf-selection). Conditions for reconsideration should be stated.
- **Related terms:** E/E policy, Pareto front

### Pareto front
- **Aliases:** Pareto-dominant set, non-dominated set
- **Bounded context:** Selection
- **Definition:** The set of variants where no other variant is strictly better on all dimensions. NQD scoring produces a Pareto front, not a single winner. Selection policy (stated BEFORE applying) picks from the front.
- **Non-examples:** A "best" solution is NOT a Pareto front analysis.
- **Related terms:** NQD, SEL-*

### CHR
- **Aliases:** Characteristic space, CSLC stack
- **Bounded context:** Measurement
- **Definition:** Observable/measurable properties of a domain organized as: Characteristic (the trait), Scale (ordinal/interval/ratio), Level (position on scale), Coordinate (how characteristics compose). All metrics must declare their scale type — ordinal averages are forbidden.
- **Related terms:** NQD, Anti-Goodhart

### Task tier
- **Aliases:** T1/T2/T3/T4
- **Bounded context:** Workflow
- **Definition:** T1 (Trivial): single-file, obvious fix, no trade-offs. T2 (Localized): clear cause, limited blast radius. T3 (Substantive): trade-offs exist, multiple approaches possible. T4 (Architectural): cross-cutting, irreversible, system-level. Default when uncertain: T3. Tier determines which gates, artifacts, and skills apply.
- **Related terms:** Lifecycle states

### ConstraintFit
- **Aliases:** eligibility filter
- **Bounded context:** Selection
- **Definition:** Non-negotiable constraints (safety, legal, ethical) that must be satisfied before NQD scoring. Variants failing ConstraintFit are marked ineligible — no amount of novelty or quality can override. Check BEFORE applying selection policy.
- **Related terms:** Anti-Goodhart, Pareto front

### Three factories
- **Aliases:** coupled double-loop factories
- **Bounded context:** Workflow architecture
- **Definition:** (1) Problem factory — creative problematization: designs problems with acceptance specs. (2) Solution factory — creative strategizing + variant generation: generates, selects, verifies solutions. (3) Factory of factories (meta) — improves the first two. Both creativity and assurance are first-class. When the workflow itself is the bottleneck, that's a Factory 3 problem (tracked via PROC-*).
- **Related terms:** ADI cycle, Task tier

