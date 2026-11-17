# Manual end-to-end test

`scripts/check.sh` covers the hook and the manifests. It does not run the skills, because that needs a model. This page is the procedure for exercising the skills in real Claude Code sessions, and the result of the last run.

## Procedure

Use a throwaway git repo with a small script and a README, and the plugin installed (or pass `--plugin-dir`). Each step is a separate headless session, so nothing carries over except the state.

Headless sessions deny anything that needs approval. `init` reads its templates from the plugin's install folder, which is outside the project, so grant read access to it:

```bash
PLUGIN_DIR="$HOME/.claude/plugins/cache/longhaul"
ALLOW=(--add-dir "$PLUGIN_DIR" --allowedTools Read Glob Grep "Bash(git:*)" "Bash(ls:*)" "Bash(python3:*)")
NOTOOLS=(--disallowedTools Read Bash Glob Grep Skill Agent)
```

1. **init**: `claude -p "/longhaul:init Just set it up without asking me questions. Goal: ... Success criteria: ... Non-goals: ... Mode: code. Already decided: ... Do not commit." --permission-mode acceptEdits "${ALLOW[@]}"`
   Expect `project-state/` with BRIEF, STATE, LOG, DECISIONS, QUESTIONS; no `{{...}}` placeholders left; `CLAUDE.md` holding the section between the `longhaul:start` and `longhaul:end` markers; the Project-instructions snippet in the reply. Commit the result.
2. **Injection**: `claude -p "Do not use any tools. From your context only: what is next action #1, when was the last checkpoint, and what is the latest log entry title?" "${NOTOOLS[@]}"`
   Expect correct answers. BRIEF, DECISIONS and QUESTIONS are not injected, so the session should say it can't see them.
3. **checkpoint**: ask for a small piece of work, a commit, then "run the longhaul checkpoint skill and commit the checkpoint", with `--permission-mode acceptEdits "${ALLOW[@]}"`.
   Expect a new `## ` entry at the bottom of LOG, STATE rewritten with new next actions, decisions and resolved questions recorded.
4. **Stale-state warning**: make a commit outside `project-state/`, then run the hook by hand:
   `echo '{"source":"startup"}' | CLAUDE_PROJECT_DIR="$PWD" bash <plugin>/scripts/session-start.sh | head -4`
   Expect `WARNING: 1 git commit(s) after the last checkpoint ...`.
5. **resume**: `claude -p "/longhaul:resume" "${ALLOW[@]}"`
   Expect a brief under 15 lines that names the unrecorded commit as drift and recommends a next action.
6. **review**: `claude -p "/longhaul:review" "${ALLOW[@]}"`
   Expect a size table, a success-criteria table, issues, and a numbered list of proposed changes, with nothing applied.
7. **Compaction**: `claude -p "Reply: ready" "${NOTOOLS[@]}"`, then `claude -p "/compact" --continue`, then
   `claude -p "Do not use tools. Quote the first line of every block in your context that starts with [longhaul]." --continue "${NOTOOLS[@]}"`
   Expect a line reading `[longhaul] Context was just compacted. Re-loading long-running project state.`

## Last run: 2026-11-17, plugin 0.1.2, Claude Code 2.1.326

Test project: an 11-line `csv2json.py` CLI in a fresh git repo. State location: files. All seven steps passed.

| Step | Result |
|---|---|
| init | Passed. Created the five sections from the templates, recorded the stated decision as D-001, marked two BRIEF fields `TODO(user)`, added three open questions, wrote the `CLAUDE.md` section and the snippet. Did not commit, as asked. |
| Injection | Passed. A fresh session with tools disabled reported next action #1, the checkpoint date and the latest log title, and said BRIEF, DECISIONS and QUESTIONS were not in its context. |
| checkpoint | Passed, with one defect (below). STATE was rewritten, D-002 added, Q-01 moved to Resolved, evidence included the commit hash and the command output. |
| Stale-state warning | Passed. One unrecorded commit produced the 1-commit warning. |
| resume | Passed. Named the unrecorded commit and its content as drift, re-ran the project's check script, listed what needed the user. |
| review | Passed. Proposed five changes and applied none. |
| Compaction | Passed. After `/compact`, the session's context held the "Context was just compacted" block from the hook. |

Findings:

- **Same-day checkpoints were merged into the previous log entry.** `checkpoint` said to add to an existing entry from the same day, so the second checkpoint's bullets landed under `## 2026-11-17: Project initialized`, and the hook then showed the latest work under that title. `review` flagged it independently. Fixed in 0.1.3: every checkpoint gets its own entry.
- **`init` needs read access to the plugin's install folder.** Without it (first headless attempt), `init` could not read `templates/` and wrote the files from memory of the skill text. The hook-facing formats were still correct, but headings and wording differed from the templates. The README's troubleshooting section now covers this.

Not covered by this run: the Claude Doc and Google Drive state locations, the Claude app (Project instructions snippet, zip upload), Cowork, moving state between locations with `review`, applying `review` proposals, and the interactive interview in `init`.

## Directory edition run: 2026-11-17, plugin 0.1.5, Claude Code 2.1.326

The directory edition (`directory/longhaul`, no hook) was tested the same way in a second throwaway repo. To keep the installed full edition's hook out of it, the test project had `.claude/settings.json` with `{"enabledPlugins": {"longhaul@longhaul": false}}`, and each session was started with `--plugin-dir <repo>/directory/longhaul` (plus `--add-dir` for the same folder so `init` could read its templates).

| Step | Result |
|---|---|
| No hook | Passed. A session with tools disabled reported no `[longhaul]` block in its context. |
| init | Passed. Created the five sections and the `CLAUDE.md` section from the templates. |
| Loading without the hook | Passed. Asked only "What should we work on next?", a fresh session read STATE, BRIEF, QUESTIONS and LOG on its own, ran `git log --oneline -5`, and reported the one commit made after the last checkpoint. |
| Compaction | Passed. After `/compact`, the session answered a question about next action 2 correctly from context without re-reading the file. |

Not covered: `checkpoint`, `resume` and `review` were not re-run for this edition, since the skill files are identical to the full edition's. One run of each step is not a measure of how reliably sessions follow the `CLAUDE.md` section.
