---
name: pr-writer
description: Draft a pull request title and description from the current branch's diff and commit history. Use when asked to write a PR description, draft a PR, or prepare a branch for review.
---

# PR Writer

Draft a PR title and body that explain *why* a change was made, not a restatement of the diff.

## 1. Determine the range

Identify the base branch (usually the repo's default branch) and the diff/commit range against it: `git log <base>..HEAD`, `git diff <base>...HEAD`, and `git diff <base>...HEAD --stat` for a shape overview. If the branch tracks a remote, check whether it's already pushed and up to date.

**Complete when:** the base branch and full commit range for the PR are known.

## 2. Find the template

Look for the repo's PR template — usually `.github/pull_request_template.md`, also check `.github/PULL_REQUEST_TEMPLATE.md` and `docs/PULL_REQUEST_TEMPLATE.md`. When one exists, always follow its sections exactly rather than substituting a preferred structure. Only fall back to a default **Summary** (bulleted, why-focused) and **Test Plan** (checklist of what to verify) when the repo has no template at all.

**Complete when:** the applicable structure — the repo's template, or the default — is settled.

## 3. Draft

Write a title under 70 characters describing the change, not the mechanism ("Fix stale cache after config reload", not "Update cache.ts"). Write the body from the full commit range and diff, not just the latest commit — summarize the net effect and motivation, using the commit messages as evidence rather than concatenating them.

**Complete when:** a complete title and body are drafted.

## 4. Present, don't publish

Show the draft to the user. Do not run `gh pr create`, push the branch, or open the PR without explicit confirmation — this is a shared-state, visible-to-others action and the draft may need edits first.

**Complete when:** the draft has been presented and, if the user confirms, the PR is created (or the branch pushed) using their explicit go-ahead.
