# memory compact

Guided compression of memory files. User-triggered only — never runs automatically.
Analyzes each file and suggests specific compressions. User approves each individually.

## Steps

### 1. Measure
Read all 4 files. Report a status table:

| File | Lines | Budget | Usage |
|------|-------|--------|-------|
| HANDOFF.md | 42 | 80 | 53% |
| SCOPE.md | 62 | 80 | 78% |
| SYSTEM.md | 104 | 80 | 130% |
| DECISIONS.md | 185 | 120 | 154% |

If ALL files are under 70% budget: "All files within budget. No compaction needed." Exit unless user explicitly asks to review anyway.

### 2. Analyze over-budget or near-budget files (>70%)
Generate suggestions using file-specific heuristics. Present highest-savings first.

**DECISIONS.md**: Entries older than 20 positions from top that share scope with a newer entry → suggest archiving. Clusters of 3+ related micro-decisions → suggest merging into one summary. Entries whose rationale is already captured in SCOPE/SYSTEM → suggest archiving with stub. Never suggest archiving based on age alone — only when superseded or redundant.

**SYSTEM.md**: Blocks >6 lines describing a single component → suggest compressing to 2-3 lines. Constraints that appear substantially reflected in README/config → surface as candidates, quote BOTH the memory text and the external source side-by-side for user comparison ("Are these saying the same thing?"). Components referencing files/services that no longer exist → suggest removal.

**SCOPE.md**: Redundant restatements of the same boundary → suggest collapsing. Multi-line examples replaceable by a single-line rule → suggest collapsing. Stale conventions that conflict with newer DECISIONS.md entries → suggest removal.

**HANDOFF.md**: Rarely needs compacting (rewritten each session). If over budget, suggest rewriting more concisely — identify the most verbose sections.

### 3. Present suggestions
One at a time per file. Each suggestion MUST include:
```
[SYSTEM.md] Suggestion 1 of 3 — saves ~9 lines
CURRENT (lines 40-52):
> <exact quoted text being removed or changed>
PROPOSED:
> <exact replacement text, or "[remove entirely]">
REASON: <why this is safe to compress>
Accept / Edit / Skip?
```
After 3+ consecutive accepts, offer: "Accept all remaining? (y/n)"

**Edit flow**: Present suggestion text as editable. User provides modified replacement. Confirm the edit before applying.

### 4. Apply
Apply each accepted suggestion immediately after approval.
Preserve file structure: section headings, entry order, and dates are never changed unless the suggestion explicitly addresses them.

**DECISIONS.md archival**: Move archived entries to `.memory/DECISIONS-archive.md` (create on first use with header `# Decisions Archive`). Archived entries preserve original date and text. Leave a stub in DECISIONS.md: `<!-- archived: entries before YYYY-MM-DD → see DECISIONS-archive.md -->`

Archive stubs (`<!-- archived: ... -->`) are excluded from all heuristic analysis.

### 5. Report
```
Compact complete.
  SYSTEM.md:    104 → 78 lines (saved 26) ✓ under budget
  DECISIONS.md: 185 → 118 lines (saved 67, 8 entries archived) ✓ under budget
  Unchanged:    HANDOFF.md, SCOPE.md
```

If still over budget after all suggestions: "SYSTEM.md still at 92/80. Consider manually trimming verbose sections."

## Edge cases
- User rejects all suggestions: "No changes applied." No re-prompting.
- Missing file: skip, note "[file] not found."
- Empty file: skip, note "[file] is empty."
- All files under 70%: report status, exit.
- Blank lines count toward line budget.
- Never merge content into dense paragraphs solely to save lines — compression means removing or archiving, not squashing formatting.
- Idempotent: running compact twice with no intervening changes produces no new suggestions.
