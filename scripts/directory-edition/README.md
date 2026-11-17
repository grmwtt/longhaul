# longhaul

Persistent project state for projects and research that run for weeks or months across many Claude sessions. longhaul keeps a brief, the current state, a log, decisions, and open questions in plain markdown, and has each new session load the current state first, so you stop re-explaining the project.

## Commands

| Command | When | What it does |
|---|---|---|
| `/longhaul:init` | Once, at project start | Asks one round of questions (goal, success criteria, non-goals, constraints), creates the state, and wires it up so future sessions load it |
| `/longhaul:checkpoint` | Milestones, end of session | Appends a log entry, records decisions and questions, rewrites the current state with next actions |
| `/longhaul:resume` | After time away | Reads the full state, checks for drift since the last checkpoint, recommends the next action |
| `/longhaul:review` | Every week or two | Archives old log entries, prunes stale state, reports progress on success criteria |

## Getting started

1. Open Claude in your project folder, or in a chat for chat-only work, and run `/longhaul:init`.
2. Work as usual. Run `/longhaul:checkpoint` at milestones and before you stop.
3. Run `/longhaul:resume` when you come back after time away.

## Where the state lives

`init` picks one place per project:

- a `project-state/` folder in your repo, when there is a working folder
- a Claude Doc with one tab per section, for chat-only projects
- a Google Drive folder with one `.md` file per section, as a fallback when Claude Docs isn't available

## Data handling

The plugin has no service of its own and sends nothing to its author. The skills read and write the project state only in the location above. A Claude Doc or a Google Drive folder is reached through connectors already set up in your Claude account; the plugin declares none of its own. The state holds whatever you and Claude record about the project, which can include the names of people involved, such as stakeholders or who to check with.

Privacy: https://github.com/grmwtt/longhaul/blob/main/PRIVACY.md

## How the state gets loaded

This edition contains skills only. It has no hooks and runs no scripts.

- **Claude Code and Cowork**: `init` adds a short section to the project's `CLAUDE.md` that tells each session to read the current state and the latest log entry before doing anything else.
- **Claude app chats**: `init` gives you a three-line snippet to paste into a Project's instructions. Every chat in that Project then loads the state first.

## Full edition

The edition on GitHub adds a session-start hook for Claude Code and Cowork. The hook puts the state into each session directly, including after compaction, and warns when git has commits newer than the last checkpoint. Install instructions and full documentation: https://github.com/grmwtt/longhaul

Install one edition, not both.

## License

MIT
