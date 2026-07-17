---
name: project_observability_stack
description: "Platform observability design + Phase 0-1 plan — Vector/Loki/Prometheus/Grafana, Mongo DROPPED for logs, PR"
metadata: 
  node_type: memory
  type: project
  originSessionId: f4b9d132-6539-4922-ba8a-7148ca5925a2
---

2026-07-03: Platform-wide logging + metrics observability effort. Design + Phase 0-1 plan
→ **root PR #143 MERGED** (docs). **Phase 0-1 BUILT** subagent-driven (TDD, per-task + opus
whole-branch review): repo **Heiberg-Systems/observability CREATED** (private, default=develop),
`heiberg-logging` package done, wired as submodule at `observability/` → **root PR #144 MERGED** (branch cleaned, submodule init on develop).
21 tests. Whole-branch review caught a real secret-leak (outbound URL query strings) + drove
hardening (pure-ASGI middleware, outbound-failure logging). Package HEAD = afdfa55.

**Locked architecture (design: `docs/designs/2026-07-03-platform-observability-design.md`):**
- Stack = **Vector (collector) → Loki (logs) + Prometheus (metrics, 30d) → Grafana**. Splunk = a
  dormant Vector sink (flip on later, zero app changes).
- **Mongo was DROPPED for logs entirely** — the user's original ask was "logs to Mongo," but we
  chose Loki as the searchable store instead. Do NOT re-propose Mongo for logs.
- **Tiered Loki retention:** 90-day operational / **12-month `stream=audit`** (auth, access-control,
  subscription/payment, admin events). POPIA-safe because logs carry identifiers only (redaction).
- **Central obs host = a DEDICATED, environment-independent box running single-node k3s** (Helm:
  kube-prometheus-stack + loki + vector). NOT inside the prod cluster (would couple staging→prod),
  NOT Docker Compose (k8s consistency won — user pushed back and was right). Staging + prod ship to
  it; **dev runs a throwaway Compose copy locally** (dev=Compose / servers=k8s split).
- **Central log-level control:** shared `heiberg-logging` package reads `LOG_LEVEL` (global) +
  `LOG_LEVELS` (comma-list `logger=LEVEL` per-module) from ONE per-env source — root `.env` in dev,
  one K8s ConfigMap + Stakater Reloader in staging/prod.

**Phase 0-1 plan (`docs/plans/2026-07-03-observability-phase-0-1-logging-package.md`):** 11 TDD
tasks — create NEW repo `Heiberg-Systems/observability` (submodule at `observability/`, package at
`packages/heiberg-logging/`, src-layout, Hatchling) + build the `heiberg-logging` package
(structlog-over-stdlib JSON, request-id middleware, exception handler, `audit()`, `logged_httpx_client`,
RED metrics via prometheus-fastapi-instrumentator, `configure_observability(app, service=)` façade).
Zero infra to test. Repo does NOT exist yet — Task 0 creates it.

