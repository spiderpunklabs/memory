# memory purge

Delete the memory and clean up agent config references.

## Steps

1. **Warn**: "This will permanently delete `.memory/` and all 4 memory files. A backup will be saved first."
2. **Backup**: Read all files, write a consolidated export to `.memory-export-YYYYMMDD.md` in the project root.
3. **Confirm**: "Type `purge` to confirm, or anything else to cancel."
4. **If confirmed**:
   - Delete `.memory/` directory and all contents
   - Remove memory section from agent config. Targets: `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/memory.mdc` (modern Cursor, preferred), and `.cursorrules` (legacy Cursor). For each file, remove only the block bounded by `<!-- memory:begin v=1.0.0 -->` and `<!-- memory:end -->` (markers inclusive). Never touch text outside the markers. If `.cursor/rules/memory.mdc` is left empty after marker removal, delete the file.
   - Remove the gitignore ownership block only if the exact 3-line block matches:
     ```
     # memory:begin v=1.0.0
     .memory/
     # memory:end
     ```
     If a bare `.memory/` line appears without the surrounding markers, leave it alone — the user authored it.
5. **Report**: List what was deleted. Remind user of the backup filename.
