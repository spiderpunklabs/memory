# /memory status

Full health check of the memory bank. Read-only — does not modify any files.

## Steps

1. **Check memory-bank/ exists** — if not, tell user to run `/memory init`

2. **Read all 6 memory bank files** and for each file:
   - Count populated sections (has content beyond headers) vs empty sections (only headers or "Not yet documented")
   - Check last modification date via `git log -1 --format="%ai" -- memory-bank/<file>`

3. **Check staleness**:
   - Count commits since each memory bank file was last modified
   - If >10 commits since last update, flag as stale

4. **Check cross-file consistency**:
   - Does `activeContext.md` "Current Focus" align with `progress.md` "In Progress"?
   - Does `techContext.md` match what's actually in package.json / requirements.txt / go.mod? (re-scan and diff)
   - Does `systemPatterns.md` reflect the actual directory structure?
   - Does `projectbrief.md` align with the current README.md?

5. **Output a health report**:

```
Memory Bank Status:
  projectbrief.md    [status] [sections]    (updated: YYYY-MM-DD)
  productContext.md  [status] [sections]    (updated: YYYY-MM-DD)
  systemPatterns.md  [status] [sections]    (updated: YYYY-MM-DD)
  techContext.md     [status] [sections]    (updated: YYYY-MM-DD)
  activeContext.md   [status] [sections]    (updated: YYYY-MM-DD)
  progress.md        [status] [sections]    (updated: YYYY-MM-DD)

Consistency:
  [any cross-file inconsistencies found]

Overall: X/6 healthy, Y incomplete, Z stale
Tip: Run /memory update to refresh
```
