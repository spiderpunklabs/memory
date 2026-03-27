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
- Read `README.md` or `README` if present
- Note the directory structure (top-level only)

#### 1b. Deep analysis (skip if project is empty or description-only init)

If the project has source code, perform targeted analysis to gather substantive context for the memory bank files. Focus on understanding the project's shape, not reading every file.

**Read dependency manifests** (not just detect them):
- `package.json` → parse `scripts`, `dependencies`, `devDependencies`
- `requirements.txt` / `pyproject.toml` → note frameworks, key libraries
- `go.mod` → note module path and major dependencies
- `Cargo.toml` → note crate name, edition, key dependencies
- Other manifests → extract equivalent information
- Goal: understand **what tools are used and why** — but do NOT store dependency lists in memory (derivable)

**Explore directory structure recursively**:
- List directories 2-3 levels deep (exclude node_modules, vendor, .git, __pycache__, build/dist output)
- Identify architectural patterns from folder organization
- For monorepos: identify packages/workspaces and their roles
- Goal: understand **how the codebase is organized** — but do NOT store directory listings in memory (derivable)

**Read key source files** (up to 5-8 files, proportional to project size):
- Entry points: `src/index.*`, `src/main.*`, `app.*`, `main.*`, `server.*`, `cmd/*/main.go`
- Config files: `tsconfig.json`, `webpack.config.*`, `vite.config.*`, `.eslintrc*`, `docker-compose.yml`, `Dockerfile`
- Route/API definitions: top-level files in `routes/`, `api/`, `pages/`
- Core modules: the 1-2 files that appear central based on directory structure
- Goal: understand **design patterns, non-obvious constraints, gotchas** — but do NOT summarize what the code does (derivable)

**Check project history** (if `.git/` exists):
- `git log --oneline -20` — project evolution and activity level
- `git log --oneline --since="2 weeks ago"` — current momentum and recent focus
- Goal: inform **activeState.md** with real history — but do NOT store changelog entries (derivable via `git log`)

**Look for additional documentation**:
- `docs/` directory, `CONTRIBUTING.md`, `CHANGELOG.md`, `ARCHITECTURE.md`
- API specs: `openapi.yaml`, `swagger.json`, `*.proto`
- CI/CD configs: `.github/workflows/`, `.gitlab-ci.yml`
- Build files: `Makefile`, `justfile`, `Taskfile.yml`
- Goal: find documented intent and constraints — but do NOT store build commands or infrastructure inventory (derivable)

#### 1c. Synthesize findings

Before proceeding to template filling, organize what was learned:
- **Architecture**: high-level shape (monolith, API+client, microservices, CLI tool, library, kernel module)
- **Patterns**: design patterns evident (component-based, MVC, event-driven, repository pattern)
- **Stack rationale**: not just what tools, but why those tools (infer from context)
- **Non-obvious constraints**: things that will break code if an agent doesn't know them
- **Gotchas**: things that look wrong but are intentional, non-obvious side effects
- **Decisions**: architectural choices and their implied rejected alternatives
- **Project maturity**: early-stage, actively developed, stable/maintenance, or stale (from git history)
- **Gaps**: what couldn't be determined from code alone (these become open questions)

### 1d. Derivability gate — PROHIBITED content

**Before writing any memory bank file**, apply this gate. Memory captures the 5% that is expensive to reconstruct, not the 95% code already encodes.

The following content is **PROHIBITED** in all memory files. If present, format verification FAILS.

| Prohibited Content | Where It Lives Instead |
|-------------------|----------------------|
| Build/dev command tables | `cat Makefile`, `cat package.json` `scripts` field, `cat Cargo.toml` |
| Dependency lists or tables | `cat package.json`, `cat go.mod`, `cat Cargo.toml`, `cat requirements.txt` |
| Infrastructure inventory (Hosting, CI/CD, Database, External services as fields) | Presence/absence of `.github/workflows/`, `Dockerfile`, `docker-compose.yml`, `*.tf` |
| Naming convention tables | Read any 2-3 source files |
| Data flow descriptions | Trace call chains in source files |
| Error handling descriptions | Read source files |
| Evolution/changelog entries | `git log --oneline` |
| Completed work items | Code exists + `git log` |
| Recent changes list | `git log --oneline -5` |
| Framework/test runner/bundler/linter/package manager fields | Config files (`tsconfig.json`, `.eslintrc`, `jest.config`, etc.) |
| Code summaries (what a function does, what a module contains) | Read the code |

