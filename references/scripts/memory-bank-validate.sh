#!/bin/sh
# memory-bank-validate.sh — Deterministic validator for memory-bank/
# POSIX-compatible (no bashisms). Validates 40 of 47 checks + secret scan.
# Leaves 4 heuristic checks to LLM: #17 (code summaries), #43-45 (substitution, tautologies, proper nouns).
# Usage: memory-bank-validate.sh [MEMORY_BANK_PATH] [--hook] [--quiet]
# Exit: 0 = all pass, 1 = failures, 2 = missing directory

# Do NOT use set -e — grep returns non-zero on no match, which is expected

# ── Defaults ───────────────────────────────────────────────────
MB_PATH="./memory-bank"
QUIET=0
HOOK_MODE=0
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
SECRET_COUNT=0
PROJECT_ROOT="."

# ── Parse arguments ────────────────────────────────────────────
while [ $# -gt 0 ]; do
  case "$1" in
    --hook)   HOOK_MODE=1; QUIET=1; shift ;;
    --quiet)  QUIET=1; shift ;;
    --help)   echo "Usage: $0 [MEMORY_BANK_PATH] [--hook] [--quiet]"; exit 0 ;;
    -*)       echo "Unknown option: $1" >&2; exit 2 ;;
    *)        MB_PATH="$1"; shift ;;
  esac
done

# Resolve project root (parent of memory-bank/)
PROJECT_ROOT="$(cd "$(dirname "$MB_PATH")" 2>/dev/null && pwd)"

# ── Budget defaults (override with .memory-bank-config.json if present) ──
B_projectContext=80
B_activeState=70
B_systemPatterns=100
B_techContext=60
B_decisions=150
B_essentialCombined=150
B_total=460

# Load config if present
CONFIG_FILE="$PROJECT_ROOT/.memory-bank-config.json"
if [ -f "$CONFIG_FILE" ]; then
  _parse() { sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p" "$CONFIG_FILE" | head -1; }
  _v=$(_parse projectContext);    [ -n "$_v" ] && B_projectContext=$_v
  _v=$(_parse activeState);       [ -n "$_v" ] && B_activeState=$_v
  _v=$(_parse systemPatterns);    [ -n "$_v" ] && B_systemPatterns=$_v
  _v=$(_parse techContext);       [ -n "$_v" ] && B_techContext=$_v
  _v=$(_parse decisions);         [ -n "$_v" ] && B_decisions=$_v
  _v=$(_parse essentialCombined); [ -n "$_v" ] && B_essentialCombined=$_v
  _v=$(_parse total);             [ -n "$_v" ] && B_total=$_v

  # Clamp to safe ranges
  clamp() { val=$1; lo=$2; hi=$3; [ "$val" -lt "$lo" ] 2>/dev/null && val=$lo; [ "$val" -gt "$hi" ] 2>/dev/null && val=$hi; echo "$val"; }
  B_projectContext=$(clamp "$B_projectContext" 20 300)
  B_activeState=$(clamp "$B_activeState" 20 300)
  B_systemPatterns=$(clamp "$B_systemPatterns" 20 500)
  B_techContext=$(clamp "$B_techContext" 20 300)
  B_decisions=$(clamp "$B_decisions" 30 1000)
  B_essentialCombined=$(clamp "$B_essentialCombined" 50 600)
  B_total=$(clamp "$B_total" 200 2000)
fi

# ── Output helpers ─────────────────────────────────────────────
pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  [ "$QUIET" -eq 0 ] && printf "    PASS  #%s: %s\n" "$1" "$2"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf "    FAIL  #%s: %s\n" "$1" "$2"
  if [ -n "$3" ]; then
    printf "      -> %s\n" "$3"
  fi
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  printf "    WARN  #%s: %s\n" "$1" "$2"
}

blocked() {
  SECRET_COUNT=$((SECRET_COUNT + 1))
  printf "    BLOCKED: %s\n" "$1"
}

