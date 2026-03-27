# memory export

Consolidate all 5 memory bank files into a single markdown document.

## Steps

1. **Read all 5 memory bank files** in order:
   - projectContext.md, activeState.md, systemPatterns.md, techContext.md, decisions.md

2. **Build a single document**:
   - Add a header: `# Memory Bank Export — <project name>`
   - Add export timestamp: `Exported: YYYY-MM-DD HH:MM`
   - Add each file's content as a top-level section, separated by `---`
   - Preserve all content exactly as-is

3. **Output options** — ask the user:
   - **Print to console** — display the consolidated document
   - **Write to file** — save as `memory-bank-export.md` in the current directory

4. **Report**: Note the total size and number of sections exported

> **Note**: The purge command performs its own inline backup without invoking this command. This command is for user-initiated exports only.
