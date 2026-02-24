# .claude/

This directory contains **Claude Code Skills** for this project.

Each skill lives in:

`.claude/skills/<skill-name>/SKILL.md`

The `name` in the YAML frontmatter becomes a `/slash-command`.

For details, see Claude Code docs:
- Skills: https://code.claude.com/docs/en/skills  (reference only)

This project’s skills operationalize the [First Principles Framework (FPF)](https://github.com/ailev/FPF)
as two coupled factories: a **problem factory** (problematization, characterization, portfolio management)
and a **solution factory** (SoTA survey, variant generation, Pareto selection, implementation, verification).
Both creativity (generating novel options) and assurance (evidence, audit trail) are first-class concerns.

## Skill sets

Skills are organized by the double-loop workflow. Other skill sets can be added alongside these.

**Session discipline** (bootstrap and close):
- `/fpf-core` — session bootstrap, FPF rules activation
- `/fpf-worklog` — session logging (plan vs reality)
- `/fpf-review` — end-of-session quality gate

**Problem factory** (observe → characterize → frame → manage portfolio → acceptance spec):
- `/fpf-problem-framing` — anomaly records and problem cards
- `/fpf-characterize` — characterization passports and characteristic cards
- `/fpf-problem-portfolio` — problem portfolio management

**Solution factory** (SoTA → strategize → variants → select → implement → verify → record):
- `/fpf-sota` — SoTA harvesting (survey existing approaches)
- `/fpf-strategize` — method family bet (first-class creative act — choose WHICH CLASS of approach)
- `/fpf-variants` — solution variant generation with NQD characterization
- `/fpf-selection` — qualitative Pareto analysis and explicit selection
- `/fpf-evidence` — evidence records for correctness claims
- `/fpf-decision-record` — decision rationale records

**Cross-cutting:**
- `/fpf-glossary` — terminology and cross-context bridges

