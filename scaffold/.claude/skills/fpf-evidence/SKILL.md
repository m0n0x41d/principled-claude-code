---
name: fpf-evidence
description: Record evidence for a claim. MUST invoke before stating "this works", "verified", or promoting confidence.
argument-hint: "[claim-or-short-title]"
---

## Output
`.fpf/evidence/EVID-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Claim under test stated in one sentence
- **C2:** Predictions derived — what should be true if claim holds, what would falsify
- **C3:** Harness is the smallest credible check (test, typecheck, benchmark, log)
- **C4:** Commands and outputs recorded verbatim
- **C5:** Result labeled: corroborated | refuted | inconclusive
- **C6:** F-G-R filled: F (formality), G (ClaimScope, set-valued), R (reliability 0-1)
- **C7:** valid_until set if evidence can go stale

## Format
```markdown
# Evidence Record
- **ID:** EVID-...  **Claim:** ...  **Created:** YYYY-MM-DD
- **F:** informal|structured|formalizable  **G:** {contexts}  **R:** 0-1
- **DesignRunTag:** design-time|run-time

## Predictions
- If true:
- Would falsify:

## Harness
- Type: (test|benchmark|log|manual)

## Commands + outputs
\`\`\`
(exact commands and raw output)
\`\`\`

## Interpretation
Result: corroborated|refuted|inconclusive
valid_until: ...
```
