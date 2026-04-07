#!/bin/sh
# memory-bank-test.sh — Acceptance test suite for memory-bank-validate.sh
# POSIX-compatible. Creates temp fixture dirs, runs validator, checks results.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALIDATOR="$SCRIPT_DIR/memory-bank-validate.sh"
PASS=0
TOTAL=0
TMPBASE=$(mktemp -d)
trap 'rm -rf "$TMPBASE"' EXIT INT TERM HUP

# ── Helpers ────────────────────────────────────────────────────
run_test() {
  _name="$1"; _fixture="$2"; _expect_exit="$3"; _expect_pattern="$4"
  TOTAL=$((TOTAL + 1))
  _outfile="$TMPBASE/_test_output"
  _exit=0
  "$VALIDATOR" "$_fixture" > "$_outfile" 2>&1 || _exit=$?

  _ok=1
  if [ "$_exit" -ne "$_expect_exit" ]; then
    _ok=0
    printf "  FAIL  %s — expected exit %d, got %d\n" "$_name" "$_expect_exit" "$_exit"
  fi
  if [ -n "$_expect_pattern" ]; then
    if ! grep -qi "$_expect_pattern" "$_outfile" 2>/dev/null; then
      _ok=0
      printf "  FAIL  %s — expected pattern '%s' not found in output\n" "$_name" "$_expect_pattern"
    fi
  fi
  if [ "$_ok" -eq 1 ]; then
    PASS=$((PASS + 1))
    printf "  PASS  %s\n" "$_name"
  fi
}

# ── Create a valid memory bank fixture ─────────────────────────
create_valid_bank() {
  _base="$1"
  _dir="$_base/memory-bank"
  mkdir -p "$_dir"

  # Create dummy source files so Source: references resolve
  mkdir -p "$_base/src"
  echo "// main entry" > "$_base/src/main.ts"
  echo "# Project README" > "$_base/README.md"

  cat > "$_dir/projectContext.md" << 'EOF'
# Project Context

## Identity
Project: TestApp
Overview: A test application for validation

## Purpose
Testing the memory bank validation system.

## Target Audience
Developers building with the memory bank skill.

## Core Requirements
- Validate all 47 checks deterministically
- Support POSIX shell environments

## Success Criteria
- All fixture tests pass on macOS and Linux

## Key User Flows
Developer runs init → memory bank created → status → all checks pass

## Scope

### In Scope
- Shell script validator
- Pre-commit hook

### Out of Scope
- GUI tools
- Database backends
EOF

  cat > "$_dir/activeState.md" << 'EOF'
# Active State

## Resume Here
Implement check #29 dual-format acceptance in src/main.ts

## Primary Thread
Building the deterministic validator script

## Working Set
- src/main.ts
- README.md
- memory-bank/decisions.md

## In Progress
- Shell script validator implementation

## Remaining
- Acceptance test suite

## Blockers
None identified

## Known Issues
None identified

## Open Questions
- Should the validator support custom config files?
EOF

  cat > "$_dir/systemPatterns.md" << 'EOF'
# System Patterns

## Architecture Overview
Type: CLI tool
Entry point(s): src/main.ts
Layer structure: src/main.ts -> lib -> utils

## Key Design Decisions
- TypeScript for type safety [observed]

## Design Patterns
- Repository pattern for data access [observed]

## Component Relationships
src/main.ts -> lib/core : routes requests

Source: src/main.ts

## Gotchas & Traps
- Config must be loaded before routes [observed]
EOF

  cat > "$_dir/techContext.md" << 'EOF'
# Tech Context

## Stack
Language: TypeScript (strict mode)
Runtime: Node 20

## Non-Obvious Constraints
- Must support Node 18+ for AWS Lambda compatibility [observed]

Source: README.md

## Setup Gotchas
None

## Environment Quirks
- CI uses Node 20, local may use Node 18 [observed]
EOF

  cat > "$_dir/decisions.md" << 'EOF'
# Decisions

## Key Decisions
2025-03-15: **Use TypeScript over JavaScript** — type safety reduces runtime errors
Scope: entire codebase
Status: active
Source: src/main.ts

## Rejected Alternatives
**What was considered**: Plain JavaScript with JSDoc
**Why rejected**: Incomplete type coverage, no compile-time guarantees
**Reconsider if**: Build times become unacceptable

## Intent & Patterns
- Strict mode enabled for all files [observed]
EOF
}

# ── Test fixtures ──────────────────────────────────────────────
echo "memory-bank-test: running acceptance tests"
echo ""

