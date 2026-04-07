# memory status

Strict validation of the memory bank. Read-only — does not modify any files.

Every check produces PASS, FAIL, or WARNING. Checks are categorized by severity:
- **BLOCKING**: Must fix. Memory bank is unreliable until resolved.
- **WARNING**: Should fix. Won't break functionality but degrades quality.
- **INFO** (heuristic): Requires human judgment. Flagged for review, not auto-repairable.

The final line is `STATUS: ALL CHECKS PASSED`, `STATUS: N FAILURES DETECTED`, or `STATUS: N FAILURES, M WARNINGS`.

## Steps

### 1. Check memory-bank/ exists
If not, tell user to run the init command and stop.

### 2. Read all 5 memory bank files
Read: projectContext.md, activeState.md, systemPatterns.md, techContext.md, decisions.md

For each file:
- Count lines
- Check last modification date via `git log -1 --format="%ai" -- memory-bank/<file>` (report "uncommitted" if no git history)

### 3. Score staleness
Count commits since each file was last modified (`git rev-list --count <last-commit>..HEAD`):
- **Unknown**: file has no git history (not yet committed)
- **Fresh**: updated within last 3 commits
- **Warm**: 4-10 commits since last update
- **Stale**: 11-20 commits since last update
- **Critical**: >20 commits since last update

### 4. Run all 47 validation checks

Each check produces `PASS`, `FAIL` (blocking), or `WARNING` with the specific violation and a recommended action.

#### File-Level Checks (6 checks)
1. File count = exactly 5 `.md` files in `memory-bank/`
2. No non-core files in `memory-bank/` (exception: `.gitkeep`, `.gitignore`, `.memory-bank.lock/`, `.*.tmp`)
3. Per-file line budgets: projectContext ≤80, activeState ≤70, systemPatterns ≤100, techContext ≤60, decisions ≤150
4. Essential combined (projectContext + activeState) ≤ 150 lines
5. Total all files ≤ 460 lines
6. No subdirectories in `memory-bank/`

