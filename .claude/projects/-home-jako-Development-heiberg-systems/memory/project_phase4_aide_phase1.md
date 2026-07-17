---
name: project_phase4_aide_phase1
description: Phase 4 (Keycloak account restructure) + Aide Phase 1 implemented 2026-06-25 across 4 open PRs; Phase 5 is gated on Phase 4 merging; 4B deferred.
metadata: 
  node_type: memory
  type: project
  originSessionId: 7585e8d4-8db1-49da-81fc-4947bcbd0435
---

On 2026-06-25 Phase 4 (Keycloak account restructure) and Aide Phase 1 (gateway+routing) were implemented and opened as **4 PRs (not yet merged)**:

- **IdP #15** (`feature/keycloak-account-restructure`) — 4A realm roles + `heiberg-account` claim scope + declarative user profile + `keycloak-init`; 4C shared `heiberg-base` + per-app login themes; 4D portal-api account model (**125 tests**, was 55); 4E `migrate_to_accounts.py`. Integration-boot-tested on isolated KC 26.6.3.
- **persistence #13** (`feature/portal-account-model-ddl`) — canonical `schemas/postgres/portal/portal.sql` (accounts/memberships/invitations/account_subscriptions/user_profiles; `products.keycloak_group`→`keycloak_realm_role`; `purchases.account_id`).
- **aide #1** (`feature/aide-phase1-gateway-routing`, in the NEW repo `Heiberg-Systems/aide`) — gateway + cost-aware router (OpenRouter + direct Anthropic), cost ledger, app budgets, prompt sanitisation. 28 tests. Repo default branch = `develop` (scaffold); Phase 1 is the PR.
- **root #88** (`feature/wire-aide-phase1`) — aide submodule + root compose `include` (profile `[aide]`) + `.env.example` vars.

**Merge order:** aide #1 → root #88; persistence #13 + IdP #15 together. Org uses **merge commits** (not squash), so the root submodule pointer `aide@410bc52` (a feature-branch commit) becomes an ancestor of `aide:develop` on merge — bump it to develop's tip afterward. Root #88 leaves the IdP/persistence submodule pointers UNcommitted on purpose (bump after their PRs merge).

**Deferred / gotchas:**
- **4B (phone verification) deferred** (per Jako): no `VERIFY_PHONE` SPI; `/internal/send-otp` + invite WhatsApp are logged stubs (`TODO(4B)`); `phone_number`/`contact_preference` declared OPTIONAL, `lastName` kept visible so current register forms work. Completing 4B = SPI + flip to required + render in per-app `register.ftl`.
- **keycloak-init**: KC26 does NOT initialise the declarative user profile from the imported `kc.user.profile.config` realm attribute — it must be applied via `PUT /admin/realms/heiberg/users/profile`. A one-shot `keycloak-init` service (`keycloak/apply-user-profile.sh`) does this; `keycloak/user-profile.json` lives OUTSIDE `keycloak/realm/` (the import dir).
- **Applying realm changes to the running dev stack** needs a realm re-import (KC import is IGNORE_EXISTING) — don't `down -v` the shared stack (wipes preserved Nourish data).
- **persistence/aide.sql** still TODO (shared-cluster schema; Phase 1 runs Aide's own `aide-postgres`).
- `forge`/`callout`/`tally` clients aren't in the realm JSON (created via `register_app.py`, which now sets `login_theme=<slug>`); existing forge client needs a one-time `login_theme` admin update.

**Next:** Phase 5 (individual apps) is gated on Phase 4 merging. Aide Phases 2–6 build on Aide #1. See [[project_infra_consolidation_phase2]].
