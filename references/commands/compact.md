# memory compact

Manually trigger a guided compression session for all memory bank files. Useful when files are approaching their line budget ceilings.

## Steps

1. **Validate**: Check `memory-bank/` exists. If not, tell user to run init and stop.

2. **Read all 5 files** and count lines per file.

3. **Report current state**:
   ```
   Current line counts:
     projectContext.md   45/80   (56%)
     activeState.md      62/70   (89%) ⚠️ near ceiling
     systemPatterns.md   88/100  (88%) ⚠️ near ceiling
     techContext.md      35/60   (58%)
     decisions.md       142/150  (95%) ⚠️ near ceiling

     Essential combined: 107/150
     Total: 372/460
   ```

4. **For each file exceeding 80% of its ceiling**, present compression options interactively:

   - **decisions.md**: List all entries with `Status: superseded`. For each, ask user: **(a) Compact** to 1-line format, **(b) Keep** full format, **(c) Remove** entirely. Then list Rejected Alternative entries with shared rejection reasons and ask if they can be merged.
   - **activeState.md**: Offer to rewrite as a clean handoff document (same as update step 5). Identify completed work items, resolved blockers, or stale Working Set entries.
   - **systemPatterns.md**: Identify entries where the `Source:` file no longer exists. Identify claims that are now derivable from code. Ask user about each.
   - **techContext.md**: Identify constraints that are now documented in README or config files. Ask user about each.
   - **projectContext.md**: Rarely needs compression. If over 80%, check for scope creep (requirements that moved out of scope).

5. **Apply user-approved changes** using the write protocol (snapshot → write → validate → proceed or rollback).

6. **Report results**: Show before/after line counts for each file that was compressed.

7. **Run validation**: Execute the checks defined in `references/commands/status.md` to confirm compression didn't break formatting.
