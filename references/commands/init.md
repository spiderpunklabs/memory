# memory init [description]

Initialize a structured memory bank in the current project.

Accepts an optional description string for seeding context (useful for empty/new projects):
- `memory init` — auto-scan project for context
- `memory init A React Native fitness app with Expo and Supabase` — use description as seed context

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

### 1d. What belongs in memory

Before filling templates, apply this filter to everything discovered above. This determines what goes into memory bank files vs. what agents should read from code each time.

**Store in memory** (expensive to reconstruct, not encoded in code):
- Current thread state: what's active, what's next, what's blocked
- Durable decisions: rejected approaches, accepted tradeoffs, product constraints
- Task routing hints: "if working on X, read these files/classes first"
- Non-obvious repo patterns: intentional quirks, swallowed exceptions, naming traps
- Product context: scope boundaries, PM constraints, user-experience goals
- Research conclusions: synthesized findings, not raw notes
- Known traps: stale docs, misleading naming, generated artifacts

**Read from code every time** (cheap to reconstruct, must be current):
- Exact implementation details: method behavior, class wiring, enum values
- Current API shape: routes, payloads, response semantics
- Module structure: file locations, package names, build dependencies
- Test coverage and behavior
- Current repo state: staged files, branches, merge conflicts
- Build commands when uncertainty exists

**Never store or store only briefly**:
- Raw session transcripts or command logs
- Long file inventories or directory listings
- Re-derivable architecture prose (the kind `rg` can answer in 10 seconds)
- Local machine repair notes or environment config
- Large copied docs/spec summaries
- Worktree noise unless it blocks current work

**Anti-patterns** (avoid these during init and all future updates):
- "Summarize the whole repo" memory — memory captures intent and decisions, not a directory listing
- "Every session gets appended forever" memory — prune aggressively
- "Memory as substitute for code reading" — if `rg` can answer it, don't store it
- "Speculative notes written as facts" — only store what's confirmed
- "Current git status" memory — unless it's blocking current work

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
- For each of the 7 template files (`projectBrief.md`, `productContext.md`, `systemPatterns.md`, `techContext.md`, `activeContext.md`, `progress.md`, `decisions.md`): read the template from the skill's `references/templates/` directory, fill in real project context discovered in Steps 1a-1c, and write to `memory-bank/`
- `decisions.md` starts mostly empty — its sections are populated over time as decisions are made
- Templates provide structure; fill in substance from what was discovered
- Prefer writing 2-3 concrete sentences over vague placeholders — if you read the code, say what you learned

**Filling guidance by file** (what to include vs. exclude):

- **projectBrief.md** — project name from manifest/repo. Overview from README + entry point analysis. Core requirements from README or docs.
  - *Include*: what the repo is, core scope, major modules, stable stakeholders
  - *Exclude*: session state, recent work, tactical priorities
  - Rewrite rarely

- **productContext.md** — purpose and audience from README/docs. Key user flows from route definitions, page structure, or CLI commands.
  - *Include*: who this serves, what outcomes matter, stable product constraints, UX goals
  - *Exclude*: open brainstorming, temporary prioritization churn

- **systemPatterns.md** — benefits most from deep analysis. Architecture from directory structure + entry points. Design patterns from code inspection. Component relationships from imports/directory organization. Data flow from tracing entry point to core modules. Naming conventions and error handling from observed code.
  - *Include*: how components fit together, recurring patterns, lifecycle norms, naming/error-handling conventions
  - *Exclude*: one-off features, current sprint specifics, every module detail
  - Update only when patterns change

- **techContext.md** — stack from manifests. Build & dev setup from scripts/Makefile. Development commands verbatim from package.json scripts or equivalent. Key dependencies with brief inferred rationale. Infrastructure from Docker/CI configs.
  - *Include*: stack, build commands, major dependencies, configuration model, hard constraints
  - *Exclude*: transient dependency upgrades, session-local setup, machine-specific quirks

- **activeContext.md** — current focus from recent git history. Recent changes from git log. Next steps inferred from recent commit trajectory.
  - *Include*: primary thread, current focus, blockers, next concrete move, working set, last 2-3 meaningful updates
  - *Exclude*: long chronology, deep background, stale repo-state snapshots, finished work older than a few sessions
  - Rewrite aggressively every update

- **progress.md** — completed work from git history and project maturity. In progress from recent commits and uncommitted changes. Known issues from TODO/FIXME/HACK comments if spotted.
  - *Include*: what's done, what's in progress, what remains, known issues
  - *Exclude*: fine-grained session diary, repeated summaries already in activeContext

- **decisions.md** — mostly empty. If obvious architectural decisions are visible (choice of ORM, state management, monorepo structure), log as retroactive entries with today's date.
  - *Include*: decision, rationale, scope, status, rejected alternatives
  - *Exclude*: vague observations, temporary chatter, implementation details easy to rediscover
  - Append-only, compress formatting if it grows

- If a section has no discoverable info, leave it with a brief "Not yet documented" note rather than the HTML comment
- **Additional context files**: If the project is complex enough that a topic doesn't fit cleanly into the 7 core files (e.g., detailed API specs, multi-service integration docs, complex deployment procedures), create additional `.md` files in `memory-bank/`. Mention these in the summary output. Most projects won't need this.

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
