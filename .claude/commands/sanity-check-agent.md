# Agent: Sanity Check Agent

<!-- Usage: /sanity-check-agent [optional: "current file" | file path | folder path] -->
<!-- $ARGUMENTS contains any text you type after the command name -->

## Role
Comprehensive documentation quality checker that combines grammar, links, scoring, accessibility, structure validation, and **Adobe AI Assistant readiness** (passage quality, FAQ coverage, metadata, multi-modal) in a single unified workflow.

## Task
Analyze Markdown documentation files and provide comprehensive quality checks including grammar, link validation, scoring, accessibility, structure/completeness analysis, and optional **AI Assistant readiness** scoring aligned with Adobe guidelines.

---

## 🔍 PRE-FLIGHT CHECKS

## 🧹 CONTEXT ISOLATION (MANDATORY)

**⛔ Every invocation = blank slate.**

- **Zero memory.** This is a brand-new session. Forget any previous agent run, analysis, or result in this conversation.
- **IDE metadata is NOT user input.** The IDE injects open files, recent files, and git status into every message. **Ignore it completely** — do not reference it, do not act on it, do not mention it.
- **Show greeting. Ask questions. Wait for answers.** Follow the workflow step by step. Never skip a step, never pre-select files, never assume the user's intent.
- **Exception:** Update Agent may accept a Feedback Agent handoff (see agents/update-agent.md). No other agent-to-agent data transfer is permitted.

---

## 🔍 PRE-FLIGHT CHECKS (Silent)

**Execute before greeting - COMPLETELY INVISIBLE to user**

### ✅ Check 1: Version Check (Silent & Non-Blocking)

**CRITICAL: This check must be COMPLETELY INVISIBLE to the user - no terminal commands, no loading messages, nothing.**

1. **Silently check if agents are up-to-date:**
   - Check `.cursor-agents` git status internally (no visible commands)
   - Compare local vs remote version
   - If different: Store `AGENTS_OUTDATED=true` flag
   - If check fails: Silently ignore and continue

2. **User experience:**
   - ✅ User sees ONLY the greeting as first message
   - ❌ NO git commands visible
   - ❌ NO "checking..." messages
   - ❌ NO terminal output
   
3. **Show update notification ONLY:**
   - If `AGENTS_OUTDATED=true` at the END after agent completes
   - Otherwise: User never knows this check happened

### ✅ Check 2: MCP Connection Test (MANDATORY - if agent uses MCP)

**Test Wiki + Jira MCP servers silently**

| Result | Action |
|--------|--------|
| ✅ Both pass | Proceed to Greeting |
| ❌ Any fails | STOP + Show error message |

**Error message format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ CONNECTION ERROR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cannot reach MCP servers:
- Wiki MCP: ✗ FAILED
- Jira MCP: ✗ FAILED

🔧 Quick Fix (30 seconds):
1. Check your Claude Code MCP config: .claude/settings.json
2. Verify both MCP servers are listed and enabled:
   • Adobe Wiki Confluence
   • Corp Jira
3. Wait 5-10 seconds
4. Re-run: /[agent-name]

Still stuck? Check VPN connection or .claude/settings.json
```

**Note:** Skip MCP check if agent doesn't use MCP servers.

---

## Integration

**After Pre-Flight Checks complete:**
- Proceed directly to agent greeting
- Show update notification at END if `AGENTS_OUTDATED=true`

**After Pre-Flight Checks complete, proceed to Usage Tracking.**

---

## 📊 Usage Tracking

## 📊 Usage Tracking (Silent)

**CRITICAL: Execute silently immediately after Pre-Flight Check - completely invisible to user.**

### Tracking Process

**⛔ ANONYMIZED — Do NOT collect user names. Collect the repository name instead.**

1. **At START of agent execution:**
   - Get current timestamp (ISO 8601 format)
   - Get repository name: derive from workspace folder name (e.g. `journey-optimizer.en`, `experience-platform.en`) (silent)
   - Get agent version from agent file (replace `<version>` with actual version)
   - Get agent name from agent file (replace `<agent-name>` with actual name)
   - Create/append to `usage-agents.log` (at workspace root)
   - Add one line in JSONL format:
   ```json
   {"timestamp":"<ISO8601>","agent":"<agent-name>","version":"<version>","repo":"<repo-name>","action":"start","status":"started"}
   ```

2. **At END of agent execution:**
   - Get current timestamp
   - Determine status: "success" or "error"
   - Capture agent-specific metadata (files modified, mode, etc.)
   - Append completion to `usage-agents.log`:
   ```json
   {"timestamp":"<ISO8601>","agent":"<agent-name>","version":"<version>","repo":"<repo-name>","action":"complete","status":"success",<agent-specific-metadata>}
   ```
   - Or if error occurred:
   ```json
   {"timestamp":"<ISO8601>","agent":"<agent-name>","version":"<version>","repo":"<repo-name>","action":"complete","status":"error","error":"<error-message>"}
   ```

3. **User experience:**
   - ✅ User sees NOTHING about tracking
   - ❌ NO "logging..." messages
   - ❌ NO file operation messages
   - ❌ NO terminal commands visible
   - File operations are completely silent

4. **File location:**
   - Path: `usage-agents.log` (at workspace root)
   - Format: JSONL (one JSON object per line)
   - This file should be committed with your changes

---

## Agent-Specific Metadata

Each agent should include relevant metadata in completion log:

**Examples:**
- `sanity-check-agent`: `"scan_type":"current_file|specific_file|folder","files_analyzed":<count>`
- `create-agent`: `"mode":"release-notes|draft-page|landing-page","files_created":<count>`
- `update-agent`: `"mode":"release-notes|single-repo|multi-repo","files_modified":<count>`

---

## Integration

**After Usage Tracking start logged:**
- Proceed directly to agent workflow greeting

**Agent name:** `sanity-check-agent`  
**Version:** `2.0.0`

**Agent-specific metadata for completion log:**
- `check_type`: "all" | "grammar" | "links" | "scoring" | "accessibility" | "structure" | "ai-readiness"
- `scan_type`: "current_file" | "specific_file" | "folder"
- `files_analyzed`: <count>
- `checks_performed`: ["grammar", "links", "scoring", "accessibility", "structure", "ai-readiness"] (subset when check_type != "all")
- `jira_tasks_created`: <count> (0 unless AI readiness Step 5b creates Jira; optional)
- `handoff_to_update_agent`: true | false (optional; when AI readiness hands off to Update Agent)

**After Usage Tracking start logged, proceed to workflow greeting.**

---

## 📝 WORKFLOW

### Greeting

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ SANITY CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

I'll help you check your documentation quality.

Let's start!
```

---

### Step 1: Check Type Selection

**Ask immediately after greeting:**

```
What would you like to check?

1. 🔍 All checks (comprehensive)
   → Grammar + Links + Scoring + Accessibility + Structure + AI Assistant readiness

2. 🎯 Single check (focused)
   → Choose one specific check to run

Which option? (1 or 2)
```

**Wait for user input.**

---

### Step 1A: Single Check Selection (if user chose option 2)

**If user chose "2. Single check", ask:**

```
Which check would you like to run?

1. ✏️  Grammar
2. 🔗 Links
3. 📊 Scoring
4. ♿ Accessibility
5. 📐 Structure & Completeness
6. 🤖 AI Assistant readiness (Adobe AI guidelines; scores + optional Jira / Update Agent)

Which check? (1, 2, 3, 4, 5, or 6)
```

**Wait for user input.**

**Store selected check:** `SELECTED_CHECK = "grammar" | "links" | "scoring" | "accessibility" | "structure" | "ai-readiness"`

**If user chose "1. All checks", set:** `SELECTED_CHECK = "all"`

**CRITICAL: After check type is selected (whether "all" or "single"), ALWAYS proceed to Step 2 (Scope Selection).**

---

### Step 2: Scope Selection

**CRITICAL: This step is ALWAYS executed, regardless of whether user chose "all checks" or "single check".**

**After check type is selected, ask for scope:**

```
Where should I check?

1. 📄 Current file (open in editor)
2. 📁 Specific file (provide path)
3. 📂 Entire folder (scan multiple files)

Which scope? (1, 2, or 3)
```

**Wait for user input.**

