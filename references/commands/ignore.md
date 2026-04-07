# memory ignore

Add `memory-bank/` to `.gitignore` to stop git-tracking the memory bank.

## Steps

1. **Check if `.git/` exists** — if not, inform user this is not a git repo and exit
2. **Check if `memory-bank/` is already in `.gitignore`** — if yes, inform user and exit
3. **Append `memory-bank/` to `.gitignore`**:
   - If `.gitignore` exists: read the file. If it ends with a newline (or is empty), append `memory-bank/`. If it does NOT end with a newline, append a newline first, then `memory-bank/`.
   - If `.gitignore` doesn't exist, create it with `memory-bank/` followed by a trailing newline.
4. **Untrack files if tracked**: Check if any memory-bank files are currently tracked (`git ls-files --error-unmatch memory-bank/ 2>/dev/null`). If files are tracked:
   - Show the user: `git ls-files --cached memory-bank/` (list of files that will be unstaged)
   - Ask: "These files will be removed from git tracking (kept on disk). Proceed? (y/n)"
   - Only run `git rm -r --cached memory-bank/` after user confirmation. If no files are tracked, skip this step.
5. **Report**: Confirm memory bank is now gitignored
