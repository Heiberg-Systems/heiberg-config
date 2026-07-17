---
name: project_platform_pwa_tally_standard
description: "Platform-wide directive — every app is a mobile-first installable PWA like Heiway, and every app feeds cost data into Tally (which gains AI invoice import)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 0023beb6-75b9-48c1-9369-19ac091eda0b
---

Cross-cutting directive from Jako (2026-06-29), to apply to **every** Heiberg Systems app (Nourish, Forge, Callout, Tally, Stay, Heiway, future):

1. **Mobile-first installable PWA** — every app must be an installable Progressive Web App for mobile *and* desktop (manifest, service worker, install prompt, web push), yet equally polished as a normal web app in mobile/desktop browsers. The reference standard is the **Heiway app** (Next.js 16 PWA on Cloudflare Workers; PWA shell in Phase 1; PWA Web Push for reminders). This generalizes Heiway's pattern to all apps.

2. **Universal cost-feed into Tally** — every app must be able to push cost data into [[project_ledger_renamed_to_tally]] (household budgeting). Architecture already exists in the [[project_heiway]] design: a generic Tally-side `POST /internal/external-transactions` (idempotent upsert/void, keyed on `(source, external_id)`, filed against shared `account_id`), fed via an app-side outbox+worker, opt-in, push-only, source-tagged. Heiway is the *first* consumer — the directive makes this the standard integration every app implements, and means the Tally side of that contract must be built generically.

3. **Tally AI invoice import** — Tally will import invoices (e.g. municipal invoice PDFs, and many other invoices) via **AI extraction** (Aide), accepting both downloaded files (PDF) and screenshots. Not yet designed (no `invoice` references in `tally/` today; Tally is design-only, no code).

**Why:** one consistent, install-anywhere UX across the suite; Tally becomes the single household cost ledger every product feeds.

**How to apply:** treat as three independent specs (decompose, don't build as one). Two have precedent — PWA pattern + the Tally external-transaction contract both originate in the Heiway design (`docs/designs/2026-06-29-heiway-design.md`, "Cross-product integration — Heiway → Tally" + Phase 1 "PWA shell"). Tally invoice import is greenfield. Tally foundation plan: `tally/docs/plans/2026-06-26-tally-foundation.md`.
