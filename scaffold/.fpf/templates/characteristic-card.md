# Characteristic Card

- **ID:** CHRC-…
- **Status:** Draft | Active | Archived
- **Created:** YYYY-MM-DD
- **Transformer:** …
- **Bounded context:** …
- **Parent passport:** `.fpf/characterizations/CHR-...`

---

## 1) Definition

- **Name:** …
- **Scale type:** Nominal | Ordinal | Interval | Ratio
- **Unit:** … (or "categorical" for nominal/ordinal)
- **Polarity:** Higher-better | Lower-better | Target (specify target value)
- **Range:** [min, max] or set of valid values
- **Precision:** (significant digits, tolerance, or granularity)

---

## 2) Measurement method

- **How to measure:** (exact procedure, tool, command, or formula)
- **Preconditions:** (what must be true for measurement to be valid)
- **Environment requirements:** (versions, hardware, configuration)
- **Reproducibility:** (can another agent repeat this measurement and get the same result?)

---

## 3) Validity and refresh

- **Valid under:** (conditions where this characteristic applies)
- **Invalidated by:** (changes that make prior measurements stale)
- **Refresh trigger:** (when to re-measure — time-based, event-based, or both)
- **valid_until:** YYYY-MM-DD (or null with justification)

---

## 4) CSLC binding

Where in the creating system lifecycle (CSLC) does this characteristic matter most?

- **Stage:** Explore | Shape | Evidence | Operate
- **Relevance:** (why this characteristic matters at this stage)
- **Decays at:** (stage where this characteristic becomes less relevant, if any)

---

## 5) Links

- Parent passport: `.fpf/characterizations/CHR-...`
- Evidence records: `.fpf/evidence/...`
- Related characteristics: `.fpf/characterizations/CHRC-...`