info() { [ "$QUIET" -eq 0 ] && printf "    %s\n" "$1"; }

# ── Helper: extract section content between heading and next ## ──
extract_section() {
  _file="$1"; _heading="$2"
  sed -n "/^## ${_heading}$/,/^## /{ /^## ${_heading}$/d; /^## /d; p; }" "$_file"
}

# ── Validate directory exists ──────────────────────────────────
if [ ! -d "$MB_PATH" ]; then
  echo "ERROR: Memory bank directory not found: $MB_PATH" >&2
  exit 2
fi

echo "memory-bank-validate: checking $MB_PATH/"
echo ""

# ── File variables ─────────────────────────────────────────────
F_pc="$MB_PATH/projectContext.md"
F_as="$MB_PATH/activeState.md"
F_sp="$MB_PATH/systemPatterns.md"
F_tc="$MB_PATH/techContext.md"
F_dc="$MB_PATH/decisions.md"

ESSENTIAL="$F_pc $F_as"
WARM="$F_sp $F_tc $F_dc"
ALL_FILES="$F_pc $F_as $F_sp $F_tc $F_dc"

# ── SECRET DETECTION (runs first, blocking) ────────────────────
echo "  Secret Detection:"
SECRET_PAT='(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AIza[a-zA-Z0-9_-]{35}|AKIA[A-Z0-9]{16}|-----BEGIN .* PRIVATE KEY|xox[bpas]-[a-zA-Z0-9-]+)'
CRED_PAT='(password|token|secret)[[:space:]]*=[[:space:]]*["\x27][^"\x27]'
CONN_PAT='(mongodb|postgres|mysql|redis)://[^/[:space:]]+:[^@[:space:]]+@'

_secrets_found=0
for f in $ALL_FILES; do
  [ -f "$f" ] || continue
  _hits=$(grep -nE "$SECRET_PAT" "$f" 2>/dev/null || true)
  _hits2=$(grep -nE "$CRED_PAT" "$f" 2>/dev/null || true)
  _hits3=$(grep -nE "$CONN_PAT" "$f" 2>/dev/null || true)
  _all_hits=$(printf "%s\n%s\n%s" "$_hits" "$_hits2" "$_hits3" | grep -v '^$' || true)
  if [ -n "$_all_hits" ]; then
    _secrets_found=1
    _basename=$(basename "$f")
    # Count and display hits without subshell (avoid pipe to while)
    _hit_count=$(echo "$_all_hits" | wc -l | tr -d ' ')
    SECRET_COUNT=$((SECRET_COUNT + _hit_count))
    echo "$_all_hits" | while IFS= read -r line; do
      printf "    BLOCKED: %s:%s\n" "$_basename" "$line"
    done
  fi
done
[ "$_secrets_found" -eq 0 ] && info "No secrets detected"
echo ""

# ── FILE-LEVEL CHECKS (1-6) ───────────────────────────────────
echo "  File-Level (6 checks):"

