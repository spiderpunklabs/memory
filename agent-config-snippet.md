# Agent Config — Memory Integration

Append the appropriate section to your agent's config file during init.

Every injected block is bracketed by `<!-- memory:begin v=1.0.0 -->` / `<!-- memory:end -->` markers. Init replaces any pre-existing block bounded by these markers; purge removes only content between them. Do not edit text inside the markers by hand — re-init will overwrite it.

## Claude Code (CLAUDE.md)

```markdown
<!-- memory:begin v=1.0.0 -->
@.memory/HANDOFF.md
@.memory/SCOPE.md

# Project Memory

## Essential (auto-loaded above)
- HANDOFF.md — current state, next steps, session gotchas
- SCOPE.md — project identity, boundaries, conventions

## Load on demand (read only when the task needs them)
- .memory/SYSTEM.md — read when: changing architecture, adding components, hitting non-obvious constraints
- .memory/DECISIONS.md — read when: making a design choice, evaluating alternatives, or about to introduce a new pattern

Run /memory update before ending sessions where significant work was done.
<!-- memory:end -->
```

## Codex (AGENTS.md)

```markdown
<!-- memory:begin v=1.0.0 -->
# Project Memory

## Always read at session start
- .memory/HANDOFF.md — current state and next steps
- .memory/SCOPE.md — project identity and boundaries

## Read on demand (only when the task requires them)
- .memory/SYSTEM.md — when working on architecture or constraints
- .memory/DECISIONS.md — when making design choices or reviewing past reasoning

Update .memory/HANDOFF.md before ending sessions.
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
