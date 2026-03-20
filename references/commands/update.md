# memory update

Update the memory bank files to reflect the current state of work.

## Steps

### 0. Detect and migrate old structure

**If `memory-bank/projectBrief.md` exists** (old 7-file structure detected):

Inform the user: "Detected v0.2.8 memory bank (7 files). Migrating to v0.2.9 (5 files)."

1. Read all existing files in `memory-bank/`
2. Merge `projectBrief.md` + `productContext.md` → `projectContext.md`:
   - Copy the projectContext template from `references/templates/projectContext.md`
   - Fill `## Identity` from projectBrief's Project Name + Overview
   - Fill `## Purpose` from productContext's Purpose
   - Fill `## Target Audience` from productContext's Target Audience
   - Fill `## Core Requirements` from projectBrief's Core Requirements
   - Fill `## Success Criteria` from projectBrief's Success Criteria
   - Fill `## Key User Flows` from productContext's Key User Flows (ensure arrow notation)
   - Fill `## Scope` from projectBrief's Scope
   - Apply derivability gate: strip any build commands, dependency lists, infrastructure inventory, naming conventions, data flow, error handling, code summaries
3. Merge `activeContext.md` + `progress.md` → `activeState.md`:
   - Copy the activeState template from `references/templates/activeState.md`
   - Fill `## Resume Here` from activeContext's Resume Here
   - Fill `## Primary Thread` from activeContext's Primary Thread
   - Fill `## Working Set` from activeContext's Working Set
   - Fill `## In Progress` from progress's In Progress
   - Fill `## Remaining` from progress's Remaining
   - Fill `## Blockers` from activeContext's Blockers
   - Fill `## Known Issues` from progress's Known Issues
   - Fill `## Open Questions` from activeContext's Open Questions
   - Drop: completed work items, recent changes, evolution log, active decisions (move decisions to decisions.md)
4. Rewrite `systemPatterns.md`:
   - Keep: Architecture Overview, Key Design Decisions, Component Relationships
   - Rename: "Design Patterns in Use" → "Design Patterns"
   - Add: `## Gotchas & Traps` (populate from known issues or infer from code)
   - Drop: Data Flow, Naming Conventions, Error Handling Approach
5. Rewrite `techContext.md`:
   - Keep only: `## Stack` (Language + Runtime fields only), `## Non-Obvious Constraints`
   - Add: `## Setup Gotchas`, `## Environment Quirks`
   - Drop: Tech Stack multi-field block, Build & Dev Setup, Development Commands, Dependencies, Environment & Configuration, Infrastructure, Constraints & Limitations
6. Rewrite `decisions.md`:
   - Keep: Key Decisions (add Source as 4th required line if missing)
   - Reformat: Rejected Alternatives to use `**What was considered**` / `**Why rejected**` / `**Reconsider if**` format
   - Rename: "Project-Specific Patterns" → "Intent & Patterns"
7. Delete old files: `projectBrief.md`, `productContext.md`, `activeContext.md`, `progress.md`
8. Update agent config: change imports from `projectBrief.md`/`activeContext.md` to `projectContext.md`/`activeState.md`
9. Run full format verification (step 9 below)
10. Report migration results, then stop (do not continue to regular update steps)

---

### 1. Read all memory bank files

Read all 5 files in `memory-bank/`:
- projectContext.md, activeState.md, systemPatterns.md, techContext.md, decisions.md

### 2. Gather current state
- Run `git diff --stat` to see what files changed recently
- Run `git log --oneline -10` to see recent commits
- Run `git status` to see uncommitted work
- Review any open tasks or conversation context

### 3. Targeted re-analysis (if structural changes detected)
- Check `git diff --name-only` output for changes to dependency manifests, config files, or new/removed directories
- **If dependency manifests changed**: re-read the manifest — update `techContext.md` ONLY if non-obvious constraints changed (do NOT add dependency lists)
- **If directory structure changed**: re-scan and update `systemPatterns.md` (architecture, component relationships)
- **If no structural changes**: skip — the git diff/log from step 2 is sufficient
- Goal: keep `systemPatterns.md` and `techContext.md` accurate without doing a full deep dive every update

### 4. Determine what needs updating

> Before writing, apply the derivability test: **If a claim can be verified by reading a single project file or running a single command (`git log`, `ls`, `cat <file>`), it MUST NOT appear in memory.**

**Drift check** — before rewriting any section:
- If the new text is vaguer than the old (fewer proper nouns, more hedges) → keep the old text
- If the new text contradicts the old → verify the change before overwriting, and add a `Source:` line
- If the new text is >80% similar to the old → skip the rewrite, don't churn files

**Format migration (MANDATORY)**: If existing content uses formats from v0.2.8 that don't match v0.2.9 templates, migrate:
- Old Tech Stack multi-field block → strip to Language: + Runtime: only
- Old Infrastructure fields → remove entirely
- Old Development Commands table → remove entirely
- Old Dependencies table → remove entirely
- Old Data Flow section → remove entirely
- Old Naming Conventions table → remove entirely
- Old Error Handling section → remove entirely
- Old Evolution Log → remove entirely
- Old Completed items → remove entirely
- Old Recent Changes → remove entirely
- Missing `## Gotchas & Traps` in systemPatterns → add section
- Missing `## Setup Gotchas` / `## Environment Quirks` in techContext → add sections
- Old `## Project-Specific Patterns` → rename to `## Intent & Patterns`
- Old Rejected Alternatives date format → convert to `**What was considered**` / `**Why rejected**` / `**Reconsider if**`
- Missing Source line on Key Decision entries → add as 4th required line

