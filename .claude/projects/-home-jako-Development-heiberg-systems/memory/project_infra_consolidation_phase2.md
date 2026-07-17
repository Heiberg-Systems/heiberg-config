---
name: project-infra-consolidation-phase2
description: "Roadmap Phase 2 (local-dev infrastructure consolidation) is COMPLETE + smoke-tested — open PRs, plan defects fixed, and what's left (pointer bump, backup cron)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 041bd856-d05f-4c36-b0a8-6d2972710f9a
---

Roadmap **Phase 2 = root `docs/plans/2026-06-12-infrastructure-consolidation.md`**. **COMPLETE + smoke-tested end-to-end 2026-06-25.** The unified root `docker compose` stack boots clean: shared PG18/Mongo, Keycloak, portal-api, nourish-backend, forge-backend all healthy on `heiberg_net`; Caddy (`/auth` + `/api`) + Mailhog up. nourish dev data **preserved** (6 meal plans / 23 recipes / 62 Mongo planning rules) by pinning the persistence volume names so the root `heiberg` project reuses `persistence_postgres_data`/`persistence_mongodb_data` instead of creating empty volumes.

**Key decision (user, 2026-06-25):** both app backends renamed to **unique Compose service keys** — `nourish-backend` / `forge-backend` (container_names unchanged: `meal-planning-backend` / `workout-plan-backend`). The old shared name `backend` collided under the root `include:`. Every future app's backend needs a unique key too.

**Three plan defects found + fixed during the smoke test** (Task 14 caught them, as designed):
1. Dual `backend` service-name collision under `include:` → renamed (above).
2. Dev compose's `KC_HOSTNAME_ADMIN` with a bare `KC_HOSTNAME` crashed Keycloak 26 (`hostname must be a URL when hostname-admin is set`) → removed from dev (admin lockdown is a prod-override concern).
3. Dev `Caddyfile` `/auth/*` forwarded without `strip_prefix` → 404 (KC26 serves at root `/realms/...`) → added `uri strip_prefix /auth`.

**MERGED 2026-06-25:** persistence #11, heiberg-idp #14, nourish #30, forge #13, root heiberg-systems #83, heiberg-claude-skills #1 (docker-debug skill), root whatsapp-webhook doc #84. **Root submodule-pointer bump = PR #86 (open, pending merge)** — points persistence/IdP/nourish/forge at their merged develop tips. Once #86 merges, Phase 2 is 100% landed. [[feedback-fast-pr-merges]] — Jako merges fast + auto-deletes branches; fetch before follow-ups.

**DONE 2026-06-25:** #86 (infra pointer bump) merged; **PR #87** bumps the 3 lagging non-Phase-2 pointers (tally, heiberg-systems-website, personal-website → their develop tips) — once #87 merges, root `git status` is fully clean, no pointers left to bump.

**RESUME / remaining:**
1. Backup cron (Phase 2 Task 15) — one-time host setup (rclone→R2), deferred.
3. Residual: shared postgres still has an empty `ledger` DB + `ledger_user` (created pre-rename); `.env` key renamed LEDGER_DB_PASSWORD→TALLY_DB_PASSWORD locally. Cosmetic — no app uses tally/ledger yet. [[project-ledger-renamed-to-tally]]

**Next roadmap phase = 2.5 Staging** (UpCloud VPS + k3s) — BLOCKED on the user provisioning the UpCloud VPS + filling Cloudflare DNS (both deferred by the user until local dev was done, which it now is).
