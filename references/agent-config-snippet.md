# Memory Bank

This project uses a memory bank for persistent context across sessions.
Always read the memory bank at the start of every task.

## Memory Bank Files

### Essential (loaded every session)

These files are loaded automatically at the start of every conversation:

- `memory-bank/projectBrief.md` — foundation: what this project is
- `memory-bank/activeContext.md` — current focus, recent changes, next steps

> **Budget**: Essential files should stay under ~150 lines combined. If they grow beyond this, compress during the next update.

> **Agent-specific loading:** Claude Code uses `@memory-bank/filename.md` imports for
> auto-loading. Other agents (Codex, Cursor, etc.) should read these files directly at
> the start of each session.

### On-demand (loaded when relevant)

Read these files when the task touches their domain — do not load them all at session start:

- `memory-bank/productContext.md` — read when working on UX, product goals, or user flows
- `memory-bank/systemPatterns.md` — read when working on architecture, design patterns, or component relationships
- `memory-bank/techContext.md` — read when working on dependencies, build setup, infrastructure, or dev tooling
- `memory-bank/progress.md` — read when checking status, planning next work, or resuming after a break
- `memory-bank/decisions.md` — read when making architectural or design decisions, or when considering approaches that may have been previously rejected

## Memory Bank Rules

- **Read essential memory bank files** at the start of every conversation or task
- **Read on-demand files** when the task touches their domain
- **Update memory bank** after completing significant work (use the update command)
- **When you discover new project patterns**, update `systemPatterns.md` and `decisions.md` immediately — don't wait for end of session
- **When context seems unclear or stale**, suggest running the update command to refresh
- `activeContext.md` and `progress.md` change most frequently
- `projectBrief.md` is the foundational document — other files build on it
- Never remove information from memory bank files without explicit instruction
- **Before ending a session** where significant work was done, suggest running the update command
- **When a decision is made or an approach is rejected**, log it in `decisions.md` (append-only — never remove entries)

## Additional Context

For complex projects, create additional files or folders within `memory-bank/` when they help organize:
- Complex feature documentation
- Integration specifications
- API documentation
- Testing strategies
- Deployment procedures

These are optional — the 7 core files are sufficient for most projects. Only create additional files when the core files become unwieldy or when a topic needs its own dedicated document.
