---
name: fpf-problem-portfolio
description: Manage the set of active problems with explicit selection rules and diversification checks.
argument-hint: "[portfolio-scope]"
---

## Output
`.fpf/portfolios/PPORT-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Selection rule stated BEFORE applying — not post-hoc
- **C2:** Archive complete — no hidden problems
- **C3:** ≥1 active problem has stepping-stone potential
- **C4:** Diversification check honest — flags imbalances
- **C5:** Each active problem references existing PROB/ANOM-*

## Format
```markdown
# Problem Portfolio
- **ID:** PPORT-...  **Scope:** ...

## Active problems (priority order)
| # | ID | Title | Impact | Feasibility | Stepping-stone? |

## Diversification check
- Problem types covered:
- Not covered (deferred):

## Selection rationale
(policy stated before applied)
```
