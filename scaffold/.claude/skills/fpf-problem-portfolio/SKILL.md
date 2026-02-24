---
name: fpf-problem-portfolio
description: Manage problems as a portfolio with explicit selection rules, goldilocks assessment, and diversification. Think through what to solve next, not just what's urgent.
argument-hint: "[portfolio-scope]"
---

## What this skill IS

This is **strategic problem selection**, not issue triage. You are managing a portfolio of problems — deciding which problems to invest effort in, balancing exploration vs exploitation, maintaining diversity, and preserving stepping stones.

**Key questions while filling the template:**
- Which problems are in the zone of proximal development (goldilocks)?
- Am I over-investing in one type of problem (exploit bias)?
- Which problems, even if not urgent, could open new solution spaces (stepping stones)?
- What problem types are NOT in the portfolio but should be?

## Output
`.fpf/portfolios/PPORT-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Selection rule stated BEFORE applying — not post-hoc rationalized
- **C2:** Archive complete — no hidden problems
- **C3:** ≥1 active problem has stepping-stone potential (not all exploit)
- **C4:** Diversification check honest — flags imbalances (problem type, domain, risk level)
- **C5:** Each active problem references existing PROB/ANOM-*
- **C6:** Goldilocks filter applied — trivial and impossible problems identified and deferred

## Selection policy examples
- **Impact × Feasibility:** highest expected value first (exploit-heavy)
- **Learning value:** problems that teach the most about the domain (explore-heavy)
- **Barbell:** 80% safe + 20% speculative stepping stones
- **Constraint-driven:** solve blocking problems first, then expand

## Format
```markdown
# Problem Portfolio
- **ID:** PPORT-...  **Scope:** ...  **E/E policy:** explore|exploit|barbell

## Selection rule
(policy stated before applied, chosen from above or custom)

## Active problems (NQD-characterized)
| # | ID | Title | D_c | Q:[impact] | Q:[feasibility] | Q:[stepping-stone] | N | D_p |
Pipeline: D_c (goldilocks filter) → Q dominance (Pareto) → N, D_p (tie-breakers). Never collapse Q to single score.

## Deferred
| # | ID | Title | Why deferred | Revisit condition |

## Diversification check
- Problem types covered: ...
- Not covered: ... (flag if imbalanced)
- Explore/exploit balance: ...
```
