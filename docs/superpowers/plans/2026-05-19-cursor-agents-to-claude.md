# Cursor Agents → Claude Code Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create 15 `.claude/commands/` slash command files by translating `.cursor-agents/agents/` source files for use with Claude Code CLI.

**Architecture:** Each command file is a translated copy of its Cursor source. Shared-component placeholders are inlined with adapted content. Cursor-specific text is replaced with Claude Code equivalents. No workflow logic changes anywhere.

**Tech Stack:** Markdown, Claude Code slash commands, `$ARGUMENTS`

---

## Transformation Reference

Every task applies some subset of these transformations. Read this section before starting any task.

### A. $ARGUMENTS header

Insert after the opening `# Agent: ...` heading, before `## Role`:

```markdown
<!-- Usage: /[agent-name] [optional context, e.g. "draft page from https://..."] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

### B. Text substitutions (find-and-replace, all files)

| Find | Replace |
|------|---------|
| `@create-agent` | `/create-agent` |
| `@update-agent` | `/update-agent` |
| `@feedback-agent` | `/feedback-agent` |
| `@sanity-check-agent` | `/sanity-check-agent` |
| `@[agent-name]` | `/[agent-name]` |
| `Open Cursor Settings (Cmd+,)` | `Check your Claude Code MCP config: .claude/settings.json` |
| `Go to: Tools & MCP` | `Verify both MCP servers are listed and enabled:` |
| `Reload: @[agent-name]` | `Re-run: /[agent-name]` |
| `Still stuck? Check VPN connection or .cursor/mcp.json` | `Still stuck? Check VPN connection or .claude/settings.json` |
| `See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: \`.cursor/commands/` | `Use /[agent-name] in Claude Code. Command file: \`.claude/commands/` |
| `Trigger (Cursor Commands – recommended): Type \`/\` in the chat, then choose` | `Trigger: Type` |

### C. Shared component placeholder replacement

Three placeholder strings appear in v3 active agents (and `content-updater`):

```
[Include shared/pre-flight-checks.md content here]
[Include shared/usage-tracking.md content here]
[Include shared/post-flight-checks.md content here]
```

Replace each with the full content of the corresponding file from `.cursor-agents/shared/`, **except** apply this adaptation to `pre-flight-checks.md` before inlining.

**pre-flight-checks.md — replace this block:**

```
🔧 Quick Fix (30 seconds):
1. Open Cursor Settings (Cmd+,)
2. Go to: Tools & MCP
3. Enable BOTH toggles (must be green):
   • Adobe Wiki Confluence
   • Corp Jira
4. Wait 5-10 seconds
5. Reload: @[agent-name]

Still stuck? Check VPN connection or .cursor/mcp.json
```

**With:**

```
🔧 Quick Fix (30 seconds):
1. Check your Claude Code MCP config: .claude/settings.json
2. Verify both MCP servers are listed and enabled:
   • Adobe Wiki Confluence
   • Corp Jira
3. Wait 5-10 seconds
4. Re-run: /[agent-name]

Still stuck? Check VPN connection or .claude/settings.json
```

`post-flight-checks.md` and `usage-tracking.md` are inlined **verbatim** — no changes.

### D. upgrade-agents.md branding substitutions (that file only)

| Find | Replace |
|------|---------|
| `Cursor Agents` (branding text, not the `.cursor-agents/` directory path) | `Claude Agents` |

Specific instances:
- `keep their Cursor Agents` → `keep their Claude Agents`
- `upgrades to the Cursor Agents submodule` → `upgrades to the Claude Agents submodule`
- `⚠️ Cursor Agents Not Installed` → `⚠️ Claude Agents Not Installed`
- `haven't installed Cursor Agents yet` → `haven't installed Claude Agents yet`
- `Your Cursor Agents are running` → `Your Claude Agents are running`
- `🔄 Updating Cursor Agents...` → `🔄 Updating Claude Agents...`

Keep all `.cursor-agents/` directory path references unchanged — the submodule directory stays named `.cursor-agents/`.

### E. ajo-roadmap-agent path substitutions (that file only)

| Find | Replace |
|------|---------|
| `~/.cursor/skills/ajo-roadmap-pptx/generate_roadmap_pptx.py` | `~/.claude/skills/ajo-roadmap-pptx/generate_roadmap_pptx.py` |
| `mkdir -p ~/.cursor/skills/ajo-roadmap-pptx` | `mkdir -p ~/.claude/skills/ajo-roadmap-pptx` |
| `~/.cursor/skills/ajo-roadmap-pptx/` | `~/.claude/skills/ajo-roadmap-pptx/` |

---

