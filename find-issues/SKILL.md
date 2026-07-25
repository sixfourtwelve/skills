---
name: find-issues
description: Search a repository's existing GitHub issues for ones matching a query — an error message, symptom, or feature request. Use when asked to find, search, or check for existing issues matching something.
---

# Find Issues

Search a repo's existing issues via `gh` for ones matching a given query, so work doesn't duplicate an already-tracked issue.

## 1. Determine the target repo

Default to the current repo's `origin` remote (`gh repo view` or `git remote get-url origin`). Use a different `owner/repo` only if the user names one explicitly.

**Complete when:** the target `owner/repo` is known.

## 2. Take the query

Use the query as given — an error message, symptom description, or feature request — without narrowing it prematurely.

**Complete when:** the search query is clear.

## 3. Search

Run `gh issue list --search "<query>" --repo <owner/repo>` (or `gh search issues "<query>" --repo <owner/repo>`), trying a few phrasings since one search under-matches: the literal query, key error text alone, and a paraphrase around the underlying functionality.

**Complete when:** multiple relevant searches have been run.

## 4. Evaluate matches

For each candidate, check whether it shares a similar title/description, the same error message or symptom, related functionality or component, or a similar feature request — not just an incidental keyword overlap.

**Complete when:** every candidate has been checked against the query for a real match, not just a keyword hit.

## 5. Report

List matching issues with their number, title, a one-sentence reason they match, and a link. If no clear matches are found, say so plainly.

**Complete when:** matches (or their absence) have been reported with a reason for each.
