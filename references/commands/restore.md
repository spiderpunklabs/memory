# memory restore [source]

Restore memory bank files from a backup export, archive, or previous git commit.

## Steps

1. **Validate**: If `memory-bank/` does not exist, create it.

2. **Determine source**:
   - If user provided a filename (e.g., `memory restore memory-bank-export.md`): use that export file
   - If user provided a commit hash (e.g., `memory restore abc123`): use `git show <hash>:memory-bank/<file>` for each file
   - If user provided an archive path (e.g., `memory restore .memory-bank-archive/`): use files from that directory
   - If no argument: look for `memory-bank-export*.md` files and `.memory-bank-archive/` in the project. List available options and ask user to choose.

3. **From export file**:
   - Read the export file
   - Split on `---` separators to extract individual file contents (sections start with `# Project Context`, `# Active State`, etc.)
   - Write each section to its corresponding `memory-bank/<file>.md`

4. **From git commit**:
   - For each of the 5 files, run `git show <hash>:memory-bank/<file>` and write to `memory-bank/<file>`
   - If a file didn't exist at that commit, warn and skip it

5. **From archive directory**:
   - Copy each `.md` file from the archive to `memory-bank/`
   - Only copy files that match the 5 expected filenames

6. **Verify**: Run the validation checks defined in `references/commands/status.md`. Report any failures but do not auto-fix — the user may want the historical state as-is.

7. **Report**: List restored files and their line counts.
