# memory track

Remove `memory-bank/` from `.gitignore` to resume git-tracking the memory bank.

## Steps

1. **Check if `.git/` exists** — if not, inform user this is not a git repo and exit
2. **Check if `memory-bank/` is in `.gitignore`** — if not, inform user it's already tracked and exit
3. **Remove `memory-bank/` from `.gitignore`**:
   - Use Edit tool to remove the line containing `memory-bank/`
   - Also remove any blank lines this creates
4. **Stage files**: Show the user the files in `memory-bank/` that will be staged. Ask: "These files will be added to git tracking. Proceed? (y/n)". Only run `git add memory-bank/` after user confirmation.
5. **Report**: Confirm memory bank is now git-tracked