## Task 1: Write verification script and confirm it fails

**Files:**
- Create: `.claude/verify-commands.sh`

- [ ] **Step 1: Create the verification script**

Create `.claude/verify-commands.sh` with this content:

```bash
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
```

- [ ] **Step 2: Make executable and run — confirm it fails**

```bash
chmod +x .claude/verify-commands.sh
bash .claude/verify-commands.sh
```

Expected: script prints 15 `MISSING:` lines and exits non-zero. Correct.

- [ ] **Step 3: Commit**

```bash
git add .claude/verify-commands.sh
git commit -m "feat: add claude commands verification script"
```

---

## Task 2: Create .claude/commands/ directory

- [ ] **Step 1: Create the directory**

```bash
mkdir -p .claude/commands
```

- [ ] **Step 2: Confirm**

```bash
ls -la .claude/
```

Expected: `commands/` listed.

---

## Task 3: Port create-agent.md

Source: `.cursor-agents/agents/create-agent.md` (323 lines, has all 3 placeholders)

**Files:**
- Create: `.claude/commands/create-agent.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/create-agent.md .claude/commands/create-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

After line 1 (`# Agent: Create Agent`), insert:

```markdown
<!-- Usage: /create-agent [optional context, e.g. "draft page from https://..."] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Replace pre-flight placeholder (Transformation C)**

Find:
```
[Include shared/pre-flight-checks.md content here]
```
Replace with: full content of `.cursor-agents/shared/pre-flight-checks.md`, with the MCP Quick Fix block adapted as shown in Transformation C.

- [ ] **Step 4: Replace usage-tracking placeholder (Transformation C)**

Find:
```
[Include shared/usage-tracking.md content here]
```
Replace with: full verbatim content of `.cursor-agents/shared/usage-tracking.md`.

- [ ] **Step 5: Replace post-flight placeholder (Transformation C)**

Find:
```
[Include shared/post-flight-checks.md content here]
```
Replace with: full verbatim content of `.cursor-agents/shared/post-flight-checks.md`.

- [ ] **Step 6: Apply text substitutions (Transformation B)**

```
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/create-agent.md`.
Replace: Use /create-agent in Claude Code. Command file: `.claude/commands/create-agent.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `create-agent`.
Replace: Trigger: Type `/create-agent` in Claude Code.
```

- [ ] **Step 7: Run verification — confirm create-agent passes**

```bash
bash .claude/verify-commands.sh 2>&1 | grep -E "create-agent|passed|failed"
```

Expected: no output for `create-agent` (meaning it passes all 4 checks for this file).

- [ ] **Step 8: Commit**

```bash
git add .claude/commands/create-agent.md
git commit -m "feat: add /create-agent claude command"
```

---

## Task 4: Port update-agent.md

Source: `.cursor-agents/agents/update-agent.md` (1082 lines, placeholders at lines 58, 66, 734)

**Files:**
- Create: `.claude/commands/update-agent.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/update-agent.md .claude/commands/update-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /update-agent [optional context, e.g. "targeted update for feature X"] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Replace all 3 shared-component placeholders (Transformation C)**

Apply in order:
- `[Include shared/pre-flight-checks.md content here]` → adapted pre-flight content
- `[Include shared/usage-tracking.md content here]` → verbatim usage-tracking content
- `[Include shared/post-flight-checks.md content here]` → verbatim post-flight content

- [ ] **Step 4: Apply text substitutions (Transformation B)**

```
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/update-agent.md`.
Replace: Use /update-agent in Claude Code. Command file: `.claude/commands/update-agent.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `update-agent`.
Replace: Trigger: Type `/update-agent` in Claude Code.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/update-agent.md
git commit -m "feat: add /update-agent claude command"
```

---

## Task 5: Port feedback-agent.md

Source: `.cursor-agents/agents/feedback-agent.md` (528 lines, placeholders at lines 13, 23, 469; references `@update-agent` at line 469)

**Files:**
- Create: `.claude/commands/feedback-agent.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/feedback-agent.md .claude/commands/feedback-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /feedback-agent [optional context, e.g. "Experience League Excel feedback"] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Replace all 3 shared-component placeholders (Transformation C)**

Apply in order:
- `[Include shared/pre-flight-checks.md content here]` → adapted pre-flight content
- `[Include shared/usage-tracking.md content here]` → verbatim usage-tracking content
- `[Include shared/post-flight-checks.md content here]` → verbatim post-flight content

- [ ] **Step 4: Apply text substitutions (Transformation B)**

```
Find:    **@update-agent**
Replace: **/update-agent**

Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/feedback-agent.md`.
Replace: Use /feedback-agent in Claude Code. Command file: `.claude/commands/feedback-agent.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `feedback-agent`.
Replace: Trigger: Type `/feedback-agent` in Claude Code.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/feedback-agent.md
git commit -m "feat: add /feedback-agent claude command"
```

---

## Task 6: Port sanity-check-agent.md

Source: `.cursor-agents/agents/sanity-check-agent.md` (1087 lines, placeholders at lines 13, 21, 361)

**Files:**
- Create: `.claude/commands/sanity-check-agent.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/sanity-check-agent.md .claude/commands/sanity-check-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /sanity-check-agent [optional: "current file" | file path | folder path] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Replace all 3 shared-component placeholders (Transformation C)**

