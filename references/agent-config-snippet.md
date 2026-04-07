<!-- MEMORY-BANK-START -->
@memory-bank/projectContext.md
@memory-bank/activeState.md

# Memory Bank

This project uses a memory bank for persistent context across sessions.

## Essential Files (auto-loaded)

These 2 files are loaded automatically at the start of every conversation:

- `memory-bank/projectContext.md` — project identity, purpose, scope
- `memory-bank/activeState.md` — current focus, next steps, working set

> **Budget**: Essential files must stay under 150 lines combined.

> **Agent-specific loading:** Claude Code uses `@memory-bank/filename.md` imports for
> auto-loading. Other agents (Codex, Cursor, etc.) should read these files directly at
> the start of each session.

## Warm Files (load on demand)

Read these files ONLY when the current task directly requires them. NEVER pre-emptively read all warm files.

- `memory-bank/systemPatterns.md`
  Load when: changing architecture, adding components, or modifying cross-file relationships

- `memory-bank/techContext.md`
  Load when: encountering build/setup issues or adding new technology

- `memory-bank/decisions.md`
  Load when: making a design choice, evaluating alternatives, or about to introduce a new pattern

## Rules

- **Read essential files** at the start of every conversation (auto-loaded)
- **Read warm files** only when the task matches their Load when trigger above
- **Update memory bank** after completing significant work (use the update command)
- **When a decision is made or an approach is rejected**, log it in `decisions.md` (append-only — never remove entries)
- **Before ending a session** where significant work was done, suggest running the update command
- The `memory-bank/` directory contains exactly 5 core files — do not create additional files in it
<!-- MEMORY-BANK-END -->
