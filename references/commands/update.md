# memory update

Update the memory bank files to reflect the current state of work.

## Steps

1. **Read all memory bank files** in `memory-bank/`:
   - projectBrief.md, productContext.md, systemPatterns.md
   - techContext.md, activeContext.md, progress.md, decisions.md

2. **Gather current state**:
   - Run `git diff --stat` to see what files changed recently
   - Run `git log --oneline -10` to see recent commits
   - Run `git status` to see uncommitted work
   - Review any open tasks or conversation context

3. **Targeted re-analysis** (if structural changes detected):
   - Check `git diff --name-only` output for changes to dependency manifests (`package.json`, `requirements.txt`, `go.mod`, etc.), config files, or new/removed directories
   - **If dependency manifests changed**: re-read the manifest and update `techContext.md` (new deps, removed deps, version changes)
   - **If directory structure changed** (new top-level dirs, new packages in monorepo): re-scan directory structure 2-3 levels deep and update `systemPatterns.md` (architecture, component relationships)
   - **If CI/CD or build configs changed**: re-read and update `techContext.md` (build setup, dev commands, infrastructure)
   - **If no structural changes**: skip this step — the git diff/log from step 2 is sufficient
   - Goal: keep `systemPatterns.md` and `techContext.md` accurate without doing a full deep dive every update

4. **Determine what needs updating**:

   > Before writing, apply this test: **Store it only if it's hard to reconstruct quickly, valuable across sessions, not obvious from code, and likely to affect future decisions.** If a fact is easy to verify from code, shorten it or delete it from memory. Memory stores intent, constraints, handoff state, and hard-won conclusions. Code supplies implementation truth.

   Per-file guidance (what to include vs. exclude):

   - `activeContext.md` — almost always needs rewriting (see step 5)
     - *Include*: primary thread, current focus, blockers, next concrete move, working set, last 2-3 meaningful updates
     - *Exclude*: long chronology, deep background, stale repo-state snapshots, finished work older than a few sessions
     - Rewrite aggressively every update
   - `progress.md` — update completed items, in-progress work, known issues
     - *Include*: what's done, what's in progress, what remains, known issues
     - *Exclude*: fine-grained session diary, repeated summaries already in activeContext
   - `decisions.md` — append any significant decisions made or alternatives rejected during this session
     - *Include*: decision, rationale, scope, status, rejected alternatives
     - *Exclude*: vague observations, temporary chatter, implementation details easy to rediscover
     - Append-only, compress formatting if it grows
   - `systemPatterns.md` — update if new patterns, architecture decisions, or design changes were made
     - *Include*: how components fit together, recurring patterns, lifecycle norms, naming/error-handling conventions
     - *Exclude*: one-off features, current sprint specifics, every module detail
   - `techContext.md` — update if dependencies, build process, or infrastructure changed
     - *Include*: stack, build commands, major dependencies, configuration model, hard constraints
     - *Exclude*: transient dependency upgrades, session-local setup, machine-specific quirks
   - `productContext.md` — update if product goals, audience, or UX changed
     - *Include*: who this serves, what outcomes matter, stable product constraints, UX goals
     - *Exclude*: open brainstorming, temporary prioritization churn
   - `projectBrief.md` — rarely changes; update only if scope or requirements shifted
     - *Include*: what the repo is, core scope, major modules, stable stakeholders
     - *Exclude*: session state, recent work, tactical priorities
   - **Additional context files** — if `memory-bank/` contains files beyond the core 7, review and update those as needed too

5. **Rewrite activeContext.md as a handoff document**:
   - Do not append session entries. Instead, rewrite the file so it reads like a briefing for the next session:
     1. Set "Primary Thread" to the current workstream (one sentence)
     2. Set "Resume Here" to the exact next action
     3. Set "Working Set" to 3-5 currently relevant files/modules
     4. Set "Blockers" to anything preventing progress (or "None")
     5. In "Recent Changes", keep only the last 2-3 meaningful updates as one-line dated entries. Delete anything older.
     6. Update "Active Decisions" and "Open Questions" to reflect current state
   - This file should read like a briefing, not a history log. If it starts reading like a timeline, you're doing it wrong.

6. **Capture decisions**:
   - Review the work done in this session for significant decisions
   - For each decision, append to the appropriate section in `decisions.md`:
     - Architectural, design, or tooling choices → **Key Decisions**
     - Approaches that were considered and rejected → **Rejected Alternatives**
     - Learned behaviors or non-obvious project rules → **Project-Specific Patterns**
   - When capturing decisions, include:
     - **Date and decision**: what was decided and why
     - **Scope**: where this applies (helps future agents know when the decision is relevant)
     - **Status**: `active` by default. Update to `superseded by [X]` if a later decision replaces it, or `revisit when [Y]` if it's time-bound.
   - When updating existing decisions:
     - Never remove entries
     - You may update the Status field of an existing entry (e.g., marking it superseded)
     - Compress formatting if the file grows long, but preserve all decision content

7. **Consolidate to prevent bloat**:
   - In `progress.md`: roll completed items older than ~2 weeks into a single summary line (e.g., "Pre-2025-03-01: Initial setup, auth module, CI pipeline")
   - Remove "Not yet documented" placeholders if a section now has real content

   **Check essential file budget**: Count combined lines of `projectBrief.md` and `activeContext.md`. If over 150 lines combined (~2,000 tokens):
   - Compress `projectBrief.md` to core identity only (what the repo is, core scope, major modules — no elaboration)
   - Prune `activeContext.md`: keep only Primary Thread, Resume Here, Working Set, Blockers, and last 2 Recent Changes entries
   - Move any detailed content that was in these files to the appropriate warm file (systemPatterns, techContext, etc.)

   **Compression heuristics** (apply ruthlessly):
   - If `activeContext.md` reads like a timeline → rewrite it as a handoff (see step 5)
   - If a note is no longer action-guiding → remove it from hot memory
   - If something is important but specialized → move it to the appropriate warm file
   - If a fact is easy to verify from code (file paths, dep versions, directory structure) → shorten or delete from memory
   - If `progress.md` duplicates `activeContext.md` → deduplicate. `progress.md` is the ledger, `activeContext` is the handoff
   - If a decision matters across workstreams → promote to `decisions.md`, remove from `activeContext`
   - If a deep topic keeps recurring in multiple files → create a dedicated additional context file rather than bloating core files
   - If any file exceeds 200 lines → compress, split, or move content until it's under

8. **Update remaining files**:
   - Use the Edit tool to update each file that needs changes
   - Preserve existing content — append or modify, don't delete unless consolidating as described above
   - Add dates to the evolution log in progress.md
   - Keep entries concise and factual

9. **Verify consistency**:
   - Ensure activeContext.md aligns with progress.md
   - Ensure techContext.md reflects any new dependencies or tools
   - Ensure systemPatterns.md reflects any new architectural decisions
   - Ensure decisions.md captures any significant choices from this session

10. **Report**:
   - List which files were updated and summarize key changes
   - Flag any inconsistencies or gaps discovered
   - Note any decisions captured in decisions.md