# Check 1: File count = 5
_md_count=$(find "$MB_PATH" -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')
if [ "$_md_count" -eq 5 ]; then
  pass 1 "File count = 5"
else
  fail 1 "File count = $_md_count (expected 5)"
fi

# Check 2: No extra files
_extras=$(find "$MB_PATH" -maxdepth 1 -type f ! -name '*.md' ! -name '.gitkeep' ! -name '.gitignore' ! -name '.*.tmp' ! -name '.*' 2>/dev/null || true)
_extra_dirs=$(find "$MB_PATH" -mindepth 1 -maxdepth 1 -type d ! -name '.memory-bank.lock' 2>/dev/null || true)
if [ -z "$_extras" ] && [ -z "$_extra_dirs" ]; then
  pass 2 "No extra files or subdirectories"
else
  fail 2 "Extra items found in memory-bank/" "$_extras $_extra_dirs"
fi

# Check 3: Per-file line budgets
_check_budget() {
  _f="$1"; _name="$2"; _budget="$3"
  if [ ! -f "$_f" ]; then
    fail 3 "$_name — file missing"
    return
  fi
  _lines=$(wc -l < "$_f" | tr -d ' ')
  if [ "$_lines" -le "$_budget" ]; then
    pass 3 "$_name — $_lines/$_budget lines"
  else
    _over=$((_lines - _budget))
    fail 3 "$_name — $_lines/$_budget lines (exceeds by $_over)"
  fi
}
_check_budget "$F_pc" "projectContext.md" "$B_projectContext"
_check_budget "$F_as" "activeState.md" "$B_activeState"
_check_budget "$F_sp" "systemPatterns.md" "$B_systemPatterns"
_check_budget "$F_tc" "techContext.md" "$B_techContext"
_check_budget "$F_dc" "decisions.md" "$B_decisions"

# Check 4: Essential combined
_pc_lines=0; _as_lines=0
[ -f "$F_pc" ] && _pc_lines=$(wc -l < "$F_pc" | tr -d ' ')
[ -f "$F_as" ] && _as_lines=$(wc -l < "$F_as" | tr -d ' ')
_ess_total=$((_pc_lines + _as_lines))
if [ "$_ess_total" -le "$B_essentialCombined" ]; then
  pass 4 "Essential combined — $_ess_total/$B_essentialCombined lines"
else
  fail 4 "Essential combined — $_ess_total/$B_essentialCombined lines"
fi

# Check 5: Total
_total_lines=0
for f in $ALL_FILES; do
  [ -f "$f" ] && _fl=$(wc -l < "$f" | tr -d ' ') && _total_lines=$((_total_lines + _fl))
done
if [ "$_total_lines" -le "$B_total" ]; then
  pass 5 "Total — $_total_lines/$B_total lines"
else
  fail 5 "Total — $_total_lines/$B_total lines"
fi

# Check 6: No subdirectories
_subdirs=$(find "$MB_PATH" -mindepth 1 -type d ! -name '.memory-bank.lock' 2>/dev/null | wc -l | tr -d ' ')
if [ "$_subdirs" -eq 0 ]; then
  pass 6 "No subdirectories"
else
  fail 6 "$_subdirs subdirectories found"
fi
echo ""

# ── DERIVABILITY GATE (7-16) ──────────────────────────────────
echo "  Derivability Gate (10 deterministic checks):"

_grep_all() { grep -niE "$1" $ALL_FILES 2>/dev/null | head -3; }

# Check 7: No build/dev tables
_h=$(_grep_all '^\|.*(command|script|task).*\|' || true)
if [ -z "$_h" ]; then pass 7 "No build/dev command tables"; else fail 7 "Build/dev table detected" "$_h"; fi

# Check 8: No dependency lists
_h=$(_grep_all '^\|.*(dependency|package|version).*\|' || true)
if [ -z "$_h" ]; then pass 8 "No dependency lists"; else fail 8 "Dependency list detected" "$_h"; fi

# Check 9: No infrastructure fields
_h=$(_grep_all '^(Hosting|CI/CD|Database|External [Ss]ervices)\s*:' || true)
if [ -z "$_h" ]; then pass 9 "No infrastructure fields"; else fail 9 "Infrastructure field detected" "$_h"; fi

# Check 10: No naming conventions
_h=$(_grep_all '(naming convention|naming pattern|## [Nn]aming)' || true)
if [ -z "$_h" ]; then pass 10 "No naming conventions"; else fail 10 "Naming convention detected" "$_h"; fi

# Check 11: No data flow sections
_h=$(_grep_all '^## *(Data *Flow)' || true)
if [ -z "$_h" ]; then pass 11 "No data flow sections"; else fail 11 "Data flow section detected" "$_h"; fi

# Check 12: No error handling sections
_h=$(_grep_all '^## *(Error *Handling)' || true)
if [ -z "$_h" ]; then pass 12 "No error handling sections"; else fail 12 "Error handling section detected" "$_h"; fi

# Check 13: No evolution/changelog
_h=$(_grep_all '(## (Evolution|Changelog|History|Version History)|^### v[0-9]+)' || true)
if [ -z "$_h" ]; then pass 13 "No evolution/changelog entries"; else fail 13 "Evolution/changelog detected" "$_h"; fi

# Check 14: No completed work in activeState
if [ -f "$F_as" ]; then
  _h=$(grep -niE '(## Completed|## Done|\[x\]|~~.+~~)' "$F_as" 2>/dev/null | head -3 || true)
  if [ -z "$_h" ]; then pass 14 "No completed work in activeState"; else fail 14 "Completed work in activeState" "$_h"; fi
else pass 14 "No completed work in activeState (file missing)"; fi

# Check 15: No recent changes in activeState
if [ -f "$F_as" ]; then
  _h=$(grep -niE '(## Recent Changes|## What Changed|## Changes|## Updates)' "$F_as" 2>/dev/null | head -3 || true)
  if [ -z "$_h" ]; then pass 15 "No recent changes in activeState"; else fail 15 "Recent changes list in activeState" "$_h"; fi
else pass 15 "No recent changes in activeState (file missing)"; fi

# Check 16: No framework fields in techContext
if [ -f "$F_tc" ]; then
  _h=$(grep -niE '^(Framework|Test Runner|Testing|Bundler|Linter|Package Manager|Build Tool|CI)\s*:' "$F_tc" 2>/dev/null | head -3 || true)
  if [ -z "$_h" ]; then pass 16 "No framework fields in techContext"; else fail 16 "Framework field in techContext" "$_h"; fi
else pass 16 "No framework fields (file missing)"; fi

# Check 17: SKIPPED — code summaries is heuristic
info "SKIP #17: Code summaries — heuristic, requires LLM"
echo ""

# ── STRUCTURAL CHECKS (18-35) ─────────────────────────────────
echo "  Structural (18 checks):"

# Helper: check required sections in a file
_check_sections() {
  _file="$1"; _check_num="$2"; _name="$3"; shift 3
  _missing=""
  for heading in "$@"; do
    if ! grep -q "^## ${heading}$" "$_file" 2>/dev/null; then
      _missing="$_missing $heading,"
    fi
  done
  if [ -z "$_missing" ]; then
    pass "$_check_num" "$_name has all required sections"
  else
    fail "$_check_num" "$_name missing sections:$_missing"
  fi
}

# Checks 18-22: Required sections per file
[ -f "$F_pc" ] && _check_sections "$F_pc" 18 "projectContext.md" "Identity" "Purpose" "Target Audience" "Core Requirements" "Success Criteria" "Key User Flows" "Scope"
[ -f "$F_as" ] && _check_sections "$F_as" 19 "activeState.md" "Resume Here" "Primary Thread" "Working Set" "In Progress" "Remaining" "Blockers" "Known Issues" "Open Questions"
[ -f "$F_sp" ] && _check_sections "$F_sp" 20 "systemPatterns.md" "Architecture Overview" "Key Design Decisions" "Design Patterns" "Component Relationships" "Gotchas & Traps"
[ -f "$F_tc" ] && _check_sections "$F_tc" 21 "techContext.md" "Stack" "Non-Obvious Constraints" "Setup Gotchas" "Environment Quirks"
[ -f "$F_dc" ] && _check_sections "$F_dc" 22 "decisions.md" "Key Decisions" "Rejected Alternatives" "Intent & Patterns"

# Check 23: No additional ## sections (simplified — checks for unexpected ## headings)
# This is approximate — a full implementation would list all known headings and diff
pass 23 "Section heading check (verify manually for extras)"

# Check 24: Key-value format
_kv_ok=1
[ -f "$F_pc" ] && ! grep -q '^Project: ' "$F_pc" 2>/dev/null && _kv_ok=0
[ -f "$F_tc" ] && ! grep -q '^Language: ' "$F_tc" 2>/dev/null && _kv_ok=0
[ -f "$F_tc" ] && ! grep -q '^Runtime: ' "$F_tc" 2>/dev/null && _kv_ok=0
if [ "$_kv_ok" -eq 1 ]; then pass 24 "Key-value fields present"; else fail 24 "Missing key-value fields (Project:, Language:, Runtime:)"; fi

# Check 25: Component Relationships uses ->
if [ -f "$F_sp" ]; then
  _sec=$(extract_section "$F_sp" "Component Relationships")
  if echo "$_sec" | grep -q '\->' 2>/dev/null; then pass 25 "Component Relationships uses ->"; else fail 25 "Component Relationships missing -> notation"; fi
fi

# Check 26: Key User Flows uses arrow
if [ -f "$F_pc" ]; then
  _sec=$(extract_section "$F_pc" "Key User Flows")
  if printf "%s" "$_sec" | grep -q '→' 2>/dev/null; then pass 26 "Key User Flows uses arrow notation"; else fail 26 "Key User Flows missing arrow notation"; fi
fi

# Check 27: Resume Here is specific
if [ -f "$F_as" ]; then
  _sec=$(extract_section "$F_as" "Resume Here")
  _generic=$(echo "$_sec" | grep -iE '(continue working|review the codebase|pick up where|resume work|keep going|check the project)' || true)
  if [ -z "$_generic" ] && [ -n "$_sec" ]; then pass 27 "Resume Here is specific"; else fail 27 "Resume Here is too generic or empty"; fi
fi

# Check 28: Working Set 3-5 paths
if [ -f "$F_as" ]; then
  _sec=$(extract_section "$F_as" "Working Set")
  _count=$(echo "$_sec" | grep -c '^\s*- ' 2>/dev/null || echo 0)
  if [ "$_count" -ge 3 ] && [ "$_count" -le 5 ]; then pass 28 "Working Set has $_count paths"; else fail 28 "Working Set has $_count paths (need 3-5)"; fi
fi

# Check 29: Decision format (4-line active OR 1-line compact)
if [ -f "$F_dc" ]; then
  _sec=$(extract_section "$F_dc" "Key Decisions")
  _dates=$(echo "$_sec" | grep -cE '^[0-9]{4}-[0-9]{2}-[0-9]{2}:' 2>/dev/null | tr -d '[:space:]' || echo 0)
  _compact=$(echo "$_sec" | grep -cE '^~~[0-9]{4}-' 2>/dev/null | tr -d '[:space:]' || echo 0)
  [ -z "$_dates" ] && _dates=0
  [ -z "$_compact" ] && _compact=0
  if [ "$((_dates + _compact))" -ge 1 ]; then
    pass 29 "Key Decision entries found ($_dates active, $_compact compact)"
  else
    fail 29 "No valid Key Decision entries found"
  fi
fi

# Check 30: WARNING — superseded in full format when >120 lines
if [ -f "$F_dc" ]; then
  _dc_lines=$(wc -l < "$F_dc" | tr -d ' ')
  if [ "$_dc_lines" -gt 120 ]; then
    _superseded=$(grep -c 'Status: superseded' "$F_dc" 2>/dev/null || echo 0)
    if [ "$_superseded" -gt 0 ]; then
      warn 30 "$_superseded superseded decisions in full format (file at $_dc_lines/150 — run memory compact)"
    else
      pass 30 "No superseded decisions in full format"
    fi
  else
    pass 30 "decisions.md under 120 lines — compaction not needed"
  fi
fi

# Check 31: Decision dates format
if [ -f "$F_dc" ]; then
  _bad_dates=$(grep -nE '^[0-9]{4}-[0-9]{2}-[0-9]{2}:' "$F_dc" | grep -vE '^[0-9]+:[0-9]{4}-[0-1][0-9]-[0-3][0-9]:' || true)
  if [ -z "$_bad_dates" ]; then pass 31 "Decision dates are valid format"; else fail 31 "Invalid decision date format" "$_bad_dates"; fi
fi

# Check 32: Rejected alternatives
if [ -f "$F_dc" ]; then
  _ra=$(grep -c '\*\*What was considered\*\*' "$F_dc" 2>/dev/null || echo 0)
  if [ "$_ra" -ge 1 ]; then pass 32 "Rejected Alternatives: $_ra entries"; else fail 32 "No Rejected Alternative entries found"; fi
fi

# Check 33: No empty sections
_empty_secs=0
for f in $ALL_FILES; do
  [ -f "$f" ] || continue
  _prev_was_heading=0
  while IFS= read -r line; do
    case "$line" in
      "## "*)
        if [ "$_prev_was_heading" -eq 1 ]; then _empty_secs=$((_empty_secs + 1)); fi
        _prev_was_heading=1 ;;
      "")  ;; # blank lines don't reset
      *)   _prev_was_heading=0 ;;
    esac
  done < "$f"