Apply in order:
- `[Include shared/pre-flight-checks.md content here]` → adapted pre-flight content
- `[Include shared/usage-tracking.md content here]` → verbatim usage-tracking content
- `[Include shared/post-flight-checks.md content here]` → verbatim post-flight content

- [ ] **Step 4: Apply text substitutions (Transformation B)**

```
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/sanity-check-agent.md`.
Replace: Use /sanity-check-agent in Claude Code. Command file: `.claude/commands/sanity-check-agent.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `sanity-check-agent`.
Replace: Trigger: Type `/sanity-check-agent` in Claude Code.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/sanity-check-agent.md
git commit -m "feat: add /sanity-check-agent claude command"
```

---

## Task 7: Port 6 clean legacy agents

These have **no shared-component placeholders**. Each needs only Transformation A + B.

**Files:**
- Create: `.claude/commands/accessibility-agent.md`
- Create: `.claude/commands/draft-page-generator.md`
- Create: `.claude/commands/fix-grammar.md`
- Create: `.claude/commands/monitoring-agent.md`
- Create: `.claude/commands/page-management-agent.md`
- Create: `.claude/commands/scoring-agent.md`

- [ ] **Step 1: Copy all 6 files**

```bash
cp .cursor-agents/agents/legacy/accessibility-agent.md   .claude/commands/accessibility-agent.md
cp .cursor-agents/agents/legacy/draft-page-generator.md  .claude/commands/draft-page-generator.md
cp .cursor-agents/agents/legacy/fix-grammar.md           .claude/commands/fix-grammar.md
cp .cursor-agents/agents/legacy/monitoring-agent.md      .claude/commands/monitoring-agent.md
cp .cursor-agents/agents/legacy/page-management-agent.md .claude/commands/page-management-agent.md
cp .cursor-agents/agents/legacy/scoring-agent.md         .claude/commands/scoring-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header in each file (Transformation A)**

In each file, insert after the opening `# Agent: ...` line:

**accessibility-agent.md:**
```markdown
<!-- Usage: /accessibility-agent [optional: file path or "current file"] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

**draft-page-generator.md:**
```markdown
<!-- Usage: /draft-page-generator [optional: Wiki/Jira URL or topic] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

**fix-grammar.md:**
```markdown
<!-- Usage: /fix-grammar [optional: file path or "current file"] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

**monitoring-agent.md:**
```markdown
<!-- Usage: /monitoring-agent [optional: repo name or date range] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

**page-management-agent.md:**
```markdown
<!-- Usage: /page-management-agent [optional: file path and operation] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

**scoring-agent.md:**
```markdown
<!-- Usage: /scoring-agent [optional: file path or "current file"] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Apply text substitutions to all 6 files (Transformation B)**

For each file, replace the usage/trigger line at the end. Pattern is identical; only the agent name changes:

```
# accessibility-agent.md
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/accessibility-agent.md`.
Replace: Use /accessibility-agent in Claude Code. Command file: `.claude/commands/accessibility-agent.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `accessibility-agent`.
Replace: Trigger: Type `/accessibility-agent` in Claude Code.

# draft-page-generator.md
Find:    `.cursor/commands/draft-page-generator.md`
Replace: `.claude/commands/draft-page-generator.md`
(and the Trigger line accordingly)

# fix-grammar.md — same pattern

# monitoring-agent.md — same pattern

# page-management-agent.md — same pattern

# scoring-agent.md — same pattern
```

- [ ] **Step 4: Commit**

```bash
git add \
  .claude/commands/accessibility-agent.md \
  .claude/commands/draft-page-generator.md \
  .claude/commands/fix-grammar.md \
  .claude/commands/monitoring-agent.md \
  .claude/commands/page-management-agent.md \
  .claude/commands/scoring-agent.md
git commit -m "feat: add 6 legacy claude commands (accessibility, draft-page, fix-grammar, monitoring, page-management, scoring)"
```

---

