<!-- longhaul:start -->
## Long-running project protocol

This project keeps durable state in `project-state/`. At the start of every session, and again after compaction, `STATE.md` and the latest entry in `LOG.md` must be in your context. Where the longhaul plugin's session-start hook is running, it has already put them there in a block that starts with `[longhaul]`. If you don't see that block, read `project-state/STATE.md` and the last `## ` entry in `project-state/LOG.md` before doing anything else, and in a git repo run `git log --oneline -5`: commits newer than the last one that touched `project-state/STATE.md` mean the state may be stale.

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
