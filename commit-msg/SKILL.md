---
name: commit-msg
description: Write or check a commit message for staged changes using Conventional Commits. Use when asked to write, suggest, or check a commit message.
---

# Commit Message

Write a commit message using [Conventional Commits](https://www.conventionalcommits.org/) — this is the user's standing preference across repos, applied by default rather than inferred per project.

## 1. Use Conventional Commits

Default to `type(scope): subject` (e.g. `feat(auth): add token refresh`, `fix(cache): resolve stale-read race`). Pick `type` from the standard set (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `build`, `ci`) and add a `scope` when it clarifies which part of the codebase changed. Only deviate from Conventional Commits if the repo explicitly enforces something else (a commitlint config, a stated convention in CONTRIBUTING.md) — in that case follow the repo's enforced convention instead and note the deviation to the user.

**Complete when:** the message format (Conventional Commits by default, or the repo's enforced alternative) is settled.

## 2. Read the change

Run `git diff --staged` (or `git diff` if nothing is staged yet, noting that to the user) to understand what's actually changing and why, not just which files touched.

**Complete when:** the staged diff has been read and its intent is understood.

## 3. Draft

Choose an accurate `type` (and `scope` if used), then write a concise description focused on *why* the change was made, not a mechanical restatement of which lines changed (`fix(cache): resolve race in invalidation`, not `fix: update cache.ts`). Add a body only if it conveys something the subject and diff don't already make obvious — most commits don't need one. Add a `BREAKING CHANGE:` footer if the change breaks a public contract.

**Complete when:** a subject (and body/footer, if warranted) is drafted in Conventional Commits format.

## 4. Present, don't commit

Show the message to the user. Do not run `git commit` automatically — creating a commit is a decision the user makes, and they may still want to adjust staging first.

**Complete when:** the message has been presented and, if the user confirms, the commit is made using their explicit go-ahead.
