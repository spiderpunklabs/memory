# /memory init [description]

Initialize a structured memory bank in the current project.

Accepts an optional description string for seeding context (useful for empty/new projects):
- `/memory init` — auto-scan project for context
- `/memory init A React Native fitness app with Expo and Supabase` — use description as seed context

## Steps

### 1. Discover
- Check if user provided a description string after "init"
- Scan the current working directory for: `memory-bank/`, `.gitignore`, `.git/`
- Detect agent config files: `CLAUDE.md` (Claude Code), `AGENTS.md` (Codex, Cursor, etc.)
- Detect tech stack by checking for: `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`, `*.csproj`
- Read `README.md` or `README` if present
- Note the directory structure (top-level only)

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
- For each of the 7 template files (`projectbrief.md`, `productContext.md`, `systemPatterns.md`, `techContext.md`, `activeContext.md`, `progress.md`, `decisions.md`): read the template from the skill's `references/templates/` directory, fill in real project context discovered in Step 1 (replacing HTML comment hints with actual content), and write to `memory-bank/`
- `decisions.md` starts mostly empty — its sections are populated over time as decisions are made
- Templates provide structure; fill in substance from what was discovered
- If a section has no discoverable info, leave it with a brief "Not yet documented" note rather than the HTML comment

### 5. Create/update agent config

Read the snippet from the skill's `references/claudemd-snippet.md`.

Detect which agent is executing this skill and update the appropriate config file:

- **Claude Code** → `CLAUDE.md`
  - Use `@memory-bank/filename.md` syntax for auto-loading imports
  - If no `CLAUDE.md` exists → create one with the snippet content (using `@` imports)
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
- Mention available `/memory` subcommands: update, status, export, hide, unhide, purge
- Remind user that memory bank files are loaded at the start of each session via agent config imports
