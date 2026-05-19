#!/usr/bin/env bash
# Verifies all 15 Claude command files are present and clean

set -e
COMMANDS_DIR=".claude/commands"
ERRORS=0

echo "=== Claude Commands Verification ==="

EXPECTED=(
  create-agent update-agent feedback-agent sanity-check-agent
  accessibility-agent content-updater draft-page-generator fix-grammar
  monitoring-agent page-management-agent release-notes-agent scoring-agent
  ajo-roadmap-agent doc-changes-agent upgrade-agents
)

echo "--- Checking all 15 files exist ---"
for name in "${EXPECTED[@]}"; do
  if [[ ! -f "$COMMANDS_DIR/$name.md" ]]; then
    echo "MISSING: $COMMANDS_DIR/$name.md"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "--- Checking for Cursor-specific text ---"
CURSOR_HITS=$(grep -ril \
  "open cursor settings\|tools & MCP\|cursor\.com/docs/context/commands\|\.cursor/commands\|\.cursor/mcp\.json" \
  "$COMMANDS_DIR" 2>/dev/null || true)
if [[ -n "$CURSOR_HITS" ]]; then
  echo "CURSOR REFS FOUND in:"
  echo "$CURSOR_HITS"
  ERRORS=$((ERRORS + 1))
fi

echo "--- Checking for unfilled placeholders ---"
PLACEHOLDER_HITS=$(grep -rl "\[Include shared" "$COMMANDS_DIR" 2>/dev/null || true)
if [[ -n "$PLACEHOLDER_HITS" ]]; then
  echo "UNFILLED PLACEHOLDERS in:"
  echo "$PLACEHOLDER_HITS"
  ERRORS=$((ERRORS + 1))
fi

echo "--- Checking for \$ARGUMENTS header ---"
for name in "${EXPECTED[@]}"; do
  f="$COMMANDS_DIR/$name.md"
  [[ -f "$f" ]] || continue
  if ! grep -q "ARGUMENTS" "$f"; then
    echo "MISSING \$ARGUMENTS header: $f"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo "All checks passed (15/15 files, clean)"
else
  echo "$ERRORS check(s) failed"
  exit 1
fi
