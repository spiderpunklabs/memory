# memory init [description]

Create `.memory/` and populate it from a project scan.

## Steps

### 1. Check for existing memory
- If `.memory/` exists: ask "Reinitialize (overwrites current memory) or cancel?"
- If `memory-bank/` exists (old format): ask "Migrate to new format or start fresh?"

### 2. Scan the project
Read what's available — don't force the user to answer questions if code exists:
- README, package.json/Cargo.toml/go.mod/pyproject.toml, directory structure
- `git log --oneline -20` for recent history and decisions
- 3-5 key source files (entry points, config, routes)
- If empty project and no description provided: ask "What is this project?"
- If description provided: use it as seed context

### 3. Apply the derivability gate
Before writing anything, test every candidate sentence:
> Can this be verified by reading one file or running one command?
> If yes — don't store it.

Store: decisions, constraints, gotchas, scope boundaries, intent, conventions, handoff state.
Never store: dependency lists, build commands, directory listings, code summaries, changelogs.

### 4. Create files
- Create `.memory/` directory
- Copy each template from `templates/`, then fill placeholders with content from the scan
- If a section has no discoverable content: write "None" or "None identified"
- Don't write actual secret values (API keys, tokens, passwords) — store variable names only
- After filling, strip HTML comments from the populated files (they're guidance for filling, not content)

### 5. Configure agent
Detect which agent is running and update the appropriate config file:
- **Claude Code** → append to `CLAUDE.md` (create if needed). Use `@.memory/` imports for auto-loading.
- **Codex** → append to `AGENTS.md` (create if needed). Use plain file path references.
- **Cursor** → append to `.cursorrules` (create if needed).
- Read `agent-config-snippet.md` for the exact content to inject.

### 6. Git tracking
- If `.git/` exists: ask "Git-track or gitignore `.memory/`?"
- If gitignored: append `.memory/` to `.gitignore`
- If no `.git/`: skip this step

### 7. Report
List created files with line counts. Remind user: "Run `/memory update` at the end of each session."

## Budgets
HANDOFF.md: 80 | SCOPE.md: 80 | SYSTEM.md: 80 | DECISIONS.md: 120
