---
title: AEM Content AI 
description: Learn about AEM Content AI, an AI-powered service that delivers semantic and generative search capabilities for Experience Manager as a Cloud Service.
feature: AEM Content AI
topic: Overview
role: Developer, Admin
level: Beginner
---

# Overview

AEM Content AI is an experimental API service that brings intelligent content discovery to Experience Manager as a Cloud Service. It crawls your website, indexes the content, and exposes it through REST APIs for semantic search and AI-generated responses.

## Key capabilities

Content AI provides two complementary capabilities:

| Capability | Description |
|---|---|
| **Semantic search** | Find content based on meaning rather than exact keywords. Queries return the most contextually relevant results from your indexed content using vector and hybrid search approaches. |
| **Generative search** | Deliver AI-generated natural-language responses to user questions, with source links drawn directly from your indexed content. |

## How it works

Content AI uses a configuration-driven pipeline to acquire, index, and serve your content.

1. **Configure** — Define your data source, crawl schedule, and optional parsers for HTML and PDF content. Add a generative step with custom prompts to enable AI responses.
2. **Discover** — Content AI crawls your website using a sitemap on a recurring cron schedule.
3. **Index** — Acquired content is processed and stored in a vector index optimized for semantic retrieval.
4. **Search** — Query the index through the REST API using semantic, fulltext, or hybrid approaches. Use the generative search endpoint to receive natural-language answers.

## Availability

>[!IMPORTANT]
>
>AEM Content AI is in the experimental phase. Multi-region AEM as a Cloud Service environments are not supported. Use a single-region environment.

Access requires an invitation to the Release Program. To request access:

1. Join the [#aem-content-ai](https://adobe.enterprise.slack.com/archives/C081W9CFWM7) Slack channel.
2. Post your Cloud Manager program name, environment ID, and a brief use case description.
3. Tag @daurer and @andbogda for visibility.

Access is typically granted within one to two business days.

## Next steps

- [Content AI API reference](https://developer.adobe.com/experience-cloud/experience-manager-apis/api/experimental/contentai/) — Complete API documentation including endpoints, parameters, and request examples.
