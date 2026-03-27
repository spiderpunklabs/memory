# memory ignore

Add `memory-bank/` to `.gitignore` to stop git-tracking the memory bank.

## Steps

1. **Check if `.git/` exists** — if not, inform user this is not a git repo and exit
2. **Check if `memory-bank/` is already in `.gitignore`** — if yes, inform user and exit
3. **Append `memory-bank/` to `.gitignore`**:
   - If `.gitignore` exists, append a newline + `memory-bank/`
   - If `.gitignore` doesn't exist, create it with `memory-bank/` as the only entry
4. **Untrack files if tracked**: Check if any memory-bank files are currently tracked (`git ls-files --error-unmatch memory-bank/ 2>/dev/null`). If files are tracked, inform the user: "Memory bank files are currently tracked by git. Removing them from the index with `git rm -r --cached memory-bank/` (files on disk are not affected)." Then run the command. If no files are tracked, skip this step.
5. **Report**: Confirm memory bank is now gitignored
