---
name: project_shared_dev_db_seed
description: Fresh shared dev DB self-seeds (nourish + portal) via persistence init hook + root scripts/seed-dev.sh; fixed a latent grant bug
metadata: 
  node_type: memory
  type: project
  originSessionId: 46beedbd-64fa-4987-b140-1af7b9d54cfc
---

2026-07-17 (nourish #56): the `persistence/`-owned shared dev Postgres came up **schema-only, no seed data** (nourish `planning_rules` empty, portal `user_profiles` empty) since apps moved off their own postgres to the shared cluster. Fixed with a **hybrid** seed mechanism (the two DBs come up at different times owned by different components, so a single seed point is impossible):
- **nourish app data** → new `persistence/postgres/init/03-seed-dev-data.sh` loads a curated `persistence/postgres/seed/nourish-dev.sql` (persons keyed by live Keycloak subs + 130 planning_rules; retired identity cols + retired tables households/household_members/medical_conditions/subscription_plans/subscription_status excluded; explicit column lists + ON CONFLICT for re-run safety). Auto-runs on a **fresh volume** only.
- **portal `user_profiles`** (schema created by portal-api `create_all` AFTER persistence init) → root **`scripts/seed-dev.sh`** runs portal-api's existing idempotent `IdP/portal-api/scripts/seed_dev_profiles.py` via `docker compose exec` + re-applies the nourish seed. Run it after `docker compose up`.
- PRs: persistence **#22** (Closes nourish#56) + root **#262** (seed orchestrator + howto). Needs persistence pointer bump in root after #22 merges.

**LATENT GRANT BUG found + fixed (important):** `persistence/postgres/init/02-apply-schemas.sh` applied the `--no-owner` schema dumps as the `postgres` **superuser**, leaving nourish/forge tables owned by `postgres` with **no grants** to `nourish_user`/`forge_user` → `permission denied` on a truly fresh volume (the live dev DB only worked because grants were applied by hand during earlier manual seeding). Fixed `02` to GRANT full access (present + future objects) to `nourish_user`/`forge_user`. Without this, a fresh spin-up app can't even read its own tables.

**Verifying a fresh-volume init — `pg_isready` gotcha (2026-07-17, verified PASS):** to prove the seed on a clean volume without touching the live stack, run an isolated throwaway `postgres:18-alpine` via **`docker run`** (fresh anon volume, spare loopback port e.g. `127.0.0.1:5499`, and do **NOT** join `heiberg_net` — its `postgres` DNS alias would collide with the live DB and could steer apps to the throwaway), mounting the repo's real `persistence/postgres/init` → `/docker-entrypoint-initdb.d`, `schemas/postgres` → `/schemas`, `postgres/seed` → `/seed`, with the 7 `*_DB_PASSWORD` env vars. **DO NOT gate readiness on `pg_isready` over the local socket** — Postgres runs a *temporary socket-only* server (`listen_addresses=''`) **while** the init scripts run, so `docker exec … pg_isready` (socket) reports READY mid-init and you query a half-initialized DB → false negative (`planning_rules "does not exist"`, `persons "permission denied"`). Gate instead on the entrypoint log marker **`"PostgreSQL init process complete"`** (printed only after 01→02→03 all ran) **plus TCP readiness** (`pg_isready -h 127.0.0.1`, which the temp server never accepts). Correct run showed: init 01(7×CREATE DB)→02→03 clean; as `nourish_user` → planning_rules=130, persons=2 (owner still `postgres`, yet readable = grant fix works, incl. non-seeded tables + forge_user); seed re-run idempotent; live `heiberg-postgres-1` untouched. Reusable script: scratchpad `verify-seed.sh`.

Related: [[project_stay_aide_deferred_own_db]], [[submodule-structure]].