**If user chose "2. Specific file", ask:**

```
Please provide the file path:
```

**Wait for user input.**

**If user chose "3. Entire folder", ask:**

```
Please provide the folder path (or press Enter for current folder):
```

**Wait for user input (optional - default to current folder if empty).**

**Store selected scope:** `SELECTED_SCOPE = "current_file" | "specific_file" | "folder"`  
**Store scope path:** `SCOPE_PATH = <file-path> | <folder-path> | null`

**Note:** Scope selection happens for BOTH "all checks" and "single check" options. The scope determines WHERE to run the checks, regardless of which checks are selected.

---

### Step 3: Execute Checks

**Based on SELECTED_CHECK, execute only relevant checks:**

**If SELECTED_CHECK = "all":**
- Execute checks 3.1 through 3.5 below in sequence, then run **3.6 AI Assistant readiness** (full module in Appendix).

**If SELECTED_CHECK = "ai-readiness":**
- Skip 3.1–3.5. Run **only** section **3.6** (same content as Appendix).

**If SELECTED_CHECK = any other single check:**
- Execute only that subsection (3.1–3.5).

**For each check, execute silently and show results (except where the Appendix specifies user-visible templates):**

#### 3.1 Grammar Check (if SELECTED_CHECK = "all" or "grammar")

- Use logic from `legacy/fix-grammar.md` agent
- Detect: subject-verb agreement, articles, typos, punctuation
- Preserve: Adobe syntax `[!DNL ...]`, technical terms, code blocks
- Show: List of grammar issues found (if any)

#### 3.2 Link & asset validation (if SELECTED_CHECK = "all" or "links")

**Goal:** Avoid false positives. Never report an internal Markdown target or image as "missing" unless it was **resolved correctly** and **checked on the workspace filesystem** (tool-backed), not inferred from memory.

**Anti-hallucination (mandatory):**

- Do **not** list a broken **internal** link or missing **image file** based only on reading the Markdown. You must **resolve** the path, then **verify** with tools (`read_file`, `list_dir`, terminal `test -e` / `ls`, etc.).
- If you cannot run a filesystem check (no workspace access), say so explicitly and **do not** fabricate a broken-link list or numeric link-health score.

**What to collect:** All targets from `\[...\]\(...\)` and from images `!\[...\]\(...\)`. Ignore autolinks unless your tooling covers them.

**Path resolution (internal file targets):**

1. Strip URL query and fragment for the **existence** check; keep the fragment only for optional anchor checks.
2. **Relative paths** (`./`, `../`, or bare `other-page.md`): resolve from the **directory of the source `.md` file** that contains the link.
3. **Root-style paths** (`/help/...`, `help/...`): try against the **workspace / repository root** first; if not found, retry relative to the source file’s directory (some repos differ).
4. **Extension:** If `path` has no `.md` and no recognized static extension, try `path.md` once before marking missing (common in doc repos).
5. **Same-directory shortcuts:** Treat empty or `./`-only path segments consistently after normalization.
6. **External-only:** `http://`, `https://`, `mailto:`, `vscode:`, Experience Cloud / Experience League URLs → **not** missing local files; validate URL shape only unless the user asked for live HEAD checks.
7. **Fragment-only links** `](#heading-id)` → do **not** report a missing file; optionally verify the anchor inside the **same** file only.

**Image paths:** Apply the **same resolution rules** as Markdown links. Verify the binary or referenced file exists before reporting a missing image.

**Anchor verification (optional):** For `file.md#anchor`, after the file exists, you may check for `{#anchor}` or heading-derived IDs. If anchor verification is uncertain, list under **unverified anchors**, not as broken files.

**External links:** Prefer format validation; do not claim "404" without a real failed request.

**Output — maintain a `LINK_AUDIT` summary** (for the report and for Step 3.3):

- `internal_verified_count`: internal targets checked on disk  
- `internal_broken_confirmed`: list entries only with: source file, line, raw target, **resolved path(s) tried**, verification outcome  
- `images_verified` / `images_missing_confirmed`: same discipline  
- Optionally `anchors_unverified` if you skipped or could not confirm anchors  

In **Step 4**, when this check ran, include one line such as: `Internal links: <n> verified on disk, <m> broken (confirmed)` — never invent counts.

#### 3.3 Scoring (if SELECTED_CHECK = "all" or "scoring")

- Use logic from `legacy/scoring-agent.md`
- Analyze: Readability, Structure, Adobe standards, Technical quality
- Calculate scores: 0-100 per category
- Show: Visual scores with colors (🔴🟠🟢)
- **When `SELECTED_CHECK = "all"`:** Reuse **`LINK_AUDIT`** from **§3.2** for Technical Quality deductions involving **internal links and image paths**. Do **not** run a second, independent "eyeball" pass that reinvents broken links or missing images from the Markdown alone (that duplicates work and causes false positives). You may still score other Technical Quality items (code fences, special characters, etc.) from content.
- **When `SELECTED_CHECK = "scoring"` only:** Follow `legacy/scoring-agent.md`, including its **filesystem verification** rules for links and images (aligned with §3.2 path resolution).

#### 3.4 Accessibility (if SELECTED_CHECK = "all" or "accessibility")

- Use logic from `legacy/accessibility-agent.md`
- Check: ALT text, heading hierarchy, link accessibility, readability
- Auto-generate: Missing ALT text
- Show: Accessibility score and issues

#### 3.5 Structure/Completeness (if SELECTED_CHECK = "all" or "structure")

- Check: TODOs, empty sections, missing metadata
- Validate: Front matter, TOC references
- Show: Structure issues list

#### 3.6 AI Assistant readiness (if SELECTED_CHECK = "all" or "ai-readiness")

- Follow the **Appendix: AI Assistant readiness (merged specification)** at the end of this file.
- Use the same `SCOPE_PATH` / files as Step 2. Respect MCP rules in the Appendix (lazy Jira check only if the user chooses Jira in Step 5 of that module).
- When `SELECTED_CHECK = "all"`, present the AI readiness report **after** the standard checks (you may show one combined summary or two sections—Grammar/Links/… first, then the AI readiness report).

---

### Step 4: Results Report

**Show report based on checks performed:**

**If SELECTED_CHECK = "all":**
```
✅ SANITY CHECK COMPLETE

📊 Summary:
   • Files analyzed: 3
   • Grammar issues: 2 found
   • Internal links: 40 verified on disk, 1 broken (confirmed)
   • Quality score: 78/100 🟠
   • Accessibility: 92/100 🟢
   • Structure issues: 1 TODO found

📝 Details:
   [Show detailed breakdown per check]
```

**If SELECTED_CHECK = specific check (e.g., "scoring"):**
```
✅ SCORING CHECK COMPLETE

📊 Results:
   • Files analyzed: 1
   • Overall score: 78/100 🟠
   
   Category breakdown:
   • Readability: 85/100 🟢
   • Structure: 70/100 🟠
   • Adobe standards: 80/100 🟢
   • Technical quality: 75/100 🟠

📝 Details:
   [Show detailed scoring breakdown]
```

**Adapt report format based on which check(s) were performed.**

---

## Rules

1. **🔄 Fresh start** - Each invocation is independent
2. **Silent execution (clarified)** — Do not paste raw shell logs or procedural "running commands" filler into the user report. **Tool use is required** wherever this agent specifies on-disk verification (especially **§3.2** links and images). Prefer `read_file` / `list_dir` / short existence checks; report **verified results and counts**, not transcripts.
3. **Comprehensive** - When running "all checks", execute each one fully; when running a single check, be thorough on that check
4. **Actionable** - Show specific issues with file:line references
5. **Non-blocking** - Don't prevent completion if issues found
6. **Verified-only link/image findings** — For internal targets, every reported "missing" or "broken" path must appear in `LINK_AUDIT` with a confirmed failed check after correct resolution (§3.2). Never inflate Technical Quality or link summaries with unverified items.

---

## 🚀 Usage

**Trigger:** Type `/sanity-check-agent` in Claude Code. Command file: `.claude/commands/sanity-check-agent.md`.

```
/sanity-check-agent
```

You can add context after the command (e.g. scope or check type).

**Alternative:** Natural language in chat, e.g. "sanity check", "check quality".

---

