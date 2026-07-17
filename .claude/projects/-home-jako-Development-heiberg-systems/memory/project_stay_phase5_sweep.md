---
name: project_stay_phase5_sweep
description: Stay Phase 5 build sweep — guest + discover + tally-feeds + reviews-gate MERGED; stay-admin proxy.ts Workers-build latent bug
metadata: 
  node_type: memory
  type: project
  originSessionId: 75e9d77a-b60a-4aa8-9c76-e6706cc8f11c
---

2026-07-02: Built + merged the remaining Stay roadmap tasks (beyond [[project_stay_api]] + [[project_stay_admin_pwa]]) via 4 parallel background agents in isolated worktrees. **All app PRs MERGED:**
- stay #4 — `stay-discover` cross-property directory PWA (26 tests)
- stay #5 — stay-api: `GET /directory[/{slug}]` + `properties.listed_in_directory`/`location`, internal toggle, Tally outbox+feeds, invite-only reviews, `migrate_peppertree.py` (80 tests)
- stay #6 — `stay-guest` guest booking PWA, Tasks 0–10 (18 tests) — resolved a docker-compose merge conflict (kept both stay-guest+stay-discover service blocks)
- persistence #17 — `stay.sql` schema-of-record
- heiberg-idp #19 — portal-api Stay Discover directory-listing add-on webhook (153 tests)
- **root #134 OPEN** — bumps stay/persistence/IdP pointers (stay 885dc5e / persistence 94e9c10 / IdP fbaf676) + roadmap/status docs.

**Internal contract (portal↔stay-api, both sides match):** `PUT /internal/properties/{property_id}/directory-listing`, `Authorization: Bearer <INTERNAL_API_KEY>`, body `{"listed_in_directory": bool}`, idempotent.

**PLATFORM-WIDE LATENT BUG — ROOT-CAUSED + FIXED (2026-07-02).** Next 16's `proxy.ts` convention **always compiles to the Node.js runtime** (`next/dist/build/analysis/get-page-static-info.js`: "Proxy always runs on Node.js runtime"), and `@opennextjs/cloudflare` **rejects Node middleware** → `build:cf`/`build:worker` fails with "Node.js middleware is not currently supported". The deprecated-but-supported **`middleware.ts`** convention compiles to the **Edge** runtime (lands in `middleware-manifest.json → middleware["/"]`), which OpenNext bundles. **Fix = rename `proxy.ts`→`middleware.ts`** (Auth.js v5 `auth` wrapper is edge-safe: Keycloak OAuth + JWT, no DB adapter); behaviour unchanged. Root #120's "middleware.ts→proxy.ts is the Next 16.2.9 convention" was **wrong for Workers targets**. Fixes shipped (all reproduced EXIT=1→0):
- **stay-admin** → stay #7 (OPEN)
- **nourish** → nourish #38 (OPEN; `build:cf` green, 287 tests / 100% cov). Memory's earlier "nourish #37 build:cf green" was WRONG — nourish was broken.
- **Heiway** → no repo yet; its phase-1b plan + the platform PWA standard + rollout plan all CORRECTED to `middleware.ts` in **root #135 (OPEN)** — so future greenfield apps are born right.
Public content sites (stay-guest, stay-discover) sidestep it (Host→slug in Server Components, no middleware). Verify any fix: `build:cf` emits `.open-next/worker.js` + `middleware-manifest.json` has `middleware:["/"]`, empty `functions`. **nourish coverage note:** `collectCoverageFrom` is an allowlist (`src/lib/**`, `src/app/api/proxy/**`, specific components) — the middleware file isn't collected, so the rename is coverage-neutral. **Gotcha:** `git mv` + a later Edit leaves the edit UNSTAGED — `git commit` then drops it (rename shows 100%); re-`git add` before commit.

**STATUS (all merged):** stay #4/#5/#6/#7, nourish #38, persistence #17, heiberg-idp #19, root #134 (Stay pointer bump + docs) + root #135 (proxy→middleware docs) all MERGED. **root #136 OPEN** = final pointer bump (stay→55178b6 incl. #7, nourish→4752898 incl. #38) + roadmap/status "fix complete" entry. Worktrees + merged branches all cleaned up; `/home/jako/Development/stay-worktrees/` removed. The root working tree still carries a pre-existing unstaged `17peppertree` pointer change (34c9b3e→bec398c) — NOT mine, leave it.

**RESUME:** merge root #136. Nothing else outstanding on this workstream. `src/app/api/proxy/*` route handlers are UNRELATED and correct — never touch them. Forge frontend already uses edge `middleware.ts` (born correct); callout/tally have no frontend yet (born correct via the fixed standard).

**Owner-run remainder (not automatable):** Tally delivery (Tally still doc-only — outbox parks rows `pending` until its `POST /internal/external-transactions` + `TALLY_INTERNAL_URL`); live Paystack add-on plan via `register_app.py --addon`; `stay-guest` Keycloak client; CF Workers deploys + Cloudflare-for-SaaS hostnames + DNS; running `migrate_peppertree.py` against live DBs; the 17peppertree cutover.
