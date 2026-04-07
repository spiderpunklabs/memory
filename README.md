# memory

[![GitHub tag](https://img.shields.io/github/v/tag/spiderpunklabs/memory?label=version)](https://github.com/spiderpunklabs/memory/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/spiderpunklabs/memory/blob/main/LICENSE)

A structured project memory bank for AI coding agents. Persists project context across sessions using 5 markdown files loaded via agent config imports.

Works with **Claude Code**, **Codex**, **Cursor**, and any agent that reads SKILL.md.

## Why

AI coding agents lose context between sessions. This skill solves that by maintaining 5 structured markdown files that capture your project's context, active state, system patterns, tech constraints, and decisions. These files are loaded automatically at the start of each session via your agent's config file.

**No databases. No vector stores. No MCP servers.** Just markdown files and `@imports`.

**Guiding principle**: Only store what cannot be derived from code. Memory routes agents to the right code and explains WHY, never summarizes WHAT code does.

## Install

```bash
# Using npx skills (recommended)
npx skills add spiderpunklabs/memory

# Or manually (use your agent's skills directory)
# Claude Code
git clone https://github.com/spiderpunklabs/memory.git ~/.claude/skills/memory
# Codex
git clone https://github.com/spiderpunklabs/memory.git ~/.codex/skills/memory
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
| `status` | Strict validation — 47 checks with severity tiers |
| `export` | Consolidate all files into a single markdown document |
| `ignore` | Add `memory-bank/` to `.gitignore` |
| `track` | Remove `memory-bank/` from `.gitignore` |
| `purge` | Delete memory bank and remove agent config imports |
| `search <query>` | Search across all memory bank files |
| `diff` | Show changes to memory bank since last commit |
| `restore [source]` | Restore from backup, archive, or git commit |
| `compact` | Interactive guided compression of memory files |
| `hook` | Install pre-commit hook for validation |

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
/memory search <query>
/memory diff
/memory restore
/memory compact
/memory hook
```

### Initialize a memory bank

```
/memory init
```

Scans your project for README, manifests, directory structure, source files, and git history, then creates 5 populated files in `memory-bank/`. Also updates your agent config (`CLAUDE.md`, `AGENTS.md`, etc.) with import references.

For empty projects, provide a description:

```
/memory init A React Native fitness app with Expo and Supabase
```

### Update after work

```
/memory update
```

Re-scans git history and project state. Updates `activeState.md` and any other files that need refreshing. Automatically migrates v0.2.8 memory banks (7 files) to v0.2.10 format (5 files).

### Check health

```
/memory status
```

Strict validator — runs 47 checks with severity tiers (BLOCKING/WARNING/INFO) covering file structure, derivability gate, section headings, evidence anchors, confidence markers, and content specificity. Final line: `STATUS: ALL CHECKS PASSED` or `STATUS: N FAILURES DETECTED`.

### Export

```
/memory export
```

Consolidates all 5 files into a single markdown document for sharing or backup. Use `--redacted` to strip internal paths and active state for external sharing.

## Full Lifecycle

```
init → [update → status]* → compact → [update → status]* → purge
         ↑                                    ↑
         └── search / diff / restore ─────────┘
```

| When | Command |
|------|---------|
| Starting a project | `init` (once) |
| After each work session | `update` |
| Before important decisions | `status` (validate health) |
| When files approach ceilings | `compact` (guided compression) |
| To see what changed | `diff` |
| To find specific decisions | `search <query>` |
| To share context | `export` (or `export --redacted`) |
| To recover from mistakes | `restore` |
| To enable commit validation | `hook` |
| To clean up | `purge` (irreversible after archive deletion) |

## Shell Script Validator

The project includes an optional POSIX shell script (`references/scripts/memory-bank-validate.sh`) that deterministically validates 40 of 47 checks plus secret detection. The remaining 4 checks (#17, #43, #44, #45) are heuristic and require LLM judgment via `memory status`.

Install the pre-commit hook with `memory hook` to automatically validate memory bank files before each commit. The hook validates the staged index (not the working tree) and fails closed if the validator is not found.

Run the acceptance test suite: `./references/scripts/memory-bank-test.sh`

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
$memory search <query>
$memory diff
$memory restore
$memory compact
$memory hook
```

Examples:

```
$memory init A Go microservice with gRPC and PostgreSQL
$memory update
$memory status
$memory search billing
$memory diff
$memory compact
```

Codex can also invoke the skill implicitly via natural language:

- "initialize memory bank"
- "update memory bank"
- "check memory status"
- "export memory bank"
- "search memory for billing"
- "what changed in memory"
- "restore memory bank"
- "compress memory bank"
- "install memory hook"

## Memory Bank Files

| File | Type | Purpose | Budget |
|------|------|---------|--------|
| `projectContext.md` | Essential | Project identity, purpose, scope, requirements | 80 lines |
| `activeState.md` | Essential | Session handoff: next action, working set, blockers | 70 lines |
| `systemPatterns.md` | Warm | Architecture, design decisions, component relationships, gotchas | 100 lines |
| `techContext.md` | Warm | Non-obvious technical constraints, setup gotchas | 60 lines |
| `decisions.md` | Warm | Key decisions, rejected alternatives, intentional patterns | 150 lines |
| **Total** | | | **460 lines** |

**Essential files** (projectContext + activeState) are auto-loaded every session. Budget: 150 lines combined.

**Warm files** are loaded on demand when the task requires them.

## Recommended: Auto-init prompt

Add this to your agent config file (`~/.claude/CLAUDE.md` for Claude Code, `AGENTS.md` for Codex) so your agent suggests initializing a memory bank in new projects:

```markdown
## Memory Bank
At the start of any session, if no `memory-bank/` directory exists in the current
project, suggest running `/memory init` (or `$memory init` in Codex).
```

## How it works

1. **`init`** scans your project and creates `memory-bank/` with 5 structured files using copy-then-edit templates
2. The init step adds 2 essential file imports to your agent config (e.g., `CLAUDE.md`)
3. At the start of each session, your agent loads the 2 essential files automatically and reads the 3 warm files on demand as the task requires
4. **`update`** refreshes the files based on git history and current state, with derivability gate enforcement, drift checking, and evidence validation
5. **`status`** runs 47 checks with severity tiers (BLOCKING/WARNING/INFO) covering structure, derivability, evidence, specificity, and security
6. Context persists across sessions — no re-explaining your project

### Derivability gate

Memory only stores what cannot be derived from code. The following are **prohibited** in memory files:

- Build/dev command tables (use `cat Makefile` or `cat package.json`)
- Dependency lists (use `cat package.json` or `cat go.mod`)
- Infrastructure inventory (check for `.github/workflows/`, `Dockerfile`, etc.)
- Naming conventions, data flow, error handling (read the code)
- Evolution logs, completed work, recent changes (use `git log`)
- Code summaries (read the code)

## Agent compatibility

The skill auto-detects which agent is running and adapts:

- **Claude Code** — writes to `CLAUDE.md` using `@memory-bank/file.md` import syntax
- **Codex** — writes to `AGENTS.md` with plain file path references
- **Other agents** — uses `AGENTS.md` or the agent's convention

The memory bank files themselves are plain markdown — readable by any tool.

## File structure

```
~/<agent>/skills/memory/
├── SKILL.md                      # Skill definition and subcommand router
├── LICENSE                       # MIT
├── README.md
└── references/
    ├── agent-config-snippet.md    # Config snippet injected into agent config
    ├── commands/
    │   ├── init.md               # Initialize memory bank
    │   ├── update.md             # Update memory bank
    │   ├── status.md             # Strict validation (47 checks)
    │   ├── export.md             # Export to single doc
    │   ├── ignore.md             # Gitignore memory bank
    │   ├── track.md              # Un-gitignore memory bank
    │   ├── purge.md              # Delete everything
    │   ├── search.md             # Search across memory files
    │   ├── diff.md               # Show memory bank changes
    │   ├── restore.md            # Restore from backup/git
    │   ├── compact.md            # Interactive guided compression
    │   └── hook.md               # Install pre-commit hook
    ├── scripts/
    │   ├── memory-bank-validate.sh  # POSIX validator (40/47 checks + secrets)
    │   ├── memory-bank-hook.sh      # Pre-commit hook (fail-closed)
    │   └── memory-bank-test.sh      # Acceptance test suite (12 tests)
    └── templates/
        ├── projectContext.md
        ├── activeState.md
        ├── systemPatterns.md
        ├── techContext.md
        └── decisions.md
```

## Best practices

- **Store intent, not implementation** — memory captures decisions, constraints, handoff state, and hard-won conclusions. Code supplies implementation truth. If `rg` can answer it in 10 seconds, don't store it.
- **Update after each session** — run the update command before ending a session where significant work was done
- **activeState.md is a handoff, not a diary** — rewrite it each update as a briefing for the next session
- **Essential files have a hard budget** — `projectContext.md` + `activeState.md` must stay under 150 lines combined. The status command enforces this.
- **Total budget: 460 lines** — all 5 files combined. No file may exceed its individual ceiling.
- **Only 5 files** — do not create additional files in `memory-bank/`. If content doesn't fit, compress.
- **Add evidence to non-obvious claims** — in warm files (decisions, systemPatterns, techContext), include a `Source:` line and confidence markers (`[observed]`, `[inferred]`, `[assumed]`). The status command validates these.
- **decisions.md is append-only** — never remove entries without user approval. Superseded decisions can be compacted to a 1-line format via `memory compact`, but only with explicit user confirmation. Every decision includes Scope, Status, and Source fields
- **Every decision implies a rejected alternative** — document what was considered and why it was rejected

## Design

The structured memory bank concept is inspired by [Cline](https://docs.cline.bot/features/memory-bank)'s Memory Bank — a community-driven approach to persistent AI context using markdown files and custom instructions. This skill adapts that concept into a cross-agent skill that works with Claude Code, Codex, Cursor, Windsurf, GitHub Copilot, and any agent that supports the Agent Skills specification.

The decision log and session summary features draw from [OpenViking](https://github.com/anthropics/openviking)'s memory categories (events, cases, patterns) and structured session commits. Adapted here for zero-dependency markdown files targeting individual developers.

## License

MIT — SpiderPunk Labs
