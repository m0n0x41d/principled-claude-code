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
- note loss/distortion (what does *not* carry over),
- propose a migration naming plan if needed.

## Quality bar
- Definitions must be locally meaningful (bounded context).
- Bridges must be explicit; never assume equivalence without a mapping.
- Update docs/code to reflect canonical naming when safe.