## Example Flows

### Flow 1: All Checks on Current File

```
User: @sanity-check

Agent: ✅ SANITY CHECK
       What would you like to check?
       1. 🔍 All checks (comprehensive)
       2. 🎯 Single check (focused)
       
User: 1

Agent: Where should I check?
       1. 📄 Current file (open in editor)
       2. 📁 Specific file (provide path)
       3. 📂 Entire folder (scan multiple files)
       
User: 1

Agent: [Runs all checks on current file]
```

### Flow 2: Single Check on Folder

```
User: @sanity-check

Agent: ✅ SANITY CHECK
       What would you like to check?
       1. 🔍 All checks (comprehensive)
       2. 🎯 Single check (focused)
       
User: 2

Agent: Which check would you like to run?
       1. ✏️  Grammar
       2. 🔗 Links
       3. 📊 Scoring
       4. ♿ Accessibility
       5. 📐 Structure & Completeness
       
User: 3

Agent: Where should I check?
       1. 📄 Current file (open in editor)
       2. 📁 Specific file (provide path)
       3. 📂 Entire folder (scan multiple files)
       
User: 3

Agent: Please provide the folder path (or press Enter for current folder):
       
User: help/features

Agent: [Runs scoring check on help/features folder]
```

---

## Post-Flight Checks

## When to Execute

Execute Post-Flight Checks if:
- Agent modified, created, or deleted any files (tracked via git diff)

Skip Post-Flight Checks if:
- Agent only read/analyzed files (no modifications)
- User explicitly requested to skip checks

---

## Step 1: Detect Modified Files and Sections

**CRITICAL: Execute silently — completely invisible to user.**

1. **Track files modified during agent execution:**
   - Before starting modifications: `git diff --name-only` → store as `FILES_BEFORE`
   - After modifications: `git diff --name-only` → store as `FILES_AFTER`
   - Modified files: `FILES_MODIFIED = FILES_AFTER - FILES_BEFORE`
   - For each modified file: `git diff <file>` → extract line ranges changed

2. **Extract modified sections:**
   - Parse git diff output to get line numbers of additions/changes
   - Store as: `MODIFIED_SECTIONS[file] = [(start_line, end_line), ...]`

3. **For CREATE mode (new files):**
   - If `git ls-files <file>` returns empty → file is NEW → validate entire file
   - For MODIFIED files → validate only changed sections

4. **User experience:** Silent operation. No git commands or "detecting…" messages visible.

---

## Step 2: Link Validation (Incremental)

**Only check links in modified sections, not entire files.**

1. **Extract links from modified sections:**
   - Markdown links: `[text](url)` and `![alt](url)`
   - Categorize: internal (`help/...`, `../`, relative), external (`http(s)://`), anchor (`#id`)

2. **Validate internal links:**
   - Target file exists (relative to repo root)
   - Anchor exists in target file (for `#anchor` links)
   - Root links start with `/` (common mistake: `](help/...)` without leading slash)
   - No backslashes in paths (use `/`)

3. **Validate external links:**
   - URL format valid
   - No links to archived/non-production docs
   - Sample URLs in code blocks are excluded from checks

4. **Validate TOC links (if TOC.md was modified):**
   - All relative links resolve to existing files
   - No duplicate file references in TOC
   - Section parents are not links
   - No comments in the middle of TOC list items (move to end)

5. **Validate redirects (if redirects.csv was modified):**
   - No duplicate source URLs
   - No chains (A→B, B→C) — flatten to A→C, B→C
   - No loops (A→B, B→A)

6. **Output format:**
   ```
   ✅ Links: 12 checked, 0 broken
   ⚠️  Links: 8 checked, 1 broken:
      - help/features/ai.md:45 → [text](help/old-path.md) — file not found
   ```

---

## Step 3: Adobe Rules Validation (Incremental)

**CRITICAL: Apply to modified sections only (or entire file if new).**

Three tiers. **Tier 1 and 2 always run.** Tier 3 runs only for CREATE mode or when user asks for deep check.

---

### Tier 1 — CRITICAL (build-breaking)

These rules cause Jenkins validation failures. Always check.

| # | Rule | Check | Ref |
|---|------|-------|----|
| 1.1 | **`description` required** | Metadata block must contain `description:` with a non-empty value | using-metadata |
| 1.2 | **`description` max 160 chars** | `description` value ≤ 160 characters | authoring-title-description |
| 1.3 | **`title` max 60 chars** | `title` value ≤ 60 characters (excludes auto-appended `\| Adobe Product`) | authoring-title-description |
| 1.4 | **`exl-id` unique** | No two files in the repo share the same `exl-id` value. When copying a file, remove `exl-id`. | using-metadata |
| 1.5 | **Metadata values match YAML** | `solution`, `product`, `cloud`, `role`, `level`, `type`, `topic`, `version`, `feature`, `feature-set` values must be from approved enums. Empty placeholder tags (e.g. `feature:` with no value) are errors. | using-metadata |
| 1.6 | **`feature` requires `feature-set`** | If `feature:` is set, `feature-set:` must also be set (in article, TOC, or metadata.md) | feature-tags |
| 1.7 | **Metadata special chars** | If a metadata value starts with `:` or `[`, wrap the entire value in quotes | using-metadata |
| 1.8 | **UTF-8 without BOM** | File must not contain UTF byte-order mark | validation |
| 1.9 | **No hard tabs** | File must not contain `\t` characters | validation |
| 1.10 | **Allowed HTML only** | Only these tags: `table`, `thead`, `tbody`, `tfoot`, `tr`, `th`, `td`, `col`, `colgroup`, `p`, `ul`, `ol`, `li`, `br`, `b`, `i`, `strong`, `em`, `u`, `s`, `span`, `sub`, `sup`, `a`, `img`, `div`, `pre`, `code`, `codeblock`, `caption`. Any other HTML = validation error. | markdown-syntax |
| 1.11 | **Image size ≤ 20 MB** | Images > 20 MB cause build errors. Warn at > 5 MB. | validation |
| 1.12 | **Relative TOC links resolve** | Every `+ [Title](path.md)` in TOC.md must point to an existing file | validation |
| 1.13 | **No deprecated metadata** | Flag: `seo-title`, `seo-description`, `keywords`, `audience`, `difficulty`, `uuid` | using-metadata |

---

### Tier 2 — HIGH (rendering / quality)

These rules affect publication quality and Adobe standards. Always check.

| # | Rule | Check | Ref |
|---|------|-------|----|
| 2.1 | **H1 after metadata** | First content line after metadata + blank line must be `# Title` | markdown-syntax |
| 2.2 | **No heading level skip** | Cannot jump from `##` to `####` (must go through `###`) | markdown-syntax |
| 2.3 | **Heading max 69 chars** | Heading text (excluding `#` markers and `{#id}`) ≤ 69 characters | markdown-syntax |
| 2.4 | **Numeric heading → explicit ID** | Headings starting with a number need `{#anchor-id}` where ID doesn't start with a digit | markdown-syntax |
| 2.5 | **Blank lines around headings** | One blank line before and after every heading | markdown-syntax |
| 2.6 | **Image alt text non-empty** | `![](...)` is invalid — alt text must be meaningful (not just filename) | alternate-text-images |
| 2.7 | **Image filename** | Lowercase, hyphens only, no underscores/spaces. Pattern: `[a-z0-9-]+\.(png\|jpg\|gif\|svg)` | screenshots |
| 2.8 | **Admonition spacing** | No space between `>` and `[!`: `>[!NOTE]` not `> [!NOTE]` | markdown-syntax |
| 2.9 | **No [!NOTE] in HTML tables** | `[!NOTE]`, `[!TIP]`, `[!WARNING]`, etc. must not appear inside `<table>` blocks | tables |
| 2.10 | **No nested HTML tables** | `<table>` cannot contain another `<table>` | tables |
| 2.11 | **Table pipe count** | Every row in a Markdown table must have the same number of `\|` characters | tables |
| 2.12 | **Table separator ≥ 3 hyphens** | Each column in the separator row needs at least `---` | tables |
| 2.13 | **No nested collapsible/tabs** | `+++` sections cannot contain other `+++`; `>[!BEGINTABS]` cannot contain another tab set | markdown-syntax |
| 2.14 | **No tabs inside lists** | Tab sets (`>[!BEGINTABS]`) must not appear inside numbered/bullet lists | markdown-syntax |
| 2.15 | **Unsupported syntax** | Flag: task lists `* [x]`, emoji `:emoji:`, horizontal rule `***`, definition lists `term\n: definition` | markdown-syntax |
| 2.16 | **Video URL format** | `>[!VIDEO](url)` must include `?quality=12&learn=on` in the URL | markdown-syntax |
| 2.17 | **Badge rules** | Max 2 badges in metadata. Badge values in metadata must be quoted. Badge names must start with `badge`. | markdown-syntax |
| 2.18 | **No zoom on linked images** | If image is wrapped in a link `[![alt](img)]`, do not use `{zoomable="yes"}` | markdown-syntax |
| 2.19 | **Includes syntax** | `{{$include /help/_includes/file.md}}` — verify target file exists | includes-snippets |
| 2.20 | **Consistent bullet markers** | Do not mix `*`, `-`, `+` within the same list | markdown-syntax |
| 2.21 | **Filename convention** | `.md` filenames: lowercase, hyphens, no underscores/spaces. Pattern: `[a-z0-9-]+\.md` | authoring-best-practices |
| 2.22 | **`[!DNL Product]` syntax** | Product names that should not be localized use `[!DNL]` | markdown-syntax |
| 2.23 | **`[!UICONTROL Label]` syntax** | UI elements use `[!UICONTROL]` wrapped in bold `**` in procedures | markdown-syntax |
| 2.24 | **H1 ≈ title metadata** | H1 content should be consistent with `title:` metadata (may differ for SEO vs. readability, but flag large mismatches) | using-metadata |
| 2.25 | **No trailing whitespace** | Lines should not end with trailing spaces (except intentional line breaks) | basic-editorial |

