# memory purge

Delete the memory and clean up agent config references.

## Steps

1. **Warn**: "This will permanently delete `.memory/` and all 4 memory files. A backup will be saved first."
2. **Backup**: Read all files, write a consolidated export to `.memory-export-YYYYMMDD.md` in the project root.
3. **Confirm**: "Type `purge` to confirm, or anything else to cancel."
4. **If confirmed**:
   - Delete `.memory/` directory and all contents
   - Remove memory section from agent config (CLAUDE.md, AGENTS.md, or .cursorrules)
   - If `.memory/` is in `.gitignore`, remove that line
5. **Report**: List what was deleted. Remind user of the backup filename.
