# Design: Adapt .cursor-agents to Claude Code

**Date:** 2026-05-19  
**Status:** Approved  
**Approach:** B — Idiomatic Claude Code translation

---

## Goal

Port the `.cursor-agents/` documentation agent suite to Claude Code slash commands so documentation writers can invoke the same workflows via `/agent-name` in the Claude Code CLI, within the same repos they already use.

---

## Scope

All 14 agents are ported:

**Active (v3):** create-agent, update-agent, feedback-agent, sanity-check-agent  
**Legacy:** accessibility-agent, content-updater, draft-page-generator, fix-grammar, monitoring-agent, page-management-agent, release-notes-agent, scoring-agent  
**New/Experimental:** ajo-roadmap-agent, doc-changes-agent  
**Setup/Maintenance:** upgrade-agents  

The `.cursor-agents/` submodule is **not modified**. The Claude commands are additive.

---

## Architecture

### What exists today

```
.cursor-agents/          <- git submodule, untouched
├── agents/              <- Cursor-specific markdown agent files
├── shared/              <- pre-flight-checks.md, post-flight-checks.md, usage-tracking.md
├── docs/
└── setup_maintenance/
```

### What we add

```
.claude/
└── commands/            <- Claude Code slash commands
    ├── create-agent.md
    ├── update-agent.md
    ├── feedback-agent.md
    ├── sanity-check-agent.md
    ├── accessibility-agent.md
    ├── content-updater.md
    ├── draft-page-generator.md
    ├── fix-grammar.md
    ├── monitoring-agent.md
    ├── page-management-agent.md
    ├── release-notes-agent.md
    ├── scoring-agent.md
    ├── ajo-roadmap-agent.md
    └── doc-changes-agent.md
```

**Note:** All commands are flat (no subdirectories). Subdirectories in `.claude/commands/` create namespaced commands (`/subdir:name`) which would break invocation muscle memory.

---

## Command File Format

Each `.claude/commands/` file is a direct translation of the corresponding `.cursor-agents/agents/` file with the following mechanical changes:

### 1. Shared component placeholders -> inlined content

The source files currently contain:
```
[Include shared/pre-flight-checks.md content here]
[Include shared/post-flight-checks.md content here]
[Include shared/usage-tracking.md content here]
```

Each placeholder is replaced with the full content of the referenced shared file, adapted for Claude Code (see Shared Component Adaptations below).

### 2. Cursor-specific text replacements

| Original (Cursor) | Replacement (Claude Code) |
|---|---|
| `@create-agent` (agent reference) | `/create-agent` |
| `Open Cursor Settings (Cmd+,) -> Tools & MCP` | `Check .claude/settings.json or run /mcp` |
| `Reload: @[agent-name]` | `Re-run: /[agent-name]` |
| `.cursor/commands/create-agent.md` | `.claude/commands/create-agent.md` |
| `Trigger (Cursor Commands): Type / in the chat` | `Trigger: Type /[agent-name] in Claude Code` |
| VSIX / extension references | Remove entirely |

### 3. Arguments header

Add to the top of every command file (below the title, above Role):

```markdown
<!-- Usage: /[agent-name] [optional context, e.g. "draft page from https://..."] -->
<!-- $ARGUMENTS contains any text you type after the command name -->
```

### 4. Workflow logic

**Unchanged.** All decision trees, modes, content rules, Adobe standards, DOCAC-12733 rules, Golden Rules, confirmation requirements — everything is preserved verbatim.

---

## Shared Component Adaptations

### pre-flight-checks.md

Two changes only:

**MCP error message** — replace Cursor Settings UI path:
```
# Before
1. Open Cursor Settings (Cmd+,)
2. Go to: Tools & MCP
3. Enable BOTH toggles (must be green)
4. Reload: @[agent-name]

# After
1. Check your Claude Code MCP config: .claude/settings.json
2. Verify both MCP servers are listed and enabled
3. Re-run: /[agent-name]
Still stuck? Check VPN connection or .claude/settings.json
```

**Version check** — references `.cursor-agents` git submodule status. No change needed: the check inspects the same submodule regardless of which editor runs it.

### post-flight-checks.md

No changes. All validation rules (link checking, Adobe tier rules, markdown linting) are editor-agnostic.

### usage-tracking.md

No changes. Claude Code writes to `usage-agents.log` via file tools identically to how Cursor agents do it. The JSONL format, fields, and silent-execution requirement are preserved.

---

## Usage Tracking

Usage tracking remains embedded inline in each command. No hook is added. The embedded `usage-tracking.md` content is sufficient — Claude writes start/complete JSONL entries to `usage-agents.log` at the workspace root, silently.

---

## What Does Not Change

- Agent names (same `/agent-name` invocation)
- All workflow logic, modes, and decision trees
- Adobe standards and DOCAC-12733 rules
- Golden Rules (user always confirms before writes)
- Confirmation gates before any file write
- Post-flight validation checks
- Feedback Agent -> Update Agent handoff
- Usage log format and file location (`usage-agents.log`)
- The `.cursor-agents/` submodule (stays as-is for Cursor users)

---

## Out of Scope

- Porting the VSIX extension
- Modifying `.cursor-agents/` source files
- Global (`~/.claude/commands/`) installation
- Claude hooks for usage tracking (inline instructions are sufficient)
- The `generate_roadmap_pptx.py` helper script (not a command)

---

## Success Criteria

1. All 14 agents are available as `/agent-name` slash commands in Claude Code
2. Each command is self-contained (no external file dependencies at runtime)
3. No Cursor-specific UI references remain in any command file
4. The `.cursor-agents/` submodule is unmodified
5. Usage tracking writes correctly to `usage-agents.log`
6. MCP error messages reference Claude Code settings, not Cursor Settings
