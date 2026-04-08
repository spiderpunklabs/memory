# memory status

Quick health check. Takes 30 seconds, not 30 minutes.

## Steps

### 1. Check `.memory/` exists
If not: "No memory found. Run `/memory init`."

### 2. Report each file
For each of HANDOFF.md, SCOPE.md, SYSTEM.md, DECISIONS.md:
- **Exists?** yes/no
- **Line count** and budget usage (flag if >80% or over budget)
- **Last modified** date (from `git log -1 --format="%ai" -- .memory/<file>` or file stat)

### 3. Staleness check
- HANDOFF.md last modified >3 days ago → "Stale — run `/memory update`"
- SCOPE.md still contains template placeholders (`<!-- `) → "Incomplete — fill it in"

### 4. Output
```
Memory Status
─────────────
HANDOFF.md    ✓ fresh     42/80 lines    updated 2026-04-08
SCOPE.md      ✓ filled    35/80 lines    updated 2026-04-01
SYSTEM.md     ✓ exists    67/80 lines    updated 2026-04-05
DECISIONS.md  ⚠ near cap  98/120 lines   updated 2026-04-07

Recommendation: DECISIONS.md approaching budget — consider /memory compact
```
