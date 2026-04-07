# memory export

Consolidate all 5 memory bank files into a single markdown document.

## Steps

1. **Read all 5 memory bank files** in order:
   - projectContext.md, activeState.md, systemPatterns.md, techContext.md, decisions.md

2. **Secret/PII preflight**: Before building the export, scan all content for secret patterns (`sk-`, `ghp_`, `AIza`, `AKIA`, `-----BEGIN`, `password=`, `token=`). If detected, warn the user and ask whether to redact before exporting.

3. **Build a single document**:
   - Add a header: `# Memory Bank Export — <project name>`
   - Add export timestamp: `Exported: YYYY-MM-DD HH:MM`
   - Add each file's content as a top-level section, separated by `---`
   - Preserve all content exactly as-is (unless redacted per step 2)

4. **Output options** — ask the user:
   - **Print to console** — display the consolidated document
   - **Write to file** — save as `memory-bank-export.md` in the current directory
   - **Redacted export** (`memory export --redacted`): omit activeState.md (contains current work state), strip `Source:` lines (internal file paths), replace repo-specific paths with `<project>/` placeholders. Useful for sharing project context without exposing internals.

5. **Report**: Note the total size and number of sections exported

> **Note**: The purge command performs its own inline backup without invoking this command. This command is for user-initiated exports only.
