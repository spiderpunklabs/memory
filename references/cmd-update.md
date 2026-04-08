# memory update

Refresh the session handoff and record any new decisions.

## Steps

### 1. Rewrite HANDOFF.md completely
This is a full rewrite every time — a snapshot, not a diary. Must include:
- **Date** and one-line session summary
- **Files changed** this session (specific paths)
- **Current state** of in-progress work (name specific files, functions, or tasks — not "continue working on the API")
- **Next action** — the concrete first thing to do next session
- **Gotchas** discovered this session (or "None")

### 2. Record decisions (if any were made this session)
Prepend to DECISIONS.md — newest first. Format:
```
YYYY-MM-DD: **Decision** — reasoning
  Rejected: alternative — why not
```
If no decisions were made, skip this file entirely.

### 3. Update SYSTEM.md (if architecture or constraints changed)
Only touch this if components, architecture shape, constraints, or gotchas actually changed.

### 4. Update SCOPE.md (if project direction changed)
Rare. Only when purpose, boundaries, or conventions genuinely shifted.

### 5. Budget check
If any file exceeds 80% of its budget after updates, inform the user:
"[file] is at N/budget lines. Run `/memory compact` to review compression options."

### 6. Hygiene
- Don't write actual secret values to memory files
- Don't store what's derivable from code (apply the gate from init)

### 7. Report
List which files were updated and summarize key changes in 1-2 lines.