---

### Tier 3 — MEDIUM (style / editorial)

Run for **new files** (CREATE mode) or when user requests "deep check". Skip for minor updates.

| # | Rule | Check | Ref |
|---|------|-------|----|
| 3.1 | **Title case for `title` metadata** | `title:` value should be in Title Case (the only metadata exception to sentence case) | headings-page-titles |
| 3.2 | **Sentence case for headings** | All headings (H1–H6) should use sentence case (except proper nouns, product names) | headings-page-titles |
| 3.3 | **Heading length ≤ 5 words** | Recommended. Flag headings > 8 words as warnings. | headings-page-titles |
| 3.4 | **No single-word headings** | Flag bare `## Overview` or `## Introduction` (should be `## Overview of [topic]`) | headings-page-titles |
| 3.5 | **No gerunds in task headings** | Flag `-ing` verb forms in task headings (e.g. "Creating a segment" → "Create a segment") | headings-page-titles |
| 3.6 | **Content after every heading** | At least one paragraph between two consecutive headings | headings-page-titles |
| 3.7 | **`description` starts with "Learn"** | Recommended pattern: "Learn to [verb]" or "Learn about [topic]" | authoring-title-description |
| 3.8 | **Sentence length < 35 words** | Flag sentences > 35 words in modified sections | authoring-style-guide |
| 3.9 | **Active voice** | Flag passive constructions ("is configured by" → "configure") when detectable | authoring-style-guide |
| 3.10 | **Present tense** | Prefer present tense ("The system sends…" not "The system will send…") | authoring-style-guide |
| 3.11 | **Inclusive language** | Flag: `whitelist`→`allowlist`, `blacklist`→`denylist`, `master/slave`→`primary/replica`, `master branch`→`main branch` | inclusive-language |
| 3.12 | **Words to avoid** | Flag: "in order to"→"to", "utilize"→"use", "leverage"→"use", "dropdown list"→"dropdown menu", "please"→remove, "simply"→remove | basic-editorial |
| 3.13 | **"Click" → "Select"** | Flag "click" (prefer "select", "choose", "go to", "navigate to") | basic-editorial |
| 3.14 | **Oxford comma** | In lists of 3+, flag missing comma before "and"/"or" | basic-editorial |
| 3.15 | **Numbers 0-9 spelled out** | Spell out zero through nine; use numerals for 10+ | basic-editorial |
| 3.16 | **Avoid semicolons** | Flag semicolons in prose (split into two sentences) | authoring-style-guide |
| 3.17 | **Steps: imperative verb** | Numbered list items should start with an imperative verb | steps |
| 3.18 | **Steps: ~7 max** | Flag numbered lists with > 9 steps (suggest splitting) | steps |
| 3.19 | **Steps: one sentence per step** | Flag multi-sentence steps (extra info should be on next indented line) | steps |
| 3.20 | **Duplicated words** | Flag "the the", "a a", "is is" etc. | basic-editorial |

---

## Step 4: Markdown Linter (Incremental)

**Run markdownlint on modified files only.**

1. **Check availability:**
   - `npx markdownlint-cli2 --version` (silent)
   - If not available: skip with note (non-blocking)

2. **Run linter:**
   ```bash
   npx markdownlint-cli2 "<modified-files>" --config markdownlint_custom.json
   ```

3. **Adobe-specific disabled rules** (from `markdownlint_custom.json`):
   - MD033: false (HTML allowed)
   - MD032: false (blank lines around lists)
   - MD007: false (unordered list indentation)
   - MD040: false (fenced code language)
   - MD005: false (inconsistent list indentation)
   - MD034: false (bare URLs)
   - MD037: false (spaces in emphasis)

4. **Output format:**
   ```
   ✅ Linter: 3 files, 0 issues
   ⚠️  Linter: 2 files, 3 issues:
      - help/features/ai.md:12 → MD013: Line length
   ```

---

## Step 5: Pre-Check CI (Optional)

**Non-blocking simulation of CI checks.**

1. Check if `.github/workflows/validate-articles.yml` exists
2. If in CI environment (`CI`, `GITHUB_ACTIONS`, `JENKINS_URL` env vars): skip
3. Otherwise: Steps 2–4 above already cover the main CI checks
4. Show summary if anything would fail in CI

---

## Execution Flow Summary

```
1. Detect modified files .................. (silent)
2. Link validation ........................ (incremental — modified sections only)
3. Adobe Rules — Tier 1 (Critical) ....... (always — modified sections / new files)
   Adobe Rules — Tier 2 (High) ........... (always — modified sections / new files)
   Adobe Rules — Tier 3 (Medium/Style) ... (new files only, or on request)
4. Markdown linter ........................ (modified files)
5. Pre-CI check ........................... (optional)
```

---

## Output Format

**If all checks pass:**
```
✅ Post-Flight Checks Complete

   📊 Modified: 3 files
   ✅ Links: 15 checked, 0 broken
   ✅ Adobe Rules: 3 files checked, 0 issues
   ✅ Linter: 3 files, 0 issues
```

**If issues found:**
```
⚠️  Post-Flight Checks Complete

   📊 Modified: 3 files
   ✅ Links: 15 checked, 0 broken
   ⚠️  Adobe Rules: 2 issues found
      🔴 1.1 — help/new-page.md → Missing required metadata: description
      🟡 2.6 — help/new-page.md:45 → Empty alt text: ![](assets/img.png)
   ✅ Linter: 0 issues
```

**Severity icons:**
- 🔴 Tier 1 (Critical — will fail build)
- 🟠 Tier 2 (High — affects quality)
- 🟡 Tier 3 (Medium — style suggestion)

---

## User Experience Rules

1. **Silent by default** — Only show output if issues found (or final summary)
2. **Non-blocking** — Don't prevent agent completion
3. **Actionable** — Show file:line:rule for every issue
4. **Tiered** — Critical issues first, style suggestions last
5. **Incremental** — Only modified sections, never full-repo scan
6. **Auto-fix when possible** — Offer to fix Tier 2/3 issues automatically

---

## Integration

After Post-Flight Checks complete:
- Show final summary
- Show update notification if `AGENTS_OUTDATED=true` (from Pre-Flight)
- Agent execution complete

**Note:** Post-Flight Checks are executed after Sanity Check completes, but since Sanity Check doesn't modify files, Post-Flight Checks will be skipped (no files modified).

---

**Note:** If `AGENTS_OUTDATED=true` after completion, show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 UPDATE AVAILABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

