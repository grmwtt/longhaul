# longhaul

A Claude plugin for projects and research that run for weeks or months across many sessions, in Claude Code and in the Claude app (web, desktop, mobile).

The main cost on long projects is Claude starting every session (and every post-compaction context) cold, and you re-explaining the goal, what's done, what failed, and what was decided. longhaul keeps that in a small set of plain markdown sections and loads the current state at the start of every session.

## Install

**Claude app** (claude.ai, desktop, mobile): go to Customize > Plugins > Add > Add marketplace, enter `grmwtt/longhaul`, then add the `longhaul` plugin. Plugins installed this way are tied to your account and also appear in Claude Code as a synced plugin. To test without GitHub, use Add > Upload plugin with `dist/longhaul-plugin.zip`.

**Claude Code only**:

```bash
claude plugin marketplace add grmwtt/longhaul
claude plugin install longhaul@longhaul
```

To try it from a clone without installing: `claude --plugin-dir ./plugins/longhaul`.

## Use

| Command | When | What it does |
|---|---|---|
| `/longhaul:init` | Once, at project start | Looks at what it can see, asks one round of questions (goal, success criteria, non-goals, constraints, code vs research), creates the state, and wires it up so future sessions load it |
| `/longhaul:checkpoint` | Milestones, end of session | Appends a log entry, records decisions and questions, rewrites STATE. Claude can also run this on its own at milestones |
| `/longhaul:resume` | After time away | Reads the full state, checks for drift since the last checkpoint, recommends the next action |
| `/longhaul:review` | Every week or two | Archives old log entries, prunes stale state, flags drift from the brief, reports progress on success criteria. Also moves state between repo files and a Claude Doc |

## Where the state lives

Each project keeps its state in one place, picked by `init`:

| Location | Picked when | Read from Claude Code | Read from the Claude app |
|---|---|---|---|
| `project-state/` files in the repo | There's a working folder (Claude Code, Cowork, or a folder connected through the desktop app) | Directly, auto-loaded by the hook | Through a folder connected from the desktop app |
| One Claude Doc, one tab per section | Chat-only projects in the Claude app | Only if Claude Code can reach Claude Docs (not verified) | Directly, on any device |
| Google Drive folder, one `.md` per section | Fallback when Claude Docs isn't available | Only if a Drive connector is available | Through the Google Drive connector |

Sections: BRIEF (goal, success criteria, non-goals, constraints), STATE (where things stand and next actions, kept short), LOG (append-only history), DECISIONS (D-NNN entries with rationale and rejected alternatives), QUESTIONS (open questions and hypotheses), SOURCES (research mode, verified vs unverified).

## How each surface loads the state automatically

- **Claude Code and Cowork**: a `SessionStart` hook injects STATE and the latest log entry at startup, on resume, after `/clear`, and after compaction. It warns when git has commits newer than the last checkpoint, and does nothing in projects that aren't set up.
- **Claude app chats**: chat doesn't run hooks. `init` gives you a three-line snippet to paste into a Project's instructions; every chat in that Project then loads the state first.

## Design notes

- **Why a plugin**: skills only load when invoked. Auto-loading needs a hook (Claude Code, Cowork) or Project instructions (chat), and a plugin bundles everything with one install that syncs across surfaces.
- **Why STATE is kept short**: it's loaded into every session, so every line costs context every time. History goes in LOG, rationale in DECISIONS.
- **Portable skills**: the skill frontmatter uses only `name` and `description`, the fields every surface accepts. `checkpoint` is meant to run on its own; the other three say "use only when the user asks" in their descriptions.
- **No Stop hook**: a Stop hook that nags for checkpoints continues the conversation every turn.

## Requirements

- Claude Code with plugin support, and/or a Claude plan with plugins in the app
- `bash` for the hook (macOS, Linux, or Git Bash/WSL on Windows). No `jq` needed.

## Customize

Fork this repo and edit:
- `plugins/longhaul/skills/init/templates/` for the section templates and the Project-instructions snippet
- `plugins/longhaul/skills/*/SKILL.md` for each command's behavior
- `plugins/longhaul/scripts/session-start.sh` for what the hook injects (`MAX_STATE_LINES`, `MAX_LOG_LINES`)

Validate after edits: `claude plugin validate .` and `claude plugin validate ./plugins/longhaul`.

## Uninstall

Claude app: Customize > Plugins > longhaul > Remove. Claude Code:

```bash
claude plugin uninstall longhaul@longhaul
claude plugin marketplace remove longhaul
```

Your state files and docs stay where they are.

## License

MIT
