# /memory hide

Add `memory-bank/` to `.gitignore` to stop git-tracking the memory bank.

## Steps

1. **Check if `.git/` exists** — if not, inform user this is not a git repo and exit
2. **Check if `memory-bank/` is already in `.gitignore`** — if yes, inform user and exit
3. **Append `memory-bank/` to `.gitignore`**:
   - If `.gitignore` exists, append a newline + `memory-bank/`
   - If `.gitignore` doesn't exist, create it with `memory-bank/` as the only entry
4. **Run `git rm -r --cached memory-bank/`** to untrack already-tracked files (if any are tracked)
5. **Report**: Confirm memory bank is now gitignored
