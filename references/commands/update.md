# memory update

Update the memory bank files to reflect the current state of work.

## Steps

1. **Read all memory bank files** in `memory-bank/`:
   - projectbrief.md, productContext.md, systemPatterns.md
   - techContext.md, activeContext.md, progress.md, decisions.md

2. **Gather current state**:
   - Run `git diff --stat` to see what files changed recently
   - Run `git log --oneline -10` to see recent commits
   - Run `git status` to see uncommitted work
   - Review any open tasks or conversation context

3. **Determine what needs updating**:
   - `activeContext.md` — almost always needs updating (current focus, next steps)
   - `progress.md` — update completed items, in-progress work, known issues
   - `decisions.md` — append any significant decisions made or alternatives rejected during this session
   - `systemPatterns.md` — update if new patterns, architecture decisions, or design changes were made
   - `techContext.md` — update if dependencies, build process, or infrastructure changed
   - `productContext.md` — update if product goals, audience, or UX changed
   - `projectbrief.md` — rarely changes; update only if scope or requirements shifted

4. **Write a session summary** in `activeContext.md`:
   - Add a dated session summary block at the top of the "Recent Changes" section
   - Use this format:
     ```
     ### Session: YYYY-MM-DD
     - **Done**: what was accomplished
     - **Decisions**: key decisions made (also logged in decisions.md)
     - **Next**: immediate next steps
     ```
   - Keep the last 3 session summaries in full detail
   - Summarize older session summaries into a single line each (e.g., "2025-03-01: Refactored auth module, added OAuth support")

5. **Capture decisions**:
   - Review the work done in this session for significant decisions
   - For each decision, append to the appropriate section in `decisions.md`:
     - Architectural, design, or tooling choices → **Key Decisions**
     - Approaches that were considered and rejected → **Rejected Alternatives**
     - Learned behaviors or non-obvious project rules → **Project-Specific Patterns**
   - `decisions.md` is append-only — never remove existing entries

6. **Consolidate to prevent bloat**:
   - In `progress.md`: roll completed items older than ~2 weeks into a single summary line (e.g., "Pre-2025-03-01: Initial setup, auth module, CI pipeline")
   - In `activeContext.md`: keep last 3 session summaries detailed, compress older ones to one line each
   - Remove "Not yet documented" placeholders if a section now has real content
   - Goal: keep each file under 200 lines

7. **Update remaining files**:
   - Use the Edit tool to update each file that needs changes
   - Preserve existing content — append or modify, don't delete unless consolidating as described above
   - Add dates to the evolution log in progress.md
   - Keep entries concise and factual

8. **Verify consistency**:
   - Ensure activeContext.md aligns with progress.md
   - Ensure techContext.md reflects any new dependencies or tools
   - Ensure systemPatterns.md reflects any new architectural decisions
   - Ensure decisions.md captures any significant choices from this session

9. **Report**:
   - List which files were updated and summarize key changes
   - Flag any inconsistencies or gaps discovered
   - Note any decisions captured in decisions.md
