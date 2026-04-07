# Decisions

<!-- Append-only log. Never remove entries without user approval. Budget: 150 lines max. -->
<!-- Warm file — requires Source: lines and confidence markers. -->

## Key Decisions
<!-- REQUIRED format per ACTIVE entry (all 4 lines mandatory):
YYYY-MM-DD: **Decision** — rationale
Scope: <affected area>
Status: active | revisit
Source: <file or commit>

COMPACT format for SUPERSEDED entries (1 line, user-approved only):
~~YYYY-MM-DD: Decision~~ → superseded by <later decision date> | Scope: <area>

Rules:
- Active/revisit entries MUST use 4-line format
- Superseded entries MAY use compact format ONLY after user approval
- Never auto-compress without asking the user
- Compact format preserves decision existence while freeing line budget
-->

## Rejected Alternatives
<!-- REQUIRED: ≥1 entry on init. Every decision implies a rejected path.
Format per entry (all 3 lines mandatory):
**What was considered**: <alternative>
**Why rejected**: <reason>
**Reconsider if**: <condition, or "N/A">
Entries with shared rejection reasons may be merged (user-approved only).
-->

## Intent & Patterns
<!-- Code that looks wrong but is intentional. Project-specific conventions. -->
<!-- Each entry: what it looks like + why it's correct. -->
- [fill: pattern — explanation] [observed]
