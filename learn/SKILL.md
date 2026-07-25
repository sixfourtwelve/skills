---
name: learn
description: Extract non-obvious learnings from the current session into AGENTS.md files, placed as close to the relevant code as possible. Use when asked to capture learnings, save session discoveries, or update AGENTS.md with what was learned.
---

# Learn

Turn genuine, non-obvious discoveries from this session into durable `AGENTS.md` entries — not a session recap.

## 1. Review the session for real learnings

Look for: hidden relationships between files or modules, execution paths that differ from how the code appears, non-obvious configuration/env vars/flags, debugging breakthroughs where the error message was misleading, API or tool quirks and their workarounds, build/test commands not documented elsewhere, architectural decisions and constraints, and files that must change together.

Filter out anything obvious from documentation, standard language/framework behavior, already present in an existing `AGENTS.md`, or specific only to this session (not durable).

**Complete when:** the session has been reviewed and every candidate has survived the "non-obvious and durable" filter.

## 2. Scope each learning

`AGENTS.md` files can exist at any directory level, not just the project root — an agent reading a file automatically loads every `AGENTS.md` in that file's parent directories. Place each learning as close to the relevant code as possible: project-wide → root `AGENTS.md`; package/module-specific → `packages/foo/AGENTS.md`; feature-specific → `src/auth/AGENTS.md`.

**Complete when:** every surviving learning has a target directory assigned.

## 3. Read before writing

Read the existing `AGENTS.md` at each target level before editing, so new entries don't duplicate what's already there and match its existing style.

**Complete when:** existing content at every target level has been read.

## 4. Write

Create or update each `AGENTS.md`, keeping every entry to 1–3 lines — a pointer for a future agent, not an explanation.

**Complete when:** all target `AGENTS.md` files reflect the filtered learnings.

## 5. Report

Summarize which `AGENTS.md` files were created or updated and how many learnings went into each. Nothing more verbose than that.

**Complete when:** the summary has been given.
