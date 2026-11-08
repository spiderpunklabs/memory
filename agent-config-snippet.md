# Agent Config — Memory Integration

Append the appropriate section to your agent's config file during init.

Every injected block is bracketed by `<!-- memory:begin v=1.0.0 -->` / `<!-- memory:end -->` markers. Init replaces any pre-existing block bounded by these markers; purge removes only content between them. Do not edit text inside the markers by hand — re-init will overwrite it.

## Claude Code / Codex (AGENTS.md)

One block serves both agents. Never write it to `CLAUDE.md`: a `CLAUDE.md` in the repo makes Claude Code ignore `AGENTS.md`.

```markdown
<!-- memory:begin v=1.0.0 -->
# Project Memory

## Always read at session start
- .memory/HANDOFF.md — current state, next steps, session gotchas
- .memory/SCOPE.md — project identity, boundaries, conventions

## Read on demand (only when the task requires them)
- .memory/SYSTEM.md — when changing architecture, adding components, or hitting non-obvious constraints
- .memory/DECISIONS.md — when making a design choice, evaluating alternatives, or introducing a new pattern

Update .memory/HANDOFF.md before ending sessions where significant work was done (Claude Code: run /memory update).
<!-- memory:end -->
```

## Cursor (`.cursor/rules/memory.mdc` preferred; `.cursorrules` legacy)

Write to `.cursor/rules/memory.mdc` if a `.cursor/` directory exists (modern Cursor rules format). Otherwise fall back to `.cursorrules` (legacy single-file format). Both target files use the same body:

```markdown
<!-- memory:begin v=1.0.0 -->
# Project Memory

Always read .memory/HANDOFF.md and .memory/SCOPE.md before starting work.
Consult .memory/SYSTEM.md for architecture and .memory/DECISIONS.md when making design choices.
After significant work, update .memory/HANDOFF.md with current state and next steps.
<!-- memory:end -->
```
