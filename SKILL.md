---
name: memory
description: >-
  Persistent project memory for AI coding agents. Maintains 4 markdown files
  that survive between sessions. Use when the user says "memory init",
  "memory update", "memory status", "memory compact", "memory purge",
  "memory search", "memory diff", "initialize memory", "update memory",
  or "check memory status".
version: 1.0.0
---

# memory — Project Memory

Lightweight session memory using markdown files. Captures what code can't tell you: decisions, intent, gotchas, and handoff state.

## Memory Files

| File | Purpose | Budget | Loading |
|------|---------|--------|---------|
| `HANDOFF.md` | Current state, next steps, session gotchas | 80 lines | Auto — every session |
| `SCOPE.md` | Project identity, boundaries, conventions | 80 lines | Auto — every session |
| `SYSTEM.md` | Architecture, components, constraints, gotchas | 80 lines | On demand |
| `DECISIONS.md` | Decision log with reasoning, prepend-only | 120 lines | On demand |

## Commands

| Command | What it does |
|---------|-------------|
| `init [description]` | Create `.memory/` with populated files |
| `update` | Refresh HANDOFF, append new decisions |
| `status` | Quick health check on memory freshness |
| `compact` | Suggest compressions, user approves each |
| `purge` | Delete `.memory/` and clean agent config |

Inline (no separate spec needed):
- `search <query>` — run `grep -ri "<query>" .memory/` and show results
- `diff` — run `git diff -- .memory/` and show results

## Rules

1. **Don't store what's derivable.** If `git log`, `grep`, or reading code answers it — skip it.
2. **HANDOFF.md is ephemeral.** Rewrite it fully each update — it's a snapshot, not a log.
3. **DECISIONS.md is prepend-only.** Newest first. Never edit past entries.
4. **SCOPE.md is stable.** Update only when project direction genuinely changes.
5. **Keep it tiny.** Prune aggressively. If a file is near budget, run `compact`.

## Routing

1. Parse the user's message for a command keyword: `init`, `update`, `status`, `compact`, `purge`, `search`, `diff`.
2. If no command recognized, show the commands table and ask.
3. For `search`: run `grep -ri "<query>" .memory/` directly. No spec file needed.
4. For `diff`: run `git diff -- .memory/` directly. No spec file needed.
5. For all other commands: verify `.memory/` exists (except `init`). If missing, say "No memory found. Run init."
6. Read and execute the corresponding spec:
   - `init` → `references/cmd-init.md`
   - `update` → `references/cmd-update.md`
   - `status` → `references/cmd-status.md`
   - `compact` → `references/cmd-compact.md`
   - `purge` → `references/cmd-purge.md`