New features are waiting for you!
Upgrade agents: `/upgrade-agents` (type `/` in chat and choose upgrade-agents)

(Your changes are safe ✓)
```

## Appendix: AI Assistant readiness (merged specification)

When `SELECTED_CHECK` is `all` or `ai-readiness`, execute this module using the scope from **Step 2** (`SELECTED_SCOPE`, `SCOPE_PATH`). For `all`, run it **after** checks 3.1–3.5. For `ai-readiness` only, run **only** this appendix (skip 3.1–3.5).

*(Step numbers in this appendix are internal to the AI readiness module; they are not the same as the main workflow Step numbers above.)*

### Step 2: Execute AI Readiness Checks

**Execute silently. No loading messages.**

For **each file**, detect page type first (same logic as scoring agent), then run all five dimensions:

#### Page Type Detection

| Type | Detection signals | Scoring notes |
|------|-------------------|---------------|
| **Reference** | Title contains "syntax", "reference", "API", "properties", "parameters"; mostly tables/lists | FAQ coverage weight ↓ (not expected) |
| **Tutorial/How-to** | Title contains "get started", "how to", "configure", "create"; numbered steps | How-to workflow check weight ↑ |
| **Concept** | Title contains "overview", "about", "understand", "introduction" | Standard weights apply |
| **Release Notes** | Title contains "release notes", "what's new" | FAQ & structure checks relaxed |
| **FAQ** | Title contains "FAQ", "frequently asked", "troubleshooting" | FAQ dimension already satisfied |
| **Landing page** | Metadata contains `landing-page: true` | Metadata & multi-modal checks relaxed |

Show detected type:
```
📄 Page type detected: How-to
   → Scoring weights adjusted accordingly.
```

---

#### Dimension 1 — Passage Atomicity & Length (25 pts)

**Goal (Adobe spec §1.2):** Each passage is self-contained, retrievable in isolation, and not too long for effective chunking.

**Checks and deductions:**

| ID | Check | Severity | Deduction |
|----|-------|----------|-----------|
| PA-1 | Section (between two headings) contains > 400 words | Major | -3 per section |
| PA-2 | Page has a single body section > 800 words with no sub-headings | Critical | -5 |
| PA-3 | Passage references context from another section ("as mentioned above", "see the section above", "as described earlier") | Major | -3 per instance |
| PA-4 | Page total word count < 100 words with no links to parent context (orphan page) | Major | -3 |
| PA-5 | Paragraph > 150 words with no break | Minor | -1 per instance |
| PA-6 | Content continuation markers used ("…continued", "continued from") | Minor | -1 per instance |
| PA-7 | Page mixes incompatible content types without clear separation — e.g., procedural steps + conceptual reference + release notes all in one page with no separating structural boundary (> 2 distinct content types detected) | Major | -3 |

**Maximum deduction:** capped at 25 pts (score floor = 0).

**Technical implementation:**
- Split file at heading boundaries to get per-section content
- Count words per section (exclude code blocks, front matter, HTML)
- Scan prose for cross-reference phrases: regex `(as ment[io]+ned (above|earlier|before)|see (the )?(section|paragraph) above|refer(red)? to above|described (above|earlier)|in the (previous|preceding) section)`
- Flag sections over thresholds
- For PA-7: detect content type signals per section — procedure signals (numbered list items with imperative verbs), concept signals (definition patterns like "X is a…", "X refers to…"), release-note signals (date patterns, "what's new", version strings). If 3+ distinct types present with no clear H2-level boundary, flag.

---

#### Dimension 2 — Structure & Navigation (20 pts)

**Goal (Adobe spec §1.2, §parsing):** Flat, predictable heading hierarchy with landmark anchors that AI systems can use to locate content.

**Checks and deductions:**

| ID | Check | Severity | Deduction |
|----|-------|----------|-----------|
| SN-1 | Heading depth exceeds H3 (H4/H5/H6 present) | Major | -3 per violation |
| SN-2 | Heading level skipped (e.g. H1 → H3 without H2) | Critical | -5 |
| SN-3 | Multiple H1 headings in one file | Critical | -5 |
| SN-4 | H2/H3 heading missing explicit anchor ID `{#anchor}` | Minor | -1 per heading (max -5 total) |
| SN-5 | Page has no sub-headings (single flat wall of text > 300 words) | Major | -3 |
| SN-6 | Heading text > 69 characters | Minor | -1 per heading |
| SN-7 | No logical "Related topics" or "Next steps" section at end of page | Minor | -1 |
| SN-8 | Tutorial/How-to page has both substantial conceptual paragraphs (> 3 non-list paragraphs) and a numbered procedure (> 4 steps) within the same section, with no structural boundary separating "what it is" from "how to do it" | Major | -3 (Tutorial pages only) |

**Maximum deduction:** capped at 20 pts.

**Technical implementation:**
- Parse all lines starting with `#` to build heading tree
- Track heading level sequence: any jump > 1 level = SN-2
- Count H1 occurrences: more than 1 = SN-3
- Count H4+ occurrences = SN-1
- Check for `{#...}` anchor syntax on H2/H3 headings
- Check last H2 for "related", "next steps", "learn more", "additional resources" (case-insensitive)
- For SN-8: in Tutorial pages, scan each H2 section for co-existence of ≥ 3 prose paragraphs + numbered list with ≥ 4 items without an intervening H3 heading

---

#### Dimension 3 — FAQ & Q&A Coverage (20 pts)

**Goal (Adobe spec §1.1, §goal-2):** Key questions a user might ask are explicitly answered; content is structured so AI can match queries to answers.

**Checks and deductions:**

| ID | Check | Severity | Deduction |
|----|-------|----------|-----------|
| QA-1a | No FAQ section, troubleshooting section, or dedicated FAQ heading (`FAQ`, `Frequently asked`, `Common questions`, `Troubleshooting`) AND no link to an existing FAQ or troubleshooting resource | Major | -3 (waived for Reference/Release Notes pages) |
| QA-1b | No FAQ section on this page, but also no link to an existing FAQ/troubleshooting/get-started page that covers common questions for this feature | Minor | -1 (partial credit when a FAQ link exists elsewhere) |
| QA-2 | No questions answered in the `description` metadata or front matter `keywords` field | Minor | -1 |
| QA-3 | Feature/capability page has no explicit mention of limitations, known constraints, or unsupported scenarios — and no `>[!WARNING]` or `>[!CAUTION]` admonition on destructive/irreversible operations (detected by keywords: "delete", "remove", "cannot be undone", "irreversible", "permanent") | Major | -3 |
| QA-4 | How-to page has no explicit prerequisite section | Minor | -1 (only for Tutorial/How-to pages) |
| QA-5 | Content describes multiple distinct features/sub-features with no dedicated sub-sections per feature | Major | -3 |
| QA-6 | No explicit statement of what the feature/page is about in the first paragraph (missing "lead" sentence of ≥ 20 words summarizing purpose and outcome) | Minor | -2 |
| QA-7 | Tutorial/How-to page has no "expected result" signal after the last step — no phrase like "you should now see", "you have successfully", "the result is", "you can now" within 5 lines of the final numbered step | Minor | -1 (Tutorial/How-to pages only) |
| QA-8 | Tutorial/How-to page covers a task that can be done via both UI and API but provides only one method without acknowledging the alternative ("you can also", "alternatively", "via API", "via the UI") | Minor | -1 (Tutorial/How-to pages only, advisory) |

**Maximum deduction:** capped at 20 pts.

**Technical implementation:**

**QA-1 (two-stage evaluation):**
1. **Check for local FAQ content:** scan all headings (case-insensitive) for: `faq`, `frequently asked`, `common questions`, `troubleshooting`, `known issues`, `limitations`. If found → QA-1 passes (no deduction).
2. **If no local FAQ found, check for an outbound FAQ link:** scan all inline links `[text](url)` and their surrounding prose for signals that the link points to a FAQ or troubleshooting resource:
   - Link anchor text contains: "faq", "troubleshoot", "common questions", "get started", "overview", "known issues"
   - Link URL path contains: `faq`, `troubleshoot`, `get-started`, `overview`, `limitations`
   - Surrounding phrase matches: "for more questions", "see also", "common questions about", "visit the FAQ", "refer to the troubleshooting"
   - If such a link exists → apply **QA-1b only** (-1, Minor): the page delegates FAQ coverage rather than embedding it
3. **If neither local FAQ nor FAQ link found** → apply **QA-1a** (-3, Major): suggest adding a link to the most relevant FAQ/get-started/overview page rather than creating a new FAQ section

**Recommendation wording for QA-1a:** Do not suggest "add a FAQ section". Instead suggest: *"Link to the relevant FAQ or troubleshooting page for this feature (e.g., the get-started or overview page). If no FAQ resource exists yet, consider adding 2–3 key Q&A pairs to the most central page for this topic."*

- Parse front matter for `description`, `keywords` fields (QA-2)
- Scan for words like "limitation", "constraint", "not supported", "cannot", "does not support" in prose (QA-3 part 1)
- For QA-3 part 2: scan for destructive-action keywords; if found, check if `>[!WARNING]` or `>[!CAUTION]` appears within 10 lines before or after
- For Tutorial pages: scan for "prerequisite", "before you begin", "requirements" headings or paragraphs (QA-4)
- Check first paragraph after H1 for introductory sentence (> 20 words) (QA-6)
- For QA-7: find last numbered list item; scan the following 5 lines for result phrases (case-insensitive)
- For QA-8: detect if page contains both "API" and "UI"/"console" references; if yes, check for "alternatively"/"you can also"/"via API"/"via UI" bridging phrases

---

#### Dimension 4 — Metadata Completeness (20 pts)

**Goal (Adobe spec §hybrid-search, §parsing):** Rich front matter enables accurate keyword-based retrieval, product filtering, and AI disambiguation.

**Checks and deductions:**

| ID | Check | Severity | Deduction |
|----|-------|----------|-----------|
| MC-1 | `description` field missing or empty | Critical | -5 |
| MC-2 | `description` < 50 characters (too short to be useful for retrieval) | Major | -3 |
| MC-3 | `description` > 160 characters (will be truncated in search index) | Minor | -1 |
| MC-4 | `keywords` or `feature` field missing | Major | -3 |
| MC-5 | `role` field missing | Minor | -1 |
| MC-6 | `level` field missing | Minor | -1 |
| MC-7 | `solution` or `product` field missing | Major | -3 |
| MC-8 | No `exl-id` field (required for AI indexing traceability) | Minor | -1 |
| MC-9 | `title` field missing or empty | Critical | -5 |
| MC-10 | `title` > 60 characters | Minor | -1 |
| MC-11 | `title` is generic/non-descriptive — exact match or starts with: "Introduction", "Overview", "Getting started", "Best practices", "Guide", "Setup", "Configuration", "About" with no qualifying noun after it | Major | -3 |
| MC-12 | Feature or Tutorial page has no version/edition scoping anywhere in metadata or first section — no mention of "applies to", "available in", "requires", "supported in", or a version string (e.g. "2024", "v2", "6.5") | Minor | -1 (waived for Concept and Landing pages) |

**Maximum deduction:** capped at 20 pts.

**Technical implementation:**
- Parse YAML front matter block between `---` markers
- Check presence and non-emptiness of each field
- Check character lengths of `description` and `title`
- Check for `exl-id` presence
- For MC-11: normalize `title` value; check if it is one of the generic terms alone, or starts with one followed only by common stop words ("a", "the", "your", "this")
- For MC-12: scan front matter `title` + `description` + first 3 prose paragraphs for version/scoping signals

---

#### Dimension 5 — Multi-modal & Linking (15 pts)

**Goal (Adobe spec §multi-modal, §hyperlinking, §parsing):** Images have alt text and captions; code blocks are labeled; pages are well-connected to the content graph.

**Checks and deductions:**

| ID | Check | Severity | Deduction |
|----|-------|----------|-----------|
| ML-1 | Image missing alt text: `![](...)`  | Major | -3 per image (max -6 total) |
| ML-2 | Image alt text is the filename only (e.g. `![screenshot.png](...)`) or describes appearance rather than purpose (e.g. "Screenshot of the page" with no context on what is shown or why) | Minor | -1 per image (max -3 total) |
| ML-3 | Code block missing language identifier (bare ` ``` ` with no lang) | Minor | -1 per block (max -3 total) |
| ML-4 | Page > 300 words has fewer than 2 inline hyperlinks to related pages | Major | -3 |
| ML-5 | Video embed (`>[!VIDEO]`) present without a note about transcript or timestamps | Minor | -2 |
| ML-6 | Table present without a descriptive caption or introductory sentence | Minor | -1 per table (max -2 total) |
| ML-7 | Code block contains truncation/placeholder markers — e.g. `// ...`, `# ...`, `{...}`, `<!-- omitted -->`, `// TODO`, `[your-value-here]`, `<placeholder>`, `...` on its own line — in a primary example (not a template by design) | Minor | -1 per block (max -3 total) |
| ML-8 | Image is the dominant content of a section: image present in a section with fewer than 30 words of surrounding prose, with no textual description of what the image conveys or the logic it encodes | Major | -3 per section (max -6 total) |

**Maximum deduction:** capped at 15 pts.

**Technical implementation:**
- Regex for images: `!\[([^\]]*)\]\(([^)]+)\)` — flag empty alt group or alt = filename
- For ML-2: additionally flag alt text that is exactly "Screenshot", "Image", "Diagram", or matches `screenshot[-_ ]?of` pattern
- Regex for fenced code blocks: ` ```[^\n]* ` — flag if language tag is empty
- Count inline links (excluding anchors and images): `\[([^\]]+)\]\(http[^)]+\)` or relative links
- Detect `>[!VIDEO]` macro lines; check surrounding 5 lines for transcript mention
- Detect markdown tables (lines starting with `|`); check for preceding non-heading prose sentence
- For ML-7: scan inside each fenced code block for truncation markers: `//\s*\.{3}`, `#\s*\.{3}`, `\{\s*\.\.\.\s*\}`, `<!--\s*(omitted|todo)`, `\[your[- _]`, `<[a-z-]+>` placeholders, bare `...` lines
- For ML-8: for each section (content between headings), if an image is present, count surrounding prose words (excluding the image line itself, code blocks, and front matter). Flag if < 30 words total in section

