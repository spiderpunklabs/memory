#!/bin/sh
# memory-bank-hook.sh — Git pre-commit hook for memory bank validation
# Install: cp to .git/hooks/pre-commit or run 'memory hook'
# Validates the STAGED INDEX (not working tree). Fails closed if validator missing.

set -e

# Check if any memory-bank/ files are staged
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep '^memory-bank/' || true)
[ -z "$STAGED" ] && exit 0

echo "memory-bank: validating staged files..."

# Extract staged versions to a temp directory (validate index, not working tree)
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT INT TERM HUP
mkdir -p "$TMPDIR/memory-bank"

for f in $STAGED; do
  git show ":0:$f" > "$TMPDIR/$f" 2>/dev/null || true
done

# Secret scan on staged content FIRST (blocking)
SECRET_PAT='(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AIza[a-zA-Z0-9_-]{35}|AKIA[A-Z0-9]{16}|-----BEGIN .* PRIVATE KEY|xox[bpas]-[a-zA-Z0-9-]+)'
if grep -rqE "$SECRET_PAT" "$TMPDIR/memory-bank/" 2>/dev/null; then
  echo ""
  echo "ERROR: Secret detected in staged memory-bank files!"
  echo ""
  grep -rnE "$SECRET_PAT" "$TMPDIR/memory-bank/" 2>/dev/null | head -5
  echo ""
  echo "Remove secrets before committing. Use 'git diff --cached -- memory-bank/' to review."
  exit 1
fi

# Locate the validator script
VALIDATOR=""
for p in \
  "./memory-bank-validate.sh" \
  "$(dirname "$0")/../../memory-bank-validate.sh" \
  "$(dirname "$0")/../../references/scripts/memory-bank-validate.sh"; do
  if [ -x "$p" ]; then
    VALIDATOR="$p"
    break
  fi
done

# FAIL CLOSED — missing validator blocks the commit
if [ -z "$VALIDATOR" ]; then
  echo ""
  echo "ERROR: memory-bank-validate.sh not found. Cannot validate memory bank."
  echo "Install the validator or use 'git commit --no-verify' to bypass."
  exit 1
fi

# Run the validator on staged versions
if ! "$VALIDATOR" --hook "$TMPDIR/memory-bank"; then
  echo ""
  echo "memory-bank: Validation failed. Fix issues above before committing."
  echo "Run 'memory-bank-validate.sh ./memory-bank' for detailed output."
  echo "Use 'git commit --no-verify' to bypass (not recommended)."
  exit 1
fi

echo "memory-bank: All checks passed."
exit 0
