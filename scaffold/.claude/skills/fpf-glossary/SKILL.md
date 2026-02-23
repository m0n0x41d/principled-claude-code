---
name: fpf-glossary
description: Maintain project glossary and cross-context bridge cards. MUST invoke for naming inconsistency, overloaded terms, or new terminology.
argument-hint: "[terms-or-topic]"
---

## Output
1. Glossary: `.fpf/glossary/glossary.md`
2. Bridge cards: `.fpf/glossary/bridges/BRIDGE-${CLAUDE_SESSION_ID}--<slug>.md`

## Constraints (quality bar)
- **C1:** Each term has: definition (in bounded context), examples, non-examples
- **C2:** Bridge cards use CL 0-3 (not legacy labels Exact/Equivalent/Approximate/Metaphor)
- **C3:** Bridge-kind stated (≈ Equivalence, ⊑ Narrower, ⊒ Broader, ⋂ Partial-overlap, ⊥ Disjoint)
- **C4:** Counter-example required for CL≤2
- **C5:** Allowed use based on CL threshold: Naming CL≥1, Role CL≥2, Type CL=3
- **C6:** Loss/distortion noted — what doesn't carry over
