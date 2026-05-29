# AEM Content AI Docs Revision

## Repo

- Local path: `/Users/pklassen/Projects/cai-docs/experience-manager-content-ai.en`
- Remote: `Adobe-Enterprise-Docs/experience-manager-content-ai.en`
- Working branch: `pklassen/docs-update`
- Target branch: `main`
- Active ticket: **GRANITE-67714** (include in all PR titles)

## Repo Structure

- `help/content-ai/contentsources.md` — Get Started guide (main onboarding doc, 5-step walkthrough); renamed from overview.md
- `help/content-ai/introduction.md` — Introduction page (Why / What / How)
- `help/content-ai/setup-adc-project.md` — ADC project setup and authentication
- `help/content-ai/TOC.md` — navigation manifest; every new `.md` must be registered here
- `help/assets/` — screenshots, filename convention: lowercase hyphens e.g. `content-ai-onboarding-step-1.png`
- `.claude/commands/` — 15 agent slash commands ported from Cursor (completed prior work)
- `docs/superpowers/` — internal plan/spec for the Cursor→Claude porting (completed)

## Goals

- Revise `overview.md` (Get Started guide) — **primary focus**

## Outline Ideas

### Idea 1 (2026-05-28)

- Introduction
  - Why
  - What
  - How
    - Enable Content AI for your AEM Environment
    - Control your Content Sources

## Open Tasks

- [x] Create `introduction.md` based on Idea 1 outline (Why / What / How)
- [x] Register `introduction.md` in `TOC.md`
- [ ] Review and refine `introduction.md` content
- [ ] Make agreed edits to `overview.md`
- [ ] Verify markdownlint compliance after edits
- [ ] Commit and push to `pklassen/docs-update`
- [ ] Open PR targeting `main` (include GRANITE-67714 in title)

## Completed Work (prior sessions)

- Ported 15 Cursor agents to `.claude/commands/` slash commands (branch: `feat/add-cursor-agents`, merged)
- Added `CLAUDE.md` with project authoring conventions (commit `f12a1ec`)
- Removed single-region restriction from prerequisites (commit `363ebe3`)
- Created `overview.md` onboarding guide with 5-step walkthrough + screenshots
- Created `setup-adc-project.md` with Server-to-Server and API Key auth flows

## Key Conventions (from CLAUDE.md)

- Admonitions: `>[!NOTE]`, `>[!IMPORTANT]`, `>[!WARNING]`, `>[!TIP]` — no space before `[!`
- UI labels: `**[!UICONTROL Label]**`
- Use `select` not `click` for UI interactions
- Section anchors: `## Heading {#slug}`
- Required metadata fields: title, description, feature, feature-set, topic, role, level, solution
- `exl-id` omitted on new pages — pipeline assigns it
