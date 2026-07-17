---
name: project-ledger-renamed-to-tally
description: "The budgeting SaaS product \"Ledger\" was renamed to \"Tally\" (2026-06-24); repos/docs updated across the org"
metadata: 
  node_type: memory
  type: project
  originSessionId: fe42a468-b146-4b36-8593-08ae227b08f0
---

On 2026-06-24 the household-budgeting SaaS product **Ledger** was renamed to **Tally** (Jako's wife disliked "Ledger"; it also collides with the Ledger crypto-wallet brand). The GitHub repo `Heiberg-Systems/ledger` was renamed to **`tally`** by Jako.

Rename PRs (merge fast — some may already be merged):
- **heiberg-systems#73** — root docs: brand + `tally` slug (realm role `tally:subscriber`, DB `tally`/`tally_user`, `TALLY_DB_PASSWORD`, schema `tally.sql`). ✅ merged
- **Heiberg-Systems/ledger#6** — submodule content; design doc `ledger.md` → `tally.md`. ✅ merged
- **heiberg-systems#74** — submodule path `ledger/`→`tally/`, `.gitmodules` URL, `.gitignore` `!tally/`, pointer bump, + root README refresh (added `aide/` row + AI/LLM stack row, fixed Stay guest = Next.js/Workers).
- **heiberg-idp#13** — IdP Phase-4 design+plan docs (`ledger:subscriber`→`tally:subscriber`). Docs-only; `heiberg-realm.json` has no role yet (added when Phase 4 is built).
- **heiberg-systems-website#12** — product **display name** Ledger→Tally in `products.js`/`EcosystemSection.jsx` + 2 tests.

Persistence DB slug also renamed (2026-06-24): `ledger`/`ledger_user`/`LEDGER_DB_PASSWORD` → `tally`/`tally_user`/`TALLY_DB_PASSWORD`, `schemas/postgres/ledger.sql`→`tally.sql` — **persistence PR #10** + root `.env.example` in **heiberg-systems#75**. After #10 merges, bump the root `persistence` submodule pointer to pick it up (stub DB, no data migration).

**Footguns / open items:**
- **Do NOT rename** Aide's `cost_ledger` / `write_ledger_row` / "cost ledger" — different concept (Aide's per-call cost ledger).
- The **website keeps slug `budget`** for this product (`slug: 'budget'`, `integratedWith: [...,'budget']`) — a pre-existing mismatch with the platform slug `tally` (was `ledger`); the buy flow would hit `/api/buy/budget`. Reconcile before launch (left as-is per decision).
- Historical docs (root changelogs; website `docs/` design+plan) keep "Ledger" as records — intentional.

Related: [[project_org_migration]], [[feedback_fast_pr_merges]].
