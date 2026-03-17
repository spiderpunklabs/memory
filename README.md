# memory

[![GitHub tag](https://img.shields.io/github/v/tag/spiderpunklabs/memory?label=version)](https://github.com/spiderpunklabs/memory/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/spiderpunklabs/memory/blob/main/LICENSE)

A structured project memory bank for AI coding agents. Persists project context across sessions using 7 markdown files loaded via agent config imports.

Works with **Claude Code**, **Codex**, **Cursor**, and any agent that reads SKILL.md.

## Why

AI coding agents lose context between sessions. This skill solves that by maintaining 7 structured markdown files that capture your project's brief, product context, system patterns, tech stack, active focus, progress, and decisions. These files are loaded automatically at the start of each session via your agent's config file.

**No databases. No vector stores. No MCP servers.** Just markdown files and `@imports`.

## Install

```bash
# Using npx skills (recommended)
npx skills add spiderpunklabs/memory

# Or manually
git clone https://github.com/spiderpunklabs/memory.git ~/.claude/skills/memory
```

### Multi-agent install

```bash
# Install for specific agents
npx skills add spiderpunklabs/memory -a claude-code
npx skills add spiderpunklabs/memory -a codex
npx skills add spiderpunklabs/memory -a claude-code -a codex -a cursor
```

### Upgrade

Re-run the install command to pull the latest version:

```bash
npx skills add spiderpunklabs/memory
```

## Subcommands

| Command | Purpose |
|---------|---------|
| `init [description]` | Initialize a new memory bank in the current project |
| `update` | Update memory bank files with current project state |
| `status` | Health check — completeness, consistency, staleness |
| `export` | Consolidate all files into a single markdown document |
| `ignore` | Add `memory-bank/` to `.gitignore` |
| `track` | Remove `memory-bank/` from `.gitignore` |
| `purge` | Delete memory bank and remove agent config imports |

## Claude Code

Claude Code invokes skills using slash command syntax — prefix any subcommand with `/memory`:

```
/memory init
/memory update
/memory status
/memory export
/memory ignore
/memory track
/memory purge
```

### Initialize a memory bank

```
/memory init
```

Scans your project for README, package.json, directory structure, etc. and creates 7 populated files in `memory-bank/`. Also updates your agent config (`CLAUDE.md`, `AGENTS.md`, etc.) with import references.

For empty projects, provide a description:

```
/memory init A React Native fitness app with Expo and Supabase
```

### Update after work

```
/memory update
```

Re-scans git history, recent changes, and project state. Updates `activeContext.md`, `progress.md`, and any other files that need refreshing.

### Check health

```
/memory status
```

Read-only report showing completeness, staleness, and cross-file consistency.

### Export

```
/memory export
```

Consolidates all 7 files into a single markdown document for sharing or backup.

## Codex

Codex uses `$` prefix syntax for custom skill invocation — prefix any subcommand with `$memory`:

```
$memory init
$memory update
$memory status
$memory export
$memory ignore
$memory track
$memory purge
```

Examples:

```
$memory init A Go microservice with gRPC and PostgreSQL
$memory update
$memory status
```

Codex can also invoke the skill implicitly via natural language:

- "initialize memory bank"
- "update memory bank"
- "check memory status"
- "export memory bank"

## Memory Bank Files

| File | Purpose | Change frequency |
|------|---------|-----------------|
| `projectBrief.md` | Core requirements, scope, stakeholders | Rarely |
| `productContext.md` | Why the project exists, audience, UX goals | Occasionally |
| `systemPatterns.md` | Architecture, design patterns, conventions | When architecture changes |
| `techContext.md` | Tech stack, dependencies, build setup | When deps/infra change |
| `activeContext.md` | Current focus, open questions, next steps | Every session |
| `progress.md` | What's done, in progress, remaining, issues | Every session |
| `decisions.md` | Decisions made, alternatives rejected, project-specific learnings | When decisions are made |

## Recommended: Auto-init prompt

Add this to your agent config file (`~/.claude/CLAUDE.md` for Claude Code, `AGENTS.md` for Codex) so your agent suggests initializing a memory bank in new projects:

```markdown
## Memory Bank
At the start of any session, if no `memory-bank/` directory exists in the current
project, suggest running `/memory init` (or `$memory init` in Codex).
```

## How it works

1. **`init`** scans your project and creates `memory-bank/` with 7 structured files
2. The init step adds essential file imports to your agent config (e.g., `CLAUDE.md`)
3. At the start of each session, your agent loads the 2 essential files automatically and reads the other 5 on demand as the task requires
4. **`update`** refreshes the files based on git history and current state
5. Context persists across sessions — no re-explaining your project

## Agent compatibility

The skill auto-detects which agent is running and adapts:

- **Claude Code** — writes to `CLAUDE.md` using `@memory-bank/file.md` import syntax
- **Codex** — writes to `AGENTS.md` with plain file path references
- **Other agents** — uses `AGENTS.md` or the agent's convention

The memory bank files themselves are plain markdown — readable by any tool.

## File structure

```
~/.claude/skills/memory/          (or wherever your agent loads skills from)
├── SKILL.md                      # Skill definition and subcommand router
├── LICENSE                       # MIT
├── README.md
└── references/
    ├── agent-config-snippet.md    # Config snippet injected into agent config
    ├── commands/
    │   ├── init.md               # Initialize memory bank
    │   ├── update.md             # Update memory bank
    │   ├── status.md             # Health check
    │   ├── export.md             # Export to single doc
    │   ├── ignore.md             # Gitignore memory bank
    │   ├── track.md              # Un-gitignore memory bank
    │   └── purge.md              # Delete everything
    └── templates/
        ├── projectBrief.md
        ├── productContext.md
        ├── systemPatterns.md
        ├── techContext.md
        ├── activeContext.md
        ├── progress.md
        └── decisions.md
```

## Best practices

- **Store intent, not implementation** — memory captures decisions, constraints, handoff state, and hard-won conclusions. Code supplies implementation truth. If `rg` can answer it in 10 seconds, don't store it.
- **Update after each session** — run the update command before ending a session where significant work was done
- **activeContext.md is a handoff, not a diary** — rewrite it each update as a briefing for the next session. If it reads like a timeline, compress it.
- **Essential files have a budget** — `projectBrief.md` + `activeContext.md` should stay under ~150 lines combined (~2,000 tokens). The status command checks this.
- **Keep all files concise** — each file should stay under 200 lines; the update command consolidates automatically
- **Let structure evolve** — start with the 7 core files; add additional context files only when a topic outgrows its section
- **projectBrief.md is the foundation** — get this right first; other files build on it
- **Add evidence to non-obvious claims** — in warm files (decisions, systemPatterns, techContext, productContext, progress), optionally include a `Source:` line pointing to the file, commit, or PR that supports the claim. The status command verifies these.
- **decisions.md is append-only** — never remove entries; include scope and status to help future agents know when a decision applies
- **Review progress.md when resuming** — it's the fastest way to remember where you left off

## Design

The structured memory bank concept is inspired by [Cline](https://docs.cline.bot/features/memory-bank)'s Memory Bank — a community-driven approach to persistent AI context using markdown files and custom instructions. This skill adapts that concept into a cross-agent skill that works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and any agent that supports the Agent Skills specification.

The decision log and session summary features draw from [OpenViking](https://github.com/anthropics/openviking)'s memory categories (events, cases, patterns) and structured session commits. Adapted here for zero-dependency markdown files targeting individual developers.

## License

MIT — SpiderPunk Labs
