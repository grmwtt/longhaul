<!-- longhaul:start -->
## Long-running project protocol

This project keeps durable state in `project-state/`. The longhaul plugin injects STATE.md and the latest log entry at session start and after compaction. If that state is not already in your context (the plugin is not installed, or this surface does not run hooks), read `project-state/STATE.md` and the last entry in `project-state/LOG.md` before doing anything else.

- `BRIEF.md`: goal, success criteria, non-goals, constraints. Do not change without a DECISIONS.md entry.
- `STATE.md`: where things stand and the next actions. Short, overwritten each checkpoint.
- `LOG.md`: append-only history, newest at the bottom.
- `DECISIONS.md`: decisions with rationale and rejected alternatives. Check here before re-opening a settled question.
- `QUESTIONS.md`: open questions and hypotheses.

Rules:
- Before non-trivial work, read BRIEF.md and confirm the task serves a success criterion. If it doesn't, say so.
- Run `/longhaul:checkpoint` at milestones (decision made, question resolved, blocker found, task finished) and before the session ends.
- In state files, record facts with evidence (file paths, commands, numbers). Mark anything inferred or unverified as such.
- Do not retry approaches listed as failed in STATE.md Gotchas or LOG.md without new information.
<!-- longhaul:end -->
