---
cloud: Experience Cloud
solution: Experience Manager
product_v2:
  - id: fd1f54a9-f50c-467d-8956-cebbaf4f3eb8
    internal-label: "Experience Manager"
usetq: true
type: Documentation
git-repo: https://github.com/AdobeDocs/experience-manager-content-ai.en
index: true
recommendations: noDisplay
---

# Metadata for internal use

Metadata in the GitHub authoring system is hierarchal and is defined the following increasing levels of precedent.

1. metadata.md
1. ToC
1. Article

Metadata defined in the metadata.md file apply to the entire repo, but can be overridden at the ToC and article levels. Any overriding of the metadata should be done at the lowest level possible.

The metadata in the experience-manager-content-ai.en repo is the minimum required.

metadata.md

* `product`
* `git-repo`
* `index`
* `solution-title`
* `solution-hub-url`
* `getting-started-title`
* `getting-started-url`
* `tutorials-title`
* `tutorials-url`

ToCs

* `sub-product`
* `user-guide-title`

Article

* `title`
* `description`
