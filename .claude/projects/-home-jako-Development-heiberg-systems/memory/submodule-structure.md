---
name: submodule-structure
description: nourish AND forge ARE git submodules of the root repo (CLAUDE.md is stale) — bump their root pointers after their PRs merge
metadata: 
  node_type: memory
  type: reference
  originSessionId: f4b9d132-6539-4922-ba8a-7148ca5925a2
---

2026-07-03: The root repo (`Heiberg-Systems/heiberg-systems`) tracks **13 submodules** — every
one of these dirs is a mode-160000 gitlink in `.gitmodules`:
`17peppertree, aide, callout, forge, heiberg-systems-website, IdP, nourish, observability,
persistence, personal-website, stay, tally, test-journeys`.

**CLAUDE.md is STALE on this point** — it still says nourish/forge/IdP/heiberg-systems-website/
personal-website/17peppertree are "separate repos, NOT submodules of it." That was true at the
2026-06-08 org migration ("7 submodules") but MORE repos have since been converted to submodules.
Verify with `git ls-files --stage <dir>` (160000 = submodule) or `git config -f .gitmodules
--get-regexp path`, NOT CLAUDE.md.

**Consequence:** after ANY app repo's PR merges, its root pointer must be bumped (checkout+pull the
submodule's develop, then `git add <dir>` in root on a chore branch → PR). I MISSED bumping
**nourish** in the Phase 2 observability reconcile (root #146) because I trusted CLAUDE.md's "nourish
isn't a submodule" — caught + fixed in root #150. The root `.gitignore` is allow-list style (`/*`
then `!dir/`); a submodule can be tracked (gitlink in index + `.gitmodules`) even if not in the
allow-list, so absence from `.gitignore` does NOT mean "not a submodule."

When "committing everything" / reconciling: `git status --short` shows ` M <dir>` for every drifted
submodule pointer; stage only the ones relevant to the current work (explicit `git add <dir> ...`),
and leave unrelated drift for a separate reconcile. CLAUDE.md's Repository-structure table was corrected (all dirs marked submodule + observability/test-journeys added + aide "not yet created" dropped) → **root PR #151 MERGED** (2026-07-03).
