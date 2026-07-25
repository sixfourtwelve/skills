---
name: duplicate-pr
description: Search for existing open PRs that might duplicate or overlap with the current branch or PR. Use when opening a PR, or asked to check for duplicate or related PRs before starting work.
---

# Duplicate PR Check

Search open PRs on the current repo for ones that might already address the same thing, using `gh`.

## 1. Establish context

If a PR is already open for the current branch, get its number, title, and description via `gh pr view` — the number must be excluded from results later so a PR never flags itself as its own duplicate. If no PR is open yet, derive the same context from the branch's commit history and diff summary (`git log <base>..HEAD`, `git diff <base>...HEAD --stat`).

**Complete when:** the current PR number (if any) and a title/description/keyword summary of the work are known.

## 2. Search

Extract a few distinct keyword phrases from the title/description/commits — not just one query, since a single search misses variants. Run `gh pr list --search "<keywords>" --state open` (or `gh search prs "<keywords>" --repo <owner/repo> --state open`) for each phrase.

**Complete when:** multiple keyword searches have been run against open PRs.

## 3. Exclude self and filter

Drop the current PR's own number from the results. Keep only PRs that plausibly address the same issue or feature — not just ones sharing a common word.

**Complete when:** the candidate list contains only other PRs, filtered for real relevance.

## 4. Report

If potential duplicates remain, list each with its title, URL, and a one-sentence reason it looks related. If none remain, respond with exactly `No duplicate PRs found` and nothing else — keep this concise and actionable either way.

**Complete when:** the result has been reported in the appropriate format for the outcome.
