# Bridge Card (cross-context alignment)

A bridge makes "sameness" explicit between two bounded contexts.
Never assume equivalence without a bridge.

- **Bridge ID:** BRIDGE-…
- **Source context:** …
- **Target context:** …
- **Bridge-kind:** ≈ Equivalence | ⊑ Narrower | ⊒ Broader | ⋂ Partial-overlap | ⊥ Disjoint | ⇄ᴅʳ Design↔Run | →ᴍᴱᵃ Measure-of | →ᴅᵉᵒ Policy-implies
- **Direction:** A→B | A↔B
- **Congruence level (CL):** 0 | 1 | 2 | 3
  - 0 = Opposed (terms conflict; using one in place of the other is wrong)
  - 1 = Comparable (same domain, different framing; naming-only use allowed)
  - 2 = Translatable (systematic mapping exists with known loss; role assignment allowed)
  - 3 = Near-identity (negligible loss in this context; type-structure reuse allowed)
- **Allowed use:** Naming-only (CL≥1) | Role Assignment (CL≥2) | Type-structure (CL=3)
- **Counter-example:** (what case would break this mapping? required for CL≤2; explain absence for CL=3)
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

## Invariants (from F.9)

- **I-LOCALITY:** Bridge cells connect SenseCells (local meanings), not entire Contexts.
- **I-FAMILY-PURITY:** Substitution bridges (≈, ⊑, ⊒, ⋂, ⊥) MUST be senseFamily-preserving. Interpretation bridges (⇄ᴅʳ, →ᴍᴱᵃ, →ᴅᵉᵒ) cross families but CANNOT justify row/substitution.
- **I-ROW-DEPENDENCE:** If this bridge participates in a Concept-Set row, the row's scope ≤ min(CL) among all participating bridges.
- **I-DIRECTION:** Non-symmetric kinds (⊑, ⊒, →ᴍᴱᵃ, →ᴅᵉᵒ) MUST state direction explicitly.
- **I-CL-HONESTY:** Counter-example or invariant explanation is REQUIRED (see counter-example field above).
- **I-LOSS-VISIBILITY:** Every bridge carries Loss Notes (see loss notes field above).

---

## Notes

