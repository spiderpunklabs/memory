# Memory Bank

This project uses a memory bank for persistent context across sessions.
Always read the memory bank at the start of every task.

## Memory Bank Files

The following files contain project context and should be loaded at the start of every conversation:

- `memory-bank/projectbrief.md`
- `memory-bank/productContext.md`
- `memory-bank/systemPatterns.md`
- `memory-bank/techContext.md`
- `memory-bank/activeContext.md`
- `memory-bank/progress.md`
- `memory-bank/decisions.md`

> **Agent-specific loading:** Claude Code uses `@memory-bank/filename.md` imports for
> auto-loading. Other agents (Codex, Cursor, etc.) should read these files directly at
> the start of each session.

## Memory Bank Rules

- **Read all memory bank files** at the start of every conversation or task
- **Update memory bank** after completing significant work (use the update command)
- `activeContext.md` and `progress.md` change most frequently
- `projectbrief.md` is the foundational document — other files build on it
- Never remove information from memory bank files without explicit instruction
- **Before ending a session** where significant work was done, suggest running the update command
- **When a decision is made or an approach is rejected**, log it in `decisions.md` (append-only — never remove entries)
