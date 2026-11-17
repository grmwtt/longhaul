# longhaul

Persistent project state for long-running projects and research, in Claude Code and the Claude app. Keeps a brief, current state, log, decisions, and open questions in repo files or a Claude Doc, and loads the current state at the start of every session, including after compaction, so you stop re-explaining the project.

Commands: `/longhaul:init` (once per project), `/longhaul:checkpoint` (at milestones), `/longhaul:resume` (after time away), `/longhaul:review` (periodic cleanup). In Claude Code and Cowork a SessionStart hook does the auto-loading; in Claude app chats, `init` gives you a snippet for a Project's instructions. Requires bash for the hook.

Install in Claude Code:

```bash
claude plugin marketplace add grmwtt/longhaul
claude plugin install longhaul@longhaul
```

In the Claude app: Customize > Plugins > Add > Add marketplace, then enter `grmwtt/longhaul`.

Full docs: https://github.com/grmwtt/longhaul
