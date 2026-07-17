---
name: project_aide_phase5
description: Aide Phase 5 (Agents) MERGED (aide #5) + root pointer/docs reconciliation PR #97 open; 2 CRITICAL worker bugs caught; deferred follow-ups; next=Phase 6 Nourish migration
metadata: 
  node_type: memory
  type: project
  originSessionId: de7fb8a0-6ff5-4cc2-a031-cff50adb287c
---

Aide **Phase 5 — Agents** (hosted autonomous runs + multi-agent orchestration) implemented 2026-06-26 via subagent-driven development from the 13-task TDD plan (`docs/plans/2026-06-23-aide-phase5-agents.md`). **aide PR #5 MERGED** (merge commit 442b42c) — 19 commits, **208 tests** (was 153). **Root pointer-bump + planning-doc reconciliation DONE: root PR #97 OPEN** (bumps aide 681e51e→442b42c; marks Phase 5 ✅ in roadmap+status). Built: versioned `AgentDefinition` ORM + CRUD, `run_agent_sync` loop (reuses Phase 2 `run_turn`/`resume_turn`), sync SSE + background `aide-worker` + Postgres `agent_run_queue`, Mongo `agent_run_events`, HMAC callable tools + completion webhooks, durable pause→resume, `invoke_agent` coordinator/sub-agent orchestration (`parent_run_id`, per-agent cost, same-app+allow-list boundary).

**Key gotcha — the plan predated Phase 2's implementation**, so its code assumed wrong engine interfaces. Reality (reconciled, see the branch): the conversation engine ALREADY writes `CostLedger` + resolves tier→model (`select_model`) + executes built-ins INLINE + injects the profile. So the runner records ONLY per-run totals (`record_run_cost`) — NO second ledger write (no double-count). `StreamEvent` is a closed union (`TextEvent`/`ToolCallEvent`/`UsageEvent`/`DoneEvent`); providers yield `UnifiedEvent` not `StreamEvent`. Tests seed a `ModelCatalog` row + monkeypatch `backend.conversations.engine.select_model`/`build_profile_block`.

**Whole-branch opus review caught 2 CRITICAL bugs the per-task reviews structurally couldn't see** (same "advertisement/wiring" class as [[project_aide_phase3]]/[[project_aide_phase4]]): C1 = `aide-worker` never registered built-in tools (registration was only in `create_app()`, which the worker never calls) → empty registry → every background tool-using run fails; C2 = `run_worker_loop` had no error isolation → first failing run crashes the worker. Both FIXED (`register_builtins()` shared + called by worker_main; failed-run drains queue + loop backstop) + 3 more (I2 enforce_budget on runs; M1 400-not-500 on invalid def; I3 dispatch ALL app tool calls per hop). Re-review: Ready to merge: Yes.

**DEFERRED follow-ups (documented in PR #5, non-blocking):**
- **I1**: durable pause/resume stores `resume_tool_results` but never feeds them back — resume re-runs from original input (a real agent would pause→resume→pause). Needs conversation-reuse redesign. NOT on critical path (first consumer = Nourish crews via callable endpoints + invoke_agent).
- `RunRequest.budget_cents` accepted but not plumbed into the selector (monthly enforce_budget IS active); orphan ephemeral conversations not GC'd; live OpenRouter agent smoke needs a real key.

**POST-MERGE reconciliation DONE (root PR #97, 2026-06-26):** root aide pointer bumped + roadmap/status marked **Phase 5 ✅ (5 of 6)** (the standard Phase 2/3/4 pattern). **Still remaining:** **Phase 6 = Nourish→Aide migration** is the next Aide workstream (in the `nourish` repo; also absorbs the deferred Nourish prompt/planner layer — see [[project_nourish_multitenant_purity]]); and `persistence/schemas/postgres/aide.sql` still owes the agent tables (`agents`/`agent_runs`/`agent_run_queue` + Mongo `agent_run_events`) — a separate root task.