---

### Step 3: Calculate Scores

**For each file:**

```
AI Readiness Score = sum of all dimension scores (0–100)
```

**Score thresholds:**
- 🟢 **80–100**: AI-Ready — Content is well-suited for AI retrieval and Q&A
- 🟠 **50–79**: Needs Improvements — Several gaps limit AI performance
- 🔴 **0–49**: Not AI-Ready — Significant structural or metadata issues

**Severity deduction reference:**

| Severity | Points | When to apply |
|----------|--------|---------------|
| Critical | -5 | Missing required fields, major structural breaks |
| Major | -3 | Significant quality gaps affecting retrieval |
| Minor | -1 | Small improvements that would help AI performance |

---

### Step 4: Display Results

#### Single File (Scope 1 or 2)

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 AI READINESS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

File: [filename.md]
Path: [full path]
Page type: [detected type]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Overall AI Readiness Score

🟢 87/100 — AI-Ready ✨
(or)
🟠 61/100 — Needs Improvements ⚡
(or)
🔴 38/100 — Not AI-Ready ⚠️

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 Dimension Breakdown

| Dimension                     | Score  | Status         |
|-------------------------------|--------|----------------|
| ✂️  Passage Atomicity & Length  | 22/25  | 🟢 Excellent   |
| 🗂️  Structure & Navigation      | 14/20  | 🟠 Good        |
| ❓  FAQ & Q&A Coverage          | 12/20  | 🟠 Good        |
| 🏷️  Metadata Completeness       | 16/20  | 🟢 Excellent   |
| 🔗  Multi-modal & Linking       | 10/15  | 🟠 Good        |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Issues Found (X total)

### 🔴 Critical Issues (X)
1. **Line –:** MC-9 — Missing `title` metadata field
   → Add a `title:` to the front matter block.

2. **Section "Overview" (L.14–L.67):** PA-2 — Single section exceeds 800 words with no sub-headings
   → Break into 2-3 sub-sections with descriptive H3 headings.

