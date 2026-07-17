---
name: project_aide_phase3
description: "Aide Phase 3 (shared user profile) MERGED + closed (aide#3 + root pointer/doc PR #92); next=Phase 4 RAG"
metadata: 
  node_type: memory
  type: project
  originSessionId: d252abc5-825c-4383-82a4-569ea1ded208
---

Aide **Phase 3 — shared user profile** implemented + **MERGED** 2026-06-26 (aide#3, all 11 plan tasks, TDD). Root submodule pointer-bump + planning-doc reconciliation **merged** (root PR #92) — root `develop` carries `aide` @ develop@56f79f4; Phase 3 flipped ✅ in implementation-status + roadmap. Plan: root `docs/plans/2026-06-23-aide-phase3-user-profile.md`.

Shipped in `aide/app/backend/`: `profile/store.py` (consent-gated, visibility-scoped fact store — `has_consent`/`set_consent`/`upsert_fact`/`get_visible_facts`/`delete_fact`/`erase_profile`/`forget_fact`, every mutation writes a `profile_audit` row), `profile/injection.py:build_profile_block`, ORM `user_profiles`/`user_facts`/`profile_audit` in `models/db_models.py`, `tools/remember.py` + `tools/forget.py` built-ins, `gateway/profile.py` REST (GET/POST/DELETE facts + profile + consent, every endpoint enforces `sub == caller.user` → 403), and `run_turn` profile-block injection in `conversations/engine.py`. Tests: 34 Phase-3, **full repo suite 118 passed**.

Key adaptations to real Phase 2 code (plan flagged as seams): injection test uses real `UnifiedEvent(kind=...)` provider stub (not `StreamEvent`) and asserts profile text in *any* system message (context_blocks become a separate system msg after `conversation.system`); `remember`/`forget`/profile-router registered in `create_app()` not a startup hook (main.py uses `lifespan`); `app_client` conftest fixture now `AIDE_KEYS=nourish:secret,forge:secret` for cross-app scoping tests.

Tests: 34 Phase-3 + 4 review-driven = full repo suite **122 passed**.

**Review folded in (2026-06-26):** background code-review verified all 5 security invariants hold in code. Found + fixed **HIGH** — `remember`/`forget` were registered but missing from `_BUILTIN_NAMES` in `gateway/conversations.py`, so the model was never offered them (auto-capture unreachable via conversation flow; only REST `POST /facts` worked); now in `_BUILTIN_NAMES`. Plus 2 LOW nits (400 instead of 500 on malformed profile-endpoint body; audit-retention comment on `erase_profile`). Commits 41b44d9 + 38834de pushed to aide#3.

**Why:** Continues the Aide build (see [[project_aide_phase2]]). Security-sensitive (POPIA, consent, cross-app isolation, cross-user access control), so a background review was run on the diff — prior phases' reviews each caught real bugs before merge (this one caught the dead-built-in HIGH).

**How to apply / RESUME:** (1) aide#3 + root #92 both merged; Phase 3 fully closed. (2) Still pending from Phase 2: **manual real-provider tool-call smoke** + **4E account migration** not yet run. (3) Migrating profile tables to the shared cluster (`persistence/schemas/postgres/aide.sql`) is a separate root-Phase-2 task. (4) Next build phase: **Phase 4 (RAG)** — pgvector + embeddings + document ingestion + `rag_retrieve` built-in; RAG context blocks flow into `run_turn(context_blocks=...)` exactly like the profile block does now. Then Phase 5 (agents), Phase 6 (Nourish migration). See [[project_aide_phase2]].
