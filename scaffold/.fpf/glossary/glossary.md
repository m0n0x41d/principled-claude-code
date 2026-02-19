# Project glossary

This file defines **canonical terms** for this repo/workspace.
If multiple repos exist in this workspace, treat each repo/module as a bounded context and
use Bridge Cards (`.fpf/glossary/bridges/`) to map between vocabularies.

---

## Term template

### <CanonicalTerm>
- **Aliases:** …
- **Bounded context:** …
- **Definition:** …
- **Examples (where used):**
  - `path/to/file.ext:line` — …
- **Non-examples / common confusions:** …
- **Related terms:** …

---

## Terms

### Bounded context
- **Aliases:** domain, context
- **Bounded context:** Meta
- **Definition:** A semantic scope in which terms have stable meaning and consistent acceptance criteria.

### Plan vs reality
- **Aliases:** design-time vs run-time
- **Bounded context:** Meta
- **Definition:** A discipline to keep the plan/spec separate from actual execution/observations.

### Role / Method / Work
- **Aliases:** process (overloaded, avoid)
- **Bounded context:** Meta
- **Definition:** A strict separation between who acts (Role), how it’s done (Method/MethodDescription), and what happened this time (Work).