**Evidence anchors**: When adding or updating claims in warm files, include a `Source:` line for non-obvious claims. Use bare references only.

**Confidence markers**: Mark claims in warm files:
- `[observed]` — seen directly in code or config
- `[inferred]` — deduced from structure, naming, or context
- `[assumed]` — not verified, best guess

Never add Source: lines or confidence markers to essential files (projectContext, activeState).

Per-file guidance:

- **activeState.md** — almost always needs rewriting (see step 5)
  - *Include*: exact next action, current workstream, working set, in-progress items, remaining work, blockers, known issues, open questions
  - *Exclude*: completed work, recent changes, evolution timeline, deep background
  - Rewrite aggressively every update

- **decisions.md** — append any significant decisions or rejected alternatives from this session
  - *Include*: decision with date/rationale/scope/status/source, rejected alternatives with 3-line format, intentional patterns
  - *Exclude*: vague observations, implementation details
  - Append-only, compress formatting if it grows

- **systemPatterns.md** — update if new patterns, architecture decisions, or design changes were made
  - *Include*: architecture shape, design decisions with rationale, non-obvious patterns, component relationships, gotchas
  - *Exclude*: naming conventions, data flow, error handling, code summaries

- **techContext.md** — update if non-obvious constraints changed
  - *Include*: language + runtime, constraints that break code if unknown, setup gotchas, environment quirks
  - *Exclude*: build commands, dependency tables, infrastructure, framework/tooling fields

- **projectContext.md** — rarely changes; update only if scope, requirements, or purpose shifted
  - *Include*: identity, purpose, audience, requirements, success criteria, user flows, scope
  - *Exclude*: technical details, session state, build commands

### 5. Rewrite activeState.md as a handoff document
Do not append session entries. Rewrite the file so it reads like a briefing for the next session:
1. Set `## Resume Here` to the exact next action (MUST name a specific file, function, or task)
2. Set `## Primary Thread` to the current workstream (one sentence)
3. Set `## Working Set` to 3-5 currently relevant file paths
4. Set `## In Progress` to current work items (or "None")
5. Set `## Remaining` to planned work not yet started (or "None")
6. Set `## Blockers` to anything preventing progress (or "None identified")
7. Set `## Known Issues` to bugs, traps, things to watch for (or "None identified")
8. Set `## Open Questions` to unresolved questions (or "None")

This file should read like a briefing, not a history log.

### 6. Capture decisions
Review the work done in this session for significant decisions:
- Architectural, design, or tooling choices → **Key Decisions** (all 4 lines required: date+decision, Scope, Status, Source)
- Approaches considered and rejected → **Rejected Alternatives** (all 3 lines required: What was considered, Why rejected, Reconsider if)
- Learned behaviors or non-obvious project rules → **Intent & Patterns**

When updating existing decisions:
- Never remove entries
- You may update the Status field (e.g., marking it superseded)
- Compress formatting if the file grows long, but preserve all decision content

### 7. Consolidate to prevent bloat

**Check per-file budgets** (HARD ceilings):

| File | Hard Ceiling |
|------|-------------|
| `projectContext.md` | 80 lines |
| `activeState.md` | 70 lines |
| `systemPatterns.md` | 100 lines |
| `techContext.md` | 60 lines |
| `decisions.md` | 150 lines |
| **Essential combined** | **150 lines** |
| **Total** | **460 lines** |

If any file exceeds its ceiling, compress before completing. There is no "marginally over" tolerance.

**Compression heuristics**:
- If activeState.md reads like a timeline → rewrite as handoff (step 5)
- If a note is no longer action-guiding → remove from memory
- If a fact is easy to verify from code → shorten or delete from memory
- If a decision matters across workstreams → ensure it's in decisions.md, remove from activeState
- If any file exceeds its ceiling → compress until it's under

**The `memory-bank/` directory MUST contain ONLY the 5 core files.** Do NOT create additional files. If content doesn't fit, compress.

### 8. Update files
- Use the Edit tool to update each file that needs changes
- Preserve existing content in decisions.md — append or modify, don't delete
- Keep entries concise and factual

### 9. Verify consistency and format

**Cross-file consistency checks:**
- Does `activeState.md` align with `decisions.md`? (active decisions should be in decisions.md)
- Does `techContext.md` match actual manifests? (constraints should reflect reality)
- Does `systemPatterns.md` match actual directory structure? (architecture should be current)
- Does `projectContext.md` align with README.md? (scope should be consistent)
- Check evidence anchors: if any `Source:` line references a file that no longer exists, update or remove

**Format verification (44 checks — ALL must pass):**

Run the same 44-check verification as init (see init.md step 4b). Fix any failures before reporting.

### 10. Report
- List which files were updated and summarize key changes
- Flag any inconsistencies or gaps discovered
- Note any decisions captured in decisions.md
