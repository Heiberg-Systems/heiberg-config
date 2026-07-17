---
name: project_heiway
description: "Heiway — new motor-vehicle tracking SaaS product; design merged, two Phase 1 plans open, repo not yet created"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5a7951d2-372b-460e-84bb-bc8031ed518e
---

Heiway = new Heiberg Systems SaaS product: capture/track/report on motor-vehicle data, **AI-first capture via Aide** (photo/NL → draft event), **metric units only**, ZAR default. Sibling to nourish/forge/callout/tally/stay.

**Status (2026-06-29):**
- Design **MERGED** to root develop: `docs/designs/2026-06-29-heiway-design.md` (PR #107).
- Phase 1A (heiway-api) plan: `docs/plans/2026-06-29-heiway-phase1-api-foundation.md` — **#108 MERGED**.
- Phase 1B (heiway-web) plan: `docs/plans/2026-06-29-heiway-phase1b-web-foundation.md` — **#109 MERGED**.
- Planning docs (`docs/planning/implementation-status.md` + `implementation-roadmap.md`) now register Heiway (Projects row + Heiway status section + Phase 5 roadmap subsection + execution-flow HW node) — **PR #110 OPEN**. (#108 + #109 also merged.)

**Key design decisions (don't re-litigate):**
- **Hybrid event-spine** data model: one `vehicle_events` timeline (account_id, occurred_at, odometer_km, cost, type, JSONB `attributes`) + typed detail tables (fuel/service/expense) + first-class `component_replacements` (tyres/battery/exhaust… with wear reminders). Schema lives in `persistence/schemas/postgres/heiway.sql`.
- **Tenancy = the shared IdP account model** (identical to [[project_nourish_idp_account_model]]): tenant key is `account_id` from JWT (NOT a per-user id); members are Keycloak logins; roster via portal-api `POST /internal/memberships/sync`; subscription per-account via realm role `heiway:subscriber` (in realm_access.roles, assigned to the account group). First design draft wrongly assumed single-owner — corrected.
- **Heiway → Tally cost feed**: opt-in, one-way, idempotent outbox keyed on `(source=heiway, external_id=event_id)`; shares the same `account_id`. Needs a new `POST /internal/external-transactions` endpoint on the **tally** repo (cross-repo dependency). Phase 6.
- Frontend = Next.js 16 mobile-first PWA; grounded in Nourish/Forge patterns (`src/lib/api.ts` server fetch + `src/app/api/proxy/*` mutations; Auth.js v5 `src/lib/auth.ts` propagates accessToken; Jest via next/jest).

**RESUME:** repo `Heiberg-Systems/heiway` **not yet created** — Phase 1A Task 0 needs `gh repo create` + `git submodule add heiway`. Then execute 1A (#108) then 1B (#109). CLAUDE.md product table + repo-structure table do **not** list Heiway yet — add when the repo lands. Jako merges fast ([[feedback_fast_pr_merges]]).
