# /memory update

Update the memory bank files to reflect the current state of work.

## Steps

1. **Read all memory bank files** in `memory-bank/`:
   - projectbrief.md, productContext.md, systemPatterns.md
   - techContext.md, activeContext.md, progress.md

2. **Gather current state**:
   - Run `git diff --stat` to see what files changed recently
   - Run `git log --oneline -10` to see recent commits
   - Run `git status` to see uncommitted work
   - Review any open tasks or conversation context

3. **Determine what needs updating**:
   - `activeContext.md` — almost always needs updating (current focus, next steps)
   - `progress.md` — update completed items, in-progress work, known issues
   - `systemPatterns.md` — update if new patterns, architecture decisions, or design changes were made
   - `techContext.md` — update if dependencies, build process, or infrastructure changed
   - `productContext.md` — update if product goals, audience, or UX changed
   - `projectbrief.md` — rarely changes; update only if scope or requirements shifted

4. **Update the files**:
   - Use the Edit tool to update each file that needs changes
   - Preserve existing content — append or modify, don't delete unless explicitly asked
   - Add dates to the evolution log in progress.md
   - Keep entries concise and factual

5. **Verify consistency**:
   - Ensure activeContext.md aligns with progress.md
   - Ensure techContext.md reflects any new dependencies or tools
   - Ensure systemPatterns.md reflects any new architectural decisions

6. **Report**:
   - List which files were updated and summarize key changes
   - Flag any inconsistencies or gaps discovered
