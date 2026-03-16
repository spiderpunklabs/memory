# /memory

A structured project memory bank for AI coding agents. Persists project context across sessions using 7 markdown files loaded via agent config imports.

Works with **Claude Code**, **Codex**, **Cursor**, and any agent that reads SKILL.md.

## Why

AI coding agents lose context between sessions. `/memory` solves this by maintaining 7 structured markdown files that capture your project's brief, product context, system patterns, tech stack, active focus, progress, and decisions. These files are loaded automatically at the start of each session via your agent's config file.

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

## Subcommands

| Command | Purpose |
|---------|---------|
| `/memory init [description]` | Initialize a new memory bank in the current project |
| `/memory update` | Update memory bank files with current project state |
| `/memory status` | Health check — completeness, consistency, staleness |
| `/memory export` | Consolidate all files into a single markdown document |
| `/memory hide` | Add `memory-bank/` to `.gitignore` |
| `/memory unhide` | Remove `memory-bank/` from `.gitignore` |
| `/memory purge` | Delete memory bank and remove agent config imports |

## Usage

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

## Memory Bank Files

| File | Purpose | Change frequency |
|------|---------|-----------------|
| `projectbrief.md` | Core requirements, scope, stakeholders | Rarely |
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
project, suggest running `/memory init`.
```

## How it works

1. **`/memory init`** scans your project and creates `memory-bank/` with 7 structured files
2. The init step adds `@import` references to your agent config (e.g., `CLAUDE.md`)
3. At the start of each session, your agent loads these files automatically
4. **`/memory update`** refreshes the files based on git history and current state
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
    ├── claudemd-snippet.md       # Config snippet injected into agent config
    ├── commands/
    │   ├── init.md               # Initialize memory bank
    │   ├── update.md             # Update memory bank
    │   ├── status.md             # Health check
    │   ├── export.md             # Export to single doc
    │   ├── hide.md               # Gitignore memory bank
    │   ├── unhide.md             # Un-gitignore memory bank
    │   └── purge.md              # Delete everything
    └── templates/
        ├── projectbrief.md
        ├── productContext.md
        ├── systemPatterns.md
        ├── techContext.md
        ├── activeContext.md
        ├── progress.md
        └── decisions.md
```

## Design

The decision log and session summary features are inspired by [OpenViking](https://github.com/anthropics/openviking)'s memory categories (events, cases, patterns) and structured session commits. Adapted here for zero-dependency markdown files targeting individual developers.

## License

MIT — SpiderPunk Labs
