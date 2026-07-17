---
name: changelog-history-not-in-status-roadmap-headers
description: "Status/roadmap \"Last updated\" headers must be a ONE-LINER; the full rolling history lives only in changelog.md"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 70011b10-36f1-428e-97e0-b5d9bfe96881
---

The rolling change **history** must ALWAYS live in `docs/planning/changelog.md`, NOT in the "Last updated:" heading of `docs/planning/implementation-status.md` or `docs/planning/implementation-roadmap.md`. Those headings must be a **single one-liner** describing only the most recent change — never a growing "Prior: … Prior: …" chain.

**Why:** the two headers had ballooned into enormous duplicated rolling histories; the changelog file is the single home for history, and the headers are just a quick "what was done last" pointer.

**How to apply:** in every post-merge reconcile — (1) prepend the full detailed entry to `docs/planning/changelog.md`; (2) set the status + roadmap "Last updated:" heading to a one-line summary of that last change with no "Prior:" tail (link to the changelog for history). Same doc-location discipline as [[feedback_doc_paths]]. The pre-existing bloated "Prior:" chains in those two headers should be migrated into the changelog when touched.
