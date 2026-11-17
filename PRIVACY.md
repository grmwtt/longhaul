# Privacy

Last updated: 2026-11-17

This page covers the longhaul plugin in both editions: the full edition in this repository's marketplace and the directory edition in Anthropic's plugin directory.

## What the author collects

Nothing. The plugin has no server, no account, no analytics and no telemetry. Its author does not receive, see or store any of your data, and the plugin sends nothing to its author.

## What the plugin does with your data

longhaul is a set of skills: written instructions that Claude follows. The skills have Claude read and write a project's state (brief, current state, log, decisions, open questions, and sources in research mode) in one location that is chosen when you set the project up:

- a `project-state/` folder in your own project folder or repository
- a Claude Doc in your Claude account
- a Google Drive folder in your Google account

A Claude Doc or a Google Drive folder is reached through connectors that are already set up in your Claude account. The plugin declares no connectors of its own.

The state holds whatever you and Claude record about the project. That can include personal data you choose to put there, such as the names of stakeholders or of people to check with. It stays in the location above and is under your control.

## The session-start hook (full edition only)

The full edition includes a shell script that runs on your computer at the start of a Claude Code or Cowork session. It reads the state files in your project folder, asks git how many commits are newer than the last checkpoint, and prints the current state into the session. It makes no network requests. The directory edition does not include this script.

## Other services

Your conversations with Claude, including anything the skills read into them, are handled by Anthropic under its own terms and privacy policy. State kept in Google Drive is handled by Google under its terms and privacy policy. This page does not cover those services.

## Deleting your data

Delete the `project-state/` folder, the Claude Doc or the Google Drive folder. Uninstalling the plugin does not delete them. `init` also adds a marked section to a project's `CLAUDE.md`, which you can remove by hand.

## Changes and contact

Changes to this page are made in this repository, where its history is public. For questions, open an issue at https://github.com/grmwtt/longhaul/issues.
