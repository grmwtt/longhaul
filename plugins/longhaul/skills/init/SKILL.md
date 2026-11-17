---
name: init
description: Set up a long-running project or research effort with persistent state (brief, current state, log, decisions, questions) so every future session, in Claude Code or the Claude app, resumes without re-explaining. Use only when the user explicitly asks to set up or initialize a project with longhaul.
---

# Initialize a long-running project

Goal: in one short pass, give this project a durable state that any future session can pick up cold, on whichever surface the user works from. Optimize for the user's time: prefill from what you can see, ask only what you can't infer. If the user typed a description along with the command, use it as the starting point.

## Find this project's state

A project's state is one set of markdown sections: BRIEF, STATE, LOG, DECISIONS, QUESTIONS, plus SOURCES in research mode. Each project keeps it in exactly ONE place. Find it in this order and use the first hit:

1. **Files**: a readable `project-state/STATE.md` in the current repo or working folder (Claude Code, Cowork), or in a folder connected from the user's computer (Claude app with the desktop app linked). Read and write the files directly. A chat conversation's own temporary workspace does not count: nothing there survives the conversation.
2. **Pointer**: a line `longhaul state: <location>` in the project instructions, the conversation, or CLAUDE.md. If the location is a folder path on the user's computer and that folder isn't connected yet, request access to exactly that folder (one prompt), then use it as Files. If it's a link, it's a Claude Doc with one tab per section, in this order: State, Brief, Log, Decisions, Questions, Sources. Use the Claude Docs tools and follow their guide before the first call. If the link is a Google Drive folder instead, it holds one `.md` file per section; use the Google Drive tools. If the needed tools aren't available in this app, say so plainly and stop rather than guessing at the state.
3. **Neither**: if the user is in the Claude app and their computer is linked, the state may be in a folder that isn't connected yet; ask once whether to request access to it. Otherwise the project isn't set up: suggest `/longhaul:init`.

Never create a second copy of the state somewhere else. In a doc, keep each tab's markdown in the same shape as the matching file, so a project can move between files and a doc without reformatting.

## 1. Check for an existing setup

Run the lookup above. If state already exists, stop: say where it is and suggest `/longhaul:resume` or `/longhaul:review`. Never overwrite existing state.

## 2. Pick where the state will live

Choose automatically and tell the user in one line which location and why:

- **Files** (`project-state/` folder) when there is a persistent working folder: Claude Code, a Cowork task on the user's computer, or a folder from the user's computer connected to this chat. Best for anything with code or data in a repo: git tracks it, Claude Code loads it automatically, and the Claude app can read the same files through the desktop app.
- **Claude Doc** when this is a chat in the Claude app with no persistent folder. Works on web, desktop, and mobile. If the Claude Docs tools aren't available, use a Google Drive folder with one `.md` file per section if the Drive tools are. If neither is available, say the project can't be saved from this app and suggest Claude Code or connecting a folder through the desktop app.

If the project clearly has a repo but this chat can't reach it, ask whether to connect that folder rather than starting a doc, so the project doesn't end up with two locations.

## 3. Look before asking

Spend a few tool calls (about 5 at most) on context you can reach: `README*`, an existing `CLAUDE.md`, `git log --oneline -20`, the top-level file tree, attached files, or the earlier part of this conversation. Draft answers to the interview from this.

## 4. Interview (one round)

Ask everything in a single round, showing your drafts so the user can just correct them. Use a multiple-choice question tool for the multiple-choice parts if one is available; otherwise ask in plain text.

1. **Goal**: what exists or is known at the end that does not now?
2. **Success criteria**: 2 to 5 measurable checks. Push back once on vague ones ("works well") and propose a measurable version.
3. **Non-goals**: what is explicitly out of scope?
4. **Constraints**: deadlines, stack, data or access limits, people to check with.
5. **Mode**: `code`, `research`, or `mixed`. Research and mixed add SOURCES and hypothesis tracking.
6. **Starting point**: anything already decided, tried, or known to fail?

If the user says "just set it up", fill what you can, mark unknowns `TODO(user)`, and continue.

## 5. Create the state

The templates are in this skill's `templates/` folder (`${CLAUDE_SKILL_DIR}/templates/`): `STATE.md`, `BRIEF.md`, `LOG.md`, `DECISIONS.md`, `QUESTIONS.md`, `SOURCES.md`. Replace `{{DATE}}` with today's date (YYYY-MM-DD) and `{{MODE}}` with the mode, fill in the interview answers, and drop template comments in sections you filled. In STATE, set "Next actions" to 1 to 3 concrete first steps. Record anything from "starting point" as DECISIONS entries (D-001, ...) or STATE Gotchas. Include SOURCES only in research or mixed mode.

- **Files**: create `project-state/` at the repo root (git root if in a repo, else the working folder) with one file per template.
- **Claude Doc**: create ONE doc titled `<project name> · project state` with one tab per section, in the order State, Brief, Log, Decisions, Questions, Sources, the State tab first. Each tab's content is the filled template.
- **Google Drive**: one folder named `<project name> · project state` with one `.md` file per section.

## 6. Wire it up so future sessions load it automatically

- **Files**: put the contents of `templates/CLAUDE-section.md` into the repo-root `CLAUDE.md`. If CLAUDE.md doesn't exist, create it with that section. If it already contains `<!-- longhaul:start -->`, replace the text between the markers. Otherwise append the section. Never rewrite the user's existing content. Claude Code then loads the state at every session start through the plugin's hook.
- **Every location, for the Claude app**: fill in `templates/PROJECT-INSTRUCTIONS.md` (replace `{{LOCATION}}` with the doc link, Drive folder link, or the folder's full path on the user's computer) and show it to the user in a code block. Tell them: create a Project in the Claude app for this work (or open the existing one), paste the snippet into the Project's instructions, and start this project's chats inside that Project. That makes every chat there load the state first, the way the hook does in Claude Code.

## 7. Finish

Show the user, briefly: where the state lives (with the link for a doc), the next actions you wrote, any `TODO(user)` fields, and the Project-instructions snippet. For files, suggest committing `project-state/` and `CLAUDE.md`, and ask before committing yourself.

Keep it fast: one interview round and one write pass.