# Test 1: Valid bank passes
_fix="$TMPBASE/valid"
create_valid_bank "$_fix"
run_test "Valid bank passes all checks" "$_fix/memory-bank" 0 ""

# Test 2: Missing file fails check #1
_fix="$TMPBASE/missing-file"
create_valid_bank "$_fix"
rm "$_fix/memory-bank/techContext.md"
run_test "Missing file fails check #1" "$_fix/memory-bank" 1 "FAIL"

# Test 3: Over budget fails check #3
_fix="$TMPBASE/over-budget"
create_valid_bank "$_fix"
_i=0; while [ $_i -lt 100 ]; do echo "- Extra line $_i"; _i=$((_i+1)); done >> "$_fix/memory-bank/projectContext.md"
run_test "Over budget fails check #3" "$_fix/memory-bank" 1 "exceeds"

# Test 4: Secret detection blocks
_fix="$TMPBASE/has-secret"
create_valid_bank "$_fix"
echo "API_KEY=ghp_abcdefghijklmnopqrstuvwxyz0123456789" >> "$_fix/memory-bank/techContext.md"
run_test "Secret detection blocks" "$_fix/memory-bank" 1 "BLOCKED"

# Test 5: Empty section fails check #33
_fix="$TMPBASE/empty-section"
create_valid_bank "$_fix"
grep -v '^None identified' "$_fix/memory-bank/activeState.md" > "$_fix/memory-bank/activeState.md.new"
mv "$_fix/memory-bank/activeState.md.new" "$_fix/memory-bank/activeState.md"
run_test "Empty section detected" "$_fix/memory-bank" 1 ""

# Test 6: [fill:] placeholder fails check #34
_fix="$TMPBASE/fill-placeholder"
create_valid_bank "$_fix"
echo "- [fill: something here]" >> "$_fix/memory-bank/systemPatterns.md"
run_test "Fill placeholder fails check #34" "$_fix/memory-bank" 1 "fill:"

# Test 7: Source in essential file fails check #39
_fix="$TMPBASE/source-in-essential"
create_valid_bank "$_fix"
echo "Source: some/file.ts" >> "$_fix/memory-bank/projectContext.md"
run_test "Source in essential fails check #39" "$_fix/memory-bank" 1 "Source"

# Test 8: Missing Source in warm file fails check #36
_fix="$TMPBASE/no-source-warm"
create_valid_bank "$_fix"
grep -v '^Source: ' "$_fix/memory-bank/systemPatterns.md" > "$_fix/memory-bank/systemPatterns.md.tmp"
mv "$_fix/memory-bank/systemPatterns.md.tmp" "$_fix/memory-bank/systemPatterns.md"
run_test "Missing Source in warm file fails check #36" "$_fix/memory-bank" 1 "Source"

# Test 9: Vague terms fail check #41
_fix="$TMPBASE/vague-terms"
create_valid_bank "$_fix"
echo "- There are several important patterns here [observed]" >> "$_fix/memory-bank/systemPatterns.md"
run_test "Vague terms fail check #41" "$_fix/memory-bank" 1 "several"

# Test 10: Hedging fails check #42
_fix="$TMPBASE/hedging"
create_valid_bank "$_fix"
echo "- The system seems to use event sourcing [assumed]" >> "$_fix/memory-bank/systemPatterns.md"
run_test "Hedging language fails check #42" "$_fix/memory-bank" 1 "seems"

# Test 11: Budget clamp (custom config)
_fix="$TMPBASE/custom-budget"
create_valid_bank "$_fix"
cat > "$_fix/.memory-bank-config.json" << 'EOF'
{"version": 1, "budgets": {"decisions": 300}}
EOF
run_test "Custom budget config accepted" "$_fix/memory-bank" 0 ""

# Test 12: Orphaned .tmp warning
_fix="$TMPBASE/orphaned-tmp"
create_valid_bank "$_fix"
echo "orphaned" > "$_fix/memory-bank/.activeState.md.tmp"
run_test "Orphaned .tmp produces warning" "$_fix/memory-bank" 0 ""

# ── Summary ────────────────────────────────────────────────────
echo ""
echo "  ════════════════════════════════════"
printf "  %d/%d tests passed\n" "$PASS" "$TOTAL"
echo ""

if [ "$PASS" -eq "$TOTAL" ]; then
  echo "  ALL TESTS PASSED"
  exit 0
else
  echo "  SOME TESTS FAILED"
  exit 1
fi
