# memory status

Full health check of the memory bank. Read-only — does not modify any files.

## Steps

1. **Check memory-bank/ exists** — if not, tell user to run the init command

2. **Read all 7 memory bank files** and for each file:
   - Count populated sections (has content beyond headers) vs empty sections (only headers or "Not yet documented")
   - Check last modification date via `git log -1 --format="%ai" -- memory-bank/<file>`

3. **Score staleness** for each file:
   - Count commits since each memory bank file was last modified (`git rev-list --count <last-commit>..HEAD`)
   - Assign a staleness level:
     - **Fresh**: updated within last 3 commits or last session
     - **Warm**: 4-10 commits since last update
     - **Stale**: 11-20 commits since last update
     - **Critical**: >20 commits since last update, or file contains "Not yet documented" in most sections

4. **Check essential file budget**:
   - Count combined lines of `projectBrief.md` + `activeContext.md`
   - If over 150 lines: flag "Essential files over budget — compress during next update"

5. **Check for bloat**:
   - Count the number of lines in each memory bank file
   - If any file exceeds 200 lines, flag it with a "consider consolidating" warning

6. **Verify evidence anchors**:
   - Scan warm files (systemPatterns.md, techContext.md, decisions.md, productContext.md, progress.md) for `Source:` lines outside of HTML comments (`<!-- -->` blocks)
   - For each file path referenced, check if the file still exists
   - For each commit hash referenced, check if it exists in git history (`git cat-file -t <hash>`)
   - Report broken evidence:
     - Count total evidence anchors found
     - List any with broken references (file deleted, commit not found)
   - This is informational — broken evidence doesn't block anything, but signals claims that may need re-verification

7. **Check cross-file consistency**:
   - Does `activeContext.md` "Primary Thread" align with `progress.md` "In Progress"?
   - Does `techContext.md` match what's actually in package.json / requirements.txt / go.mod? (re-scan and diff)
   - Does `systemPatterns.md` reflect the actual directory structure?
   - Does `projectBrief.md` align with the current README.md?
   - Does `decisions.md` have entries, or is it still empty from init?

8. **Priority-ranked update recommendations**:
   - Sort files by: essential + stale first, then on-demand + stale, then warm
   - Recommend update order based on priority

9. **Output a health report**:

```
Memory Bank Status:

  Essential (hot):
    projectBrief.md    [Fresh]  62 lines    (updated: 2026-03-17)
    activeContext.md   [Stale]  94 lines    (updated: 2026-03-10)
    Budget: 156/150 lines ⚠️ over budget — compress on next update

  On-demand (warm):
    decisions.md       [Fresh]  38 lines    (updated: 2026-03-17)
    systemPatterns.md  [Warm]   120 lines   (updated: 2026-03-14)
    techContext.md     [Fresh]  85 lines    (updated: 2026-03-16)
    productContext.md  [Stale]  45 lines    (updated: 2026-03-08)
    progress.md        [Stale]  67 lines    (updated: 2026-03-09)

  Bloat: [any files over 200 lines]

  Evidence:
    12 anchors across 4 files
    1 broken: decisions.md:15 → src/old-auth.ts (file not found)

  Consistency:
    [any cross-file inconsistencies found]

  Recommended update order:
    1. activeContext.md — stale, essential file
    2. productContext.md — stale
    3. progress.md — stale

  Overall: X/7 fresh, Y warm, Z stale
```
