---
name: fpf-glossary
description: Maintain the project glossary and cross-context bridge cards. MUST be invoked when naming is inconsistent across repos/modules, when terms are overloaded (e.g., "process"), or when new terminology is introduced.
argument-hint: "[terms-or-topic]"
---

## Goal
Keep language coherent across code, docs, and multiple repositories.

FPF treats naming as a *modeling responsibility*: if terms drift, reasoning collapses.

## Outputs
1) Update (or create) the main glossary:

- `.fpf/glossary/glossary.md`

2) When mapping terms across contexts (repo A <-> repo B), create a bridge card:

- `.fpf/glossary/bridges/BRIDGE-${CLAUDE_SESSION_ID}--<slug>.md`

Use the template:

- `.fpf/templates/bridge-card.md`

## Procedure
1) **Detect naming problems**
Examples:
- Same word, different meaning across repos.
- Different words, same meaning.
- Overloaded words ("process", "service", "model", "spec").
- Inconsistent abbreviations or casing.

2) **Choose a canonical term**
- Prefer stable, descriptive names.
- Keep aliases for legacy names.

3) **Write definitions in context**
For each term include:
- definition (in this bounded context),
- examples (where it appears in code/docs),
- synonyms/aliases,
- non-examples (common confusions).

4) **Bridge across contexts**
If two repos have different vocabularies:
- state source + target contexts,
- map terms,
- assign CL level (0-3) per F.9: 0=Opposed, 1=Comparable, 2=Translatable, 3=Near-identity,
- state bridge-kind (≈ Equivalence, ⊑ Narrower, ⊒ Broader, ⋂ Partial-overlap, ⊥ Disjoint, ⇄ᴅʳ Design↔Run, →ᴍᴱᵃ Measure-of, →ᴅᵉᵒ Policy-implies),
- state allowed use based on CL threshold (Naming-only CL≥1, Role Assignment CL≥2, Type-structure CL=3),
- note loss/distortion (what does *not* carry over),
- provide counter-example (what case would break the mapping) for CL≤2,
- propose a migration naming plan if needed.

## Quality bar
- Definitions must be locally meaningful (bounded context).
- Bridges must be explicit; never assume equivalence without a mapping.
- Bridge cards must have CL (0-3), not informal labels (Exact/Equivalent/Approximate/Metaphor).
- Bridge cards must have bridge-kind and allowed-use fields.
- Update docs/code to reflect canonical naming when safe.
