# longhaul

A Claude plugin for projects and research that run for weeks or months across many sessions. It works in Claude Code and in the Claude app (web, desktop, mobile).

On a long project, Claude starts every session cold, and you end up re-explaining the goal, what's done, what failed, and what was decided. longhaul keeps that in a small set of plain markdown sections and loads the current state at the start of every session, including after compaction.

## Contents

- [Requirements](#requirements)
- [Install](#install)
- [Quick start](#quick-start)
- [Commands](#commands)
- [Using it in Claude app chats](#using-it-in-claude-app-chats)
- [Where the state lives](#where-the-state-lives)
- [What loads automatically](#what-loads-automatically)
- [Update](#update)
- [Uninstall](#uninstall)
- [Troubleshooting](#troubleshooting)
- [Design notes](#design-notes)
- [Customize](#customize)
- [Development](#development)

## Requirements

- Claude Code with plugin support, or a Claude plan with plugins in the Claude app, or both.
- `bash` for the session-start hook: macOS, Linux, or Git Bash/WSL on Windows. `jq` is not needed.

## Install

Pick the option that matches where you work. You only need one.

### Option A: Claude Code

1. Add this repo as a plugin marketplace:

   ```bash
   claude plugin marketplace add grmwtt/longhaul
   ```

2. Install the plugin:

   ```bash
   claude plugin install longhaul@longhaul
   ```

3. Confirm it is installed. You should see 4 skills (`checkpoint`, `init`, `resume`, `review`) and 1 `SessionStart` hook:

   ```bash
   claude plugin details longhaul
   ```

4. Start a new Claude Code session. Plugins load at session start, so a session that was already open won't have the commands.

### Option B: Claude app (claude.ai, desktop, mobile)

1. Open **Customize > Plugins > Add > Add marketplace**.
2. Enter `grmwtt/longhaul`.
3. Add the `longhaul` plugin from that marketplace.

Plugins installed this way are tied to your account and also appear in Claude Code as a synced plugin.

### Option C: Upload a zip to the Claude app

Use this to install without adding the marketplace.

1. Download `longhaul-plugin.zip` from the [latest release](https://github.com/grmwtt/longhaul/releases/latest):

   https://github.com/grmwtt/longhaul/releases/latest/download/longhaul-plugin.zip

2. In the Claude app, open **Customize > Plugins > Add > Upload plugin** and choose the downloaded zip.

To build the zip yourself instead, clone this repo and run `bash scripts/build-zip.sh`; it writes `dist/longhaul-plugin.zip`.

### Option D: Try it from a clone without installing

```bash
git clone https://github.com/grmwtt/longhaul.git
claude --plugin-dir ./longhaul/plugins/longhaul
```

The plugin is active for that session only.

## Quick start

1. **Set up the project (once).** Open Claude in your project folder, or in a chat for chat-only work, and run:

   ```
   /longhaul:init
   ```

   Claude looks at what it can see (README, git history, attached files), then asks one round of questions: goal, success criteria, non-goals, constraints, whether this is code or research, and anything already decided or tried. It then creates the state and wires it up so future sessions load it.

   - In a folder, this creates `project-state/` and adds a short section to `CLAUDE.md`. Commit both.
   - In a chat with no folder, this creates one Claude Doc with a tab per section.
   - Either way, `init` also gives you a three-line snippet for Claude app Projects. See [Using it in Claude app chats](#using-it-in-claude-app-chats).

2. **Work as usual.** In Claude Code and Cowork, each new session starts with the current state and the latest log entry already loaded. You don't need to run anything.

3. **Save progress at milestones and before you stop.**

   ```
   /longhaul:checkpoint
   ```

   This appends a log entry, records decisions and open questions, and rewrites the current state with concrete next actions. Claude may also run it on its own at milestones. You can add a note after the command to emphasize something.

4. **Catch up after time away.**

   ```
   /longhaul:resume
   ```

   Claude reads the full state, checks whether the work has moved on since the last checkpoint, and recommends the next action.

5. **Tidy up every week or two.**

   ```
   /longhaul:review
   ```

   Claude reports progress against your success criteria, proposes cleanups (archiving old log entries, pruning stale state), and applies only the ones you approve.

## Commands

| Command | When | What it does |
|---|---|---|
| `/longhaul:init` | Once, at project start | Looks at what it can see, asks one round of questions, creates the state, and wires it up so future sessions load it. Never overwrites existing state. |
| `/longhaul:checkpoint` | Milestones, end of session | Appends a log entry, records decisions and questions, rewrites STATE. Claude can also run this on its own at milestones. |
| `/longhaul:resume` | After time away | Reads the full state, checks for drift since the last checkpoint, recommends the next action. |
| `/longhaul:review` | Every week or two | Archives old log entries, prunes stale state, flags drift from the brief, reports progress on success criteria. Also moves the state between repo files and a Claude Doc when you ask. |

## Using it in Claude app chats

Chats in the Claude app don't run hooks, so the state is loaded through a Project's instructions instead.

1. Run `/longhaul:init`. At the end it shows a snippet like this, with your project's location filled in:

   ```
   This Project is a long-running project managed with the longhaul plugin.
   longhaul state: <doc link, Drive folder link, or folder path>
   At the start of every chat in this Project, before answering, load the state (the State section and the most recent Log entry; the Brief too before any non-trivial work) and treat it as context. Run the longhaul checkpoint skill at milestones and before we wrap up.
   ```

2. In the Claude app, create a Project for this work, or open the existing one.
3. Paste the snippet into the Project's instructions.
4. Start this project's chats inside that Project. Each chat then loads the state first.

## Where the state lives

Each project keeps its state in exactly one place, picked by `init`:

| Location | Picked when | Read from Claude Code | Read from the Claude app |
|---|---|---|---|
| `project-state/` files in the repo | There's a working folder (Claude Code, Cowork, or a folder connected through the desktop app) | Directly, auto-loaded by the hook | Through a folder connected from the desktop app |
| One Claude Doc, one tab per section | Chat-only projects in the Claude app | Through the Claude Docs connector, when the Claude Code session has it | Directly, on any device |
| Google Drive folder, one `.md` per section | Fallback when Claude Docs isn't available | Only if a Drive connector is available | Through the Google Drive connector |

The sections:

| Section | Holds |
|---|---|
| BRIEF | Goal, success criteria, non-goals, constraints. Changes only with a recorded decision. |
| STATE | Where things stand and the next actions. Kept short and rewritten at each checkpoint. |
| LOG | Append-only history, newest entry at the bottom. |
| DECISIONS | `D-NNN` entries with rationale and rejected alternatives. |
| QUESTIONS | Open questions and hypotheses. |
| SOURCES | Research mode only: sources, marked verified or unverified. |

## What loads automatically

- **Claude Code and Cowork**: a `SessionStart` hook injects STATE and the latest log entry at startup, on resume, after `/clear`, and after compaction. It warns when git has commits newer than the last committed checkpoint. It does nothing in projects that aren't set up.
- **Claude app chats**: the Project-instructions snippet above tells each chat to load the state first.
- **Sessions without the plugin**: the section `init` adds to `CLAUDE.md` tells Claude to read `project-state/STATE.md` and the latest log entry itself, so collaborators who haven't installed the plugin still get the state.

## Update

Claude Code:

```bash
claude plugin marketplace update longhaul
claude plugin update longhaul@longhaul
```

Then start a new session.

## Uninstall

Claude app: **Customize > Plugins > longhaul > Remove**.

Claude Code:

```bash
claude plugin uninstall longhaul@longhaul
claude plugin marketplace remove longhaul
```

Your state files and docs stay where they are.

## Troubleshooting

- **The `/longhaul:` commands don't appear.** Start a new session after installing, and check `claude plugin details longhaul`.
- **Nothing is loaded at session start.** The hook is silent unless it finds `project-state/STATE.md` in the current folder or a parent folder. Run `/longhaul:init` if the project isn't set up. The hook also needs `bash` on your PATH.
- **`init` says it couldn't read its templates.** The templates live in the plugin's install folder, outside your project. Allow Claude to read that folder when it asks. In headless runs (`claude -p`), pass `--add-dir ~/.claude/plugins/cache/longhaul`.
- **A warning says commits aren't reflected in STATE.md.** Work was committed after the last checkpoint. Run `/longhaul:checkpoint`, then commit `project-state/`.
- **A Claude app chat doesn't know the project.** Make sure the chat is inside the Project whose instructions contain the snippet.

## Design notes

- **Why a plugin**: skills only load when invoked. Auto-loading needs a hook (Claude Code, Cowork) or Project instructions (chat), and a plugin bundles everything with one install that syncs across surfaces.
- **Why STATE is kept short**: it's loaded into every session, so every line costs context every time. History goes in LOG, rationale in DECISIONS.
- **Portable skills**: the skill frontmatter uses only `name` and `description`, the fields every surface accepts. `checkpoint` is meant to run on its own; the other three say "use only when the user asks" in their descriptions.
- **No Stop hook**: a Stop hook that nags for checkpoints continues the conversation every turn.

## Customize

Fork this repo and edit:

- `plugins/longhaul/skills/init/templates/` for the section templates and the Project-instructions snippet
- `plugins/longhaul/skills/*/SKILL.md` for each command's behavior
- `plugins/longhaul/scripts/session-start.sh` for what the hook injects (`MAX_STATE_LINES`, `MAX_LOG_LINES`)

## Development

- `bash scripts/check.sh` runs everything: shell syntax (plus `shellcheck` if installed), a check that the "Find this project's state" block is identical in all four skills, hook tests in a throwaway git repo, and `claude plugin validate` for the marketplace and the plugin. CI runs the same script on every push and pull request.
- `scripts/check.sh` does not run the skills. [docs/manual-test.md](docs/manual-test.md) has the procedure for testing them end to end in real sessions, and the result of the last run.
- `bash scripts/build-zip.sh` builds `dist/longhaul-plugin.zip` for Upload plugin. `dist/` is not committed.
- To release: bump `version` in `plugin.json`, commit, then push a matching tag (`git tag v0.1.3 && git push origin v0.1.3`). The `release` workflow runs the checks, builds the zip, and attaches it to the GitHub release for that tag, creating the release if needed. The install instructions link to the latest release's zip, so every version should be released this way.
- Bump `version` in `plugins/longhaul/.claude-plugin/plugin.json` with every change you want installed copies to receive.
- The "Find this project's state" block is repeated in each `SKILL.md` because skills can't share includes. Edit all four copies together.

## License

MIT
