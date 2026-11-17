#!/usr/bin/env bash
# Repo checks: run before committing. Usage: bash scripts/check.sh
# - shell syntax (and shellcheck, if installed) for every script
# - the "Find this project's state" block is identical in all four skills
# - session-start hook behaviour in a throwaway git repo
# - `claude plugin validate` for the marketplace and the plugin, if the CLI is installed
set -u
cd "$(dirname "$0")/.." || exit 1
NAME="longhaul"
PLUGIN="plugins/$NAME"
HOOK="$PWD/$PLUGIN/scripts/session-start.sh"
fails=0
ok()  { echo "ok    $1"; }
bad() { echo "FAIL  $1"; fails=$((fails + 1)); }

# --- shell scripts ---
for f in "$PLUGIN"/scripts/*.sh scripts/*.sh; do
  if bash -n "$f" 2>/dev/null; then ok "syntax: $f"; else bad "syntax: $f"; fi
done
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck "$PLUGIN"/scripts/*.sh scripts/*.sh; then ok "shellcheck"; else bad "shellcheck"; fi
else
  echo "skip  shellcheck (not installed)"
fi

# --- shared block: heading through the "Never create a second copy" paragraph ---
block() { awk '/^## Find this project.s state/{f=1} f{print} /^Never create a second copy/{f=0}' "$1"; }
ref="$PLUGIN/skills/init/SKILL.md"
if [ -z "$(block "$ref")" ]; then bad "shared block missing in $ref"; fi
for s in checkpoint resume review; do
  f="$PLUGIN/skills/$s/SKILL.md"
  if [ "$(block "$f")" = "$(block "$ref")" ]; then
    ok "shared block: $s matches init"
  else
    bad "shared block: $s differs from init (edit all four copies together)"
    diff <(block "$ref") <(block "$f") | head -n 10
  fi
done

# --- hook behaviour ---
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
hook() { # hook <start dir> [run-from dir]: prints hook output, returns its exit code
  (cd "${2:-$tmp}" && printf '{"source":"startup"}' | CLAUDE_PROJECT_DIR="$1" timeout 10 bash "$HOOK")
}
expect() { # expect <label> <want: warn|quiet|silent> <start dir> [run-from dir]
  local out rc
  out="$(hook "$3" "${4:-}")"; rc=$?
  if [ "$rc" -ne 0 ]; then bad "hook: $1 (exit $rc)"; return; fi
  case "$2" in
    warn)   if printf '%s' "$out" | grep -q '^WARNING: 1 git commit'; then ok "hook: $1"; else bad "hook: $1 (expected a 1-commit warning)"; fi ;;
    quiet)  if [ -n "$out" ] && ! printf '%s' "$out" | grep -q '^WARNING'; then ok "hook: $1"; else bad "hook: $1 (expected state with no warning)"; fi ;;
    silent) if [ -z "$out" ]; then ok "hook: $1"; else bad "hook: $1 (expected no output)"; fi ;;
  esac
}
g() { git -C "$tmp/proj" -c user.name=check -c user.email=check@example.invalid "$@"; }

mkdir -p "$tmp/proj/project-state" "$tmp/proj/src/deep" "$tmp/empty"
git -C "$tmp/proj" init -q
printf '# Current State\n\nLast checkpoint: %s\n' "$(date +%Y-%m-%d)" > "$tmp/proj/project-state/STATE.md"
printf '# Work Log\n\n## %s: Project initialized\n- Done: setup\n' "$(date +%Y-%m-%d)" > "$tmp/proj/project-state/LOG.md"
g add -A; g commit -qm "checkpoint"
expect "no commits since checkpoint" quiet "$tmp/proj"
echo x > "$tmp/proj/src/a"; g add -A; g commit -qm "work"
expect "same-day work commit warns, found from a subfolder" warn "$tmp/proj/src/deep"
echo "- more" >> "$tmp/proj/project-state/LOG.md"; g add -A; g commit -qm "log only"
expect "commit touching only project-state is not counted" warn "$tmp/proj"
echo "- edit" >> "$tmp/proj/project-state/STATE.md"
expect "uncommitted STATE.md falls back to the checkpoint date" quiet "$tmp/proj"
g add -A; g commit -qm "checkpoint 2"
expect "committed checkpoint clears the warning" quiet "$tmp/proj"
expect "project that is not set up" silent "$tmp/empty"
expect "backslash path does not hang" silent 'C:\Users\x\proj' "$tmp/empty"
expect "relative path does not hang" silent 'some/rel/dir' "$tmp/empty"
if hook "$tmp/proj" | grep -q '^## .*Project initialized'; then ok "hook: latest log entry injected"; else bad "hook: latest log entry injected"; fi

# --- manifests ---
if command -v claude >/dev/null 2>&1; then
  if claude plugin validate . >/dev/null 2>&1; then ok "claude plugin validate ."; else bad "claude plugin validate ."; fi
  if claude plugin validate "./$PLUGIN" >/dev/null 2>&1; then ok "claude plugin validate ./$PLUGIN"; else bad "claude plugin validate ./$PLUGIN"; fi
else
  echo "skip  claude plugin validate (CLI not installed)"
fi

echo
if [ "$fails" -eq 0 ]; then echo "All checks passed."; else echo "$fails check(s) failed."; exit 1; fi
