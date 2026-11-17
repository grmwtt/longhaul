---
name: resume
description: Re-orient on a long-running longhaul project after time away. Reads the full state, checks for drift since the last checkpoint, and proposes the next step. Use when the user asks to resume, says "where were we", or asks to be caught up on the project.
---

# Resume

At session start, Claude Code's hook (or the Project instructions in the Claude app) loads only STATE and the latest log entry. This skill goes deeper and checks that state against reality.

## Find this project's state

A project's state is one set of markdown sections: BRIEF, STATE, LOG, DECISIONS, QUESTIONS, plus SOURCES in research mode. Each project keeps it in exactly ONE place. Find it in this order and use the first hit:

1. **Files**: a readable `project-state/STATE.md` in the current repo or working folder (Claude Code, Cowork), or in a folder connected from the user's computer (Claude app with the desktop app linked). Read and write the files directly. A chat conversation's own temporary workspace does not count: nothing there survives the conversation.
2. **Pointer**: a line `longhaul state: <location>` in the project instructions, the conversation, or CLAUDE.md. If the location is a folder path on the user's computer and that folder isn't connected yet, request access to exactly that folder (one prompt), then use it as Files. If it's a link, it's a Claude Doc with one tab per section, in this order: State, Brief, Log, Decisions, Questions, Sources. Use the Claude Docs tools and follow their guide before the first call. If the link is a Google Drive folder instead, it holds one `.md` file per section; use the Google Drive tools. If the needed tools aren't available in this app, say so plainly and stop rather than guessing at the state.
3. **Neither**: if the user is in the Claude app and their computer is linked, the state may be in a folder that isn't connected yet; ask once whether to request access to it. Otherwise the project isn't set up: suggest `/longhaul:init`.

Never create a second copy of the state somewhere else. In a doc, keep each tab's markdown in the same shape as the matching file, so a project can move between files and a doc without reformatting.

## 1. Read

- BRIEF (full) and STATE (full)
- The last 3 LOG entries
- Active DECISIONS (titles and decision lines)
- Open items in QUESTIONS

## 2. Check for drift

- In a git repo: `git log --oneline --since="<Last checkpoint date>"` and `git status --short`. Commits or uncommitted changes that STATE and LOG don't mention mean the state is stale.
- Spot-check 1 or 2 claims in STATE against what you can reach (does the file exist, does the link work, does Next action #1 still make sense).
- Flag anything in "Active threads" or "Blockers" older than about 2 weeks.
- If you can't reach the underlying work from here (for example, a chat that can see the state but not the repo), say that the drift check was skipped.

## 3. Brief the user

In under 15 lines:
- **Goal** (one line) and which success criteria are met or not
- **Where things stand** (2 to 4 bullets)
- **Drift found**, or "none", or "not checked" and why
- **Recommended next action** with a one-line reason, plus one alternative if there's a real choice
- **Needs you**: open questions or blockers only the user can resolve

Then ask whether to start on the recommended action. If drift was found, offer to run `/longhaul:checkpoint` first to bring the state up to date.
