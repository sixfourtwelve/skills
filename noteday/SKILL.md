---
name: noteday
model: haiku
description: Log today's work — a summary of the day plus any tickets worked on — as an entry in the personal Notion "Daily Log" database. Use when the user runs /noteday or asks to note down their day.
---

# noteday — log today's work to Notion

Create (or update) today's entry in the **Daily Log** database in Ethan's personal Notion workspace.

## Fixed references

- Notion database: "Daily Log", data source: `collection://FILL THIS`
  (database page: https://app.notion.com/p/FILL THIS, parent: Home)
- Workspace guard: entries go to the personal workspace "SOMEONS's Notion" (workspace ID `FILL THIS`). If `notion-fetch` with id `self` reports any other workspace, STOP and tell the user.

## Steps

1. **Load tools** (they are deferred): use ToolSearch for
   `mcp__notion__notion-fetch`, `mcp__notion__notion-query-data-sources`, `mcp__notion__notion-create-pages`, `mcp__notion__notion-update-page`.

2. **Verify workspace**: call `notion-fetch` with id `self` and apply the workspace guard above.

3. **Gather ticket activity (optional)**: if a Linear (or similar issue-tracker) MCP server is connected in this session, find the current user and list issues assigned to them with `updatedAt` within today. Collect for each ticket: identifier, title, URL, and status. If no tracker is connected, skip this step.

4. **Draft the summary**:
   - If the user passed arguments to /noteday, treat them as the day's summary (verbatim or lightly cleaned up).
   - Otherwise, draft a one-paragraph summary from the current session's work and any ticket activity, and show it to the user for a quick confirm/edit before saving. Ask for an optional Mood (great/good/meh/rough); omit the property if they don't give one.

5. **Upsert today's entry**: query the data source for a row where `date:Date:start` is today.
   - If one exists, update that page instead of creating a duplicate (append/replace summary and merge ticket links).
   - Otherwise create a page via `notion-create-pages` with parent `{"data_source_url": "collection://FILL THIS"}` and properties:
     - `Name`: weekday + date, e.g. "Wed, Jul 16 2026"
     - `date:Date:start`: today as ISO date (YYYY-MM-DD), `date:Date:is_datetime`: 0
     - `Summary`: the day's summary
     - `Tickets`: markdown links, e.g. `[ABC-123](https://...) Ticket title (Done)` — one per line; "none" if no ticket activity
     - `Mood`: only if the user gave one

6. **Report**: confirm with a link to the created/updated entry and list the tickets that were logged.
