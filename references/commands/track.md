# memory track

Remove `memory-bank/` from `.gitignore` to resume git-tracking the memory bank.

## Steps

1. **Check if `.git/` exists** — if not, inform user this is not a git repo and exit
2. **Check if `memory-bank/` is in `.gitignore`** — if not, inform user it's already tracked and exit
3. **Remove `memory-bank/` from `.gitignore`**:
   - Use Edit tool to remove the line containing `memory-bank/`
   - Also remove any blank lines this creates
4. **Stage files**: Inform the user: "Staging memory bank files with `git add memory-bank/`." Then run the command.
5. **Report**: Confirm memory bank is now git-tracked
