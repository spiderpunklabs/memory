# memory status

Full health check of the memory bank. Read-only — does not modify any files.

## Steps

1. **Check memory-bank/ exists** — if not, tell user to run the init command

2. **Read all 7 memory bank files** and for each file:
   - Count populated sections (has content beyond headers) vs empty sections (only headers or "Not yet documented")
   - Check last modification date via `git log -1 --format="%ai" -- memory-bank/<file>`

3. **Check staleness**:
   - Count commits since each memory bank file was last modified
   - If >10 commits since last update, flag as stale

4. **Check for bloat**:
   - Count the number of lines in each memory bank file
   - If any file exceeds 200 lines, flag it with a "consider consolidating" warning
   - Suggest running the update command which includes a consolidation step

5. **Check cross-file consistency**:
   - Does `activeContext.md` "Current Focus" align with `progress.md` "In Progress"?
   - Does `techContext.md` match what's actually in package.json / requirements.txt / go.mod? (re-scan and diff)
   - Does `systemPatterns.md` reflect the actual directory structure?
   - Does `projectbrief.md` align with the current README.md?
   - Does `decisions.md` have entries, or is it still empty from init?

6. **Output a health report**:

```
Memory Bank Status:
  projectbrief.md    [status] [sections]    (updated: YYYY-MM-DD)
  productContext.md  [status] [sections]    (updated: YYYY-MM-DD)
  systemPatterns.md  [status] [sections]    (updated: YYYY-MM-DD)
  techContext.md     [status] [sections]    (updated: YYYY-MM-DD)
  activeContext.md   [status] [sections]    (updated: YYYY-MM-DD)
  progress.md        [status] [sections]    (updated: YYYY-MM-DD)
  decisions.md       [status] [sections]    (updated: YYYY-MM-DD)

Bloat:
  [any files over 200 lines — suggest consolidation]

Consistency:
  [any cross-file inconsistencies found]

Overall: X/7 healthy, Y incomplete, Z stale
Tip: Run the update command to refresh
```
