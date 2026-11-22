# Agent Config — Memory Integration

During init, inject the block for the running agent into its config file, following step 5 of `references/cmd-init.md`.

Every injected block is bracketed by `<!-- memory:begin v=1.1.0 -->` / `<!-- memory:end -->` markers. Init replaces any pre-existing block bounded by a `memory:begin` marker of any version and `memory:end`; purge removes only the markers and the content between them. Do not edit text inside the markers by hand — re-init will overwrite it.

## Claude Code / Codex (AGENTS.md)

One block serves both agents. Never write it to `CLAUDE.md`. Claude Code expands the two `@` import lines and loads those files into context; Codex and other agents that do not expand imports read the lines as text and follow the instruction below them.

Claude Code reads `AGENTS.md` only when there is no `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` in the working directory or any directory above it. When the project has one, init adds an `@AGENTS.md` import to it or warns — see step 5 of `references/cmd-init.md`.

```markdown
<!-- memory:begin v=1.1.0 -->
# Project Memory

## Always read at session start
@.memory/HANDOFF.md
@.memory/SCOPE.md

If the two lines above were not expanded into file contents, open and read both files before starting work.
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
<!-- memory:begin v=1.1.0 -->
# Project Memory

Always read .memory/HANDOFF.md and .memory/SCOPE.md before starting work.
Consult .memory/SYSTEM.md for architecture and .memory/DECISIONS.md when making design choices.
After significant work, update .memory/HANDOFF.md with current state and next steps.
<!-- memory:end -->
```
