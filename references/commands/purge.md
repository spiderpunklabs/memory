# memory purge

Delete the memory bank and all related configuration. This is destructive and irreversible.

## Steps

1. **Auto-backup**: Before any destructive action, automatically run the export command to save a backup to `memory-bank-export.md` in the current directory. Inform the user that a backup has been created.

2. **Path validation**: Resolve `memory-bank/` relative to the current working directory. Never follow absolute paths or parent-directory references (`../`). If the resolved path escapes the project root, abort with an error.

3. **Confirm with user**: "This will permanently delete:
   - `memory-bank/` directory and all 7 files (projectBrief.md, productContext.md, systemPatterns.md, techContext.md, activeContext.md, progress.md, decisions.md)
   - Memory bank section from agent config (CLAUDE.md / AGENTS.md)

   Type `purge` to confirm, or anything else to cancel."

4. **If confirmed** (user typed exactly `purge`):
   - Delete the `memory-bank/` directory and all contents
   - Remove the memory bank section from the appropriate agent config file:
     - **Claude Code** → edit `CLAUDE.md` to remove the block from `# Memory Bank` through `## Memory Bank Rules` and its content
     - **Codex / other agents** → edit `AGENTS.md` (or whichever config file contains the memory bank section) to remove the same block
   - If the agent config file is now empty after removal, delete it too
   - If `memory-bank/` is in `.gitignore`, remove that line too

5. **Report**: List everything that was deleted/modified
6. **Note**: "Run the init command to create a fresh memory bank anytime."
