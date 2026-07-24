# skills

Ethan Morgan's personal [agent skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) — self-contained instruction packages that coding agents load on demand to handle a specific kind of task.

Each top-level folder is one skill, defined by a `SKILL.md` with YAML frontmatter (`name`, `description`, and optional fields like `model` or `disable-model-invocation`). An agent reads the `description` to decide when a skill is relevant, then follows the body. Some skills carry extra `references/` or `agents/` files that the body pulls in only when needed.

## Skills

| Skill | What it is |
| --- | --- |
| [`bro`](bro/) | Restates the agent's last message in plain, jargon-free language — one human talking to another. User-invoked only (`disable-model-invocation`). |
| [`effect`](effect/) | Opinionated guide for building production TypeScript with [Effect](https://effect.website) v4 — services, layers, schemas, config, schedules, caches, streams, HTTP clients, and tests. |
| [`effect-service-design`](effect-service-design/) | Designs or audits Effect **services**, treating each as an authority seam with a clear contract, production Layer, and honest test Layer. |
| [`herdr`](herdr/) | Drives Herdr, a terminal multiplexer for coding agents — inspect and control panes, tabs, and workspaces, run commands, and start/monitor agents. Requires `HERDR_ENV=1`. |
| [`noteday`](noteday/) | Logs the day's work (summary + tickets touched) to the personal Notion "Daily Log" database. Runs on Haiku; triggered by `/noteday`. |

### `bro`
Restate the previous message more simply and concisely, dropping jargon. Invoked explicitly rather than chosen by the model.

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

### `herdr`
Wraps the `herdr` CLI for coordinating multiple agents and terminals: split panes, start named agents, submit prompts and wait on lifecycle state (`idle`/`working`/`blocked`/`done`), and read pane output. Guards on `HERDR_ENV=1` so it never touches a session from outside Herdr.

### `noteday`
Upserts today's entry in the Notion "Daily Log" database — verifies the target workspace, optionally pulls ticket activity from a connected issue tracker, drafts a one-paragraph summary, and creates or updates the row so there's no duplicate.

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