**Derivability test** (applied per-claim during filling): If a claim can be verified by reading a single project file or running a single command (`git log`, `ls`, `cat <file>`), it MUST NOT appear in memory.

**Exception**: The `Stack` fields in techContext.md (Language, Runtime) are permitted as 1-line routing hints despite being derivable, because they prevent agents from needing to scan the entire project to identify the language.

**Store in memory**: thread state, durable decisions, routing hints ("if working on X, read Y first"), non-obvious constraints, gotchas, rejected alternatives, product intent, scope boundaries.

**Never store**: directory listings, build commands, dependency tables, infrastructure inventory, naming conventions, data flow, error handling approach, evolution logs, code summaries.

### 1e. Specificity gate

Before writing any memory bank file, apply these self-checks to every sentence:

- **Substitution test**: Could this sentence describe a different project? If yes, it's filler — make it specific or delete it.
- **Quantification test**: Does it use "several", "various", "many" without specifics? Replace with an actual list or count, or delete.
- **Hedge test**: "seems to", "appears to", "might" — verify and state as fact, or move to Open Questions.
- **Tautology test**: Does it restate the section header? Delete.

**Density test**: Each section must contain at least one proper noun (tool name, file path, pattern name, dependency). A section with zero proper nouns is filler.

### 1f. No-filler rule

Every sentence in a memory bank file must satisfy at least one of:
1. Names something specific (a file, tool, pattern, endpoint, config key)
2. States a relationship between two specific things
3. Captures a decision and its rationale
4. Identifies a gap or open question

If none apply, delete the sentence.

**Evidence anchors**: When writing claims in warm files (systemPatterns, techContext, decisions), add a `Source:` line pointing to where the claim can be verified — a file path or commit hash. This is required for non-obvious claims. Use bare references only (e.g., `Source: adapter/adapter.go`). Never add evidence anchors to essential files (projectContext, activeState).

**Confidence markers**: Mark claims by certainty:
- `[observed]` — seen directly in code or config
- `[inferred]` — deduced from structure, naming, or context
- `[assumed]` — not verified, best guess

Only in warm files. Never in essential files.

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
- For each of the 5 template files, follow this two-step process:
  1. **Copy**: Read the template from `references/templates/<file>` and write it verbatim to `memory-bank/<file>`
  2. **Fill**: Use the Edit tool to replace each `[fill: ...]` placeholder and HTML comment with real content discovered in Steps 1a-1c

This copy-then-edit workflow ensures the template structure is preserved. The templates contain key-value fields (like `Language:`), arrow notation, and fixed section headings that MUST appear in the final output.

**Rules when editing:**
- **Key-value fields** (e.g., `Language: [fill: ...]`): replace the `[fill: ...]` placeholder with the real value. Do NOT delete the line or convert to bullets.
- **Section headings**: keep exactly as named. Do NOT rename sections.
- **Arrow notation** in Component Relationships: replace the placeholder with real `A -> B : description` lines.
- **Arrow notation** in Key User Flows: replace the placeholder with real `Trigger → Action → Outcome` lines.
- **HTML comments**: replace with real content. Delete the comment tags but keep the surrounding structure.

Template files: `projectContext.md`, `activeState.md`, `systemPatterns.md`, `techContext.md`, `decisions.md`

**The `memory-bank/` directory MUST contain ONLY these 5 files.** No additional markdown files, no subdirectories, no supplementary context files. If project-specific context doesn't fit within the 5-file budget, compress — do not create a 6th file. Exception: a `.gitkeep` or `.gitignore` file is permitted for version control purposes.

**Per-file line budgets** (HARD ceilings — no tolerance):

