# memory init [description]

Initialize a structured memory bank in the current project.

Accepts an optional description string for seeding context (useful for empty/new projects):
- `memory init` — auto-scan project for context
- `memory init A React Native fitness app with Expo and Supabase` — use description as seed context

## What memory is

Memory is a **handoff document**, not a specification. It answers: "What does the next session need to know to be productive immediately?"

- **NOT** a comprehensive system specification (that's the code)
- **NOT** a project wiki (too much detail kills context budgets)
- **NOT** a session log or a substitute for reading code
- **IS** a briefing, routing table, decision record, pattern catalog, scope boundary

**The test**: If an agent reads the memory bank and still needs to ask "what are you working on?" — memory failed. If an agent never needs to read source code — memory is doing too much.

## Steps

### 1. Discover

#### 1a. Surface scan
- Check if user provided a description string after "init"
- Scan the current working directory for: `memory-bank/`, `.gitignore`, `.git/`
- Detect agent config files: `CLAUDE.md` (Claude Code), `AGENTS.md` (Codex, Cursor, etc.)
- Detect tech stack by checking for: `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, `*.csproj`
- Detect beads: check if `bd` CLI is available on PATH
- Read `README.md` or `README` if present
- Note the directory structure (top-level only)

#### 1b. Deep analysis (skip if project is empty or description-only init)

If the project has source code, perform targeted analysis to gather substantive context for the memory bank files. Focus on understanding the project's shape, not reading every file.

**Read dependency manifests** (not just detect them):
- `package.json` → parse `scripts`, `dependencies`, `devDependencies`; note the framework, test runner, bundler, linter
- `requirements.txt` / `pyproject.toml` → note frameworks (Django, Flask, FastAPI), key libraries
- `go.mod` → note module path and major dependencies
- `Cargo.toml` → note crate name, edition, key dependencies
- Other manifests → extract equivalent information
- Goal: understand **what tools are used and why**, not just that a manifest exists

**Explore directory structure recursively**:
- List directories 2-3 levels deep (exclude node_modules, vendor, .git, __pycache__, build/dist output)
- Identify architectural patterns from folder organization: `src/`, `lib/`, `components/`, `routes/`, `api/`, `services/`, `models/`, `utils/`, `hooks/`, `middleware/`, `tests/`, `scripts/`
- For monorepos: identify packages/workspaces and their roles
- Goal: understand **how the codebase is organized**

**Read key source files** (up to 5-8 files, proportional to project size):
- Entry points: `src/index.*`, `src/main.*`, `app.*`, `main.*`, `server.*`, `cmd/*/main.go`
- Config files: `tsconfig.json`, `webpack.config.*`, `vite.config.*`, `.eslintrc*`, `tailwind.config.*`, `docker-compose.yml`, `Dockerfile`
- Route/API definitions: `routes/`, `api/`, `pages/` (top-level files, not every route)
- Core modules: the 1-2 files that appear central based on directory structure
- Goal: understand **design patterns, error handling, naming conventions, data flow**

**Check project history** (if `.git/` exists):
- `git log --oneline -20` — project evolution and activity level
- `git log --oneline --since="2 weeks ago"` — current momentum and recent focus
- Goal: inform **progress.md** and **activeContext.md** with real history

**Look for additional documentation**:
- `docs/` directory, `CONTRIBUTING.md`, `CHANGELOG.md`, `ARCHITECTURE.md`
- API specs: `openapi.yaml`, `swagger.json`, `*.proto`
- CI/CD configs: `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`
- Build files: `Makefile`, `justfile`, `Taskfile.yml`
- Goal: find documented intent, build/deploy processes, and contribution patterns

**Understand build and dev workflow**:
- Read the `scripts` section of `package.json` or equivalent (Makefile targets, task runner commands)
- Check for dev containers (`.devcontainer/`), Docker setup
- Identify test setup: test runner, test directory structure, test config
- Goal: populate **techContext.md** with real commands

#### 1c. Synthesize findings

Before proceeding to template filling, organize what was learned:
- **Architecture**: high-level shape (monolith, API+client, microservices, CLI tool, library, static site)
- **Patterns**: design patterns evident (component-based, MVC, event-driven, repository pattern, middleware chain)
- **Data flow**: how data moves (HTTP request lifecycle, state management, pub/sub, CLI argument parsing)
- **Stack rationale**: not just what tools, but why those tools (infer from context)
- **Project maturity**: early-stage, actively developed, stable/maintenance, or stale (from git history)
- **Gaps**: what couldn't be determined from code alone (these become "Not yet documented" or open questions)

### 1d. What belongs in memory — memory vs. specification

Before filling templates, apply this filter. Memory captures the 5% that is expensive to reconstruct, not the 95% code already encodes.

**The Borges map**: A map that reproduces the territory at 1:1 scale is useless. Memory that restates what code says is equally useless. Store intent, constraints, decisions, and routing hints — not implementation details.

**Store in memory**: thread state, durable decisions, routing hints ("if working on X, read Y first"), non-obvious repo patterns, product constraints, research conclusions.

**Read from code every time**: implementation details, API shape, module structure, test coverage, repo state, build commands.

**Never store**: raw transcripts, directory listings, re-derivable prose, machine-specific config, large spec summaries.

**Anti-patterns**:
- **Specification filler**: every sentence must name something concrete — a file, tool, pattern, decision. Prose that "sounds informative but communicates nothing specific" is worse than an empty section.
- **The Borges map**: memory captures the 5% expensive to reconstruct, not the 95% code already encodes. If `rg` can answer it in 10 seconds, don't store it.
- **The ever-growing diary**: memory is a snapshot, not a timeline. Prune aggressively.
- **A substitute for code reading**: memory tells agents *which* files to read and *why*, not *what* those files contain.
- **Speculative notes as facts**: only store what's confirmed. Move uncertainty to Open Questions.

### 1e. Specificity gate

Before writing any memory bank file, apply these self-checks to every sentence:

- **Substitution test**: Could this sentence describe a different project? If yes, it's filler — make it specific or delete it.
- **Quantification test**: Does it use "several", "various", "many" without specifics? Replace with an actual list or count, or delete.
- **Hedge test**: "seems to", "appears to", "might" — verify and state as fact, or move to Open Questions.
- **Tautology test**: Does it restate the section header? (e.g., "Architecture Overview: This section describes the architecture.") Delete.

**Density test**: Each section must contain at least one proper noun (tool name, file path, pattern name, dependency). A section with zero proper nouns is filler.

### 1f. No-filler rule

Every sentence in a memory bank file must satisfy at least one of:
1. Names something specific (a file, tool, pattern, endpoint, config key)
2. States a relationship between two specific things
3. Captures a decision and its rationale
4. Identifies a gap or open question

If none apply, delete the sentence. An empty section with "Not yet documented" beats vague prose.

**Evidence anchors**: When writing claims in warm files (systemPatterns, techContext, decisions, productContext, progress), add a `Source:` line pointing to where the claim can be verified — a file path, commit hash, or PR number. This is the default for non-obvious claims, not optional. Keep it to one line. Use bare references only (e.g., `Source: adapter/adapter.go`, not `Source: adapter/adapter.go (writeOutput function)`). Never add evidence anchors to essential files (projectBrief, activeContext).

**Confidence markers**: When the source of a claim varies in certainty, mark it:
- `[observed]` — seen directly in code or config
- `[inferred]` — deduced from structure, naming, or context
- `[assumed]` — not verified, best guess

Status checks flag `[assumed]` claims as pending verification.

### 2. Handle edge cases
- If `memory-bank/` already exists → ask user: **reinitialize** (overwrite and re-populate from fresh scan), **merge** (update existing files with fresh scan), or **cancel**
- If agent config already contains memory bank references → skip config update, inform user
- If no `.git/` directory → skip the gitignore question entirely
- If directory is empty AND no description provided → ask 3-4 interactive questions:
  1. "What is this project?" (purpose, name)
  2. "Who is it for?" (target audience)
  3. "What tech stack are you planning?" (languages, frameworks, tools)
  4. "Any specific goals or constraints?" (optional)
  Then use answers as seed context for populating the memory bank files.
- If directory is empty AND description provided → use the description as seed context (skip questions)
- If in a subdirectory of a monorepo → create memory-bank/ at cwd, not at git root

### 3. Ask about git tracking
- Only if `.git/` exists and `memory-bank/` is not already in `.gitignore`
- Ask: "Should the memory bank be **git-tracked** or **gitignored**?"
- If gitignored → append `memory-bank/` to `.gitignore`

### 4. Create memory-bank/
- Create the `memory-bank/` directory
- For each of the 7 template files, follow this two-step process:
  1. **Copy**: Read the template from `references/templates/<file>` and write it verbatim to `memory-bank/<file>`
  2. **Fill**: Use the Edit tool to replace each `[fill: ...]` placeholder and HTML comment with real content discovered in Steps 1a-1c

This copy-then-edit workflow ensures the template structure is preserved. The templates contain key-value fields (like `Languages:`), markdown tables, arrow notation, and fixed section headings that MUST appear in the final output.

**Rules when editing:**
- **Key-value fields** (e.g., `Languages: [fill: ...]`): replace the `[fill: ...]` placeholder with the real value. Use `none` if not applicable. Do NOT delete the line or convert to bullets.
- **Tables** (e.g., `| Command | What it does |`): replace `[fill]` cells with real values, or replace the entire table with a one-line explanation if no data exists (e.g., "None — zero external dependencies").
- **Section headings**: keep exactly as named. Do NOT rename `## Primary Thread` to `## Current Focus` or similar.
- **Arrow notation** in Component Relationships: replace the comment with real `A -> B : description` lines.
- **HTML comments**: replace with real content. Delete the comment tags but keep the surrounding structure.

Template files: `projectBrief.md`, `productContext.md`, `systemPatterns.md`, `techContext.md`, `activeContext.md`, `progress.md`, `decisions.md`

`decisions.md` starts mostly empty — its sections are populated over time. Prefer 2-3 concrete sentences over vague placeholders.

**Per-file line budgets** (target, not hard cap — 200 is the hard ceiling):

| File | Budget | Notes |
|------|--------|-------|
| `projectBrief.md` | 80 | Essential. Elaboration → productContext or systemPatterns |
| `activeContext.md` | 70 | Essential. Combined with projectBrief ≤ 150 |
| `productContext.md` | 80 | Warm. Stable context, keep tight |
| `systemPatterns.md` | 120 | Warm. Most structured — tables/arrows need room |
| `techContext.md` | 100 | Warm. Commands/deps tables take space |
| `progress.md` | 80 | Warm. Roll up old items aggressively |
| `decisions.md` | 150 | Warm. Append-only — compress formatting, not content |
| **Total** | **680** | ~9,000 tokens across all 7 files |

**Filling guidance by file** (what to include vs. exclude):

- **projectBrief.md** — project name from manifest/repo. Overview from README + entry point analysis. Core requirements from README or docs.
  - *Include*: what the repo is, core scope, major modules, stable stakeholders
  - *Exclude*: session state, recent work, tactical priorities
  - Rewrite rarely

- **productContext.md** — purpose and audience from README/docs. Key user flows from route definitions, page structure, or CLI commands.
  - *Include*: who this serves, what outcomes matter, stable product constraints, UX goals
  - *Exclude*: open brainstorming, temporary prioritization churn

- **systemPatterns.md** — benefits most from deep analysis. Architecture from directory structure + entry points. Design patterns from code inspection. Component relationships from imports/directory organization. Data flow from tracing entry point to core modules. Naming conventions and error handling from observed code. Optionally add `Source:` lines for non-obvious architectural claims.
  - *Include*: how components fit together, recurring patterns, lifecycle norms, naming/error-handling conventions
  - *Exclude*: one-off features, current sprint specifics, every module detail
  - Update only when patterns change

- **techContext.md** — stack from manifests. Build & dev setup from scripts/Makefile. Development commands verbatim from package.json scripts or equivalent. Key dependencies with brief inferred rationale. Infrastructure from Docker/CI configs. Optionally add `Source:` lines for non-obvious technical claims.
  - *Include*: stack, build commands, major dependencies, configuration model, hard constraints
  - *Exclude*: transient dependency upgrades, session-local setup, machine-specific quirks

- **activeContext.md** — current focus from recent git history. Recent changes from git log. Next steps inferred from recent commit trajectory.
  - *Include*: primary thread, current focus, blockers, next concrete move, working set, last 2-3 meaningful updates
  - *Exclude*: long chronology, deep background, stale repo-state snapshots, finished work older than a few sessions
  - Rewrite aggressively every update

- **progress.md** — completed work from git history and project maturity. In progress from recent commits and uncommitted changes. Known issues from TODO/FIXME/HACK comments if spotted.
  - *Include*: what's done, what's in progress, what remains, known issues
  - *Exclude*: fine-grained session diary, repeated summaries already in activeContext

- **decisions.md** — mostly empty. If obvious architectural decisions are visible (choice of ORM, state management, monorepo structure), log as retroactive entries with today's date. Include an optional `Source:` line pointing to the file path, commit hash, or PR number that supports the decision. Each reference must be something the status command can verify — avoid non-checkable references like "git log" or "code review".
  - *Include*: decision, rationale, scope, status, rejected alternatives, optional Source line
  - *Exclude*: vague observations, temporary chatter, implementation details easy to rediscover
  - Append-only, compress formatting if it grows

- If a section has no discoverable info, leave it with a brief "Not yet documented" note rather than the HTML comment
- **Additional context files**: If the project is complex enough that a topic doesn't fit cleanly into the 7 core files (e.g., detailed API specs, multi-service integration docs, complex deployment procedures), create additional `.md` files in `memory-bank/`. Mention these in the summary output. Most projects won't need this.

### 4b. Format verification (MANDATORY)

After writing all 7 files, re-read each one and verify the following. If any check fails, edit the file to fix it before proceeding to step 5. Do not skip this step.

**techContext.md**:
- `## Tech Stack` contains `Languages:`, `Framework:`, `Test runner:`, `Bundler:`, `Package manager:` as key-value fields (not bullets or prose)
- `## Infrastructure` contains `Hosting:`, `CI/CD:`, `Database:`, `External services:` as key-value fields
- `## Development Commands` uses a `| Command | What it does |` markdown table (or a one-liner explaining why no commands exist, e.g., "No build commands — open index.html directly")
- `## Dependencies` uses a table or explicitly states "None" / "Zero external dependencies"

**systemPatterns.md**:
- `## Architecture Overview` contains `Type:`, `Entry point(s):`, `Layer structure:` as key-value fields (not a prose paragraph)
- `## Component Relationships` uses `A -> B : description` arrow notation (not prose descriptions)
- `## Naming Conventions` uses a `| Scope | Convention | Example |` markdown table
- At least one `Source:` line exists somewhere in the file

**activeContext.md**:
- Uses these exact section names: `## Primary Thread`, `## Resume Here`, `## Working Set`, `## Blockers`, `## Recent Changes`
- `## Resume Here` names a specific file, function, or task
- `## Working Set` lists 3-5 specific files

**decisions.md**:
- Each entry in Key Decisions has `Scope:` and `Status:` lines immediately after the decision line
- No template example text remains (e.g., "Use SQLite over PostgreSQL")

**productContext.md**:
- `## Key User Flows` uses `→` or `->` arrow notation, one flow per line (not numbered sequential steps)

**Warm files** (systemPatterns, techContext, decisions, productContext, progress):
- Each file has at least one `Source:` line with a bare reference (file path, commit hash, or PR)
- Each file has at least one confidence marker (`[observed]`, `[inferred]`, or `[assumed]`)

**Essential files** (projectBrief, activeContext):
- No `Source:` lines
- No confidence markers

### 5. Create/update agent config

Read the snippet from the skill's `references/agent-config-snippet.md`.

Detect which agent is executing this skill and update the appropriate config file:

- **Claude Code** → `CLAUDE.md`
  - Add `@memory-bank/projectBrief.md` and `@memory-bank/activeContext.md` as auto-loading imports
  - Add the on-demand files as a reference list (without `@` prefix) so the agent knows they exist but doesn't auto-load them
  - If no `CLAUDE.md` exists → create one with the snippet content (using `@` imports for essential files)
  - If `CLAUDE.md` exists → append the snippet to the end (never overwrite existing content)

- **Codex** → `AGENTS.md`
  - Use plain file path references (no `@` prefix)
  - If no `AGENTS.md` exists → create one with the snippet content
  - If `AGENTS.md` exists → append the snippet to the end (never overwrite existing content)

- **Other agents** (Cursor, Windsurf, etc.) → use whichever config file the agent convention expects, falling back to `AGENTS.md`

### 6. Summary
- Print a summary of what was created/modified
- List all files created in memory-bank/
- Note which agent config file was created or updated
- Mention available subcommands: update, status, export, ignore, track, purge
- Remind user that essential memory bank files are loaded at the start of each session via agent config imports, with other files loaded on demand
