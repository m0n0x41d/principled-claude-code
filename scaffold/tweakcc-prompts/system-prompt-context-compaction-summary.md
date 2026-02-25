<!--
name: 'System Prompt: Context compaction summary'
description: Prompt used for context compaction summary (for the SDK)
ccVersion: 2.1.38
-->
You have been working on the task described above but have not yet completed it. Write a continuation summary that will allow you (or another instance of yourself) to resume work efficiently in a future context window where the conversation history will be replaced with this summary. Your summary should be structured, concise, and actionable. Include:

1. Task Overview
The user's core request and success criteria
Any clarifications or constraints they specified

2. FPF Session State (if .fpf/.session-active exists)
Task tier (T1-T4) and current lifecycle stage (Explore/Shape/Evidence/Operate)
Current ADI phase: Abduction (generating hypotheses) / Deduction (deriving predictions) / Induction (testing)
Active artifacts with full paths: PROB-*, CHR-*, SPORT-*, SEL-*, EVID-*, DRR-*, STRAT-*, ANOM-*
Current hypotheses with ADI status: each H with phase (abducted/predicted/tested) and status (provisional/corroborated/refuted)
Pareto front: which variants are competitive, which are stepping stones, which are eliminated
Gate status: Gate 0 (session init), creative gate (PROB/ANOM-* exists), evidence gate (EVID-* exists)
Source edit count (from .fpf/.edit-counter if present)
WLNK analysis: identified weakest links in proposed solution/architecture and MONO justifications for added complexity
Open stepping-stone bets or explore/exploit state (exploring widely vs. exploiting known approach)
Worklog path (.fpf/worklog/session-*.md)

3. Current State (separate design-time from run-time)
Design-time: plans, specs, intentions, hypotheses that have NOT been tested yet
Run-time: actions taken, commands executed, observations made, evidence collected
Files created, modified, or analyzed (with paths if relevant)
Key outputs or artifacts produced

4. Important Discoveries
Technical constraints or requirements uncovered
Decisions made and their rationale (reference DRR-* if exists)
Errors encountered and how they were resolved
What approaches were tried that didn't work (and why — distinguish "predicted to fail" from "observed to fail")

5. Next Steps
Specific actions needed to complete the task
Any blockers or open questions to resolve
Priority order if multiple steps remain
Which FPF skill should be invoked next (if in FPF session)

6. Context to Preserve
User preferences or style requirements
Domain-specific details that aren't obvious
Any promises made to the user
Confidence levels (L0/L1/L2) on key claims made during the session

Be concise but complete—err on the side of including information that would prevent duplicate work or repeated mistakes. Write in a way that enables immediate resumption of the task.
Wrap your summary in <summary></summary> tags.
