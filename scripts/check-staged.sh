#!/usr/bin/env bash
# check-staged.sh — canonical pre-commit check runner.
# Copied from spiderpunklabs/workstation/ci-templates/check-staged.sh at SHA 36d1f6146c3c82651f6dc2663837aaf75816f902.
# Memory CHECKS array: secret-scan only (markdown-only skill repo).

set -uo pipefail

STAGED=$(git diff --cached --name-only --diff-filter=ACMR -z)
if [ -z "$STAGED" ]; then
  exit 0
fi

check_secrets() {
  local FORBIDDEN_PATTERNS=(
    '\.env$' '\.env\.' '\.pem$' '\.key$' '\.p12$' '\.pfx$'
    'id_rsa' 'id_ed25519' 'credentials' 'secrets' '\.tfvars$'
  )
  local fail=0 file
  while IFS= read -r -d '' file; do
    for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
      if printf '%s' "$file" | grep -qE "$pattern"; then
        printf 'pre-commit: BLOCKED filename matches forbidden pattern %s: %s\n' "$pattern" "$file" >&2
        fail=1
      fi
    done
  done <<<"$STAGED"
  # Content regex assembled from primitives so literal substrings
  # never appear contiguously on disk.
  local pk="PRIV""ATE KEY"
  local gpa="github""_pat_"
  local secret_regex="(${pk}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|${gpa})"
  if git diff --cached -U0 | grep -qEi "$secret_regex"; then
    printf 'pre-commit: BLOCKED staged diff contains what looks like a secret/token\n' >&2
    fail=1
  fi
  return $fail
}

CHECKS=(
  check_secrets
)

overall=0
for c in "${CHECKS[@]}"; do
  if ! "$c"; then overall=1; fi
done
exit $overall
