# memory diff

Show what changed in memory bank files since the last commit (or between two commits).

## Steps

1. **Validate**: Check `memory-bank/` exists. If not, tell user to run init and stop.

2. **Check git**: If no `.git/` directory (either at cwd or via `git rev-parse --show-toplevel`), report "Not a git repository — diff requires git history" and exit.

3. **Generate diff**:
   - If memory-bank files have uncommitted changes: run `git -C <project-root> diff -- memory-bank/`
   - If memory-bank files have staged changes: also run `git -C <project-root> diff --cached -- memory-bank/`
   - If no uncommitted or staged changes: run `git -C <project-root> diff HEAD~1 -- memory-bank/` (last commit's changes)
   - If user provided a commit range (e.g., `memory diff abc123..def456`): run `git -C <project-root> diff <range> -- memory-bank/`

4. **Output**: Display the diff output. If empty: "No changes detected in memory bank files."