**Phase 2 plan** MERGED (root PR #145). **Phase 2 BUILT** subagent-driven (background; per-task +
opus whole-branch review), all 8 tasks + final-review fixes, verified E2E live (Nourish logs→Loki
w/ request_id, RED metrics→Prometheus, both via Grafana proxy, LOG_LEVEL flip). **observability #1** (dev stack `deploy/dev/`: Vector→Loki+Prometheus→Grafana; pins loki 3.3.2 /
vector 0.44.0 / prometheus v3.1.0 / grafana 11.4.0) + **nourish #39** (adopts heiberg-logging via
compose additional_contexts, configure_observability, central LOG_LEVEL replacing MEAL_API_LOG_LEVEL,
uvicorn --no-access-log) both **MERGED** (obs develop @03176b8, nourish develop @814c0d1; feature
branches cleaned). Root submodule pointer bump **+ planning-doc updates** (implementation-status.md new Observability
section/row/header + Nourish note; implementation-roadmap.md shared-infra Phase 4.6 node + section)
→ **root PR #146 OPEN** (chore/bump-observability-pointer).
Dev-only hygiene (docker-socket, anon-admin Grafana, no-auth Loki/Prom, service-label cardinality)
explicitly deferred to Phase 5.
Root pointer #146 MERGED (+ planning-status/roadmap docs updated: Observability section + Phase 4.6 node).
**Phase 3 plan** WRITTEN (scoped to CORE fan-out) → `docs/plans/2026-07-03-observability-phase-3-backend-fanout.md`,
**root PR #147 OPEN**. 5 tasks: fan heiberg-logging + configure_observability into forge/stay-api/
aide(+worker via configure_logging)/portal-api (Nourish pattern), audit() at portal-api Paystack
grant/revoke (webhooks.py ~L117/~L231), + 4 Prometheus scrape jobs. Grounded in an exact per-backend
map (app-construction lines, Dockerfile/compose, additional_contexts paths). **Phase 3b (deferred):**
SQLAlchemy slow-query helper + comprehensive job logging + broader audit().
Phase 3 plan #147 MERGED; #148 marks Phase 3 in-progress in status/roadmap.
**Phase 3 (core fan-out) EXECUTED** subagent-driven (background; per-task + opus whole-branch review),
all 5 tasks + verified E2E live (each backend service=<slug> logs→Loki, heiberg_<slug>_* metrics,
all 5 Prometheus targets up incl. nourish). **5 PRs OPEN:** forge #27, stay #9, aide #7,
heiberg-idp #27, observability #2. Final review = READY TO MERGE (no code blockers).
DISCOVERY (flagged): **aide-worker had NEVER started in dev** (Dockerfile omitted worker_main.py →
ModuleNotFoundError each boot; Phase 5 background-agent processing never exercised via compose) —
fixed in aide #7 commit ac5b1e1 (**Jako confirmed 2026-07-03: KEEP ac5b1e1 in aide #7 as-is**, do NOT split). Benign doc-note bug: plan ~L495 claims worker import doesn't run
configure_observability, but module-level app=create_app() means it does (harmless; decouple → 3b).
5 PRs MERGED + cleaned up. **Root reconcile = PR #150 OPEN** (chore/observability-phase-3-reconcile):
bumped 6 submodule pointers — forge/stay/aide/IdP/observability (Phase 3) + **nourish** (Phase 2
catch-up: nourish #39 pointer was MISSED in root #146 because nourish was wrongly treated as a
non-submodule — it IS one, see [[submodule-structure]]); flipped status/roadmap Phase 3 → ✅;
corrected the plan-doc aide-worker note. Left heiberg-systems-website + test-journeys drift for a
separate reconcile.
Reconcile #150 + CLAUDE.md/header-docs #151 both MERGED. **Observability Phases 0–3 fully DONE + docs
current.** All submodule pointers bumped & in-sync EXCEPT two UNRELATED (deliberately left):
heiberg-systems-website (root 5 behind) + test-journeys (diverged) — need a separate non-observability
reconcile (Jako aware).
**Phase 3b SPLIT into 3b-library + 3b-2-per-app.** **3b-library plan** WRITTEN → `docs/plans/
2026-07-03-observability-phase-3b-library-helpers.md`, **root PR #153 OPEN**. 4 tasks in the
heiberg-logging package (bumps 0.1.0→0.2.0): (1) optional `component` field (api/worker), (2)
`instrument_sqlalchemy(engine, slow_ms=500)` — slow-query + error logging, STATEMENT-ONLY/no params
(POPIA), async-engine aware, lazy sqlalchemy import (dev-extra dep only), (3) `log_job`/`log_job_async`
(job.started/completed/failed). Unit-tested, zero infra like Phase 0-1.
3b-library plan #153 MERGED. **Phase 3b-library EXECUTED** subagent-driven (background; per-task + opus
whole-branch review), all 4 tasks → **heiberg-logging 0.2.0** → **observability PR #3 OPEN** (6 commits).
Adds: `component` field (api/worker); `instrument_sqlalchemy(engine, slow_ms=500)` (db.slow_query +
db.error, statement-only/no params, async-engine aware, lazy sqlalchemy import); `log_job`/`log_job_async`.
34 tests. **Review CAUGHT+FIXED a CRITICAL POPIA leak** (db.error originally logged str(exc) which
Postgres/asyncpg embeds literal values into via DETAIL clause — now logs error_type+statement only,
regression-tested). Minors deferred: target="postgres" hardcoded, conftest cache-freeze comment,
no import-without-sqlalchemy test, component untyped.
observability #3 + pointer #155 + Phase 3b-2 plan #156 ALL MERGED (branches cleaned).
**Phase 3b-2 plan** = `docs/plans/2026-07-03-observability-phase-3b-2-per-app-wiring.md`. 5 tasks
(per backend): instrument_sqlalchemy on forge/stay-api/portal-api/aide(app+lazy-engine worker),
log_job_async around forge/stay/nourish/aide jobs, component=worker + register_builtins create_app()
decouple in aide worker. KEY MAP FINDINGS: **nourish uses raw psycopg2 (NO SQLAlchemy)** → job logging
only, DB slow-query needs separate psycopg2 mechanism (deferred); portal-api no jobs; aide engine is
LAZY (_engine, instrument after init_models). DB_SLOW_MS env = tunable threshold + verification knob.
Broader audit() deferred.
**Phase 3b-2 EXECUTED** subagent-driven (background; per-task + opus reviews + opus cross-repo final
review), all 5 tasks, each verified live via docker-log greps (db.slow_query service=<app>, job.*,
component=worker, /metrics, 0.2.0 in-container). **5 PRs OPEN → develop:** forge #28, stay #10,
heiberg-idp #28, nourish #40, aide #8. Final review = READY TO MERGE (cross-repo coherence ✅ on all
7 checks; no Critical/blocking). KEY IMPLEMENTATION FACTS discovered: (a) plan's `DB_SLOW_MS=0 docker
compose up` was a NO-OP — shell env doesn't reach the container without a compose mapping; added
`DB_SLOW_MS: ${DB_SLOW_MS:-500}` to forge/stay/portal-api/aide+aide-worker `environment:` (default-
preserving; nourish n/a). (b) aide decouple: new `backend/builtins.py` has ZERO module-level imports
(unconditional); engine via inline `from backend.db import _engine` AFTER init_models (avoids None-
capture). (c) nourish run_pipeline binds week_number+account_id only, NEVER caller_sub (POPIA).
**DEFERRED → one shared Phase-3b follow-up = FILED observability#4:** job.failed-narrowing trio
(stay.tally_delivery / nourish.pipeline / aide.agent_run all have a pre-existing internal try/except
that swallows the op error, so job.failed is narrow/unreachable — make it fire on domain-failure);
aide idle-poll (move aide.agent_run wrap PAST the empty-queue claim guard + bind run_id, else ~86k
no-op job pairs/worker/day); M5 repoint test_agent_worker.py import backend.main→backend.builtins.
5 PRs MERGED (forge#28→5475526, stay#10→637c8d6, heiberg-idp#28→2cba224, nourish#40→097f506,
aide#8→7e4c3af); submodule feature branches cleaned, all back on develop. **Root pointer-bump +
doc reconcile = root PR #157 OPEN** (commit 2e58e60): bumped 5 pointers + reconciled implementation-
status.md (obs summary + 3b-library & 3b-2 merged rows) + implementation-roadmap.md (Phase 3b ◐,
mermaid P3b node, changelog). Plan-doc checkboxes deliberately NOT flipped (matches phase-3/3b-library
convention — completion tracked in status/roadmap only). personal-website untouched (pre-existing drift).
**Phase 3b-2 FULLY DONE + reconciled** (root #157 MERGED; root develop @6b10a31; all submodules on
develop, SDD scratch cleared). **OPEN observability follow-up issues:** #4 EXECUTED (see below); **#5 (broader `audit()`)** — DECOMPOSED
(too big: 5 apps × 2 event classes). **Slice 1 = entitlement-gate DENY EXECUTED** subagent-driven
(brainstorm→plan→SDD, per-task + opus final review): `audit("access.denied", app, subject=<kc sub>,
reason, required_role, method, path)` (identifier-only/POPIA, deny-only, `stream="audit"`) emitted before
the existing role/subscription 403/402 at each central gate — **forge #29 / stay #12 / nourish #43 OPEN**
(aide=service-key + portal-api=granter → NOT gated, excluded). No library change (audit() already exists).
GOTCHA (found+fixed+propagated): `request: Request | None = None` CRASHES FastAPI 0.139.0 at import
(special Request-injection matches only a BARE `Request`, not a union) → use `request: Request = None`.
**3 code PRs MERGED; root reconcile = root PR #162 OPEN** (chore/observability-5-slice1-pointers, commit
e80d956: 3 pointers forge baa81f0 / stay 96c2875 / nourish dc4455f + plan doc + roadmap slice-1-done as
a checklist w/ slice 2/3 open). Submodule feature branches deleted, all on develop; SDD scratch cleared.
**#5 STAYS OPEN** (commented) — remaining slices = admin/privileged-action audit (slice 2) + cross-
account/IDOR-authz denials (slice 3), later specs. **#6 (nourish psycopg2-layer DB slow-query — likely a
shared `instrument_psycopg2` helper)** still remains. RESUME: after Jako merges #162 → root `git checkout
develop && git pull` + delete chore branch (trivial final sync). Plan: docs/plans/2026-07-05-observability-
5-audit-access-denied.md. (NOTE: nourish submodule has pre-existing untracked week28 PDFs — legacy meal-
plan outputs, unrelated, do not commit.)

**observability#4 EXECUTED** subagent-driven (brainstorm→plan→SDD; per-task + opus final review), 4 tasks.
Design decisions (via AskUserQuestion): (a) swallow-and-continue jobs signal failure via a LIBRARY
`.fail()` handle — `heiberg-logging` 0.3.0: `log_job`/`log_job_async` yield a `_JobHandle`; `job.fail(exc)`
→ logs `job.failed` (error_type/error_message/duration_ms, same timer) on clean exit WITHOUT re-raising
(loop/scheduler stays alive); propagating exception still wins + re-raises; ignoring the handle = old
behaviour (backward-compat, 34→38 tests). (b) aide pause path = job.completed (no distinct event).
Wired into stay.tally_delivery + nourish.pipeline (caller_sub stays unbound, POPIA) + aide.agent_run
(also: empty-queue guard moved OUTSIDE the wrap → idle worker emits NO job.* — was ~86k no-op pairs/day;
run_id bound; test import repoint backend.main→backend.builtins). **4 PRs OPEN: observability #7
(prerequisite) + stay #11 + nourish #41 + aide #9.** Final review READY-TO-MERGE. CROSS-REPO GATE:
consumers must resolve heiberg-logging >=0.3.0 (else job.fail()→AttributeError in the swallow handler);
closed by an ATOMIC root pointer bump. CONTROLLER FIX: __init__.__version__ was hardcoded 0.2.0 (plan
only bumped pyproject) → fixed to 0.3.0 (commit 0eca317). **4 code PRs MERGED; observability#4 CLOSED.**
Root reconcile = **root PR #159 OPEN** (chore/observability-4-pointers, commit 8690bda): ATOMIC bump of all
4 submodule pointers (observability 920c1a8 / stay 6e16f73 / nourish 012b1a1 / aide fe0c4a1) + plan doc +
roadmap Phase-3b #4-done tick. Submodule feature branches deleted, all on develop; SDD scratch cleared.
RESUME: after Jako merges #159 → root `git checkout develop && git pull` + delete chore branch (trivial
final sync). Remaining obs: #5 broader audit() + #6 nourish psycopg2 slow-query, then Phase 4/5/6. Then Phase 4 (JS logger + CF Logpush) / 5 (central k3s host) / 6
(alerting).
Dev stack + all backends left running (Grafana localhost:3001). NOTE (unrelated): root working
tree has IdP/heiberg-systems-website/test-journeys submodules checked out AHEAD of their recorded
pointers — pre-existing drift, needs a separate pointer-bump, NOT part of #144.
Remaining phases: 3=backend fan-out, 4=frontend JS logger + CF Logpush, 5=central k3s host +
shipping, 6=alerting. See [[project_platform_pwa_tally_standard]] for the parallel per-app standards.

**2026-07-06 (Phase 4a EXECUTED): frontend structured logging** — brainstorm→design→plan (root #174 MERGED)
→ SDD (5 tasks, per-task reviews + opus Task-4 & whole-branch reviews = Ready-to-merge, no Critical/Important;
**LIVE E2E PROVEN**). **PRs OPEN: observability #10** (`@heiberg/logging` package) **+ nourish #49** (reference).
Built `@heiberg/logging` (heiberg-logging-js, `observability/packages/`): Workers-safe TS logger mirroring the
Python field set (createLogger/.child/requestId/serializeError; 16-key redaction BYTE-FOR-BYTE parity w/ Python
`_SENSITIVE_KEYS`; LOG_LEVEL global knob; console JSON captured by CF Workers `[observability]`). Nourish
reference: `src/lib/backend.ts` `backendFetch` (single choke point → forwards X-Request-ID + logs outbound
`backend.call`/`backend.call_failed`, POPIA no-body) + middleware seeds/propagates X-Request-ID + ALL 35 proxy
routes migrated (DRY win). jest 297/297 @ 100% cov; live verify: frontend request_id=ac66631c matched the
nourish-backend log for the same request (Python RequestContextMiddleware read the forwarded header). KEY
DISTRIBUTION FINDING (design §5 was wrong): npm can't git-subdir-install; raw-TS `file:` symlink does NOT
resolve under Next16 **Turbopack** (the real build:cf) though jest+webpack do → FIX = ship the package as
**committed compiled ESM `dist/`** + **`.npmrc install-links=true`** in each consuming frontend (real copy, not
symlink, because Turbopack can't resolve a symlink across the submodule boundary). build:cf now passes E2E.
**ROLLOUT NOTE for Phase 4b (forge + stay-admin/guest/discover): each needs the same `.npmrc install-links=true`
line + `npm install` when the package's committed `dist/` changes; add a dist drift-guard (prepare script / CI
`git diff --exit-code dist/`).** Roadmap Phase 4 ◐ (PR #175 MERGED). **obs #10 + nourish #49 MERGED; root pointer bump = root PR #177 OPEN**
(chore/observability-phase4a-pointer, commit 775d85d: observability b0408b9→b2950e1 + nourish a67eabf→53b2652
+ design §5 as-built correction + roadmap 4a-done + status note; only those 2 pointers staged; IdP/websites dirty
CONTENT left untouched). RESUME after Jako merges #177 → root `git checkout develop && git pull` + `git submodule
update --remote observability nourish` + delete chore branch. THEN observability Phase 4a CLOSED → **Phase 4b**
(fan out @heiberg/logging to forge + stay-admin/guest/discover — EACH needs `.npmrc install-links=true` + a
`npm install` when the committed `dist/` changes; add a dist drift-guard) / **Phase 5** (central k3s obs host +
per-env agents + the ACTUAL CF Logpush→central-Vector shipping, still deferred + needs deployed Workers) /
**Phase 6** (alerting). Reusable `@heiberg/logging` package pattern is proven; 4b is mechanical per-frontend.

**2026-07-06: observability#5 slices 2 & 3 DESIGNED + PLANNED** (brainstorm→design→writing-plans;
grounded in a fresh 5-backend source map via parallel Explore agents). **Docs PR = root #165 OPEN**
(branch docs/observability-5-admin-authz-audit): design `docs/designs/2026-07-06-observability-5-admin-
authz-audit-design.md` + 2 plans `docs/plans/2026-07-06-observability-5-slice-2-admin-action.md` &
`...-slice-3-authz-denied.md`. KEY FINDING: the 2 slices land on DIFFERENT apps (admin surface vs
clean cross-account-deny signal are not co-located). DECISIONS (via AskUserQuestion): (1) scope to
where the signal is — **Slice 2 (admin.action, success-audit) = stay-api + portal-api**; **Slice 3
(authz.denied, deny-audit) = nourish + aide + stay-api + portal-api**; **forge in NEITHER** (no admin
tier, zero explicit 403s — all ownership is silent-404 WHERE-scoping). (2) curated sensitive subset
for admin actions (financial/entitlement/membership/destructive/provisioning, NOT routine CRUD). (3)
**explicit denials only** for slice 3 (silent WHERE-scoped 404s can't tell "not yours" from "absent"
without invasive probes) → this ALSO excluded portal `remove_member` (its 404 is WHERE-scoped; design
§7.4 corrected). (4) identifiers-only per POPIA + a `heiberg-logging` `_SENSITIVE_KEYS` backstop
(+name/person_name/phone/phone_number, patch bump 0.3.0→0.3.1, slice-2 Task 1, no ordering gate).
3 events: `access.denied` (slice1, extended to portal `_require_admin` reason=not_account_admin),
`admin.action` (new, after-commit), `authz.denied` (new, before-raise, SPLIT-GUARD so it fires only
on real ownership mismatch not a genuine not-found). aide adds caller_app field. GOTCHAs baked into
plans: bare `request: Request` (no union) for FastAPI-injected params; slice-2/slice-3 SHARE files in
stay (bookings/rooms/images) + portal (invitations) → cut slice-3 branch AFTER slice-2 merges / rebase,
don't dup the audit import. Design §10 FLAGS real IDOR gaps found while mapping (nourish weeks_views/
get_image cross-account reads, forge create_workout_log unverified FKs, portal products?sub= leak) as
SEPARATE issues — NOT folded into audit PRs (asked Jako; left in doc for now). Plans are per-app-branch
TDD (`feature/observability-5-admin-action` / `-authz-denied` per repo), NOT executed by merging #165.
RESUME after #165 review: EXECUTE the 2 plans subagent-driven (slice-2 first: 3 tasks obs+stay+IdP;
then slice-3: 4 tasks nourish+aide+stay+IdP) → 7 app PRs, then root pointer-bump + roadmap slice-2/3
tick. #6 (nourish psycopg2 slow-query) still remains after.

**2026-07-06 (later): SLICE 2 EXECUTED subagent-driven** (SDD: 3 fresh implementers + per-task sonnet
reviews + opus cross-repo final review = "Ready to merge, no Critical/Important"). **3 PRs OPEN:
observability #9** (heiberg-logging 0.3.1 PII redactor backstop, +name/person_name/phone/phone_number;
collision grep zero-hit so `name` included; 39/39) **+ stay #13** (6 curated admin.action: booking.updated/
review.invited/tally_income.toggled/property.domain_provisioned[only on domain change]/room.deleted/
image.deleted; 87/87) **+ heiberg-idp #30** (portal account/membership admin.action ×5 + admin-gate
`access.denied reason=not_account_admin` via bare request threaded into 3 handlers; 161/161). Bases:
obs 1c05bee→519f322, stay 96c2875→bf7068d, IdP 586dab9→ed9912b. **PLAN DEFECT found+fixed by BOTH stay
& portal implementers independently (real bug): autouse `_configure_logging` fixture is INVISIBLE to
capsys** (structlog StreamHandler binds the setup-phase stdout buffer; call-phase readouterr never reads
it → StopIteration) → WORKING pattern = `configure_logging()` INLINE at top of each test body (per
slice-1 tests / test_webhook_audit.py). Also: JSON-line test helpers must SKIP non-JSON stdout lines
(pre-existing `[EMAIL]`/`[WHATSAPP]` dev-stub prints crash json.loads). **Both fixes now baked into the
slice-3 plan Global Constraints (committed to #165).** RESUME: after obs#9/stay#13/idp#30 merge → root
pointer bump (3 submodules) + roadmap slice-2 tick.

**2026-07-06 (later still): SLICE 3 half-EXECUTED.** nourish + aide (the two repos with NO slice-2 file
overlap) done subagent-driven (per-task sonnet reviews, both Approved) → **PRs nourish #45 + aide #10 OPEN**.
authz.denied deny-audit before the explicit ownership 403/404s: nourish 11 roster/household sites via DRY
`audit_authz_denied` helper in auth.py (POPIA: attempted person_name NEVER bound; 443 suite/100% cov);
aide cross-app/cross-user sites (conversations/profile/agents×6-via-_check_app/documents), SPLIT-GUARD so a
genuine not-found emits NO authz.denied (dedicated negative tests; 227 suite). Bases nourish 4d8a51b→787785c,
aide fe0c4a1→cd28918. authz.denied schema coherent across both (aide adds caller_app per §7.2). **Slice-3
stay+portal (Tasks 3-4) HELD** — they share the `from heiberg_logging import audit` line with slice-2's
stay/IdP branches → cutting before slice-2 merges = guaranteed import conflict. **BLOCKED ON JAKO merging
slice-2 PRs (obs#9/stay#13/idp#30) — external, no auto-notify.** RESUME once stay#13+idp#30 merge: pull
develop in stay+IdP, cut feature/observability-5-authz-denied, SDD Tasks 3-4 (stay guest+cross-property /
portal accept_invitation only — remove_member EXCLUDED), slice-3 FINAL whole-branch review across all 4,
open 2 PRs. Then 2 root pointer-bump PRs (slice-2 = 3 submodules + roadmap; slice-3 = 4 submodules + roadmap).
NB: portal remove_member dropped from slice 3 (WHERE-scoped 404). SDD ledger = root `.superpowers/sdd/progress.md`.

**2026-07-06 (final): SLICE 2 MERGED + SLICE 3 FULLY EXECUTED.** Jako merged slice-2 (obs#9/stay#13/idp#30).
Slice-3 all 4 tasks done subagent-driven (per-task sonnet reviews all Approved + opus final whole-branch
review across 4 repos = "Ready to merge, no Critical/Important"). **4 slice-3 PRs OPEN: nourish #45, aide #10,
stay #14, heiberg-idp #31** (stay+portal cut from post-slice-2 develop: stay 2287826→bffbba2, IdP 279d545→
3c764b7; 9 stay split-guards + portal accept_invitation only). Design §4.3 reason enum reconciled
(cross_account RETIRED with remove_member; nourish uses `not_in_account`; helpers omit method/path) → committed
to docs #165. Final-review minors (non-blocking, Loki-alerting awareness): nourish ai_targets authz.denied is
WHERE-scoped so fires on non-existent names too (design-sanctioned per §3 no-probes); aide foreign_app vs
foreign_document disambiguated by resource_type. **ALL APP WORK FOR BOTH SLICES DONE.** REMAINING (blocked on
Jako): merge 4 slice-3 PRs + docs #165 → then ONE COMBINED root pointer bump (observability + nourish + aide +
stay + IdP → final develop HEADs) + roadmap/status ticks for BOTH slices (deferred slice-2-only bump into this
to avoid double-bumping stay/IdP). After that: observability #6 (nourish psycopg2 slow-query) remains, then
Phase 4/5/6. Full SDD ledger + both final-review reports in root `.superpowers/sdd/`.

**2026-07-06 (CLOSED): observability #5 DONE — all slice-3 PRs + docs #165 MERGED, COMBINED root pointer bump
= root PR #166 OPEN** (chore/observability-5-pointers, commit 9f01a73): bumps 5 submodules to final post-both-
slices develop HEADs (observability b0408b9 / stay 92f5965 / IdP 3e60b8d / nourish ca31565 / aide 622237b) +
roadmap/status slice-2&3 ticks (roadmap #5 checklist all [x]; status "broader audit() now fully done"). Bases
were still at pre-slice-2 (IdP 586dab9 / stay 96c2875 / obs 1c05bee / nourish 4d8a51b / aide fe0c4a1) — root
pointer had NOT been bumped for slice 1 either? No—slice-1 bump was #162; these 5 bases = slice-1-merged state.
DELIBERATELY left heiberg-systems-website + personal-website pointer drift UNSTAGED (unrelated, needs separate
reconcile — Jako aware). observability #5 (broader audit, all 3 slices) COMPLETE pending #166 merge. RESUME:
after Jako merges #166 → root `git checkout develop && git pull` + `git submodule update --remote` + delete
chore branch (trivial sync). NEXT observability backlog: **#6 nourish psycopg2-layer slow-query** (likely a
shared `instrument_psycopg2` helper), then Phase 4 (JS logger + CF Logpush) / 5 (central k3s host) / 6 (alerting).

**2026-07-06 (FINAL): observability #6 EXECUTED — but PIVOTED from `instrument_psycopg2` to a full nourish
psycopg2→SQLAlchemy Core MIGRATION** (Jako's call: nourish was the platform's ONLY psycopg2/sync backend;
the other 4 use SQLAlchemy async + were instrumented in 3b-2 — so migrate for uniformity, which closes #6
for free via the EXISTING `instrument_sqlalchemy`, NO heiberg-logging change). KEY INSIGHT: `Connection.
exec_driver_sql(sql, params)` runs the raw psycopg2 cursor under the engine → fires the events
instrument_sqlalchemy hooks AND preserves `%s`/tuple + `%(name)s` dict + `ANY(%s::uuid[])` list→array
adaptation + `%%`-LIKE (SQLAlchemy `text()` would BREAK array/`%%` — so exec_driver_sql ONLY, never text()).
Design+plan (root docs, PR #167 MERGED). Executed subagent-driven (4 tasks, per-task reviews all Approved +
Task-2 opus review + opus whole-branch review = Ready-to-merge no Critical/Important): T1 engine
(create_engine URL.create postgresql+psycopg2, QueuePool+pool_pre_ping) + instrument_sqlalchemy(slow_ms=
DB_SLOW_MS) + execute_query/execute_many over exec_driver_sql (params-None→single-arg protects literal-%;
returns [dict(r) for r in result.mappings()]); T2 get_db_connection→engine.begin() + ALL 14 direct-cursor
sites→exec_driver_sql (RealDictCursor→.mappings(), .rowcount→CursorResult.rowcount, multi-stmt atomic blocks
preserved, commit-then-raise 422 paths preserved); T3 weeks.delete_week 3 blocking PG calls→asyncio.to_thread
(+added module-level import asyncio — plan wrongly said it existed); T4 DB_SLOW_MS compose mapping. SEAM
PRESERVED (execute_query/get_db_connection/execute_many names+sigs+dict-return) → 112 call sites + 21
execute_query-mock test files UNTOUCHED; only test_db.py + ~5 get_db_connection-mock files changed. 446
passed/100% gated cov. **LIVE dev smoke PASSED** (DB_SLOW_MS=0 → db.slow_query service=nourish/target=
postgres, parameterized/no bound values). Whole-branch review cleared 3 cross-task hazards: no
`except psycopg2.*` catches (DBAPIError-wrapping safe), no bare-list params (exec_driver_sql rejects; all
callers pass tuple/dict), no shared/nested Connection. Bonus: nourish now POOLED (was fresh-connect-per-query;
QueuePool 5+10, design-approved). nourish PR #47 MERGED. **Root pointer bump = root PR #168 OPEN** (chore/observability-6-pointer, commit c535e5b:
nourish ca31565→2ce6789 + roadmap/status #6 leads/notes + a #6 changelog.md entry in both sections; ONLY nourish
staged). GOTCHA on the pointer bump: nourish develop ff-aborted on an untracked `app/frontend/src/app/auth/signin/
page.tsx` (a frontend page an incoming non-obs commit adds tracked; verified IDENTICAL to develop's copy → safe,
backed up in scratch) — moved it aside to ff. **RESUME after Jako merges #168: root `git checkout develop && git
pull` + `git submodule update --remote nourish` + delete chore branch (trivial sync).** THEN observability #6
CLOSED → whole audit+instrumentation backlog (#1-#6) DONE; remaining = Phase 4 (JS logger + CF Logpush) / 5
(central k3s host) / 6 (alerting). **PRE-EXISTING POINTER DRIFT (needs a separate NON-obs reconcile, Jako aware):
root records IdP=3e60b8d but IdP develop=86f2229 (ahead); + heiberg-systems-website + personal-website drift —
all deliberately LEFT UNSTAGED in #168.** SDD ledger + final-review reports in root `.superpowers/sdd/` (scratch);
nourish local venv/scratch cleaned.

**2026-07-06 (Phase 4b EXECUTED): frontend logging fan-out to the 4 remaining Next-on-Workers frontends**
— brainstorm-decisions→plan (`docs/plans/2026-07-06-observability-phase4b-frontend-fanout.md`)→SDD (4 impl
tasks, fresh sonnet implementers + per-task sonnet reviews all "spec ✅/approved" + opus whole-branch review
over BOTH branches = **both READY TO MERGE, no Critical/Important**). Fanned `@heiberg/logging` (the Phase-4a
package) into forge + stay-admin + stay-guest + stay-discover, each = `.npmrc install-links=true` +
compiled-`dist` `file:` dep (depth: forge `../../../`, stay apps `../../`) + `logger.ts` + wrangler
`logpush`/`[observability]`/`LOG_LEVEL` trio + `transpilePackages`. Per-app: **forge** = `backendFetch`
(target forge-backend) + ALL 8 `api/proxy/**` routes migrated, NO middleware change (matcher excludes /api →
per-call minted rid), no test runner (verify tsc+build:cf); empty-`Bearer ""`→omitted (strict improvement).
**stay-admin** = 2 routes + `opts.headers` pass-through forwarding existing `X-Stay-Property-Id` + middleware
rid-seed (auth gate/matcher kept) + vitest. **stay-guest** = 3 UNAUTH routes (no token) + NEW seed-only
`middleware.ts` (plain non-auth seed, NOT proxy.ts) + vitest; POPIA critical (booking/verify PII). **stay-discover**
= MINIMAL (no routes/mw/Request): `directoryFetch` wraps the 2 public `lib/api.ts` fetches to log backend.call/
_failed, `[]`/`null`-on-failure contract preserved. BUILD SCRIPT: all stay apps use `build:worker` (NOT
`build:cf` — nourish/forge use build:cf); all green. Controller folded in the one opus/task-review Minor (stay-
admin+stay-guest success-path test titled "logs backend.call" didn't assert the log emission → added console.log
spy + event/target/method/path/status_code asserts, mirroring stay-discover's already-shipped pattern; 2/2 green
each) → stay commit 7fd453a. **PRs OPEN: forge #30** (baa81f0→ad8b9d7) **+ stay #15** (92f5965→7fd453a, 4
commits: admin b15e6df / guest 7a097b1 / discover 20fed96 / test-nit 7fd453a). Roadmap Phase 4 node still ◐
(4a done); 4b to be ticked in the pointer-bump. **RESUME after Jako merges #30 + #15: pull forge+stay develop,
branch off ROOT `develop` (NOT the leftover `docs/dev-tunnel-mobile-access` branch the root is currently on) →
bump forge+stay pointers + roadmap/status 4b-done + include the plan doc → root PR.** THEN Phase 4 (frontend
logging) fully DONE across all 5 frontends; remaining obs = Phase 5 (central k3s host + ACTUAL CF Logpush→Vector
shipping, needs deployed Workers) / Phase 6 (alerting). BENIGN pre-existing state left untouched: forge working
tree has an untracked root-owned `.next-stale-root-owned/` (needs `sudo rm`, outside the PR); nourish shows only
a regenerated `next-env.d.ts`; IdP/heiberg-systems-website/personal-website content/pointer drift still awaits a
separate non-obs reconcile. SDD ledger + review packages in root `.superpowers/sdd/`.
**POINTER BUMP DONE — root PR #178 OPEN** (chore/observability-phase4b-pointer, commit c617aba): forge
baa81f0→c693ef9 + stay 92f5965→4ec5202 + the Phase 4b plan doc + roadmap/status/changelog 4b-done
(roadmap OBS node `P4 frontend ✅`; Phase-4 frontend section ✅; Logpush reassigned to Phase 5 in status
§Observability). ONLY those 2 pointers + 4 docs staged; IdP/heiberg-systems-website/nourish/personal-website
content drift + forge's untracked `.next-stale-root-owned/` deliberately left unstaged. A pre-commit hook
refreshed a roadmap mermaid link (folded into the commit). Root was on the leftover `docs/dev-tunnel-mobile-
access` branch — bumped off `develop` as planned. **RESUME after Jako merges #178: root `git checkout develop
&& git pull` + `git submodule update --remote forge stay` + delete the chore branch (trivial sync).** THEN
observability **Phase 4 (frontend logging) FULLY DONE across all 5 frontends**; remaining obs = **Phase 5**
(central single-node-k3s obs host + per-env Vector/Prometheus agents + the ACTUAL Cloudflare Logpush→central-
Vector shipping, needs deployed Workers) + **Phase 6** (alerting). STILL-PENDING non-obs reconcile (Jako aware):
IdP + heiberg-systems-website + personal-website pointer/content drift.

**2026-07-07 (Phase 5 DEFERRED — decision, no work done): observability Phase 5 (central obs host + per-env
agents + Logpush shipping) is BLOCKED on there being a real environment to observe.** Brainstorming exploration
found the platform is **dev-Compose-only**: roadmap Phase 2.5 (staging UpCloud VPS+k3s) and Phase 3 (prod UKS)
are BOTH `☐ not started`; there is **NO Terraform/Ansible anywhere in git history** (searched all refs — the root
`infrastructure/` dir exists only on the staging/production branches and is DOCS-ONLY: `.claude` + 3 design/plan
docs incl. `2026-05-27-infrastructure-consolidation`); UpCloud + Cloudflare accounts (External prerequisites) also
`☐`. So Phase 5 has nothing to ship from and no cluster/account to provision into. **Jako's decision (AskUserQuestion):
DEFER Phase 5 — provision the central obs host as PART OF the staging effort (roadmap Phase 2.5), not standalone
now.** (Rejected: author-IaC-now-gate-apply, and provision-host-now-for-real — both premature pre-staging.) Design
doc `docs/designs/2026-07-03-platform-observability-design.md` §4/§15 still describes Phase 5 correctly for when it
runs; the only new fact is the sequencing gate: **Phase 5 folds into Phase 2.5 (staging) — do NOT re-attempt it
standalone until staging is being stood up.** Observability code/instrumentation backlog (Phases 0–4, #1–#6) remains
DONE; the remaining obs phases (5 central host + shipping, 6 alerting) are now environment-gated.

**2026-07-17: GitHub issues #5 + #6 were still OPEN despite the work being done — CLOSED them.** A maintenance pass found observability #5 (broader audit) + #6 (nourish psycopg2 slow-query) open on GitHub even though both are code-complete/merged on develop (roadmap Phase 3b + status "no audit/instrumentation backlog remains" already said so). Verified on develop: #5 slice-2 (`admin.action`, commits 519f322/bf7068d/ed9912b) + slice-3 (`authz.denied` helpers+calls+tests in nourish/aide/stay/portal; forge & stay-property.py & portal-remove_member correctly WHERE-scoped-excluded) — tests green (aide 6, nourish 2, stay 156, portal 322). #6 done via nourish→SQLAlchemy-Core migration (nourish #47). Both issues closed with evidence comments. **NOTE:** a #6 sub-agent (mis-)built the optional `instrument_psycopg2` shared helper → observability **PR #12** (heiberg-logging 0.4.0, 47 tests) — it's SPECULATIVE future-proofing (no app uses raw psycopg2 anymore); Jako to decide merge-vs-close. Lesson: check planning-docs/develop state BEFORE dispatching "fix issue" agents — 2 of the 3 open issues were already done.
