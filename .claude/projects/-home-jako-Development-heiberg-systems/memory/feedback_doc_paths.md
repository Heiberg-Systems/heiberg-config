---
name: feedback_doc_paths
description: "Project documentation paths — designs, plans, specs, etc. always go to project-conventional paths, never skill-default paths"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: ae849cb0-f4f4-47c5-9e30-700cbbeaabb2
---

Use `./docs/designs/`, `./docs/plans/`, `./docs/recommends/`, `./docs/reports/`, `./docs/proposals/` for all written documents — in every repo (heiberg-systems root, eating-plan, workout-plan, heiberg-co-za, IdP, heiberg-systems-website, infrastructure, etc.).

**Why:** Explicit user correction — skill defaults like `docs/superpowers/specs/` or `docs/superpowers/plans/` conflict with the project convention defined in CLAUDE.md.

**How to apply:** When any skill (brainstorming, writing-plans, etc.) instructs you to save to `docs/superpowers/specs/` or `docs/superpowers/plans/`, override with the correct path:

| Document type | Correct path |
|---|---|
| Designs / specs | `./docs/designs/` |
| Plans | `./docs/plans/` |
| Recommendations | `./docs/recommends/` |
| Reports | `./docs/reports/` |
| Proposals | `./docs/proposals/` |
