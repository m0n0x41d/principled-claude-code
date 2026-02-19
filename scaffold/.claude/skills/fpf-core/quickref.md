# FPF quick reference (for day-to-day project work)

This is a **pragmatic** quickref. For deeper definitions and the full pattern language,
see `reference/FPF-Spec.md`.

---

## The ADI loop (Canonical Reasoning Cycle)

### Abduction — *Propose*
- Frame the anomaly/problem in one sentence.
- Generate multiple hypotheses (don’t prematurely converge).
- Mark the prime hypothesis as *provisional*.

### Deduction — *Analyze*
- Derive predictions and invariants.
- Define falsifiers (what evidence would prove you wrong?).
- Identify dependencies and second-order effects.

### Induction — *Test*
- Run tests / experiments / measurements that correspond to deduced predictions.
- Record the evidence and update confidence conservatively.

---

## Lifecycle states (state machine)

**Explore → Shape → Evidence → Operate**

- Explore: options & hypotheses (wide search)
- Shape: formalize one direction (blueprint/architecture)
- Evidence: validate/verify (tests, measurements, harnesses)
- Operate: deploy + monitor + refresh evidence over time

---

## Strict distinctions (common traps)

### Plan vs reality
- A design doc is not a successful deployment.
- A TODO is not completed work.
- A “should” statement is not evidence.

### Object vs description vs carrier
- Repo/PDF/wiki: carriers
- Specs/docs/code: descriptions (epistemes)
- Running software / deployed infra: objects/systems

### Role / Capability / Method / MethodDescription / Work / WorkPlan
- Role: “actor mask in context”
- Capability: “can do”
- Method: “how (abstract)”
- MethodDescription: “the recipe”
- WorkPlan: “when/by whom we intend to run”
- Work: “what happened this time”

When someone says “process”, resolve it explicitly.

---

## Evidence mindset

When you say “this is true”, prefer one of:
- a deterministic check (type check, static analysis)
- a unit/integration test
- a reproducible benchmark
- a runtime trace/log with reproduction steps

Capture:
- exact command(s)
- environment (OS, versions)
- commit hash / revision
- result summary
- validity window (`valid_until`) if it can go stale

---

## Conservative confidence (weakest link)

Avoid optimistic roll-ups.
If a claim depends on multiple sub-claims, the overall reliability is bounded by the weakest piece.

---

## Where to write things

- `.fpf/anomalies/` — anomalies + hypotheses + predictions
- `.fpf/decisions/` — decision rationale records (DRR)
- `.fpf/evidence/` — evidence records
- `.fpf/glossary/` — glossary + bridges
- `.fpf/worklog/` — session logs

Templates live in `.fpf/templates/`.