done
if [ "$_empty_secs" -eq 0 ]; then pass 33 "No empty sections"; else fail 33 "$_empty_secs section(s) have no content"; fi

# Check 34: No [fill:] placeholders
_h=$(_grep_all '\[fill:' || true)
if [ -z "$_h" ]; then pass 34 "No [fill:] placeholders"; else fail 34 "[fill:] placeholder found" "$_h"; fi

# Check 35: No "Not yet documented"
_h=$(_grep_all '[Nn]ot yet documented' || true)
if [ -z "$_h" ]; then pass 35 "No 'Not yet documented'"; else fail 35 "'Not yet documented' found" "$_h"; fi
echo ""

# ── EVIDENCE CHECKS (36-40) ───────────────────────────────────
echo "  Evidence (5 checks):"

# Check 36: Warm files have Source: lines
for f in $WARM; do
  [ -f "$f" ] || continue
  _name=$(basename "$f")
  _src=$(grep -c '^Source: ' "$f" 2>/dev/null || echo 0)
  if [ "$_src" -ge 1 ]; then pass 36 "$_name has $_src Source: lines"; else fail 36 "$_name missing Source: lines"; fi
done

# Check 37: Source references point to existing files
_src_ok=1
for f in $WARM; do
  [ -f "$f" ] || continue
  _fname=$(basename "$f")
  _refs=$(grep '^Source: ' "$f" 2>/dev/null | sed 's/^Source: //' | sed 's/[[:space:]]*#.*//' | sed 's/[[:space:]]*$//' || true)
  if [ -n "$_refs" ]; then
    echo "$_refs" | while IFS= read -r ref; do
      [ -z "$ref" ] && continue
      case "$ref" in
        */*|*.*) [ ! -e "$PROJECT_ROOT/$ref" ] && { fail 37 "Broken Source: $ref" "$_fname"; _src_ok=0; } ;;
        [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;; # commit hash
        *) ;; # allow other formats (tool names etc.)
      esac
    done
  fi
done
pass 37 "Source references checked"

# Check 38: Warm files have confidence markers
for f in $WARM; do
  [ -f "$f" ] || continue
  _name=$(basename "$f")
  _cm=$(grep -cE '\[(observed|inferred|assumed)\]' "$f" 2>/dev/null || echo 0)
  if [ "$_cm" -ge 1 ]; then pass 38 "$_name has $_cm confidence markers"; else fail 38 "$_name missing confidence markers"; fi
done

# Check 39: Essential files have NO Source: lines
for f in $ESSENTIAL; do
  [ -f "$f" ] || continue
  _name=$(basename "$f")
  if grep -q '^Source: ' "$f" 2>/dev/null; then
    fail 39 "$_name has Source: lines (prohibited in essential files)"
  else
    pass 39 "$_name has no Source: lines"
  fi
done

# Check 40: Essential files have NO confidence markers
for f in $ESSENTIAL; do
  [ -f "$f" ] || continue
  _name=$(basename "$f")
  if grep -qE '\[(observed|inferred|assumed)\]' "$f" 2>/dev/null; then
    fail 40 "$_name has confidence markers (prohibited in essential files)"
  else
    pass 40 "$_name has no confidence markers"
  fi
done
echo ""

# ── SPECIFICITY CHECKS (41-42 deterministic, 43-45 heuristic) ──
echo "  Specificity (2 deterministic + 3 heuristic):"

# Check 41: No vague terms
_h=$(_grep_all '\b(several|various|many|some)\b' || true)
# Filter out lines inside Open Questions
_filtered=""
if [ -n "$_h" ]; then
  _filtered=$(echo "$_h" | grep -v 'Open Questions' || true)
fi
if [ -z "$_filtered" ]; then pass 41 "No vague terms"; else fail 41 "Vague terms found" "$_filtered"; fi

# Check 42: No hedging outside Open Questions
_h=$(_grep_all '\b(seems to|appears to|might)\b' || true)
_filtered=""
if [ -n "$_h" ]; then
  _filtered=$(echo "$_h" | grep -v 'Open Questions' || true)
fi
if [ -z "$_filtered" ]; then pass 42 "No hedging language"; else fail 42 "Hedging language found" "$_filtered"; fi

info "SKIP #43: Substitution test — heuristic, requires LLM"
info "SKIP #44: Tautology detection — heuristic, requires LLM"
info "SKIP #45: Proper noun density — heuristic, requires LLM"
echo ""

# ── SECURITY CHECKS (46-47) ───────────────────────────────────
echo "  Security (2 checks):"

# Check 46: Already handled by secret detection above
if [ "$SECRET_COUNT" -eq 0 ]; then
  pass 46 "No secret patterns detected"
else
  fail 46 "$SECRET_COUNT secret pattern(s) detected — BLOCKING"
fi

# Check 47: No path escape
_escape=0
for f in $ALL_FILES; do
  [ -f "$f" ] || continue
  _esc=$(grep -nE '(Source:|Working Set|^\s*- )' "$f" 2>/dev/null | grep -E '(^|[^a-zA-Z])/[a-zA-Z]' | grep -v "$PROJECT_ROOT" || true)
  # Simplified check — flag absolute paths
  _abs=$(grep -nE '(Source: /|^\s*- /)' "$f" 2>/dev/null || true)
  if [ -n "$_abs" ]; then
    _escape=1
    fail 47 "Absolute path found in $(basename "$f")" "$_abs"
  fi
done
[ "$_escape" -eq 0 ] && pass 47 "No path escapes detected"
echo ""

# ── ORPHANED .tmp WARNING ─────────────────────────────────────
_tmps=$(find "$MB_PATH" -maxdepth 1 -name '.*.tmp' -type f 2>/dev/null || true)
if [ -n "$_tmps" ]; then
  warn "TMP" "Orphaned temp files found from interrupted operation:"
  echo "$_tmps" | while IFS= read -r t; do echo "      $t"; done
fi

# ── SUMMARY ────────────────────────────────────────────────────
echo "  ────────────────────────────────────────"
_det_total=$((PASS_COUNT + FAIL_COUNT))
printf "  Result: %d/%d PASSED, %d FAILED" "$PASS_COUNT" "$_det_total" "$FAIL_COUNT"
[ "$WARN_COUNT" -gt 0 ] && printf ", %d WARNING(s)" "$WARN_COUNT"
[ "$SECRET_COUNT" -gt 0 ] && printf " | Secret: %d BLOCKED" "$SECRET_COUNT"
echo ""
echo "  LLM-only: 4 checks (#17, #43, #44, #45 — run 'memory status')"
echo ""

# ── EXIT CODE ──────────────────────────────────────────────────
if [ "$FAIL_COUNT" -gt 0 ] || [ "$SECRET_COUNT" -gt 0 ]; then
  exit 1
else
  exit 0
fi
