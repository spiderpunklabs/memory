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

   **Drift check** — before rewriting any section:
   - If the new text is vaguer than the old (fewer proper nouns, more hedges) → keep the old text
   - If the new text contradicts the old → verify the change before overwriting, and add a `Source:` line
   - If the new text is >80% similar to the old → skip the rewrite, don't churn files

   **Format migration (MANDATORY)**: If existing content uses prose, bullets, or free-form text where the template expects structured format, you MUST migrate during this update. Read each template from `references/templates/` — the templates contain explicit `[fill:]` placeholders showing the required format. Specific migrations:
   - Prose tech stack → `Languages:`, `Framework:`, `Test runner:`, `Bundler:`, `Package manager:` key-value fields
   - Prose infrastructure → `Hosting:`, `CI/CD:`, `Database:`, `External services:` key-value fields
   - Prose dev commands → `| Command | What it does |` markdown table
   - Prose architecture → `Type:`, `Entry point(s):`, `Layer structure:` key-value fields
   - Prose component relationships → `A -> B : description` arrow notation
   - Prose naming conventions → `| Scope | Convention | Example |` markdown table
   - Sequential numbered user flows → `Trigger → Action → Outcome` one-line arrow flows
   - Missing `Scope:` / `Status:` on decision entries → add them
   - Wrong section names in activeContext (e.g., "Current Focus" instead of "Primary Thread") → rename to match template exactly

   **Evidence anchors**: When adding or updating claims in warm files, include a `Source:` line (file path, commit, or PR) for non-obvious claims. This is the default, not optional. Keep evidence to one line — a pointer, not a quote. Use bare references only — file paths, commit hashes, or PR numbers. No inline descriptions or parenthetical clarifiers.

   **Confidence markers**: When updating warm files, mark claims by certainty:
   - `[observed]` — seen directly in code or config
   - `[inferred]` — deduced from structure, naming, or context
   - `[assumed]` — not verified, best guess
   Status checks flag `[assumed]` claims as pending verification.

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
     - **Source** (optional): file path, commit hash, or PR that supports this decision
   - When updating existing decisions:
     - Never remove entries
     - You may update the Status field of an existing entry (e.g., marking it superseded)
     - Compress formatting if the file grows long, but preserve all decision content

7. **Consolidate to prevent bloat**:
   - In `progress.md`: roll completed items older than ~2 weeks into a single summary line (e.g., "Pre-2025-03-01: Initial setup, auth module, CI pipeline")
   - Remove "Not yet documented" placeholders if a section now has real content

   **Check per-file budgets** (target / hard ceiling of 200):

   | File | Budget |
   |------|--------|
   | `projectBrief.md` | 80 |
   | `activeContext.md` | 70 |
   | `productContext.md` | 80 |
   | `systemPatterns.md` | 120 |
   | `techContext.md` | 100 |
   | `progress.md` | 80 |
   | `decisions.md` | 150 |

   **Essential files** (`projectBrief.md` + `activeContext.md`) must stay under 150 lines combined (~2,000 tokens). If over budget:
   - Compress `projectBrief.md` to core identity only (what the repo is, core scope, major modules — no elaboration)
   - Prune `activeContext.md`: keep only Primary Thread, Resume Here, Working Set, Blockers, and last 2 Recent Changes entries
   - Move any detailed content to the appropriate warm file (systemPatterns, techContext, etc.)

   **Warm files** over their budget: compress, split into additional context files, or prune re-derivable content.

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
   - Check evidence anchors in warm files: if any `Source:` line references a file that no longer exists or a path that has moved, update or remove the anchor

10. **Format verification** (same checklist as init — apply after every update):

    **techContext.md**:
    - `## Tech Stack` has `Languages:`, `Framework:`, `Test runner:`, `Bundler:`, `Package manager:` as key-value fields
    - `## Infrastructure` has `Hosting:`, `CI/CD:`, `Database:`, `External services:` as key-value fields
    - `## Development Commands` uses a markdown table or explains why none exist

    **systemPatterns.md**:
    - `## Architecture Overview` has `Type:`, `Entry point(s):`, `Layer structure:` key-value fields
    - `## Component Relationships` uses `A -> B : description` arrow notation
    - `## Naming Conventions` uses a `| Scope | Convention | Example |` table

    **activeContext.md**:
    - Uses exact section names: `## Primary Thread`, `## Resume Here`, `## Working Set`
    - `## Resume Here` names a specific file, function, or task

    **decisions.md**:
    - Each Key Decisions entry has `Scope:` and `Status:` lines

    **productContext.md**:
    - `## Key User Flows` uses `→` or `->` arrow notation, one flow per line

    **Warm files**: each has ≥1 `Source:` line and ≥1 confidence marker (`[observed]`/`[inferred]`/`[assumed]`)
    **Essential files**: no `Source:` lines, no confidence markers

    Fix any failures before reporting.

11. **Report**:
   - List which files were updated and summarize key changes
   - Flag any inconsistencies or gaps discovered
   - Note any decisions captured in decisions.md
