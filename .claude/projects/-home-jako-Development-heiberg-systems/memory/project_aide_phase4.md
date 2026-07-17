---
name: project_aide_phase4
description: "Aide Phase 4 (RAG) MERGED + closed (aide#4 + root #93) — ingestion API, rag_retrieve tool, pgvector; next=Phase 5 agents"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1ec08d68-c58c-46f5-8d3c-ccb9d2a81584
---

Aide Phase 4 — RAG — implemented 2026-06-26 via subagent-driven-development (per-task TDD + spec/quality review, final opus whole-branch review). Builds on [[project_aide_phase3]].

**MERGED + CLOSED:** aide#4 merged → aide `develop` @ `681e51e`; root submodule pointer/docs PR **#93 merged** → root `develop` @ `f188315` (bumped 56f79f4→681e51e + reconciled implementation-status/roadmap). Local develop synced, both feature branches deleted (per [[feedback_fast_pr_merges]]). 12 commits, 153 backend tests passing (baseline was 122), 0 warnings.

**What shipped:** `rag/` module (chunking, OpenRouter embeddings via `embed_texts` provider-agnostic seam, app-scoped cosine top-k retrieve, ingest_document orchestrator); `documents`/`chunks` ORM with a portable embedding column (pgvector `Vector(dim)` on Postgres, JSON on sqlite — tests rank in pure Python, no live pgvector); `init_models()` creates the `vector` extension on Postgres only; `POST/GET/DELETE /v1/documents` (app-scoped); `rag_retrieve` built-in tool with provenance.

**Final review (opus) caught 2 Important that per-task reviews structurally couldn't see — both fixed in commit 923a65f:**
1. `rag_retrieve` was registered but NOT in `gateway/conversations.py` `_BUILTIN_NAMES`, so it was never advertised to the model → unreachable through the live conversation API. **IDENTICAL class of bug to Phase 3's remember/forget gap.** Tool advertisement = there's one hardcoded `_BUILTIN_NAMES` list in conversations.py (tasks.py only passes app-supplied tools). Any new built-in must be added there or it's dead.
2. `ingest_document` silently truncated chunks if `embed_texts` returned fewer vectors than chunks (`zip`) → silent data loss. Now raises on count mismatch; `embed_texts` also guards a malformed 200 body.

**Plan bug found pre-flight (fixed during impl):** the plan's Task 3 `init_models()` snippet dropped `from backend.models import db_models` + `_get_maker()` (would crash — `_engine` None); merged the extension branch into the existing function instead. Reused existing `_uuid` helper (plan added a duplicate `_uuid_hex`).

**Manual pgvector smoke RUN 2026-06-26 — PASS** (commit bae877d). Real `pgvector/pgvector:pg18` Postgres: `CREATE EXTENSION` (vector 0.8.3), `chunks.embedding` is a real `vector` column (not JSON fallback), ingest→Vector(1536) INSERT→cosine retrieve→rag_retrieve tool→app-scoping→pgvector-native `<=>` all green. Driven with a deterministic 1536-dim stub embedder; the **live OpenRouter embeddings HTTP leg still pending** — no `OPENROUTER_API_KEY` in the root `.env` or env (root .env has ANTHROPIC_API_KEY only; Aide has no AIDE_KEYS set either). Embeddings transport is respx-covered in unit tests.

**Smoke surfaced + fixed 2 container bugs (bae877d) — the dev stack had NEVER booted before:** (1) `app/backend/Dockerfile` pinned a HARDCODED runtime-dep list that had drifted — missing `pgvector` (→ image would silently use the JSON column, defeating pgvector!), `motor` (crash on import), `httpx-sse`. (2) postgres 18 / pgvector:pg18 needs the volume mount at `/var/lib/postgresql`, not `/…/data`.

**Dockerfile then converted to install from pyproject (57633ad):** build context moved to the aide repo root (compose `context: ..` + `dockerfile: app/backend/Dockerfile`); deps derived from `pyproject [project].dependencies` via tomllib→requirements→pip (single source of truth, can't drift). Deps install before the source COPY (caching). Added `aide/.dockerignore` (context is now the repo root). `backend` package still COPY'd (not pip-installed) so `tiers.yaml` (loaded by `Path(__file__).parent.parent` in router/tiers.py) stays beside its module. Verified: clean build + boot + load_tiers() + full pgvector smoke all green.

**Deferred (plan-sanctioned, not defects):** embedding cost-ledger row; pgvector-native `ORDER BY embedding <=> :q` path (Python cosine used); `persistence/schemas/postgres/aide.sql` shared-cluster DDL (separate root task).

**RESUME:** Phase 4 fully closed. Remaining non-blocking follow-ups: run the **live OpenRouter embeddings HTTP leg** before live rollout (needs an `OPENROUTER_API_KEY`); add `documents`/`chunks` + pgvector to the shared-cluster `persistence/.../aide.sql` (separate root task). **Phase 5 (agents)** is next and consumes `rag_retrieve` through the same registry (plan: `docs/plans/2026-06-23-aide-phase5-agents.md`, 13 tasks). SDD ledger at `aide/.superpowers/sdd/progress.md` (gitignored).
