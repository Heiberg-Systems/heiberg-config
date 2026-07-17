---
name: project_stay_aide_deferred_own_db
description: "Stay & Aide run their own dev DBs on purpose (deferred consolidation) — not a bug to \"fix\"; shared persistence IS live in dev"
metadata: 
  node_type: memory
  type: project
  originSessionId: 46beedbd-64fa-4987-b140-1af7b9d54cfc
---

As of 2026-07-16: the shared `persistence/` Postgres (`postgres:18`) + Mongo (`mongo:7`) stack **is implemented and used in dev** — Keycloak, portal-api, Nourish, Forge, Tally all connect via `DB_HOST: postgres` on `heiberg_net` and define no DB of their own. Old root CLAUDE.md wrongly still said "shared DB Planned / each app owns its own postgres" → corrected in root **PR #260** (also fixes the "Starting the dev stack" steps to bring up `persistence` first).

**Stay and Aide are the two deliberate holdouts** that still run their own DB — this is **deferred consolidation, NOT an isolation requirement or a mistake**. Do not "fix" it by force-migrating them.
- **Stay** — own `postgres:18` on `:5442` (`profiles: [stay]`, schema from `stay-api/database/schema.sql`). Kept separate specifically to keep the **imminent 17peppertree→Stay migration** simple (see `docs/designs/2026-07-02-stay-local-bringup-and-peppertree-migration-design.md` lines 31/59). The shared cluster already provisions an **unused `stay` DB** (`persistence/schemas/postgres/stay.sql`) as the landing spot.
- **Aide** — own internal-only `aide-postgres` (uses `pgvector/pgvector:pg18`, RAG needs the pgvector extension) + `aide-mongo`, no host ports (`aide/app/docker-compose.yml`, included by root compose). Aide's own design (`docs/designs/2026-06-22-aide-design.md`) intends these to fold into the shared cluster.

**Decision (Jako, 2026-07-16):** leave both deferred; do the Stay consolidation **with / right after** the 17peppertree→Stay migration, not before. 17peppertree's `deploy.sh` (`main`) vs `deploy.yml` (`production`) branch mismatch was **intentionally left unfixed** — the repo is being migrated to Stay and decommissioned. Related: [[project_infra_consolidation_phase2]], [[project_stay_api]].
