# /memory purge

Delete the memory bank and all related configuration. This is destructive and irreversible.

## Steps

1. **Confirm with user**: "This will permanently delete:
   - `memory-bank/` directory and all 6 files
   - Memory bank section from agent config (CLAUDE.md / AGENTS.md)
   Are you sure? (yes/no)"

2. **If confirmed**:
   - Delete the `memory-bank/` directory and all contents
   - Remove the memory bank section from the appropriate agent config file:
     - **Claude Code** → edit `CLAUDE.md` to remove the block from `# Memory Bank` through `## Memory Bank Rules` and its content
     - **Codex / other agents** → edit `AGENTS.md` (or whichever config file contains the memory bank section) to remove the same block
   - If the agent config file is now empty after removal, delete it too
   - If `memory-bank/` is in `.gitignore`, remove that line too

3. **Report**: List everything that was deleted/modified
4. **Note**: "Run `/memory init` to create a fresh memory bank anytime."
