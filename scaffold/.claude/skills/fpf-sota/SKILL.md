---
name: fpf-sota
description: Survey existing approaches (SoTA harvesting) before variant generation. MUST be invoked for architectural decisions, library selection, or design pattern choices where known approaches exist.
argument-hint: "[problem-or-domain]"
---

## Goal
Survey existing approaches and traditions before generating solution variants.
Prevents reinventing the wheel and ensures variant generation is informed by the state of the art.

Simplified from FPF G.2 — focuses on the operational core relevant to Claude Code work.

> **Simplification scope vs full G.2:** Scoped out: full PRISMA flow record (we use PRISMA-lite),
> edition pinning with DistanceDefRef, UTS draft generation, MethodFamily/GeneratorFamily cards,
> NQD annex with formal QD-score definitions, DHC hooks, SoS-indicator families.
> These are discipline-pack-grade mechanisms. For Claude Code agent work,
> the simplified survey with claim distillation and bridge matrix is sufficient.
> See FPF-Spec.md §G.2 for the full SoTA Harvester & Synthesis specification.

## Output
Create a new file:

- `.fpf/characterizations/SOTA-${CLAUDE_SESSION_ID}--<slug>.md`

Use template:

- `.fpf/templates/sota-palette.md`

If the user passed arguments, use them to derive `<slug>` and the title.
If not, derive a short slug from the current context.

## When to invoke
- Before variant generation for problems where existing approaches exist
- Architectural decisions (framework choices, system design patterns)
- Library/tool selection (multiple established options)
- Design pattern choices (known alternatives in the literature or ecosystem)
- Any problem where "how others solve this" is relevant

## Procedure

1) **Discovery** (PRISMA-lite: identify → screen → include)
- Survey existing approaches via web search, codebase analysis, documentation.
- Identify ≥2 distinct traditions/approaches.
- Record search terms, sources consulted, scope of search.
- Note what was NOT searched and why (bounding the survey).
- Track: sources identified → sources screened → sources included (simplified PRISMA flow).

2) **Claim distillation**
- For each tradition/approach, extract key claims.
- Tag each claim with F-G-R:
  - **F (Formality):** informal | structured | formalizable | proof-grade
  - **G (ClaimScope):** set of contexts/conditions where the claim holds (set-valued, per USM A.2.6)
  - **R (Reliability):** 0–1 estimate, conservative

3) **Bridge matrix**
- Build tradition×tradition alignment map.
- Assign CL level (0-3) per F.9: 0=Opposed, 1=Comparable, 2=Translatable, 3=Near-identity.
- Note loss/distortion at each crossing.
- Identify where traditions agree (shared ground) vs. disagree (genuine alternatives).

4) **Gap identification**
- What does no tradition cover?
- Where do traditions disagree fundamentally (CL 0-1)?
- What questions remain unresolved?
- What would need empirical evidence to resolve?

5) **Feed to variant generation**
- Summarize what this survey implies for solution design.
- Identify which traditions map to distinct solution variants.
- Note which gaps might be addressed by novel variants.
- Output feeds directly into `/fpf-variants` as input.

## Quality bar
- ≥2 traditions/approaches surveyed (more for well-studied domains).
- Bridge matrix has CL levels (0-3), not informal labels.
- Gaps identified — what no tradition covers.
- Claims have F-G-R tags.
- Search scope is bounded — stated what was and wasn't searched.
- Output is actionable — clear implications for variant generation.