| File | Hard Ceiling | Notes |
|------|-------------|-------|
| `projectContext.md` | 80 lines | Essential. |
| `activeState.md` | 70 lines | Essential. Combined with projectContext ≤ 150. |
| `systemPatterns.md` | 100 lines | Warm. |
| `techContext.md` | 60 lines | Warm. |
| `decisions.md` | 150 lines | Warm. Append-only. |
| **Total** | **460 lines** | |

If any file exceeds its ceiling after population, compress before proceeding. There is no "marginally over" tolerance. The ceiling IS the maximum.

**Filling guidance by file** (what to include vs. exclude):

- **projectContext.md** — project identity, intent, and scope in one document. Project name from manifest/repo. Overview from README + entry point analysis. Purpose: why the project exists. Target audience from README/docs. Core requirements from README or docs. Key user flows from route definitions or CLI commands (arrow notation required). Scope from README or inferred.
  - *Include*: what the project is, why it exists, who it's for, core requirements, success criteria, scope boundaries
  - *Exclude*: technical implementation details, session state, build commands, dependency lists
  - Rewrite rarely

- **activeState.md** — session handoff document. An agent reading ONLY this file and projectContext.md MUST know what to work on next.
  - *Include*: exact next action (Resume Here), current workstream, 3-5 working set files, in-progress items, remaining work, blockers, known issues, open questions
  - *Exclude*: completed work, recent changes log, evolution timeline, deep background
  - Rewrite aggressively every update

- **systemPatterns.md** — architecture and design intent. HOW things fit together and WHY. Benefits most from deep analysis.
  - *Include*: architecture type/shape, entry points, layer structure, key design decisions with rationale, non-obvious design patterns, component relationships (arrow notation), gotchas and traps
  - *Exclude*: naming conventions, data flow descriptions, error handling approach, code summaries, one-off features
  - Update only when patterns change

- **techContext.md** — non-obvious technical constraints ONLY. Does NOT inventory the tech stack.
  - *Include*: language + runtime (routing hints), constraints that will break code if unknown, setup gotchas not in README, environment quirks not in config files
  - *Exclude*: build commands, dependency tables, infrastructure fields, framework/test runner/bundler/linter/package manager fields, environment variables already in config
  - Update when constraints change

- **decisions.md** — decisions, rejected alternatives, intentional patterns. The highest-value non-derivable content.
  - *Include*: key decisions with date/rationale/scope/status/source, rejected alternatives (≥1 on init), intentional patterns that look wrong but are correct
  - *Exclude*: vague observations, implementation details, code summaries
  - Append-only, compress formatting if it grows

- If a section has no discoverable content:
  - Write `None identified` (for Blockers, Known Issues, Gotchas, Setup Gotchas, Environment Quirks)
  - Write `No active thread` or equivalent factual statement (for Resume Here, Primary Thread, In Progress)
  - NEVER leave a section heading with no content below it
  - NEVER use `Not yet documented`

### 4b. Format verification (MANDATORY — 44 checks, ALL must pass)

After writing all 5 files, re-read each one and verify every check below. If ANY check fails, edit the file to fix it before proceeding. Do not skip this step.

#### File-Level Checks (6 checks)
- [ ] Exactly 5 `.md` files exist in `memory-bank/` — no more, no fewer
- [ ] No non-core files in `memory-bank/` (only exception: `.gitkeep`, `.gitignore`)
- [ ] No file exceeds its hard ceiling (projectContext ≤80, activeState ≤70, systemPatterns ≤100, techContext ≤60, decisions ≤150)
- [ ] Essential files combined (projectContext + activeState) ≤ 150 lines
- [ ] Total all files ≤ 460 lines
- [ ] No subdirectories in `memory-bank/`

#### Derivability Gate Checks (11 checks)
- [ ] No build/dev command tables in any file
- [ ] No dependency lists or tables in any file
- [ ] No infrastructure inventory fields (Hosting, CI/CD, Database, External services)
- [ ] No naming convention tables in any file
- [ ] No data flow sections in any file
- [ ] No error handling sections in any file
- [ ] No evolution/changelog entries in any file
- [ ] No completed work items in activeState.md
- [ ] No recent changes list in activeState.md
- [ ] No framework/runner/bundler/linter/package-manager fields in techContext.md
- [ ] No code summaries (what a function does, what a module contains)

