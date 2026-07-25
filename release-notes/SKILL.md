---
name: release-notes
description: Draft release notes or changelog entries from a commit or tag range. Use when asked to write release notes, draft a changelog, or summarize what changed between two versions or tags.
---

# Release Notes

Draft categorized release notes from a range of history, preferring PR-level context over raw commit noise.

## 1. Determine the range

Identify the two endpoints: two tags (`git tag --sort=-creatordate` to find the latest), a tag against `HEAD`, or explicit refs the user gave. Confirm the range before gathering history if it's ambiguous — a wrong range produces a wrong changelog silently.

**Complete when:** the exact ref range is settled.

## 2. Gather history

Run `git log <range> --oneline` for the raw commit list. If `gh` is available and commits reference merged PRs, prefer the PR titles and labels over raw commit messages — they're usually cleaner and already categorized by the author. Squash-merged branches in particular lose useful detail in the commit log that the PR retains.

**Complete when:** the full set of changes in range has been gathered from the best available source.

## 3. Categorize

Group into **Features**, **Fixes**, **Breaking Changes**, and **Other**. Use Conventional Commit prefixes (`feat`, `fix`, `!`/`BREAKING CHANGE`) or PR labels when present; otherwise fall back to keyword heuristics on the message. Anything that doesn't clearly fit goes in an **Uncategorized** bucket rather than being force-fit or dropped.

**Complete when:** every change in range has a category, including an explicit Uncategorized bucket if needed.

## 4. Match existing format

If a `CHANGELOG.md` already exists, match its format (e.g. Keep a Changelog headings, version/date conventions). Otherwise use plain categorized markdown headings.

**Complete when:** the draft's format matches the project's existing convention, or a sensible default if none exists.

## 5. Present, don't publish

Show the draft to the user. Do not write to `CHANGELOG.md` or create a GitHub release without explicit confirmation.

**Complete when:** the draft has been presented and, if the user confirms, it's written to the changelog or published using their explicit go-ahead.
