---
name: project_stay_api
description: "Stay API (new product) implemented from plan; stay repo created; 2 PRs open, root pointer PR pending merges"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6c6b3723-5fe3-4451-b598-854f841efc75
---

Stay hospitality-booking backend implemented from `docs/plans/2026-06-16-stay-api.md` (2026-06-29). The `Heiberg-Systems/stay` GitHub repo was **created** (private, default `develop`) and added as a submodule at `stay/` — previously it was "planned, repo not yet created" (see [[project_org_migration]] sibling list / CLAUDE.md still says planned → update in root PR).

**What shipped (stay-api):** FastAPI multi-tenant backend, all 13 plan tasks (0–12). 22 routes (public/guest/admin/internal), RS256 Keycloak JWT auth, R2 + Cloudflare-for-SaaS custom-hostname services, APScheduler cleanup task. Python 3.14, SQLAlchemy 2 async, PostgreSQL 18. **15/15 pytest pass; stay.sql applies clean; docker compose smoke (/docs 200, clean lifespan).** Tested via a host venv at `stay/stay-api/.venv` against the compose `db` (port 5442, DB `stay_test`).

**Plan had real bugs — fixed during impl:** `TIMESTAMPTZ` import doesn't exist → `DateTime(timezone=True)`; models needed `server_default` to match stay.sql (raw-SQL test inserts); missing `email-validator` dep; postgres:18 volume must mount `/var/lib/postgresql` not `.../data`; admin PropertyOut needed eager-load (MissingGreenlet); guest bookings `scalar_one_or_none`→`.scalars().first()`. **Security (HIGH, automated review):** `/me/bookings` now requires `email_verified` claim before lazy-linking Keycloak account to bookings (account-takeover/IDOR gate).

**State (2026-06-29):** stay#1, stay#2, persistence#15, root#113 all **MERGED**. stay develop=d112ee8 (incl. realm-role auth), persistence develop=d1931d8. **Root #114 OPEN** — bumps stay pointer c2007b9→d112ee8 + marks auth reconciled in status/roadmap. stay submodule registered at `stay/`; CLAUDE.md updated. Dev compose torn down (stay-pgdata volume kept; test venv at stay/stay-api/.venv).

**Auth reconciled (stay#2 OPEN, 2026-06-29):** auth now gates on **realm roles** from `realm_access.roles` — admin=`stay:subscriber`, guest=`stay-guest` (singular) — matching the account-restructure ([[project_phase4_aide_phase1]] / IdP#15) + nourish/forge pattern + `IdP/keycloak/realm/heiberg-realm.json`. Replaced legacy group checks in `auth/dependencies.py` (`_require_realm_role`) AND public member-rate masking. 22 tests (7 new in test_auth_roles.py incl. legacy-group-rejected). Do NOT create `app-stay-subscribers`/`stay-guests` groups.

**RESUME:** after #113 + stay#2 merge → bump root stay pointer to new develop + check off the roadmap auth item (currently unchecked in #113). Next frontend: **stay-admin re-planned PWA-conformant → see [[project_stay_admin_pwa]] (root PR #118)** — supersedes UI/PWA of `2026-06-16-stay-admin.md`. Then `2026-06-16-stay-guest.md` (still owes its own PWA reconcile). Still owed per stay-api plan: wire Keycloak Admin token in `_link_keycloak_id` (no-op stub).