#### Structural Checks (17 checks)
- [ ] projectContext.md has all 7 required section headings: `## Identity`, `## Purpose`, `## Target Audience`, `## Core Requirements`, `## Success Criteria`, `## Key User Flows`, `## Scope` (with `### In Scope` and `### Out of Scope`)
- [ ] activeState.md has all 8 required section headings: `## Resume Here`, `## Primary Thread`, `## Working Set`, `## In Progress`, `## Remaining`, `## Blockers`, `## Known Issues`, `## Open Questions`
- [ ] systemPatterns.md has all 5 required section headings: `## Architecture Overview`, `## Key Design Decisions`, `## Design Patterns`, `## Component Relationships`, `## Gotchas & Traps`
- [ ] techContext.md has all 4 required section headings: `## Stack`, `## Non-Obvious Constraints`, `## Setup Gotchas`, `## Environment Quirks`
- [ ] decisions.md has all 3 required section headings: `## Key Decisions`, `## Rejected Alternatives`, `## Intent & Patterns`
- [ ] No additional section headings beyond those specified above
- [ ] All key-value fields use `Key: value` format — not bullets, not bold labels, not prose
- [ ] Component Relationships uses arrow notation `->` (not prose)
- [ ] Key User Flows uses arrow notation `→` (not numbered steps)
- [ ] Resume Here names a specific file, function, or task (not generic)
- [ ] Working Set contains 3-5 file paths
- [ ] Every Key Decision entry has all 4 required lines: date+decision, Scope, Status, Source
- [ ] Decision dates are commit dates, not analysis dates (use earliest evidencing commit if unknown)
- [ ] ≥1 Rejected Alternative entry with all 3 required lines (`**What was considered**`, `**Why rejected**`, `**Reconsider if**`)
- [ ] No section heading has empty content below it
- [ ] No `[fill:]` placeholders remain
- [ ] No `Not yet documented` appears anywhere

#### Evidence Checks (5 checks)
- [ ] systemPatterns.md, techContext.md, decisions.md each have ≥1 `Source:` line
- [ ] Every `Source:` reference points to a file that exists in the project
- [ ] Warm files use confidence markers `[observed]`, `[inferred]`, or `[assumed]` on claims
- [ ] Essential files (projectContext, activeState) contain zero `Source:` lines
- [ ] Essential files contain zero confidence markers

#### Specificity Checks (5 checks)
- [ ] No sentence passes the substitution test (could describe a different project)
- [ ] No unquantified vague terms ("several", "various", "many", "some")
- [ ] No hedging language ("seems to", "appears to", "might") outside Open Questions
- [ ] No tautologies (sentence restates its section heading)
- [ ] Every section contains ≥1 proper noun (file path, tool name, pattern name, dependency, config key)

**Total: 44 checks. All 44 must pass.**

### 5. Create/update agent config

Read the snippet from the skill's `references/agent-config-snippet.md`.

Detect which agent is executing this skill and update the appropriate config file:

- **Claude Code** → `CLAUDE.md`
  - Add `@memory-bank/projectContext.md` and `@memory-bank/activeState.md` as auto-loading imports
  - Add the warm file loading triggers (without `@` prefix) so the agent knows when to load them
  - If no `CLAUDE.md` exists → create one with the snippet content
  - If `CLAUDE.md` exists → append the snippet to the end (never overwrite existing content)

- **Codex** → `AGENTS.md`
  - Use plain file path references (no `@` prefix)
  - When using the snippet content, strip the leading `@` from any file references (e.g., `@memory-bank/projectContext.md` → `memory-bank/projectContext.md`)
  - If no `AGENTS.md` exists → create one with the transformed snippet content
  - If `AGENTS.md` exists → append the transformed snippet to the end (never overwrite existing content)

- **Other agents** (Cursor, Windsurf, etc.) → use whichever config file the agent convention expects, falling back to `AGENTS.md`

### 6. Summary
- Print a summary of what was created/modified
- List all 5 files created in memory-bank/
- Note which agent config file was created or updated
- Mention available subcommands: update, status, export, ignore, track, purge
- Remind user that 2 essential files are auto-loaded at session start, with 3 warm files loaded on demand
