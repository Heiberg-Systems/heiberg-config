---
name: project_static_dev_port_registry
description: "Platform-wide static dev host-port registry — allocation, the clashes it fixed, open PRs, and RESUME (pointer bumps + Keycloak follow-up)"
metadata: 
  node_type: memory
  type: project
  originSessionId: b6e4f4c7-5a30-4d72-89f3-5f8fbca655ed
---

2026-07-05: Gave every developer-facing surface a unique, static dev host port so the whole stack
comes up on one workstation without clashes. Authoritative table lives in root `CLAUDE.md` ("Dev port
registry"); rationale in `docs/designs/2026-07-05-dev-port-allocation-design.md`. Scope = dev only
(staging/prod on K8s/Cloudflare, out of scope). Env `${VAR:-default}` overrides kept but every default
unique; dev servers fail loudly (Vite `strictPort`, pinned `next dev -p`) instead of drifting.

**Clashes fixed:** 5173 ×3 → personal-website 3030, heiberg-systems-website 3031, **17peppertree keeps
5173** (its own self-contained Keycloak wires `localhost:5173/auth/callback`, so leave it); 8787 ×2 →
personal-website worker keeps 8787 (its Vite `/api` proxy targets it), heiberg-systems worker → 8788;
Grafana 3001 → 3101 (was clashing with forge-web `-p 3001`); nourish bare `next dev` → `-p 3000`.
**No change:** forge, stay, aide, IdP, persistence (already unique).

**MERGED (2026-07-05):** docs #160 + nourish #42 + observability #8 + heiberg-systems-website #29 +
personal-website #24. Root pointer-bump **#161 OPEN** (bumps 4 pointers; personal-website advances to
origin/develop 37e556f which also carries the already-merged series-admin fix #23). All local
`chore/static-dev-ports` feature branches deleted; worktree removed.

**personal-website gotcha (for future submodule work):** its main checkout sits on Jako's active
branch **`feature/homepage-app-suite`** (NOT develop) with uncommitted WIP on series.ts +
AdminSeriesPosts.jsx. So I bumped root's personal-website gitlink via `git update-index --cacheinfo
160000,<sha>,personal-website` (points root at origin/develop without disturbing the feature-branch
checkout) — do NOT `git add personal-website` there or you record the feature-branch commit. Left
Jako's WIP fully intact (stashed then popped it back).

**DONE:** root #161 (pointer bumps) MERGED. Keycloak follow-up DONE — added `localhost:3030/*` +
`:3031/*` to `portal-frontend` redirectUris + webOrigins + post.logout in
`IdP/keycloak/realm/heiberg-realm.json` (mirrors existing :3089/:5173 dev entries) → **heiberg-idp
#29 OPEN**; also applied LIVE to running dev Keycloak `heiberg-keycloak-1` via `kcadm` (realm file
only re-imports on fresh KC, so live-apply was needed). portal-frontend lives ONLY in that realm JSON
(not register_app); apply live with `docker exec heiberg-keycloak-1 kcadm.sh config credentials
--realm master --user $KEYCLOAK_ADMIN ...` then `update clients/<id>`. Left `:5173` (now 17pt's, own
realm). NOTE prod `auth.heiberg.systems` only picks it up on its own realm (re)import — not changed here.

heiberg-idp #29 MERGED; root IdP pointer bump → **root #163 OPEN** (last piece).

**RESUME:** merge root #163 — then the whole static-dev-port effort is fully DONE. Relates to
[[submodule-structure]] and [[feedback_fast_pr_merges]].
