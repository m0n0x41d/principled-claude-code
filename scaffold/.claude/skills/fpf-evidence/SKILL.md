---
name: fpf-evidence
description: Test a claim against reality by running the evidence procedure. Produce EVID-* record with commands, outputs, and interpretation. MUST invoke before claiming "works" or "verified".
argument-hint: "[claim-or-short-title]"
---

## What this skill IS

This is **testing against reality**, not documentation. You are running an experiment — defining predictions, executing tests, interpreting results. The evidence record is the lab notebook, not a post-hoc report.

**Work through the template as the test procedure.** Define predictions BEFORE running tests. Record what actually happened. Interpret honestly.

## Feedback loop

If evidence **refutes** the prime hypothesis or reveals new constraints:
- Update the PROB-\* card (feed back to problem factory)
- Consider: does the problem need reframing?
- Create new ANOM-\* if evidence reveals unexpected behavior

If evidence **corroborates**:
- Note the scope limitations in G (ClaimScope)
- Set valid_until (REQUIRED — expiry date or "perpetual" with justification)

## Output
`.fpf/evidence/EVID-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Claim under test stated in one sentence
- **C2:** Predictions derived BEFORE testing — what should be true, what would falsify
- **C3:** Harness is the smallest credible check (test, typecheck, benchmark, log)
- **C4:** Commands and outputs recorded verbatim
- **C5:** Result labeled: corroborated | refuted | inconclusive
- **C6:** F-G-R filled: F (formality), G (ClaimScope — set-valued, enumerate specific contexts), R (reliability 0-1)
- **C7:** valid_until REQUIRED — set expiry date (YYYY-MM-DD) for time/version-dependent claims, or "perpetual" with justification for universal truths. Stop gate blocks if missing.
- **C8:** If refuted: MUST update PROB-\* or create new ANOM-\* (feedback to problem factory). Stop gate blocks session end if refuted evidence exists without problem reframing.

## Format
```markdown
# Evidence Record
- **ID:** EVID-...  **Claim:** ...  **Created:** YYYY-MM-DD
- **F:** informal|structured|formalizable  **G:** {contexts}  **R:** 0-1
- **DesignRunTag:** design-time|run-time

## Predictions (defined before testing)
- If true: ...
- Would falsify: ...

## Harness
- Type: (test|benchmark|log|typecheck|manual)
- Rationale: why this is the smallest credible check

## Commands + outputs
\`\`\`
(exact commands and raw output)
\`\`\`

## Interpretation
- Result: corroborated|refuted|inconclusive
- valid_until: ...
- Feedback to problem factory: (if refuted, what changes in PROB-*?)
```
