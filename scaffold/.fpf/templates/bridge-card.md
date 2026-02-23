# Bridge Card (cross-context alignment)

A bridge makes "sameness" explicit between two bounded contexts.
Never assume equivalence without a bridge.

- **Bridge ID:** BRIDGE-…
- **Source context:** …
- **Target context:** …
- **Bridge-kind:** ≈ Equivalence | ⊑ Narrower | ⊒ Broader | ⋂ Partial-overlap | ⊥ Disjoint
- **Direction:** A→B | A↔B
- **Congruence level (CL):** 0 | 1 | 2 | 3
  - 0 = Opposed (terms conflict; using one in place of the other is wrong)
  - 1 = Comparable (same domain, different framing; naming-only use allowed)
  - 2 = Translatable (systematic mapping with known loss; role assignment allowed)
  - 3 = Near-identity (negligible loss in this context; type-structure reuse allowed)
- **Allowed use:** Naming-only (CL≥1) | Role Assignment (CL≥2) | Type-structure (CL=3)
- **Counter-example:** (required for CL≤2: what case breaks this mapping? For CL=3: explain why no counter-example exists)
- **Loss notes:** what does not carry over?
- **Status:** Proposed | Accepted | Deprecated

---

## Term mappings

| Source term | Target term | Notes / constraints |
|---|---|---|
| … | … | … |

---

## Units & conventions

- Units:
- Time semantics:
- Error semantics:
- Naming conventions:

---

## Correspondence checks (how to validate the mapping)

- Test 1:
- Test 2:

---

## Key rules

- **Weakest link:** If this bridge participates in a claim chain, the chain's reliability is bounded by min(CL) among participating bridges.
- **CL penalties route to R only** — bridges cannot degrade Formality or ClaimScope.
- **Non-symmetric kinds** (⊑, ⊒) MUST state direction explicitly.
- **Substitution bridges** (≈, ⊑, ⊒, ⋂, ⊥) must preserve meaning within the bounded context. Cross-context interpretation bridges (design↔run, measure-of, policy-implies) explain but do not justify substitution.

---

## Notes