## Task 8: Port content-updater.md (legacy with 1 placeholder)

Source: `.cursor-agents/agents/legacy/content-updater.md` (1449 lines, pre-flight placeholder at line 19)

**Files:**
- Create: `.claude/commands/content-updater.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/legacy/content-updater.md .claude/commands/content-updater.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /content-updater [optional: file path, scope, or instruction] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Replace the pre-flight placeholder (Transformation C)**

Find:
```
[Include shared/pre-flight-checks.md content here]
```
Replace with: full content of `.cursor-agents/shared/pre-flight-checks.md` with the MCP Quick Fix block adapted per Transformation C.

- [ ] **Step 4: Apply text substitutions (Transformation B)**

```
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/content-updater.md`.
Replace: Use /content-updater in Claude Code. Command file: `.claude/commands/content-updater.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `content-updater`.
Replace: Trigger: Type `/content-updater` in Claude Code.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/content-updater.md
git commit -m "feat: add /content-updater claude command"
```

---

## Task 9: Port release-notes-agent.md (inline MCP error block)

Source: `.cursor-agents/agents/legacy/release-notes-agent.md` (477 lines, no placeholders; has inline MCP error block around line 62)

**Files:**
- Create: `.claude/commands/release-notes-agent.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/legacy/release-notes-agent.md .claude/commands/release-notes-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /release-notes-agent [optional: release month/year or Jira filter] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Update the inline MCP Quick Fix block**

Find this block (around line 62 in source):

```
🔧 Quick Fix (30 seconds):
1. Open Cursor Settings (Cmd+,)
2. Go to: Tools & MCP
3. Enable BOTH toggles (must be green):
   • Adobe Wiki Confluence
   • Corp Jira
4. Wait 5-10 seconds
5. Reload: @[agent-name]

Still stuck? Check VPN connection or .cursor/mcp.json
```

Replace with:

```
🔧 Quick Fix (30 seconds):
1. Check your Claude Code MCP config: .claude/settings.json
2. Verify both MCP servers are listed and enabled:
   • Adobe Wiki Confluence
   • Corp Jira
3. Wait 5-10 seconds
4. Re-run: /[agent-name]

Still stuck? Check VPN connection or .claude/settings.json
```

- [ ] **Step 4: Apply text substitutions (Transformation B)**

```
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/release-notes-agent.md`.
Replace: Use /release-notes-agent in Claude Code. Command file: `.claude/commands/release-notes-agent.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `release-notes-agent`.
Replace: Trigger: Type `/release-notes-agent` in Claude Code.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/release-notes-agent.md
git commit -m "feat: add /release-notes-agent claude command"
```

---

## Task 10: Port ajo-roadmap-agent.md (~/.cursor/ path substitution)

Source: `.cursor-agents/agents/new/ajo-roadmap-agent.md` (475 lines, no placeholders, 3 `~/.cursor/skills/` references)

**Files:**
- Create: `.claude/commands/ajo-roadmap-agent.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/new/ajo-roadmap-agent.md .claude/commands/ajo-roadmap-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /ajo-roadmap-agent [optional: Jira filter or date range] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Apply path substitutions (Transformation E)**

```
Find:    ~/.cursor/skills/ajo-roadmap-pptx/generate_roadmap_pptx.py
Replace: ~/.claude/skills/ajo-roadmap-pptx/generate_roadmap_pptx.py

Find:    mkdir -p ~/.cursor/skills/ajo-roadmap-pptx
Replace: mkdir -p ~/.claude/skills/ajo-roadmap-pptx

Find:    ~/.cursor/skills/ajo-roadmap-pptx/
Replace: ~/.claude/skills/ajo-roadmap-pptx/
```

- [ ] **Step 4: Apply text substitutions (Transformation B)**

```
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/ajo-roadmap-agent.md`.
Replace: Use /ajo-roadmap-agent in Claude Code. Command file: `.claude/commands/ajo-roadmap-agent.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `ajo-roadmap-agent`.
Replace: Trigger: Type `/ajo-roadmap-agent` in Claude Code.
```

- [ ] **Step 5: Verify path substitution**

```bash
grep "cursor/skills" .claude/commands/ajo-roadmap-agent.md
# Expected: no output

grep "claude/skills" .claude/commands/ajo-roadmap-agent.md
# Expected: 3 lines with ~/.claude/skills/ajo-roadmap-pptx/
```

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/ajo-roadmap-agent.md
git commit -m "feat: add /ajo-roadmap-agent claude command"
```

---

## Task 11: Port doc-changes-agent.md (cleanest file)

Source: `.cursor-agents/agents/new/doc-changes-agent.md` (124 lines, no placeholders, no Cursor refs)

