# memory

[![GitHub tag](https://img.shields.io/github/v/tag/spiderpunklabs/memory?label=version)](https://github.com/spiderpunklabs/memory/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/spiderpunklabs/memory/blob/main/LICENSE)

Persistent project memory for AI coding agents. Four markdown files that capture what code can't tell you.

Works with **Claude Code**, **Codex**, **Cursor**, and any agent that reads SKILL.md.

## Why

AI agents lose context between sessions. They re-discover gotchas, re-make decisions, and ask the same questions. Memory fixes this with four small files:

- **HANDOFF.md** — Where we left off and what's next
- **SCOPE.md** — What this project is and isn't
- **SYSTEM.md** — How the system works, constraints, gotchas
- **DECISIONS.md** — Why things are the way they are

Only HANDOFF and SCOPE auto-load each session (~160 lines). SYSTEM and DECISIONS load on demand.

## Install

```bash
npx skills add spiderpunklabs/memory
```

Or manually:
```bash
git clone https://github.com/spiderpunklabs/memory.git ~/.claude/skills/memory
```

## Usage

| When | Do |
|------|----|
| Start of project | `/memory init` — scans and populates memory |
| End of session | `/memory update` — refreshes handoff, records decisions |
| Quick check | `/memory status` — freshness and budget report |
| Files getting large | `/memory compact` — guided compression with approval |
| Find something | `/memory search <query>` |
| See what changed | `/memory diff` |
| Clean up | `/memory purge` — deletes memory and cleans config |

## The Rule

**Don't store what's derivable.** If git log, grep, or reading the code answers it, don't put it in memory. Memory is for intent, reasoning, and state that lives in your head — not in the repo.

## Memory Files

| File | Budget | Auto-loaded | Updated |
|------|--------|-------------|---------|
| HANDOFF.md | 80 lines | Yes | Every session (full rewrite) |
| SCOPE.md | 80 lines | Yes | Rarely (when direction changes) |
| SYSTEM.md | 80 lines | On demand | When architecture changes |
| DECISIONS.md | 120 lines | On demand | When decisions are made |

## Best Practices

- **HANDOFF is disposable.** Rewrite it completely each session. It's today's sticky note.
- **DECISIONS are sacred.** Never edit past entries. If reversed, add a new entry explaining why.
- **SCOPE is stable.** Touch it only when the project's direction genuinely shifts.
- **Keep files short.** If approaching budget, run `/memory compact` for guided compression.
- **Commit memory files.** They're part of the project. Other agents and contributors benefit.

## What NOT to Store

- Dependency lists, build commands (read package.json/Makefile)
- File locations, directory structure (use grep/find)
- Code summaries (read the code)
- Change history (read git log)
- TODO lists (use issues/tickets)

## Compatibility

Works with any agent that can read markdown:
- **Claude Code** — `@` imports in CLAUDE.md
- **Codex** — file path references in AGENTS.md
- **Cursor** — file references in .cursorrules
- **Any other agent** — point it at `.memory/`

## License

MIT — SpiderPunk Labs
