# Agent Config — Memory Integration

Append the appropriate section to your agent's config file during init.

## Claude Code (CLAUDE.md)

```markdown
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
```

## Codex (AGENTS.md)

```markdown
# Project Memory

## Always read at session start
- .memory/HANDOFF.md — current state and next steps
- .memory/SCOPE.md — project identity and boundaries

## Read on demand (only when the task requires them)
- .memory/SYSTEM.md — when working on architecture or constraints
- .memory/DECISIONS.md — when making design choices or reviewing past reasoning

Update .memory/HANDOFF.md before ending sessions.
```

## Cursor (.cursorrules)

```markdown
# Project Memory

Always read .memory/HANDOFF.md and .memory/SCOPE.md before starting work.
Consult .memory/SYSTEM.md for architecture and .memory/DECISIONS.md when making design choices.
After significant work, update .memory/HANDOFF.md with current state and next steps.
```
