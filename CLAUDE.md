# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Adobe Experience League documentation for AEM Content AI.
Content lives in `help/content-ai/`. Images in `help/assets/`.

## PR Conventions

- Active ticket: GRANITE-67714 (include in all PR titles)
- Branch pattern: `feat/GRANITE-XXXXX-description`
- Target branch: `main`

## Content Structure

- `help/content-ai/TOC.md` — navigation manifest; every new `.md` must be registered here
- `help/content-ai/*.md` — documentation pages
- `help/assets/` — images; filename convention: lowercase, hyphens only
  e.g. `content-ai-onboarding-step-1.png`

### TOC.md format

```
# Section Title {#using}

+ [Page Title](filename.md)
+ [Another Page](another.md)
```

Image references from content pages use `../assets/filename.png` (one level up from `help/content-ai/`).

## Required Metadata (every .md page)

```yaml
---
title:
description:
feature: AEM Content AI
feature-set: Cloud Manager
topic:              # e.g. Overview, Configuration
role:               # e.g. Developer, Admin
level:              # e.g. Beginner
solution: Experience Manager
exl-id:             # Adobe-assigned UUID; omit on new pages — the publishing pipeline assigns it
---
```

## Adobe Markdown Notes

- Admonitions: `>[!NOTE]`, `>[!IMPORTANT]`, `>[!WARNING]`, `>[!TIP]`
- No space between `>` and `[!`: `>[!NOTE]` not `> [!NOTE]`
- UI labels: `**[!UICONTROL Label]**`
- Non-localized terms: `[!DNL term]`
- Use `select` not `click` for UI interactions
- Section anchors: `## Heading {#slug}` — used for deep links (`overview.md#prerequisites`)

## Validation

CI runs `validate-articles.yml` on every PR targeting `main`. To re-trigger validation after fixing issues, comment `retest` on the PR. No local markdownlint config exists yet; validation is entirely pipeline-driven.
