---
name: review
description: Periodic maintenance for a long-running longhaul project's state. Archives old log entries, prunes stale state, flags drift from the brief, reports progress on success criteria, and can move the state between repo files and a Claude Doc. Use when the user asks to review, clean up, or move the project state.
---

# Review

State rots: LOG grows without bound, STATE collects stale bullets, and work drifts from the brief. This skill fixes that. It proposes changes first and applies them only after the user agrees, since it rewrites and moves content.

## Find this project's state

A project's state is one set of markdown sections: BRIEF, STATE, LOG, DECISIONS, QUESTIONS, plus SOURCES in research mode. Each project keeps it in exactly ONE place. Find it in this order and use the first hit:

1. **Files**: a readable `project-state/STATE.md` in the current repo or working folder (Claude Code, Cowork), or in a folder connected from the user's computer (Claude app with the desktop app linked). Read and write the files directly. A chat conversation's own temporary workspace does not count: nothing there survives the conversation.
2. **Pointer**: a line `longhaul state: <location>` in the project instructions, the conversation, or CLAUDE.md. If the location is a folder path on the user's computer and that folder isn't connected yet, request access to exactly that folder (one prompt), then use it as Files. If it's a link, it's a Claude Doc with one tab per section, in this order: State, Brief, Log, Decisions, Questions, Sources. Use the Claude Docs tools and follow their guide before the first call. If the link is a Google Drive folder instead, it holds one `.md` file per section; use the Google Drive tools. If the needed tools aren't available in this app, say so plainly and stop rather than guessing at the state.
3. **Neither**: if the user is in the Claude app and their computer is linked, the state may be in a folder that isn't connected yet; ask once whether to request access to it. Otherwise the project isn't set up.

Never create a second copy of the state somewhere else. In a doc, keep each tab's markdown in the same shape as the matching file, so a project can move between files and a doc without reformatting.

If no state is found, say so and suggest `/longhaul:init`. Don't create state here.

## 1. Measure

Report the length of each section. Thresholds:
- STATE over about 60 lines: needs pruning
- LOG over about 300 lines: archive old entries
- DECISIONS: count active vs superseded
- QUESTIONS: count open items older than 30 days

## 2. Assess

- **Progress**: each success criterion in BRIEF, with status (met / in progress / not started / at risk) and evidence from LOG or the work itself.
- **Drift**: do the last ~10 LOG entries serve the goal and criteria? Flag work that matches a non-goal or maps to no criterion.
- **Staleness**: STATE bullets that LOG shows are done, blockers that look resolved, open questions that LOG answers.
- **Consistency**: decisions that contradict each other with no supersede link; Gotchas that no longer apply.
- **Brief health**: are the criteria still measurable and still the right ones? Only flag this; never edit BRIEF without the user.

## 3. Propose

Show a short health report (a criteria table plus the issues found), then a numbered list of proposed changes, for example:
1. Archive LOG entries older than 4 weeks (files: to `project-state/archive/LOG-YYYY-MM.md`; doc: to an `Archive` tab nested under Log), leaving a 5 to 10 line summary in LOG under `## Archived through YYYY-MM-DD`
2. Remove 4 stale bullets from STATE
3. Move 2 answered questions to Resolved
4. Mark D-003 superseded by D-007

Ask which to apply.

## 4. Apply

Apply only the approved changes. Archiving moves text verbatim; never summarize away evidence that the archive doesn't also keep. Then append a LOG entry `## YYYY-MM-DD: State review` listing what changed. For files in git, offer to commit.

## Moving the state (only when the user asks)

Typical case: a project started as a Claude Doc in chat now has a repo, or the reverse.
1. Copy every section verbatim to the new location (Files: one `.md` per section in `project-state/`; Doc: one tab per section). Copy archives too.
2. Wire up the new location as `/longhaul:init` step 6 describes (CLAUDE.md section and/or a new Project-instructions snippet for the user to paste).
3. Replace the old location's STATE content with one line: `Moved to <new location> on YYYY-MM-DD.` Leave the rest in place as a backup; tell the user they can delete it.
4. Add a DECISIONS entry recording the move.
