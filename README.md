# skills

Ethan Morgan's personal [agent skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) — self-contained instruction packages that coding agents load on demand to handle a specific kind of task.

Each top-level folder is one skill, defined by a `SKILL.md` with YAML frontmatter (`name`, `description`, and optional fields like `model` or `disable-model-invocation`). An agent reads the `description` to decide when a skill is relevant, then follows the body. Some skills carry extra `references/` or `agents/` files that the body pulls in only when needed.

## Skills

| Skill | What it is |
| --- | --- |
| [`ada`](ada/) | Opinionated, source-backed guide for modern Ada 2022 applications and libraries, with GNAT/GPRbuild/Alire defaults and incremental SPARK verification. |
| [`bro`](bro/) | Restates the agent's last message in plain, jargon-free language — one human talking to another. User-invoked only (`disable-model-invocation`). |
| [`commit-msg`](commit-msg/) | Writes a commit message for staged changes using Conventional Commits. |
| [`duplicate-pr`](duplicate-pr/) | Searches open PRs on the current repo for ones that might already address the same thing as the current branch/PR. |
| [`effect`](effect/) | Opinionated guide for building production TypeScript with [Effect](https://effect.website) v4 — services, layers, schemas, config, schedules, caches, streams, HTTP clients, and tests. |
| [`effect-service-design`](effect-service-design/) | Designs or audits Effect **services**, treating each as an authority seam with a clear contract, production Layer, and honest test Layer. |
| [`find-issues`](find-issues/) | Searches a repo's existing GitHub issues for ones matching a query — an error message, symptom, or feature request. |
| [`herdr`](herdr/) | Drives Herdr, a terminal multiplexer for coding agents — inspect and control panes, tabs, and workspaces, run commands, and start/monitor agents. Requires `HERDR_ENV=1`. |
| [`learn`](learn/) | Extracts non-obvious learnings from the current session into `AGENTS.md` files, placed as close to the relevant code as possible. |
| [`noteday`](noteday/) | Logs the day's work (summary + tickets touched) to the personal Notion "Daily Log" database. Runs on Haiku; triggered by `/noteday`. |
| [`objfw`](objfw/) | Opinionated guide for writing, reviewing, and testing Objective-C with ObjFW, using ARC by default and ObjFW-native APIs. |
| [`pr-writer`](pr-writer/) | Drafts a pull request title and description from the current branch's diff and commit history, following the repo's PR template if one exists. |
| [`release-notes`](release-notes/) | Drafts categorized release notes or changelog entries from a commit or tag range. |
| [`review-pass`](review-pass/) | Portable, checklist-driven review of a diff or PR for correctness, security, simplification, and test coverage — for agents without a built-in review command. |
| [`yeetslop`](yeetslop/) | Strips AI-generated slop (inconsistent comments, needless defensive code, `any` casts, stray emoji) out of the current branch's diff. User-invoked only. |

### `ada`
A production-oriented Ada guide that starts with semantic types, private package boundaries, contracts, deliberate ownership, and compiler/runtime version gating. Its focused references cover language/API design, controlled finalization and access types, strings and containers, contracts and incremental SPARK/GNATprove, tasking and Ada 2022 parallelism, Alire/GPRbuild/AUnit tooling, and C interoperability/portability. GNAT, GPRbuild, and Alire are the default workflow without making implementation-specific facilities part of portable APIs or imposing safety-critical restrictions universally.

### `bro`
Restate the previous message more simply and concisely, dropping jargon. Invoked explicitly rather than chosen by the model.

### `commit-msg`
Drafts a Conventional Commits message (`type(scope): subject`) for the staged diff, deviating only when a repo explicitly enforces a different convention (commitlint config, CONTRIBUTING.md). Presents the message rather than running `git commit` itself.

### `duplicate-pr`
Searches open PRs via `gh` for ones that might duplicate the current branch/PR — extracting keywords from the title, description, and commit history, excluding the current PR's own number, and reporting matches with a reason or `No duplicate PRs found` and nothing else.

### `effect`
A branch-based reference for Effect v4 work. `SKILL.md` sets the core defaults (compose with `Effect.gen`, model records with `Schema.Struct`, read config through `Config`, etc.) and points to a matching file under `references/` for the task at hand:

- `SCHEMA.md` — data models, schemas, brands, variants, decoders
- `SERVICES_LAYERS.md` — services, layers, runtime wiring, errors, `Effect.fn`
- `CONFIG.md` — runtime config, env variables, `ConfigProvider`
- `SCHEDULING.md` — retry, repeat, polling, backoff, jitter
- `CACHING.md` — TTL caches, concurrent-lookup dedupe, request batching
- `STREAMS.md` — streams, queues/pubsubs, pagination, backpressure
- `HTTP_CLIENTS.md` — outgoing HTTP with Effect `HttpClient`
- `TESTING.md` — Effect tests, `TestClock`, deterministic synchronization

### `effect-service-design`
A step-by-step method for deciding whether something should be an Effect service or stay a plain value, where the authority seam belongs, and how to shape the module (tag, interface, `make`, production `layer`, test `layer`). Includes [`references/AUDIT.md`](effect-service-design/references/AUDIT.md) for the codebase-audit branch.

### `find-issues`
Searches a repo's existing GitHub issues via `gh` for ones matching a query, defaulting to the current repo's `origin` remote. Tries multiple phrasings and checks each candidate for a real match (title, error text, functionality) before reporting.

### `herdr`
Wraps the `herdr` CLI for coordinating multiple agents and terminals: split panes, start named agents, submit prompts and wait on lifecycle state (`idle`/`working`/`blocked`/`done`), and read pane output. Guards on `HERDR_ENV=1` so it never touches a session from outside Herdr.

### `learn`
Reviews the current session for non-obvious, durable discoveries (hidden relationships, misleading error messages, quirky workarounds, architectural constraints) and writes them into the nearest relevant `AGENTS.md` — root, package, or feature level — rather than one project-wide file.

### `noteday`
Upserts today's entry in the Notion "Daily Log" database — verifies the target workspace, optionally pulls ticket activity from a connected issue tracker, drafts a one-paragraph summary, and creates or updates the row so there's no duplicate.

### `objfw`
A source-backed ObjFW coding guide that defaults application and library code to ARC with exception-safe unwinding, prefers matching class factories and designated initializers, and routes deeper guidance for API design, core types, I/O and run loops, testing, build integration, and portability through focused references.

### `pr-writer`
Drafts a PR title and body from the full commit range against the base branch, not just the latest commit — always following the repo's `.github/pull_request_template.md` when one exists, since PR structure should match repo convention rather than a fixed default. Presents the draft rather than running `gh pr create` or pushing.

### `release-notes`
Drafts release notes from a commit or tag range, preferring PR titles/labels over raw commit messages when available, and categorizing into Features / Fixes / Breaking Changes / Other. Matches an existing `CHANGELOG.md` format if present; presents the draft rather than writing or publishing it.

### `review-pass`
A checklist-driven review of a diff, branch, or PR across correctness, security, simplification, and test coverage. Verifies each candidate finding against the actual code before reporting, so findings come with a concrete file/line and failure scenario rather than vague impressions.

### `yeetslop`
Diffs the current branch against its base and strips out AI-generated slop: inconsistent comments, abnormal defensive checks/try-catch around trusted codepaths, `any` casts used to dodge type errors, style mismatches, and stray emoji — verifying each candidate against the file's actual style before removing it. Reports with only a 1–3 sentence summary. Invoked explicitly rather than chosen by the model.

## Installing

[`scripts/install-skills.sh`](scripts/install-skills.sh) copies every `*/SKILL.md` folder into your agent skills directory (default `~/.dotfiles/home/.agents/skills`, override with `SKILLS_DEST`):

```bash
./scripts/install-skills.sh
# or
SKILLS_DEST=~/.claude/skills ./scripts/install-skills.sh
```

Each skill is copied as a self-contained folder with its `.git` stripped.

## License

[MIT](LICENSE)