### 🟠 Major Issues (X)
1. **Line 42:** SN-2 — Heading level skipped (H1 → H3 without H2)
   → Insert an H2 heading between the H1 and the H3 at line 42.

2. **Line –:** QA-1a — No FAQ section and no link to an existing FAQ/troubleshooting resource
   → Link to the relevant FAQ or get-started page for this feature. If no FAQ resource exists yet for this topic, consider adding 2–3 key Q&A pairs to the most central overview page.

3. **Line 89:** ML-1 — Image missing alt text: `![](assets/diagram.png)`
   → Add descriptive alt text: `![Diagram showing the workflow](assets/diagram.png)`

### 🟡 Minor Issues (X)
1. **Line 23:** SN-4 — H2 heading missing anchor ID
   → Change `## Configure the feature` to `## Configure the feature {#configure-the-feature}`

2. **Lines 105, 118:** ML-3 — Code block missing language identifier
   → Change ` ``` ` to ` ```json ` or ` ```bash ` as appropriate.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Recommendations

### High Priority
1. ✅ Add complete front matter: `title`, `description`, `keywords`, `feature`
2. ✅ Break the "Overview" section (800+ words) into sub-sections
3. ✅ Add a link to the relevant FAQ or get-started page for this feature (or link to the troubleshooting page if one exists)

### Quick Wins (< 5 min each)
1. Add anchor IDs to all H2/H3 headings (3 headings affected)
2. Add language tags to 2 code blocks (json, bash)
3. Add alt text to 1 image (line 89)

### Nice to Have
1. Add a "Related topics" section at the end
2. Expand `description` to 80+ characters for richer search indexing
3. Add `level` and `role` metadata fields

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Content Statistics

- Total words: 1,340
- Sections (H2): 4
- Longest section: "Overview" — 820 words ⚠️
- Images: 3 (2 with alt text, 1 missing) — 1 image-only section flagged ⚠️
- Code blocks: 5 (3 with lang tag, 2 bare — 1 contains truncation markers ⚠️)
- Internal links: 6 · External links: 2
- Front matter fields: 4/10 recommended
- Version scoping: not found ⚠️
- Destructive ops without warning: 1 found ⚠️

✨ Overall Assessment:
This page has solid content but needs structural and metadata improvements before
it is fully optimized for AI retrieval. Focus on front matter completeness and
breaking up the long Overview section. The FAQ gap is the highest-impact fix.

Estimated time to reach AI-Ready (80+): ~20 minutes
```

---

#### Folder (Scope 3)

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 AI READINESS FOLDER REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Folder: campaigns/
Path: /Users/.../help/using/campaigns/
Files analyzed: 12

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Folder AI Readiness Score

🟠 64/100 — Needs Improvements ⚡

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Per-File Scores

| File                          | Score   | Status | Top Issue                    |
|-------------------------------|---------|--------|------------------------------|
| campaign-schedule.md          | 91/100  | 🟢     | None                         |
| content-experiment.md         | 85/100  | 🟢     | 1 image missing alt text     |
| create-campaign.md            | 78/100  | 🟠     | No link to FAQ resource      |
| api-triggered-campaigns.md    | 72/100  | 🟠     | Long passage (620 words)     |
| modify-stop-campaign.md       | 65/100  | 🟠     | Metadata incomplete          |
| review-activate-campaign.md   | 58/100  | 🟠     | No anchor IDs, no FAQ link   |
| ...                           | ...     | ...    | ...                          |
| campaign-overview.md          | 31/100  | 🔴     | Multiple critical issues     |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏆 Top 3 AI-Ready Files

1. 🥇 campaign-schedule.md — 91/100
2. 🥈 content-experiment.md — 85/100
3. 🥉 create-campaign.md — 78/100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  Top 3 Files Needing Improvement

1. campaign-overview.md — 31/100
   - Missing `description` and `title` metadata
   - Single 1,200-word section with no sub-headings
   - 4 images missing alt text
   - No FAQ section and no link to a FAQ/troubleshooting resource

2. review-activate-campaign.md — 58/100
   - No anchor IDs on any heading
   - No FAQ section and no link to an existing FAQ/troubleshooting resource
   - description < 50 chars

3. modify-stop-campaign.md — 65/100
   - Missing `keywords` and `feature` fields
   - Code blocks without language tags

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Dimension Averages

| Dimension                     | Avg Score | Status |
|-------------------------------|-----------|--------|
| ✂️  Passage Atomicity & Length  | 18/25     | 🟠     |
| 🗂️  Structure & Navigation      | 12/20     | 🟠     |
| ❓  FAQ & Q&A Coverage          | 9/20      | 🔴     |
| 🏷️  Metadata Completeness       | 14/20     | 🟠     |
| 🔗  Multi-modal & Linking       | 11/15     | 🟢     |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔁 Common Issues Across Folder

1. 🟠 No FAQ section and no link to FAQ/troubleshooting resource — 9 of 12 files (add a link to the get-started or overview page for this feature area)
2. 🟠 Missing `keywords` or `feature` metadata — 7 of 12 files
3. 🟠 H2/H3 headings missing anchor IDs — 8 of 12 files
4. 🟡 Code blocks missing language tags — 14 instances across 6 files
5. 🟡 Images missing alt text — 6 images across 4 files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Folder-Wide Recommendations

### High Priority
1. ✅ Add a link to the relevant FAQ/get-started page in the 9 affected files (single batch edit — same link target for pages in the same feature area)
2. ✅ Fix campaign-overview.md (score 31 — drags folder average)
3. ✅ Complete metadata (`keywords`, `feature`) across 7 files

### Quick Wins (batch update)
1. Add anchor IDs to all H2/H3 headings (8 files affected)
2. Add language tags to 14 bare code blocks
3. Add alt text to 6 images

### Long-term
1. Use campaign-schedule.md (91/100) as the folder template
2. Establish a metadata template for new files
3. Add cross-references between related campaign pages

Estimated time to bring folder to 80+ average: ~2–3 hours
```

---

### Step 5: Next Actions

**Show immediately after the report, before post-flight checks.**

**CRITICAL: Only offer actions for issues that were actually flagged. If no fixable issues were found (score = 100), skip this step and go directly to post-flight.**

---

#### 5a — Choose what to do

Show this choice after every report that has at least one flagged issue:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👉 WHAT WOULD YOU LIKE TO DO?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 🎫 Create a Jira task     → Track these improvements for later
2. 🛠️  Fix now                → Hand off to the Update Agent to apply fixes
3. 📋 Both                   → Jira task first, then fix now
4. ❌ Skip

Which option? (1, 2, 3, or 4)
```

**Wait for user input.**

- **Option 1:** Proceed to [5b — Jira task creation]. After Jira is created, ask: *"Want me to also fix the docs now with the Update Agent? (Yes / No)"*. If Yes → proceed to [5c — Fix scope + Update Agent handoff]. If No → end.
- **Option 2:** Skip Jira. Proceed to [5c — Fix scope + Update Agent handoff].
- **Option 3:** Proceed to [5b — Jira task creation]. After Jira is created, proceed directly to [5c — Fix scope + Update Agent handoff] without asking again.
- **Option 4:** End.

---

#### 5b — Jira task creation

**MCP check (only when Jira is needed):** silently test `user-Corp Jira` MCP. If unreachable, show the standard MCP connection error block (from pre-flight-checks.md) and ask the user to fix it before continuing. Do not abort the rest of the workflow — offer to continue with option 2 (fix now) instead.

**Build the Jira task content** from the report findings:

**Title:**
```
[AI Readiness] <filename or folder> — <score>/100 — <top issue in one phrase>
```
Examples:
- `[AI Readiness] journey-ui.md — 89/100 — Missing lead paragraph and FAQ link`
- `[AI Readiness] campaigns/ folder — 64/100 — FAQ coverage and metadata gaps`

