# memory search <query>

Search across all 5 memory bank files for a keyword, pattern, or topic.

## Steps

1. **Validate**: Check `memory-bank/` exists. If not, tell user to run init and stop.

2. **Read all 5 files**: projectContext.md, activeState.md, systemPatterns.md, techContext.md, decisions.md

3. **Search**: Find all lines containing the query string (case-insensitive substring match).
   - If query matches a section heading (`## ...`), include the full section content.
   - If query matches within a section, include the matching line(s) with 1 line of context above and below.

4. **Output**:
   ```
   Search results for "<query>":

     memory-bank/decisions.md:
       L14: 2025-03-15: **Use PostgreSQL** — needed JSONB support
       L15: Scope: database
       L16: Status: active

     memory-bank/systemPatterns.md:
       L8: - Repository pattern for database access [observed]

     2 files, 4 matches
   ```

5. If no matches found: "No results for `<query>` in memory bank files."
