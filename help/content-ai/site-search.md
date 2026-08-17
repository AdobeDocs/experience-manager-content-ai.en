---
title: Get Started with AEM Content AI Search
description: This guide explains how to enable search on your site with Content AI - connect your content, then choose a search component to present it to visitors.
topic: Configuration
role: Developer, Admin
level: Beginner
solution: Experience Manager
keywords: AEM Content AI, AEM Content AI Search, GenSearch, Quick Search, Content AI Sources, Acquisition, Cloud Manager
---

# Get Started with AEM Content AI Search

This guide helps you transform your site's search with generative and AI-powered capabilities.

Getting there comes down to two decisions: how your content gets into Content AI, and which component brings it to visitors. Connect your content, then add a search component to a page - and your site is ready to give visitors real answers, not just results.

## Prerequisites {#prerequisites}

Before you begin, ensure the following conditions are met:

* You have an active Cloud Manager program with at least one AEM as a Cloud Service environment.
* Your user is assigned to the **[!UICONTROL AEM Users]** product profile (to view content sources) and/or **[!UICONTROL AEM Administrators]** (to create and edit them), assigned at the **publish** tier - Content AI indexes published content, not authored content. See [Assign a user to an AEM product profile](contentsources.md#assign-product-profile) for the full procedure.
* The environment's product profile has been provisioned in **Adobe Admin Console**.

>[!NOTE]
>
>Access to Cloud Manager alone is not sufficient. A user also needs an AEM product profile assigned at the publish tier to view or manage content sources.

## Step 1a - Connect an Existing Index {#option-a}

Existing repository indexes appear automatically in the Content Sources list as Source Type AEM - shown by what they index, such as Pages, Assets, or Content Fragments. They start out **Restricted** and locked, not yet searchable through Content AI.

1. Sign in to [Cloud Manager](https://my.cloudmanager.adobe.com/), select your program, and open the **[!UICONTROL Content AI Sources]** tab for the environment you want to configure.
1. Find the source you want to search against (for example, **Pages**) and select its lock icon. Only users with the **[!UICONTROL AEM Administrators]** product profile can do this - **[!UICONTROL AEM Users]** can view content sources, not change their searchability.
1. Read the **Make source searchable?** dialog carefully. It warns that Apache Oak access control lists (ACLs) will not be enforced for this index once searchable - any authenticated user will be able to retrieve all of its content. Check **I understand that access controls (ACLs) are not enforced and all content in this source will be searchable**, then select **Make searchable**.
1. Confirm the status changes to **Available**. A warning icon stays next to the source as a permanent reminder that ACLs are bypassed for it.
1. Run a test search to verify results come back correctly.

>[!WARNING]
>
>Making an existing index searchable this way bypasses Apache Oak ACLs for that source entirely - any authenticated user can retrieve all of its content through search, regardless of their normal repository permissions. Only do this for sources you're comfortable exposing in full.

>[!NOTE]
>
>This path is a good fit if you already have an index with your site's content - for instance, your page content. Use that index instead of setting up a separate crawling mechanism.

## Step 1b - Crawl a Website {#option-b}

Use this path if you don't already have a search index for your site. Content AI's own crawler builds and refreshes one for you. This crawling process is also referred to as **acquisition** throughout Cloud Manager and this guide.

1. Open the **[!UICONTROL Content AI Sources]** tab, the same as in Step 1a.
1. Select **[!UICONTROL Create Source]** and fill in the fields. Only users with the **[!UICONTROL AEM Administrators]** product profile can add new content sources.

   | Field | Description |
   | --- | --- |
   | **[!UICONTROL Content AI Configuration Name]** | A unique identifier for this source. Cannot be changed after creation. |
   | **[!UICONTROL Website address]** | The root URL to crawl, for example `https://www.example.com/`. |
   | **[!UICONTROL Exclude URLs]** | *(Optional)* URL patterns to skip during crawling. |
   | **[!UICONTROL Refresh frequency]** | Weekly, Daily, Daily 4×, 60 Min, or 15 Min. |

1. Select **[!UICONTROL Create Source]**. Acquisition starts automatically, and the source moves to **Indexing**.
1. Monitor the status until it reaches **Available**:

   | Status | Meaning |
   | --- | --- |
   | **New** | Source just created; automatic acquisition hasn't started yet. |
   | **Indexing** | Crawling and indexing in progress. |
   | **Available** | Indexing complete - ready to serve search queries. |

1. Select the **search** icon next to the source and run a test query to confirm your content was indexed correctly.

>[!CAUTION]
>
>A source stuck in **[!UICONTROL Indexing]**? Retry acquisition from the (…) menu first. If it still doesn't advance, confirm the website address is publicly reachable and that your **[!UICONTROL Exclude URLs]** patterns aren't filtering out every page.

## Step 2 - Choose a Search Component {#choose-component}

There are two components that can put search on a page, built on different foundations:

| | Quick Search (v3) with Semantic Search | AEM Content AI Search |
| --- | --- | --- |
| Foundation | Existing Quick Search core component, upgraded to v3 | New, standalone component - calls the Content AI APIs directly |
| Content source | Your existing site content, already in an index, enriched for semantic matching | A Content AI Source (Step 1a or 1b) |
| Generative answer | No - improves match quality of the existing results list only | Yes - optional AI-generated summary with sources and a disclaimer |
| Best fit | Sites already using Quick Search that want a lighter, incremental upgrade | The suggested component for the full range of Content AI capabilities - semantic search, generative search, and natural language search (NLS) |

## Quick Search (v3) with Semantic Search {#quicksearch}

If your site already uses the classic [!DNL AEM] Quick Search component, v3 adds an opt-in **AI Search** toggle visitors can switch on - no new component, proxy, or Content Source required.

* Search still runs through the same JCR/QueryBuilder path as today - nothing changes in the result servlet or how results render.
* When a visitor enables the toggle, the component prefixes the query with a special marker that routes it to semantic matching instead of plain keyword full-text.
* There's no generative-answer summary on this path. It improves the match quality of the existing results list; it doesn't add a generative AI answer.
* **Step 1 (Content AI onboarding) does not apply to this path.** There's no Content Source to create or connect - this component queries your existing page index directly.

>[!NOTE]
>
>If semantic search isn't working as expected after you enable the toggle, raise a support ticket.

This path is a good fit if you want an incremental semantic-search upgrade without adopting a new component or Content Sources. It is not the right path if you want the generative-answer experience; use AEM Content AI Search for that.

## AEM Content AI Search {#gensearch}

AEM Content AI Search is an [!DNL AEM] Core Component that lets visitors search a Content Source directly from a page, with both semantic search and generative search capabilities.

>[!NOTE]
>
>Generative search capabilities are purchased separately via an AI SKU. Contact your Adobe sales representative to enable it for your account.

### Prerequisites {#gensearch-prerequisites}

* [!DNL AEM] Core Components installed on your project.
* At least one Content Source already created and in **Available** status.
* The **AEM Content AI Client** OSGi configuration (`ContentAIClientImpl`) set up on both author and publish, with a valid API credential and a default Content Source.

For the full setup guide - making the component available to authors, wiring up its client library, and configuring the dialog - see the [Core Components documentation](https://www.adobe.com/go/aem_cmp_library). 

## Congratulations! {#congratulations}

You have successfully set up your semantic and generative search capabilities.

## Next Steps {#next-steps}

* [Set Up an Adobe Developer Console Project](setup-adc-project.md) - Create the ADC project and credentials you need to call the Content AI API directly.
* [Content AI API reference](https://developer.adobe.com/experience-cloud/experience-manager-apis/api/experimental/contentai/) - Query your indexed content using semantic, generative, or hybrid search endpoints.
* [Core Components documentation](https://www.adobe.com/go/aem_cmp_library) - More on proxy components and template policies.
