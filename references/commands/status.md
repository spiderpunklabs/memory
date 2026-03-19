# memory status

Full health check of the memory bank. Read-only — does not modify any files.

## Steps

1. **Check memory-bank/ exists** — if not, tell user to run the init command

2. **Read all 7 memory bank files** and for each file:
   - Count populated sections (has content beyond headers) vs empty sections (only headers or "Not yet documented")
   - Check last modification date via `git log -1 --format="%ai" -- memory-bank/<file>`. If the file has no git history (untracked or uncommitted), report the date as "uncommitted"

3. **Score staleness** for each file:
   - Count commits since each memory bank file was last modified (`git rev-list --count <last-commit>..HEAD`). If a file has no git history, assign staleness as "Unknown — not yet committed"
   - Assign a staleness level:
     - **Unknown**: file has no git history (not yet committed)
     - **Fresh**: updated within last 3 commits or last session
     - **Warm**: 4-10 commits since last update
     - **Stale**: 11-20 commits since last update
     - **Critical**: >20 commits since last update, or file contains "Not yet documented" in most sections

4. **Check per-file budgets**:
   - Count lines in each memory bank file and compare against budgets:

     | File | Budget |
     |------|--------|
     | `projectBrief.md` | 80 |
     | `activeContext.md` | 70 |
     | `productContext.md` | 80 |
     | `systemPatterns.md` | 120 |
     | `techContext.md` | 100 |
     | `progress.md` | 80 |
     | `decisions.md` | 150 |

   - Flag files over budget with "over budget — compress on next update"
   - Check combined lines of `projectBrief.md` + `activeContext.md`. If over 150: flag "Essential files over budget"
   - If any file exceeds 200 lines (hard ceiling), flag with "consider consolidating" warning

5. **Verify evidence anchors**:
   - Scan warm files (systemPatterns.md, techContext.md, decisions.md, productContext.md, progress.md) for `Source:` lines outside of HTML comments (`<!-- -->` blocks)
   - For each file path referenced, check if the file still exists
   - For each commit hash referenced, check if it exists in git history (`git cat-file -t <hash>`)
   - Report broken evidence:
     - Count total evidence anchors found
     - List any with broken references (file deleted, commit not found)
   - This is informational — broken evidence doesn't block anything, but signals claims that may need re-verification

6. **Coverage and confidence check**:
   - **Coverage**: For each warm file, count the percentage of non-empty sections that contain at least one `Source:` line. Flag files below 30% coverage as "mostly ungrounded."
   - **Confidence audit**: Scan warm files for `[assumed]` markers. List all `[assumed]` claims as "pending verification." Count `[observed]`, `[inferred]`, and `[assumed]` markers per file.

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

    The output MUST include ALL of the following sections. Do not skip any section, even if there are zero items to report (state "None" or "0" instead). Use the `NN/BB lines` format (actual/budget) for every file.

```
Memory Bank Status:

  Essential (hot):
    projectBrief.md    [Fresh]  62/80 lines   (updated: 2026-03-17)
    activeContext.md   [Stale]  94/70 lines ⚠️ over budget  (updated: 2026-03-10)
    Combined: 156/150 lines ⚠️ over budget — compress on next update

  On-demand (warm):
    decisions.md       [Fresh]  38/150 lines  (updated: 2026-03-17)
    systemPatterns.md  [Warm]   120/120 lines (updated: 2026-03-14)
    techContext.md     [Fresh]  85/100 lines  (updated: 2026-03-16)
    productContext.md  [Stale]  45/80 lines   (updated: 2026-03-08)
    progress.md        [Stale]  67/80 lines   (updated: 2026-03-09)

  Total: 511/680 lines

  Bloat: [any files over 200 hard ceiling, or "None"]

  Evidence:
    12 anchors across 4 files, 30% avg coverage
    1 broken: decisions.md:15 → src/old-auth.ts (file not found)
    2 files below 30% coverage: productContext.md, progress.md

  Confidence:
    [observed]: 8  [inferred]: 3  [assumed]: 2
    Pending verification:
      techContext.md:14 — [assumed] Redis used for session caching
      systemPatterns.md:22 — [assumed] Event-driven between services

  Consistency:
    [any cross-file inconsistencies found]

  Recommended update order:
    1. activeContext.md — stale, essential file, over budget
    2. productContext.md — stale, low evidence coverage
    3. progress.md — stale

  Overall: X/7 fresh, Y warm, Z stale
```

    **Required sections checklist** — verify all are present before outputting:
    - [ ] Per-file lines in `NN/BB` format (actual/budget) for all 7 files
    - [ ] Combined essential line count (`projectBrief + activeContext: NN/150`)
    - [ ] Total line count (`Total: NN/680`)
    - [ ] Evidence section with: total anchor count, broken references (if any), files below 30% coverage
    - [ ] Confidence section with: counts per marker type, `[assumed]` claims listed individually
    - [ ] Consistency section
    - [ ] Recommended update order (priority-ranked file list)
