#!/usr/bin/env bash
# longhaul SessionStart hook.
# Silent unless the project has project-state/STATE.md. When it does, prints the
# current state + most recent log entry to stdout, which Claude Code adds to the
# session context (SessionStart stdout from an exit-0 hook becomes context).
# Fires on startup, resume, /clear, and after compaction, so state survives /compact.
# Never fails the session: every error path exits 0 with no output.

set -u
STATE_DIR_NAME="project-state"
MAX_STATE_LINES=120
MAX_LOG_LINES=40

input="$(cat 2>/dev/null || true)"

# Session source (startup | resume | clear | compact | fork), parsed without jq.
source_kind="$(printf '%s' "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p' | head -n1)"
# cwd from the hook payload, falling back to CLAUDE_PROJECT_DIR, then PWD.
payload_cwd="$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
start_dir="${CLAUDE_PROJECT_DIR:-${payload_cwd:-$PWD}}"

# Walk up from start_dir to find project-state/STATE.md (handles sessions started in a subfolder).
dir="$start_dir"
root=""
while [ -n "$dir" ] && [ "$dir" != "/" ]; do
  if [ -f "$dir/$STATE_DIR_NAME/STATE.md" ]; then root="$dir"; break; fi
  parent="$(dirname "$dir")"; [ "$parent" = "$dir" ] && break; dir="$parent"
done
if [ -z "$root" ]; then
  # No local files. A project whose state lives in a Claude Doc or Drive folder leaves a
  # "longhaul state: <link>" pointer in CLAUDE.md; surface it so Claude loads it.
  dir="$start_dir"
  while [ -n "$dir" ] && [ "$dir" != "/" ]; do
    if [ -f "$dir/CLAUDE.md" ]; then
      ptr="$(grep -m1 -E '^[[:space:]]*longhaul state:[[:space:]]*[^[:space:]]+' "$dir/CLAUDE.md" 2>/dev/null | sed -E 's/^[[:space:]]*longhaul state:[[:space:]]*//')"
      if [ -n "$ptr" ]; then
        echo "[longhaul] This is a long-running project. Its state lives outside this repo: $ptr"
        echo "Before non-trivial work, load the State section and the latest Log entry from there (Claude Docs or Google Drive tools). If those tools aren't available in this session, tell the user and suggest /longhaul:review to move the state into project-state/ files."
        exit 0
      fi
    fi
    parent="$(dirname "$dir")"; [ "$parent" = "$dir" ] && break; dir="$parent"
  done
  exit 0
fi

sd="$root/$STATE_DIR_NAME"
state="$sd/STATE.md"
log="$sd/LOG.md"

# "Last checkpoint: YYYY-MM-DD" line in STATE.md
last_cp="$(grep -m1 -oE 'Last checkpoint:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$state" 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')"

days_ago=""
if [ -n "$last_cp" ]; then
  now_s="$(date +%s)"
  cp_s="$(date -d "$last_cp" +%s 2>/dev/null || date -j -f '%Y-%m-%d' "$last_cp" +%s 2>/dev/null || true)"
  if [ -n "$cp_s" ]; then days_ago=$(( (now_s - cp_s) / 86400 )); fi
fi

commits_since=""
if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Anchor on the last commit that touched STATE.md and count later commits that changed
  # anything outside the state folder. Only valid when STATE.md is committed and clean.
  anchor=""
  if [ -z "$(git -C "$root" status --porcelain -- "$STATE_DIR_NAME/STATE.md" 2>/dev/null)" ]; then
    anchor="$(git -C "$root" log -1 --format=%H -- "$STATE_DIR_NAME/STATE.md" 2>/dev/null)"
  fi
  if [ -n "$anchor" ]; then
    commits_since="$(git -C "$root" rev-list --count "$anchor..HEAD" -- . ":(exclude)$STATE_DIR_NAME" 2>/dev/null)"
  elif [ -n "$last_cp" ]; then
    # STATE.md is untracked or has uncommitted edits: fall back to the checkpoint date.
    commits_since="$(git -C "$root" log --since="$last_cp 23:59:59" --oneline 2>/dev/null | wc -l | tr -d ' ')"
  fi
fi

case "$source_kind" in
  compact) header="Context was just compacted. Re-loading long-running project state." ;;
  resume)  header="Resumed session on a long-running project." ;;
  *)       header="This is a long-running project managed with longhaul." ;;
esac

echo "[longhaul] $header"
if [ -n "$last_cp" ]; then
  if [ -n "$days_ago" ]; then
    echo "Last checkpoint: $last_cp ($days_ago day(s) ago)."
  else
    echo "Last checkpoint: $last_cp."
  fi
else
  echo "STATE.md has no 'Last checkpoint:' date. Treat it as possibly stale."
fi
if [ -n "$commits_since" ] && [ "$commits_since" -gt 0 ] 2>/dev/null; then
  echo "WARNING: $commits_since git commit(s) after the last checkpoint are not reflected in STATE.md. Check 'git log' before trusting it, and run /longhaul:checkpoint once caught up."
fi
echo
echo "===== $STATE_DIR_NAME/STATE.md ====="
head -n "$MAX_STATE_LINES" "$state"
total_state="$(wc -l < "$state" | tr -d ' ')"
if [ "$total_state" -gt "$MAX_STATE_LINES" ] 2>/dev/null; then
  echo "...(STATE.md truncated at $MAX_STATE_LINES of $total_state lines; it is meant to stay short. Run /longhaul:review.)"
fi

if [ -f "$log" ]; then
  # Most recent entry = last "## " section in LOG.md (entries are appended at the bottom).
  last_entry="$(awk '/^## /{buf=""} {buf=buf $0 "\n"} END{printf "%s", buf}' "$log" | head -n "$MAX_LOG_LINES")"
  if printf '%s' "$last_entry" | grep -q '^## '; then
    echo
    echo "===== Most recent entry in $STATE_DIR_NAME/LOG.md ====="
    printf '%s\n' "$last_entry"
  fi
fi

echo
echo "Also in $STATE_DIR_NAME/: BRIEF.md (goal, success criteria, non-goals), DECISIONS.md, QUESTIONS.md. Read them before any non-trivial work. Run /longhaul:checkpoint at milestones and before ending the session."
exit 0