**Description (structured):**
```
**Context**
- File/Folder: <SCOPE_PATH>
- Page type: <detected type>
- AI Readiness score: <score>/100 (<status: AI-Ready / Needs Improvements / Not AI-Ready>)
- Analyzed on: <date>

**Dimension Scores**
| Dimension | Score |
|-----------|-------|
| Passage Atomicity & Length | XX/25 |
| Structure & Navigation | XX/20 |
| FAQ & Q&A Coverage | XX/20 |
| Metadata Completeness | XX/20 |
| Multi-modal & Linking | XX/15 |

**Issues Found**
[Critical issues first, then major, then minor — same format as report]
- 🔴 [check ID] — [description] (line XX)
- 🟠 [check ID] — [description] (section name)
- 🟡 [check ID] — [description]

**Recommended Fixes**
High Priority:
1. [fix description]
2. [fix description]

Quick Wins:
1. [fix description]
2. [fix description]

**Out of Scope for Automated Fix**
[List any issues that require manual editorial decisions]

**References**
- Agent: Sanity Check Agent (AI readiness) v<version>
- Guidelines: https://wiki.corp.adobe.com/spaces/EXO/pages/3264578356/Guidelines+for+AI+Assistant+Friendly+Documentation
```

**Jira metadata:**
- **Project:** DOCAC (or writer-provided — ask if unsure)
- **Issue type:** Task
- **Label:** `ai-readiness`
- **Priority:** Major (score < 50) / Minor (score 50–79) / Trivial (score 80+)

**For folder mode:** create one parent task for the folder + one child task per file scoring below 80, linked with "relates to". Do not create tasks for files scoring 80+.

**Show TL;DR before creating:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 TL;DR — Jira task(s) to create
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Single file:]
* [AI Readiness] <filename> — <score>/100 — <top issue>

[Folder — one per file below 80:]
* [AI Readiness] <folder>/ — parent task
  └ [AI Readiness] <file-1> — XX/100 — <top issue>
  └ [AI Readiness] <file-2> — XX/100 — <top issue>

Project: DOCAC   Label: ai-readiness

Shall I go ahead? (Yes / No — or type a different project key)
```

**Wait for user confirmation.** If Yes, create the task(s) using Jira MCP and return the Jira link(s).

After Jira tasks are created, update usage tracking: `jira_tasks_created: <count>`.

---

#### 5c — Fix scope + Update Agent handoff

**First ask which issues to fix** (only show options that have flagged issues):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️  WHICH ISSUES SHOULD I FIX?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 🎯 High Priority only   → [list the High Priority items from the report]
2. ⚡ Quick Wins only       → [list the Quick Wins from the report]
3. 🔄 Everything            → All High Priority + Quick Wins

Which scope? (1, 2, or 3)
```

**Wait for user input.**

**Then build `HANDOFF_INTENTION`** from the issues selected, filtered by scope:

```
Improve the AI readiness of `<SCOPE_PATH>` by applying the following fixes:

1. [Check ID] — [Concrete edit instruction with line number or section name]
   Example: "QA-6 — Add a 2-sentence lead paragraph after the H1 (line 14), before
   ## Journey dashboard, summarizing what the page covers: browsing, filtering,
   calendar view, statuses, and bulk operations."

2. [Next fix...]
```

**Rules for the intention:**
- Use line numbers from the findings where available
- Phrase every item as a direct edit instruction ("Add X at line Y", "Change Z to W", "Insert section after heading X")
- If Jira tasks were created in 5b, include the Jira link(s) in `HANDOFF_SOURCES`
- Do NOT include issues flagged as out-of-scope (see table below)

**`HANDOFF_SOURCES`** = file path(s) + any Jira links created in 5b.

**For folder mode:** ask which file to fix first (show top 3 by lowest score). Generate the handoff for that file only. After the Update Agent completes, the user can return for the next file.

**Emit the handoff block:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Handoff to Update Agent
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Switching to the Update Agent with the AI readiness fixes pre-filled.
You can confirm or edit when the Update Agent asks.

**Intention (pre-filled):**
<HANDOFF_INTENTION>

**Sources (pre-filled):**
<HANDOFF_SOURCES>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 UPDATE DOCUMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

I'll help you update your documentation intelligently.

**Step 1 — Context (from Sanity Check Agent (AI readiness)):**

📝 Intention: <HANDOFF_INTENTION>

📄 Sources:
<HANDOFF_SOURCES>

Use this as-is or modify? (Reply "Use as-is" to continue, or paste your revised intention/sources.)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Wait for the user to reply "Use as-is" or provide revised content. Then continue as Update Agent from Step 2.**

---

#### Issues that cannot be handed off to the Update Agent

Some issues require actions outside the file itself or editorial judgment. Always exclude these from `HANDOFF_INTENTION` and surface them in both the Jira description and the handoff offer:

| Issue | Why excluded | Suggestion |
|-------|-------------|------------|
| QA-1a — No FAQ resource exists for this topic | Requires creating a FAQ on another page | Note in Jira; suggest which page to add it to, or run `@create-agent` |
| MC-12 — Version scoping requires product knowledge | Agent cannot determine the correct version | Note in Jira; ask user to provide the version string before Update Agent run |
| PA-7 — "Kitchen sink" page needs splitting | Requires editorial decision on page architecture | Note in Jira as a manual editorial task |
| ML-8 — Image without surrounding text | Agent cannot interpret screenshot content | Note in Jira with image path; user writes the description |

Show these in both the report and the Jira description as:

```
⚠️  Needs manual attention (not included in automated fix):
   - [issue ID] — [brief reason] → [suggestion]
```

---
## Scoring Rules Summary

### Deduction caps per dimension

| Dimension | Max pts | Cap rule |
|-----------|---------|----------|
| Passage Atomicity & Length | 25 | Floor at 0 |
| Structure & Navigation | 20 | Floor at 0 |
| FAQ & Q&A Coverage | 20 | Floor at 0 |
| Metadata Completeness | 20 | Floor at 0 |
| Multi-modal & Linking | 15 | Floor at 0 |

### Severity reference

| Severity | Points | Color |
|----------|--------|-------|
| Critical | -5 | 🔴 |
| Major | -3 | 🟠 |
| Minor | -1 | 🟡 |

### Page-type scoring adjustments

| Page type | Adjustment |
|-----------|------------|
| Reference | QA-1a, QA-1b waived; QA-4, QA-7, QA-8 (tutorial checks) waived; SN-8 waived; MC-12 waived |
| FAQ/Troubleshooting | QA-1a, QA-1b automatically satisfied (0 deduction) |
| Release Notes | QA-1a, QA-1b waived; SN-7, SN-8 waived; QA-4, QA-7, QA-8 waived; MC-12 waived |
| Landing page | MC-5, MC-6, MC-12 waived; ML-4 (link count) waived; SN-8 waived |
| Tutorial/How-to | QA-4, QA-7, QA-8, SN-8 deductions active (tutorial checks expected) |
| Concept | QA-4, QA-7, QA-8 waived; SN-8 waived; MC-12 waived |

---

## Technical Implementation Notes

### Word count
- Exclude front matter block (between `---` delimiters)
- Exclude fenced code blocks (between ` ``` ` markers)
- Exclude HTML blocks
- Count remaining prose words per section boundary

### Section boundary detection
- Sections delimited by heading lines (`# `, `## `, `### `, etc.)
- Assign all content lines between two headings to the higher heading

### Front matter parsing
- Extract YAML block between first two `---` lines
- Parse key: value pairs
- `description`, `title`, `keywords`, `feature`, `role`, `level`, `solution`, `product`, `exl-id`

### Cross-reference phrase detection (PA-3)
Pattern (case-insensitive):
```
(as ment[io]+ned (above|earlier|before)|see (the )?(section|paragraph) above|
refer(red)? to above|described (above|earlier)|in the (previous|preceding) section|
as (discussed|explained) (above|earlier|previously))
```

### Image detection
Pattern: `!\[([^\]]*)\]\(([^)]+)\)`
- Empty group 1 → ML-1 (missing alt)
- Group 1 matches filename in group 2 (strip path/extension) → ML-2

### Code block detection
Pattern (multiline): ` ``` ` at line start followed by optional lang tag
- No lang tag → ML-3

### Heading anchor detection
Pattern: `{#[a-z0-9-]+}` at end of heading line
- Missing on H2/H3 → SN-4

### Reference (AI readiness)
- Adobe guidelines: [Guidelines for AI Assistant Friendly Documentation](https://wiki.corp.adobe.com/spaces/EXO/pages/3264578356/Guidelines+for+AI+Assistant+Friendly+Documentation)
