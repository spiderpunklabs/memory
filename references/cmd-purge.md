# memory purge

Delete the memory and clean up agent config references.

## Steps

1. **Warn**: "This will permanently delete `.memory/` and all 4 memory files. A backup will be saved first."
2. **Backup**: Read all files, write a consolidated export to `.memory-export-YYYYMMDD.md` in the project root.
3. **Confirm**: "Type `purge` to confirm, or anything else to cancel."
4. **If confirmed**:
   - Delete `.memory/` directory and all contents
   - Remove memory section from agent config. Targets: `AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md` (v1.0.0 wrote the block to `CLAUDE.md`), `.cursor/rules/memory.mdc` (modern Cursor, preferred), and `.cursorrules` (legacy Cursor). For each file, remove only the block that starts at a `<!-- memory:begin v=X.Y.Z -->` line (any version) and ends at the next `<!-- memory:end -->` line (markers inclusive). Never touch text outside the markers. If `.cursor/rules/memory.mdc` is left empty after marker removal, delete the file.
   - Leave any `@AGENTS.md` / `@../AGENTS.md` import line in `CLAUDE.md` or `.claude/CLAUDE.md` in place. Init may have added it, but it cannot be told apart from one the user wrote, and it still loads the rest of `AGENTS.md`. Mention the line in the report so the user can remove it by hand if they want.
   - Remove the gitignore ownership block only if it is exactly these 3 lines (the version in the first line may be any `X.Y.Z`):
     ```
     # memory:begin v=1.1.0
     .memory/
     # memory:end
     ```
     If a bare `.memory/` line appears without the surrounding markers, leave it alone — the user authored it.
5. **Report**: List what was deleted. Remind user of the backup filename.
