---
name: review-pass
description: Review a diff, branch, or PR for correctness, security, and quality issues. Use when asked to review code changes, review a PR, or do a code review — especially useful in agents without a built-in review command.
---

# Review Pass

A portable, checklist-driven review for any diff. Produces ranked findings with concrete evidence, not vague impressions.

## 1. Determine scope

Figure out what's being reviewed: uncommitted working changes (`git status`, `git diff`), a branch against its base (`git diff <base>...HEAD`, `git log <base>..HEAD`), or a specific PR/file set the user named. Confirm the scope before reading further if it's ambiguous.

**Complete when:** the exact diff or file set under review is known.

## 2. Read with context

Read each changed file with enough surrounding code to understand callers, types, and existing patterns — not just the diff hunks. A change that looks wrong in isolation is often correct given context two lines outside the hunk, and vice versa.

**Complete when:** every changed file has been read with its relevant surrounding context, not just the patch lines.

## 3. Apply the checklist

Evaluate the change against four categories:

- **Correctness** — logic errors, off-by-one/boundary bugs, unhandled edge cases, wrong assumptions about types or state, race conditions.
- **Security** — injection (SQL, command, XSS), secrets committed in code, missing auth/authz checks, unsafe deserialization, path traversal.
- **Simplification** — dead code, needless abstraction, duplicated logic that should reuse an existing helper, over-engineering beyond what the change needs.
- **Test coverage** — new behavior with no test, a weakened or deleted assertion, an edge case the diff clearly introduces but doesn't cover.

Only flag something you can point to concretely — a suspicion without a mechanism isn't a finding yet.

**Complete when:** the diff has been evaluated against all four categories and every candidate issue has a specific file/line.

## 4. Verify before reporting

For each candidate finding, re-check it against the actual code: confirm the failure scenario is real (concrete input/state → wrong output/crash), not hypothetical. Drop anything that doesn't survive this check. This step exists because a plausible-sounding finding is often wrong once you trace the actual control flow.

**Complete when:** every remaining finding has a verified, concrete failure scenario.

## 5. Report

Report findings ranked most-severe-first. For each: file:line, a one-sentence statement of the defect, and the concrete failure scenario that triggers it. If nothing survives verification, say so plainly — an empty result is a valid outcome, not a failure to find something.

**Complete when:** findings (or their absence) have been reported with evidence for each.
