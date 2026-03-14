---
name: memory
description: >-
  Manage a structured project memory bank. This skill should be used when the
  user says "memory init", "memory update", "memory status", "memory export",
  "memory hide", "memory unhide", "memory purge", "initialize memory bank",
  "setup memory bank", "create memory bank", "update memory bank",
  "check memory status", or "update project context".
version: 0.1.0
---

# /memory — Project Memory Bank

Manage a structured, file-based memory bank that persists project context across AI coding agent sessions. Works with Claude Code, Codex, Cursor, and any agent that reads SKILL.md.

## Subcommand Router

Determine the subcommand from the user's message. Match the first recognized keyword after `/memory` (or from natural language triggers like "initialize memory bank").

### Available Subcommands

| Command | Purpose |
|---------|---------|
| `/memory init [description]` | Initialize a new memory bank in the current project |
| `/memory update` | Update memory bank files with current project state |
| `/memory status` | Health check — completeness, consistency, staleness |
| `/memory export` | Consolidate all files into a single markdown document |
| `/memory hide` | Add `memory-bank/` to `.gitignore` |
| `/memory unhide` | Remove `memory-bank/` from `.gitignore` |
| `/memory purge` | Delete memory bank and remove agent config imports |

### Routing Logic

1. Parse the user's message for a subcommand keyword: `init`, `update`, `status`, `export`, `hide`, `unhide`, `purge`.
2. If no subcommand is recognized, display the help table above and ask the user which operation they want.
3. Check preconditions:
   - For `init`: proceed directly (init handles its own edge cases including reinitialize).
   - For all other commands: verify `memory-bank/` exists in the current working directory. If it does not exist, tell the user: "No memory bank found. Run `/memory init` to create one."
4. Read the corresponding reference file and execute its instructions:
   - `init` → Read `references/commands/init.md` and execute its instructions.
   - `update` → Read `references/commands/update.md` and execute its instructions.
   - `status` → Read `references/commands/status.md` and execute its instructions.
   - `export` → Read `references/commands/export.md` and execute its instructions.
   - `hide` → Read `references/commands/hide.md` and execute its instructions.
   - `unhide` → Read `references/commands/unhide.md` and execute its instructions.
   - `purge` → Read `references/commands/purge.md` and execute its instructions.

### Natural Language Triggers

Map these phrases to subcommands:

- "initialize memory bank", "setup memory bank", "create memory bank" → `init`
- "update memory bank", "refresh memory", "update project context" → `update`
- "check memory status", "memory health", "validate memory" → `status`
- "export memory", "consolidate memory" → `export`
- "hide memory bank", "gitignore memory" → `hide`
- "unhide memory bank", "track memory" → `unhide`
- "delete memory bank", "remove memory bank", "purge memory" → `purge`
