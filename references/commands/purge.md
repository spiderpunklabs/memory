# memory purge

Delete the memory bank and all related configuration. This is destructive and irreversible.

## Steps

1. **Auto-backup (transactional)**: Before any destructive action, read all 5 memory bank files and write a consolidated export (using the format from export.md step 2) directly to a file. If `memory-bank-export.md` does not exist, write to that filename. If it already exists, write to `memory-bank-export-YYYYMMDD-HHMM.md` using the current timestamp.

   **Backup verification**: After writing, re-read the backup file and verify it contains all 5 section headers (`# Project Context`, `# Active State`, `# System Patterns`, `# Tech Context`, `# Decisions`). If the backup file is missing, empty, or incomplete → **ABORT**. Report: "Backup verification failed — purge aborted. No files were deleted." Inform the user of the backup filename only after verification passes.

   **Secret scan**: Before writing the backup, scan all content for secret patterns (`sk-`, `ghp_`, `AIza`, `AKIA`, `-----BEGIN`, `password=`, `token=`). If detected, warn the user and ask whether to redact in the backup.

2. **Path validation**: Resolve `memory-bank/` relative to the current working directory. Never follow absolute paths or parent-directory references (`../`). If the resolved path escapes the project root, abort with an error.

3. **Warn about data loss**: Before the confirmation prompt, display this warning:

   "⚠️ **Warning**: Purging will destroy all accumulated project context, including:
   - **Key decisions and their rationale** (decisions.md) — these cannot be reconstructed from code
   - **Rejected alternatives** — why certain approaches were not taken
   - **Non-obvious constraints and gotchas** — traps that took time to discover
   - **Active work state** — what to work on next and current blockers

   A backup will be saved before deletion, but re-initializing will lose all hand-curated context that was refined over multiple sessions."

4. **Confirm with user**: "This will permanently delete:
   - `memory-bank/` directory and all 5 files (projectContext.md, activeState.md, systemPatterns.md, techContext.md, decisions.md)
   - Memory bank section from agent config (CLAUDE.md / AGENTS.md)

   Type `purge` to confirm, or anything else to cancel."

5. **If confirmed** (user typed exactly `purge`):
   - Delete the `memory-bank/` directory and all contents
   - Remove the memory bank section from the appropriate agent config file:
     1. Look for `<!-- MEMORY-BANK-START -->` and `<!-- MEMORY-BANK-END -->` delimiters. If found, remove everything between and including these markers.
     2. Fallback (pre-v0.3.0 installs): look for the `# Memory Bank` heading, remove from there to the next `#`-level heading (or end of file). Also remove any lines matching `@memory-bank/*.md` or `memory-bank/*.md` above the heading.
     3. After removal, verify no orphaned memory-bank references remain in the file. If found, list them and ask the user to review.
     - **Claude Code** → edit `CLAUDE.md`
     - **Codex / other agents** → edit `AGENTS.md` (or whichever config file contains the memory bank section)
   - If the agent config file is now empty after removal, delete it too
   - If `memory-bank/` is in `.gitignore`, remove that line too

6. **Report**: List everything that was deleted/modified. Remind the user of the backup filename from step 1.
7. **Note**: "Run the init command to create a fresh memory bank anytime. Note that a fresh init will auto-scan the project but cannot recover hand-curated decisions, rejected alternatives, or gotchas from the purged memory bank — refer to the export backup if needed."
