---
name: project_stay_admin_pwa
description: "Stay-admin PWA built + fully MERGED (stay #3 + root #118/#119/#120/#121; on proxy.ts; pointer bumped); full-auth live smoke deferred (needs IdP/.env + stay-admin Keycloak client)"
metadata: 
  node_type: memory
  type: project
  originSessionId: eef05752-48f0-44ed-a644-1753e12991e6
---

**IMPLEMENTATION DONE (2026-06-30):** all 18 tasks built subagent-driven on `feature/stay-admin` in the `stay/` submodule → **stay PR #3 OPEN** (base develop, 27 commits); each task got an implement→review gate + a whole-branch opus review. stay-api **30/30** pytest, stay-admin **11/11** Vitest + `npm run build` + `npm run build:worker` green. Docs: design root #118 MERGED; planning-status root #119 OPEN.
- **Whole-branch review caught a MERGE-BLOCKER the 18 per-task reviews missed:** "Save notes" PATCH sent `{admin_notes}` with no `status` but `BookingStatusPatch.status` was required → 422 on the only button shown for confirmed/rejected bookings. Fixed TDD (`status: str|None=None`) + regression test. Tenant isolation verified airtight (every `/admin/*` resolves via one owner-scoped `_get_owner_property`; un-owned `X-Stay-Property-Id`→404, tested).
- **PROXY MIGRATION DONE (Jako approved):** renamed `middleware.ts`→`proxy.ts` in stay-admin (in stay #3, build warning cleared) + migrated the PWA-standard §3.5 recipe + Heiway/rollout plans → **root PR #120 OPEN**. Future apps inherit `proxy.ts`.
- **Compose bug fixed (stay #3):** `stay/docker-compose.yml` declared `stay-admin` on `heiberg_net` but never declared the network external → whole `docker compose up` was invalid; added top-level `networks: heiberg_net: external` + `name: stay`.
- **PARTIAL LIVE SMOKE — PASS (Chrome DevTools, `npm run dev`):** `/`→`/login` proxy redirect works; login renders on-brand (Syne, `.hb-card` accent border, blue `.hb-btn`); **service worker registered+active** (`/sw.js`); manifest+3 icons all serve 200; `theme-color #0F172A`; **no horizontal scroll at true 320px**, 56px tap target. Installability criteria met.
- **FULL AUTH SMOKE BLOCKED (env):** this workstation has **no `IdP/.env`** → Keycloak can't start, so the actual login + authenticated routes (dashboard/bookings/wizard) couldn't be exercised. To run it later: provide `IdP/.env`, bring up IdP+stay-api, register a `stay-admin` confidential Keycloak client (redirect `http://localhost:3010/api/auth/callback/keycloak`), seed a `stay:subscriber` owner + provision a property, then login→routes + Lighthouse.
- **ALL MERGED (2026-06-30):** stay #3 → stay develop `1515b46`; root #118 (design) + #119 (planning) + #120 (proxy doc migration) all merged. Root **pointer-bump + status/roadmap-✅ PR #121 OPEN** (bumps stay pointer to 1515b46). Merged local branches deleted; stay + root synced on develop.
- **RESUME:** after #121 merges, stay-admin is fully done. Remaining for the product: the **full auth live smoke** (needs `IdP/.env` + a registered `stay-admin` Keycloak client — see the env-blocked note above), then **stay-guest** (its own PWA reconcile owed) + the 17peppertree migration. Follow-ups list above still stands.
- **Non-blocking follow-ups:** token refresh on expiry; real avatar initials; `getBooking(id)`+`GET /admin/bookings/{id}` (detail does O(n) find); `.hb-btn-success` class; per-env Worker separation in CI; `status_history` model(`dict`)/schema(`list[dict]`) drift.

---

2026-06-30: brainstormed + planned the **stay-admin** frontend conforming to the platform mobile-first installable-PWA standard ([[project_pwa_standard_rollout]] / `docs/designs/2026-06-29-platform-pwa-mobile-first-standard.md`). The old `docs/plans/2026-06-16-stay-admin.md` predated the standard (fixed desktop sidebar, no PWA contract, off-palette hex) — superseded for its UI/PWA parts.

**Artifacts (root repo, branch `docs/stay-admin-pwa`, PR #118 OPEN, base develop):** `docs/designs/2026-06-30-stay-admin-pwa-design.md` + `docs/plans/2026-06-30-stay-admin-pwa.md` (18-task TDD plan). **No app code yet** — implementation lands later on a `stay/` submodule branch.

**Scope = FULL spec** (Jako chose): Dashboard, Bookings (responsive cards-mobile/table-desktop + detail), Reviews, Rooms, Images, Settings (rates/property/domain/account), **multi-property switcher**, and the **one-time 5-step onboarding wizard** (Property→Rooms→Images→Rates→Domain).

**Key facts that shaped it:**
- **Stay admin is the platform's FIRST real build of the §4.1 shared app-shell** (bottom tabs + account menu on mobile, collapsible-to-icon-rail desktop side-nav). Heiway — the named reference — only shipped the PWA contract + tokens and **deferred its shell**. So there's a copyable PWA recipe but no copyable shell; stay-admin sets the precedent. App-shell IA: tabs = Dashboard·Bookings·Reviews·Rooms·More; More→Images+Settings; account menu→Switch property·Account·Sign out.
- **stay-api changes folded into the plan (Task 1, same submodule):** (a) extend `BookingOut` to surface `admin_notes`+payment fields (PATCH already accepts them, read side was the gap); (b) add `GET /admin/properties` + make the shared `_get_owner_property` resolver honour an optional `X-Stay-Property-Id` header (one contained change enables the switcher across all `/admin/*` since every admin route resolves through that helper; always filtered by owner → un-owned id = 404, no cross-tenant leak). **No new `GET /admin/images`** — images come embedded in `GET /admin/property` (`PropertyOut.images`); old plan's "add it" task dropped.
- Auth = realm role **`stay:subscriber`** (already enforced by stay-api after stay#2, see [[project_stay_api]]) — frontend handles 403 gracefully; the old `app-stay-subscribers` group assumption is dead.
- Canonical `--hb-*` tokens (`#0F172A` bg, `#1E293B` surface, `#3B82F6` accent) + Syne/IBM Plex via next/font — replaces the 2026-06-16 plan's off-palette hex.
- Stack: Next.js 16 + React 19 + `next-auth@beta` (v5) + Tailwind v4 + Vitest; deploy Cloudflare Workers via `@opennextjs/cloudflare` (`wrangler.jsonc` + `open-next.config.ts`) at single fixed `admin.stay.heiberg.systems`.

**Self-review caught + fixed in the plan before PR:** `lib/property.ts` must NOT be `"use server"` (it exports sync `isPropertySetUp`; module is server-side-only, not client actions); delete the scaffold's `app/page.tsx` so `/` resolves to `app/(dashboard)/page.tsx` (gets the shell); design §5 aligned with the property-selector backend addition.

**Deferred (noted, not built):** Web Push (new-booking alert to owner), offline precaching (Serwist), richer booking lifecycle (completed/cancelled needs stay-api), image drag-reorder, Tally cost-feed.

**RESUME:** after PR #118 merges → execute the 18-task plan on a `feature/stay-admin` branch **inside the `stay/` submodule** (NOT root) via subagent-driven-development or executing-plans; prerequisite: register the `stay-admin` Keycloak client (confidential + redirect URIs). After submodule PR merges → bump root `stay` pointer + tick plan/design status. Then stay-guest still owes its own PWA reconcile (note its §5.1 per-hostname dynamic manifest wrinkle).
