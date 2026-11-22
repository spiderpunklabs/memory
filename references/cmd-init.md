# memory init [description]

Create `.memory/` and populate it from a project scan.

## Steps

### 1. Check for existing memory
- If `.memory/` exists: ask "Reinitialize (overwrites current memory) or cancel?"
- Migration from a pre-v1.0.0 `memory-bank/` is not supported; the user must `init` fresh.

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
Detect which agent is running and update the appropriate config file. "Project root" means the directory that contains `.memory/`.
- **Claude Code or Codex** → the shared block goes in `AGENTS.md` in the project root. Both agents read the same block, so inject it once, then follow "Claude Code and Codex: `AGENTS.md`" below.
- **Cursor** → write to `.cursor/rules/memory.mdc` if `.cursor/` exists (modern, preferred). Otherwise append to `.cursorrules` (legacy fallback). Create the target file if needed.
- Read `agent-config-snippet.md` for the exact content to inject.

Marker contract (applies to every injected block):
- Each block is bracketed by `<!-- memory:begin v=1.1.0 -->` and `<!-- memory:end -->`.
- A pre-existing block is any region that starts at a line of the form `<!-- memory:begin v=X.Y.Z -->` (any version, e.g. `v=1.0.0`) and ends at the next `<!-- memory:end -->` line.
- If the target file already has a pre-existing block, replace it in place (markers included) with the fresh block. Do not duplicate. If it has more than one, replace the first and remove the others.
- If no such block exists, append the full block at the end of the file.
- Never edit content outside the markers; treat the bounded region as owned by this skill.

Claude Code and Codex: `AGENTS.md`. Run these steps in order:

1. **Write the block.** Apply the marker contract to `AGENTS.md` in the project root (create the file if needed). Never write the block to a `CLAUDE.md`.
2. **Remove a legacy block.** v1.0.0 wrote the block to `CLAUDE.md`. For each of `CLAUDE.md` and `.claude/CLAUDE.md` in the project root: skip it if it does not exist or is a symlink to the project-root `AGENTS.md`. Otherwise, if it contains a pre-existing block (as defined in the marker contract), remove that block (markers included) and nothing else. Do not delete the file, even if only whitespace is left — step 3 adds the import to it.
3. **Make sure Claude Code loads `AGENTS.md`.** Claude Code reads `AGENTS.md` only when there is no `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md` in the working directory or any directory above it (the user-level `~/.claude/CLAUDE.md` does not count). Apply the first case that matches:
   - **The project root has `CLAUDE.md` or `.claude/CLAUDE.md`.** If either one is a symlink to the project-root `AGENTS.md`, or already contains a line that imports it (`@AGENTS.md` in `CLAUDE.md`, `@../AGENTS.md` in `.claude/CLAUDE.md`), change nothing. Otherwise append one import line to the end of one file: `@AGENTS.md` to `CLAUDE.md` if it exists, else `@../AGENTS.md` to `.claude/CLAUDE.md` (imports resolve relative to the file that contains them). Append only — never rewrite, reorder, or truncate existing content.
   - **Otherwise, the project root has `CLAUDE.local.md`, or a directory above the project root has `CLAUDE.md`, `.claude/CLAUDE.md`, or `CLAUDE.local.md`** (ignoring `~/.claude/CLAUDE.md`). Do not edit these files. Warn in the report: "`<path>` exists, so Claude Code will not load `AGENTS.md` and the memory block will not be read. Fix it one of two ways: add an `@` import of this project's `AGENTS.md` to that file (`@AGENTS.md` if the file sits next to it), or set Project instructions to `claude-md-and-agents-md` in Claude Code's settings."
   - **Otherwise** (no such file): change nothing.
4. Never create a `CLAUDE.md`.

Re-running init is idempotent for this step: the block in `AGENTS.md` is replaced in place, a removed legacy block stays removed, and an import line that is already present is not added again. A second run changes nothing.

Claude Code sessions that do not read `AGENTS.md` directly (versions before v2.1.277, or the built-in AGENTS.md plugin disabled) still get the block through the `@AGENTS.md` import in a `CLAUDE.md`; in a project with no `CLAUDE.md`, those sessions do not load it.

### 6. Git tracking
- If `.git/` exists: ask "Git-track or gitignore `.memory/`?"
- If gitignored: append the following three-line ownership block to `.gitignore` (create if needed). Comment lines starting with `#` are valid gitignore syntax and ignored by git matching, so they establish provenance without affecting ignore behavior.
  ```
  # memory:begin v=1.1.0
  .memory/
  # memory:end
  ```
  - If a block bounded by a `# memory:begin` line (any version) and `# memory:end` already exists, leave it as-is (idempotent).
  - If `.memory/` is already present in `.gitignore` outside of the ownership block, do not modify the user's line — append the ownership block anyway so purge has something to clean. The duplicate is harmless.
- If no `.git/`: skip this step

### 7. Report
List created files with line counts. List every change made to agent config in step 5: the file the block was written to, any legacy block removed from a `CLAUDE.md`, and any import line appended (name the file and the line). Print the step 5 warning if one applies. Remind user: "Run `/memory update` at the end of each session."

## Budgets
HANDOFF.md: 80 | SCOPE.md: 80 | SYSTEM.md: 80 | DECISIONS.md: 120
