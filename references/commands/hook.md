# memory hook

Install the pre-commit hook for memory bank validation. The hook blocks commits containing invalid memory bank files or secrets.

## Steps

1. **Check prerequisites**:
   - If no `.git/` directory → inform user "Not a git repository — hooks require git" and exit
   - If `memory-bank/` doesn't exist → warn but continue (hook will be ready for when memory bank is initialized)

2. **Locate validator script**: Check for `memory-bank-validate.sh` at:
   - `./memory-bank-validate.sh` (project root)
   - The skill's `references/scripts/memory-bank-validate.sh`
   - If not found → copy it from the skill's references to the project root and make it executable (`chmod +x`)

3. **Check for existing hook**: If `.git/hooks/pre-commit` already exists:
   - Read its content
   - If it already contains `memory-bank` references → inform user hook is already installed, exit
   - If it contains other hook logic → ask user: "A pre-commit hook already exists. Append memory bank validation to it, or replace it?"

4. **Install hook**: Write (or append) the hook content from `references/scripts/memory-bank-hook.sh` to `.git/hooks/pre-commit` and make it executable.

5. **Verify**: Run the validator once on the current memory bank (if it exists) to confirm the hook setup works.

6. **Report**: "Pre-commit hook installed. Memory bank files will be validated before each commit. Secret detection is enabled. Use `git commit --no-verify` to bypass if needed."
