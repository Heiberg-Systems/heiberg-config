---
name: project-org-migration
description: GitHub org migration from jheiberg personal account to Heiberg-Systems org — completed 2026-06-08. All repos now under Heiberg-Systems.
metadata: 
  node_type: memory
  type: project
  originSessionId: f52fc782-9def-416d-b674-47411a8030cc
---

GitHub org migration completed 2026-06-08. All repos transferred from `jheiberg` personal account to `Heiberg-Systems` org.

**Why:** Consolidate repos under a proper org for Heiberg Systems work.

**How to apply:** All GitHub URLs use `Heiberg-Systems/` now, not `jheiberg/`. CLAUDE.md updated to reflect new org. Local remotes all updated.

Final state:
- 11 repos in Heiberg-Systems org: heiberg-systems, eating-plan, workout-plan, heiberg-co-za, heiberg-idp, heiberg-systems-website, infrastructure, 17peppertree, heiberg-claude-skills, heiberg-config, my-yazi
- 7 git submodules in heiberg-systems root: infrastructure, eating-plan, workout-plan, heiberg-co-za, heiberg-systems-website, IdP, 17peppertree
- docs/ absorbed as plain files (was a submodule to jheiberg/docs, now plain files in root repo)
- infrastructure/ extracted as its own submodule (Heiberg-Systems/infrastructure)
- 17peppertree moved from ~/Development/17peppertree into heiberg-systems tree
- jheiberg/docs archived on GitHub