**Files:**
- Create: `.claude/commands/doc-changes-agent.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/agents/new/doc-changes-agent.md .claude/commands/doc-changes-agent.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /doc-changes-agent [optional: date range or branch name] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

- [ ] **Step 3: Confirm clean**

```bash
grep -i "cursor\|\.cursor" .claude/commands/doc-changes-agent.md
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add .claude/commands/doc-changes-agent.md
git commit -m "feat: add /doc-changes-agent claude command"
```

---

## Task 12: Port upgrade-agents.md

Source: `.cursor-agents/setup_maintenance/upgrade-agents.md` (277 lines, no placeholders, Cursor branding throughout)

**Files:**
- Create: `.claude/commands/upgrade-agents.md`

- [ ] **Step 1: Copy source**

```bash
cp .cursor-agents/setup_maintenance/upgrade-agents.md .claude/commands/upgrade-agents.md
```

- [ ] **Step 2: Insert $ARGUMENTS header (Transformation A)**

```markdown
<!-- Usage: /upgrade-agents -->
<!-- $ARGUMENTS is not used by this command -->
```

- [ ] **Step 3: Apply branding substitutions (Transformation D)**

```
Find:    keep their Cursor Agents
Replace: keep their Claude Agents

Find:    upgrades to the Cursor Agents submodule
Replace: upgrades to the Claude Agents submodule

Find:    ⚠️ Cursor Agents Not Installed
Replace: ⚠️ Claude Agents Not Installed

Find:    haven't installed Cursor Agents yet
Replace: haven't installed Claude Agents yet

Find:    Your Cursor Agents are running the latest version
Replace: Your Claude Agents are running the latest version

Find:    🔄 Updating Cursor Agents...
Replace: 🔄 Updating Claude Agents...
```

Keep all `.cursor-agents/` path references unchanged.

- [ ] **Step 4: Apply text substitutions (Transformation B)**

```
Find:    See [Cursor Commands](https://cursor.com/docs/context/commands). Command file: `.cursor/commands/upgrade-agents.md`.
Replace: Use /upgrade-agents in Claude Code. Command file: `.claude/commands/upgrade-agents.md`.

Find:    Trigger (Cursor Commands – recommended): Type `/` in the chat, then choose `upgrade-agents`.
Replace: Trigger: Type `/upgrade-agents` in Claude Code.
```

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/upgrade-agents.md
git commit -m "feat: add /upgrade-agents claude command"
```

---

## Task 13: Final verification

- [ ] **Step 1: Run verification script — expect all green**

```bash
bash .claude/verify-commands.sh
```

Expected output:
```
=== Claude Commands Verification ===
--- Checking all 15 files exist ---
--- Checking for Cursor-specific text ---
--- Checking for unfilled placeholders ---
--- Checking for $ARGUMENTS header ---

All checks passed (15/15 files, clean)
```

- [ ] **Step 2: Spot-check a v3 agent**

```bash
grep -c "Context Isolation" .claude/commands/create-agent.md
# Expected: 1

grep -c "ARGUMENTS" .claude/commands/create-agent.md
# Expected: 1

grep -i "cursor settings" .claude/commands/create-agent.md
# Expected: no output
```

- [ ] **Step 3: Spot-check ajo-roadmap paths**

```bash
grep "cursor/skills" .claude/commands/ajo-roadmap-agent.md
# Expected: no output

grep "claude/skills" .claude/commands/ajo-roadmap-agent.md
# Expected: 3 lines
```

- [ ] **Step 4: Count files**

```bash
ls .claude/commands/*.md | wc -l
# Expected: 15
```

- [ ] **Step 5: Final commit**

```bash
git add .claude/
git commit -m "feat: complete claude commands suite (15 agents ported from .cursor-agents)"
```

---

## Spec Coverage

| Spec requirement | Task |
|---|---|
| All 14 agents ported | Tasks 3–11 |
| upgrade-agents ported | Task 12 |
| Flat structure in `.claude/commands/` | Task 2 |
| `$ARGUMENTS` header in every file | Tasks 3–12 (Transformation A) |
| Shared placeholders inlined | Tasks 3–6, 8 (Transformation C) |
| No Cursor-specific UI references | All tasks + Task 13 |
| `.cursor-agents/` submodule untouched | All `cp` commands, no `mv` |
| Usage tracking writes to `usage-agents.log` | Preserved verbatim in inlined content |
| MCP error messages reference Claude Code settings | Tasks 3–9 (adapted pre-flight + Task 9 inline) |
| ajo-roadmap `~/.cursor/` paths updated | Task 10 (Transformation E) |
