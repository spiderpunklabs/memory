---
name: memory
description: >-
  Persistent project memory for AI coding agents. Maintains 5 structured markdown
  files (project context, active state, system patterns, tech context, decisions)
  that survive between sessions. Use when the user says "memory init",
  "memory update", "memory status", "memory export", "memory ignore",
  "memory track", "memory purge", "memory search", "memory diff",
  "memory restore", "memory compact", "memory hook",
  "initialize memory bank", "setup memory bank",
  "create memory bank", "update memory bank", "check memory status",
  or "update project context".
version: 0.3.0
---

# memory — Project Memory Bank

Manage a structured, file-based memory bank that persists project context across AI coding agent sessions. Works with Claude Code, Codex, Cursor, and any agent that reads SKILL.md.

## Subcommand Router

Determine the subcommand from the user's message. Match the first recognized keyword after the skill invocation (or from natural language triggers like "initialize memory bank").

### Available Subcommands

| Command | Purpose |
|---------|---------|
| `init [description]` | Initialize a new memory bank in the current project |
| `update` | Update memory bank files with current project state |
| `status` | Health check — completeness, consistency, staleness |
| `export` | Consolidate all files into a single markdown document |
| `ignore` | Add `memory-bank/` to `.gitignore` |
| `track` | Remove `memory-bank/` from `.gitignore` |
| `purge` | Delete memory bank and remove agent config imports |
| `search <query>` | Search across all memory bank files for a keyword |
| `diff` | Show what changed in memory bank files since last commit |
| `restore [source]` | Restore memory bank from backup, archive, or git commit |
| `compact` | Interactive guided compression of memory bank files |
| `hook` | Install pre-commit hook for memory bank validation |

### Routing Logic

1. Parse the user's message for a subcommand keyword: `init`, `update`, `status`, `export`, `ignore`, `track`, `purge`, `search`, `diff`, `restore`, `compact`, `hook`.
2. If no subcommand is recognized, display the help table above and ask the user which operation they want.
3. Check preconditions:
   - For `init`: proceed directly (init handles its own edge cases including reinitialize).
   - For all other commands: verify `memory-bank/` exists in the current working directory. If it does not exist, tell the user: "No memory bank found. Run the init command to create one."
4. Read the corresponding reference file and execute its instructions:
   - `init` → Read `references/commands/init.md` and execute its instructions.
   - `update` → Read `references/commands/update.md` and execute its instructions.
   - `status` → Read `references/commands/status.md` and execute its instructions.
   - `export` → Read `references/commands/export.md` and execute its instructions.
   - `ignore` → Read `references/commands/ignore.md` and execute its instructions.
   - `track` → Read `references/commands/track.md` and execute its instructions.
   - `purge` → Read `references/commands/purge.md` and execute its instructions.
   - `search` → Read `references/commands/search.md` and execute its instructions.
   - `diff` → Read `references/commands/diff.md` and execute its instructions.
   - `restore` → Read `references/commands/restore.md` and execute its instructions.
   - `compact` → Read `references/commands/compact.md` and execute its instructions.
   - `hook` → Read `references/commands/hook.md` and execute its instructions.

### Natural Language Triggers

Map these phrases to subcommands:

- "initialize memory bank", "setup memory bank", "create memory bank" → `init`
- "update memory bank", "refresh memory", "update project context" → `update`
- "check memory status", "memory health", "validate memory" → `status`
- "export memory", "consolidate memory" → `export`
- "ignore memory bank", "gitignore memory" → `ignore`
- "track memory bank", "unignore memory" → `track`
- "purge memory bank", "purge memory" → `purge` (requires explicit use of the word "purge" — do not trigger from "delete" or "remove")
- "search memory", "find in memory", "memory search" → `search`
- "memory diff", "what changed in memory" → `diff`
- "restore memory", "recover memory bank" → `restore`
- "compact memory", "compress memory bank" → `compact`
- "install memory hook", "memory hook", "setup pre-commit" → `hook`
