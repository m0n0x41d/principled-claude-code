# Evidence Record

- **ID:** EVID-…
- **Date/time:** YYYY-MM-DD hh:mm
- **Transformer:** …
- **Bounded context:** …
- **Commit / revision:** …
- **Environment:** OS / versions / runtime details
- **ClaimScope(G):** (set of contexts/conditions where this claim holds — set-valued per USM A.2.6)
- **Evidence lane:** TA (Typing Assurance) | VA (Validity Assurance) | LA (Logical Assurance)
- **Claim under test:** …
- **Prediction (deduced):** …
- **DesignRunTag:** design-time | run-time (is this evidence about a spec/plan or about execution/observation?)
- **Type:** Verification (formal/test) | Validation (runtime/user/field)
- **Result:** Corroborated | Refuted | Inconclusive
- **valid_until:** YYYY-MM-DD (or null with justification). No implicit "latest" — state explicitly what version/time this evidence applies to (Γ_time per USM A.2.6).

---

## 1) Setup

- Preconditions:
- Data / fixtures:
- Configuration:

---

## 2) Procedure (run-time)

Exact commands / steps to reproduce:

```bash
# commands here
```

---

## 3) Raw outputs

Paste key outputs (or link to log files).

---

## 4) Interpretation (conservative)

- What does this evidence support?
- What does it *not* support?
- Confounders / alternative explanations:

---

## 5) Assurance update (required)

- **F (Formality):** informal | structured | formalizable | proof-grade (simplified from F0-F9; see C.2.3 for full scale)
  - F_eff = min_i F_i (weakest link caps formality of the whole chain)
- **G (ClaimScope):** List the specific contexts/conditions where this evidence holds.
  - G is set-valued (USM A.2.6). NOT an ordinal level — enumerate the contexts.
  - Example: "G = {Node.js ≥18, Linux/macOS, single-process deployment}"
- **R (Reliability):** 0–1 estimate, conservative
  - R_raw = min_i R_i (weakest link in the evidence chain)
  - If cross-context: R_eff = max(0, R_raw − Φ(CL_min)) where Φ is the CL penalty
- **CL (if cross-context):** If this evidence crosses bounded contexts, state CL (0-3) and apply penalty.
  - CL penalties affect R only (not F or G)

---

## 6) Follow-ups

- Next tests:
- Refutations to pursue:
- Refresh plan (if evidence decays):

