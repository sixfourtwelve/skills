---
name: yeetslop
description: Remove AI-generated code slop introduced in the current branch. User-invoked only.
disable-model-invocation: true
---

# Yeet Slop

Strip AI-generated slop out of the current branch's diff — invoked explicitly rather than chosen by the model.

## 1. Scope the diff

Diff the current branch against its base branch (the repo's default branch, or whatever the user names) to see everything introduced in this branch: `git diff <base>...HEAD`.

**Complete when:** the full set of changes introduced in this branch is known.

## 2. Scan for slop

Within that diff, look for:

- Extra comments a human wouldn't add, or that are inconsistent with the rest of the file's commenting style.
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase — especially around calls from trusted or already-validated codepaths.
- Casts to `any` (or the language equivalent) used to get around a type error instead of fixing it.
- Any other style that doesn't match the surrounding file.
- Unnecessary emoji.

**Complete when:** every candidate instance of slop in the diff has been identified.

## 3. Verify before removing

For each candidate, check it against the rest of the file and nearby code — remove it only if it's actually inconsistent with established style or genuinely unnecessary, not just unfamiliar. Don't strip something that's load-bearing or already how the file normally looks.

**Complete when:** each candidate has been confirmed as genuine slop, not a false positive.

## 4. Apply and report

Make the edits directly. Report with only a 1–3 sentence summary of what was changed — no itemized list, no restating the diff.

**Complete when:** the edits are applied and a brief summary has been given.
