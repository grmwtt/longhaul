---
name: checkpoint
description: Save progress on a long-running project into its longhaul state (STATE, LOG, DECISIONS, QUESTIONS). Use at milestones (decision made, question resolved, blocker found, task finished), before compacting or ending a session, or when the user says checkpoint or save progress. Only applies to projects set up with longhaul.
---

# Checkpoint

Persist what this session learned so the next session, on any surface, can continue cold. If the user added a note with the command, emphasize it.

## Find this project's state

A project's state is one set of markdown sections: BRIEF, STATE, LOG, DECISIONS, QUESTIONS, plus SOURCES in research mode. Each project keeps it in exactly ONE place. Find it in this order and use the first hit:

1. **Files**: a readable `project-state/STATE.md` in the current repo or working folder (Claude Code, Cowork), or in a folder connected from the user's computer (Claude app with the desktop app linked). Read and write the files directly. A chat conversation's own temporary workspace does not count: nothing there survives the conversation.
2. **Pointer**: a line `longhaul state: <location>` in the project instructions, the conversation, or CLAUDE.md. If the location is a folder path on the user's computer and that folder isn't connected yet, request access to exactly that folder (one prompt), then use it as Files. If it's a link, it's a Claude Doc with one tab per section, in this order: State, Brief, Log, Decisions, Questions, Sources. Use the Claude Docs tools and follow their guide before the first call. If the link is a Google Drive folder instead, it holds one `.md` file per section; use the Google Drive tools. If the needed tools aren't available in this app, say so plainly and stop rather than guessing at the state.
3. **Neither**: if the user is in the Claude app and their computer is linked, the state may be in a folder that isn't connected yet; ask once whether to request access to it. Otherwise the project isn't set up: suggest `/longhaul:init`.

Never create a second copy of the state somewhere else. In a doc, keep each tab's markdown in the same shape as the matching file, so a project can move between files and a doc without reformatting.

If no state is found, say so and suggest `/longhaul:init`. Don't create state here.

## 1. Gather

- Read STATE, the last 2 LOG entries, and the DECISIONS and QUESTIONS headings.
- Review this session: what was done, learned, decided, and what failed.
- If you're in a git repo: `git status --short` and `git log --oneline --since="<Last checkpoint date>"` to catch work not discussed in the conversation.

## 2. Write (in this order)

**LOG**: append ONE entry at the end:

```
## YYYY-MM-DD: short title
- Done: concrete outcomes, not activity ("eval harness runs end to end on 50 Qs", not "worked on eval")
- Learned: findings, surprises, numbers
- Failed / dead ends: what was tried and why it didn't work (so it isn't retried)
- Evidence: commands, file paths, commit hashes, metrics, source IDs, links
- Files: main files touched (omit for chat-only work)
```

If a checkpoint already happened today, add to that entry instead of making a new one.

**DECISIONS**: add a `D-NNN` entry for each decision that would be expensive to re-litigate. If it replaces an older one, mark the old one `superseded by D-NNN`. Skip trivial choices.

**QUESTIONS**: add new open questions; move answered ones to Resolved with the answer and its source. Update hypothesis statuses with evidence.

**SOURCES** (if present): add sources used this session. Mark `verified` only if the primary source was actually read.

**STATE**: rewrite it, don't append. Set `Last checkpoint:` to today. Keep it under about 60 lines. "Next actions" must be concrete enough to start on #1 without asking. Remove resolved blockers. Add Gotchas for anything a fresh session would get wrong.

In a Claude Doc, edit only the parts that changed (append to the end of the Log tab, replace the State tab's content), not whole tabs at once.

## 3. Rules

- Facts only, with evidence. Prefix anything inferred or unverified with `(unverified)`.
- No duplication across sections: STATE says where things are, LOG says what happened, DECISIONS says why.
- Specific over general: keep the actual number, path, error message, command, or link.
- Never edit BRIEF here. If the goal, criteria, or scope changed, add a DECISIONS entry, tell the user BRIEF needs updating, and update it only if they agree.

## 4. Report

Reply in 3 to 6 lines: what was recorded, the new #1 next action, and anything that needs the user. For files in a git repo, offer to commit (`git add project-state && git commit -m "checkpoint: <title>"`); don't commit without a yes.