#### Derivability Gate Checks (11 checks)
7. No build/dev command tables in any file
8. No dependency lists or tables in any file
9. No infrastructure inventory fields (Hosting:, CI/CD:, Database:, External services:)
10. No naming convention tables in any file
11. No data flow sections (`## Data Flow` or equivalent) in any file
12. No error handling sections (`## Error Handling` or equivalent) in any file
13. No evolution/changelog entries in any file
14. No completed work items in activeState.md
15. No recent changes list in activeState.md
16. No framework/runner/bundler/linter/package-manager fields in techContext.md (only Language: and Runtime: permitted in ## Stack)
17. No code summaries (what a function does, what a module contains)

#### Structural Checks (17 checks)
18. projectContext.md has all 7 required sections: `## Identity`, `## Purpose`, `## Target Audience`, `## Core Requirements`, `## Success Criteria`, `## Key User Flows`, `## Scope` (with `### In Scope`, `### Out of Scope`)
19. activeState.md has all 8 required sections: `## Resume Here`, `## Primary Thread`, `## Working Set`, `## In Progress`, `## Remaining`, `## Blockers`, `## Known Issues`, `## Open Questions`
20. systemPatterns.md has all 5 required sections: `## Architecture Overview`, `## Key Design Decisions`, `## Design Patterns`, `## Component Relationships`, `## Gotchas & Traps`
21. techContext.md has all 4 required sections: `## Stack`, `## Non-Obvious Constraints`, `## Setup Gotchas`, `## Environment Quirks`
22. decisions.md has all 3 required sections: `## Key Decisions`, `## Rejected Alternatives`, `## Intent & Patterns`
23. No additional section headings (## level) beyond those specified above
24. All key-value fields use `Key: value` format (Identity: Project/Overview, Architecture Overview: Type/Entry point(s)/Layer structure, Stack: Language/Runtime)
25. Component Relationships uses `->` arrow notation
26. Key User Flows uses `→` arrow notation
27. Resume Here names a specific file, function, or task (not generic statements like "review the codebase")
28. Working Set contains 3-5 file paths
29. Every Key Decision entry uses a valid format: EITHER the 4-line active format (date+decision, Scope:, Status:, Source:) for active/revisit entries, OR the 1-line compact format (`~~date: decision~~ → superseded by <date> | Scope: <area>`) for superseded entries only
30. [WARNING] No superseded decision uses 4-line format when decisions.md exceeds 120 lines — recommended: run `memory compact` to free space
31. Decision dates are commit dates, not analysis dates
32. ≥1 Rejected Alternative entry with all 3 required lines: `**What was considered**`, `**Why rejected**`, `**Reconsider if**` (merged entries with shared rejection reasons are valid)
33. No section heading has empty content below it
34. No `[fill:]` placeholders remain
35. No `Not yet documented` appears anywhere

#### Evidence Checks (5 checks)
36. systemPatterns.md, techContext.md, decisions.md each have ≥1 `Source:` line
37. Every `Source:` reference points to a valid target: if it looks like a file path (contains `/` or `.`), verify the file exists; if it looks like a commit hash (7+ hex chars), verify with `git cat-file -t <hash>`; otherwise FAIL with "unrecognized Source format"
38. Warm files use confidence markers (`[observed]`, `[inferred]`, or `[assumed]`) on claims
39. Essential files (projectContext, activeState) contain zero `Source:` lines
40. Essential files contain zero confidence markers (`[observed]`, `[inferred]`, `[assumed]`)

#### Specificity Checks (5 checks — checks 41, 43 are deterministic; checks 44, 45, 46 are heuristic/INFO)
41. No unquantified vague terms ("several", "various", "many", "some")
42. No hedging language ("seems to", "appears to", "might") outside Open Questions
43. [INFO/heuristic] No sentence could describe a different project (substitution test) — requires human judgment
44. [INFO/heuristic] No tautologies (sentence restates its section heading) — requires human judgment
45. [INFO/heuristic] Every section contains ≥1 proper noun (file path, tool name, pattern name, dependency, config key) — requires human judgment

#### Security Checks (2 checks)
46. [BLOCKING] No memory bank file contains common secret patterns: `sk-`, `ghp_`, `AIza`, `AKIA`, `-----BEGIN`, `password=`, `token=`, `secret=`, `PRIVATE KEY`, connection strings (`postgres://`, `mysql://`, `mongodb://`)
47. [BLOCKING] No `Source:` or Working Set path escapes the git repository root (paths traversing `../` are allowed IF they resolve to a file within the git root; absolute paths outside the project are blocked)

### 5. Cross-file consistency checks (concrete signals)
Report as informational alongside the pass/fail checks:
- Every path in `activeState.md` Working Set exists in the project filesystem
- The file or function named in `activeState.md` Resume Here exists in the project
- Decision `Scope:` values in `decisions.md` reference components that appear in `systemPatterns.md` Component Relationships
- `techContext.md` constraints match actual manifests (constraints should reflect reality)
- `systemPatterns.md` architecture matches actual directory structure

### 6. Evidence and confidence summary
- Count total `Source:` anchors across warm files
- List any broken references (file deleted, commit not found)
- Count confidence markers: `[observed]`, `[inferred]`, `[assumed]`
- List all `[assumed]` claims as "pending verification"

### 7. Output the validation report

```
Memory Bank Status:

  File Inventory:
    projectContext.md  [Fresh]  NN/80 lines   (updated: YYYY-MM-DD)
    activeState.md     [Warm]   NN/70 lines   (updated: YYYY-MM-DD)
    systemPatterns.md  [Fresh]  NN/100 lines  (updated: YYYY-MM-DD)
    techContext.md     [Fresh]  NN/60 lines   (updated: YYYY-MM-DD)
    decisions.md       [Fresh]  NN/150 lines  (updated: YYYY-MM-DD)

    Essential combined: NN/150 lines
    Total: NN/460 lines

  Validation (47 checks):
    File-Level:       N/6  passed
    Derivability:     N/11 passed
    Structural:       N/18 passed  (includes 1 WARNING-level check)
    Evidence:         N/5  passed
    Specificity:      N/5  passed  (3 heuristic/INFO — require human review)
    Security:         N/2  passed

    Blocking Failures:
      FAIL #NN: <description of violation>
        → Action: <recommended fix>

    Warnings:
      WARN #30: <description>
        → Action: Run `memory compact` for guided compression

    Heuristic (INFO — human review needed):
      INFO #43: <flagged content for review>

  Evidence:
    NN anchors across 3 warm files
    Broken: [list or "None"]

  Confidence:
    [observed]: NN  [inferred]: NN  [assumed]: NN
    Pending verification:
      <file>:<line> — [assumed] <claim>

  Consistency:
    [any cross-file inconsistencies, or "All consistent"]

  Staleness: N/5 fresh, N warm, N stale

STATUS: ALL CHECKS PASSED
```

or:

```
STATUS: N FAILURES DETECTED
```

**Required sections checklist** — verify all are present before outputting:
- [ ] Per-file lines in `NN/ceiling` format for all 5 files
- [ ] Essential combined line count
- [ ] Total line count with /460 budget
- [ ] All 47 checks reported with pass/fail/warn counts per category
- [ ] Blocking failures listed with check number, description, and recommended action
- [ ] Warnings listed separately from blocking failures
- [ ] Heuristic/INFO checks flagged for human review (not counted as failures)
- [ ] Evidence section with anchor count and broken references
- [ ] Confidence section with marker counts and assumed claims listed
- [ ] Consistency section with concrete cross-file signals
- [ ] Staleness summary
- [ ] Final STATUS line (ALL CHECKS PASSED, N FAILURES DETECTED, or N FAILURES M WARNINGS)
