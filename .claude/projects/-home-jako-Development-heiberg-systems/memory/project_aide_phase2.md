---
name: project_aide_phase2
description: "Aide Phase 2 (conversations + client SDK + base tools) implemented; PR aide#2 open, residual gates before production"
metadata: 
  node_type: memory
  type: project
  originSessionId: 580bd227-57ef-4c19-9b9d-b668fffd27f4
---

Aide Phase 2 (conversations, streaming, turn engine, built-in tools, `aide_client` Python SDK + `@heiberg/aide-react` + Next.js template) implemented 2026-06-25 via subagent-driven development from `docs/plans/2026-06-23-aide-phase2-conversations-sdk-tools.md`.

- **MERGED:** `Heiberg-Systems/aide#2` merged into aide `develop` (merge commit `5145830`) 2026-06-26. Local feature branch deleted, develop synced. Tests at merge: backend 80 / python-client 6 / react 5. Builds on [[project_phase4_aide_phase1]].
- **Root pointer bump + planning docs: DONE** — `heiberg-systems#91` merged (root develop `2f809b6`); `aide` submodule pointer at `5145830` (consistent, no `+`). Same PR also reconciled the planning docs: flipped Aide Phase 2 → ✅ and swept other completed-but-unmarked work (Phase 4 IdP sub-phases 4A/4C/4D/4E bullets, Phase 2 infra bullets, IdP design row ❌→✅). Note: **Aide Phase 1's roadmap bullets had also been left unchecked** under a ✅ header — a recurring pattern worth checking on future merges. 4E migration script is merged but **not yet run** against any env (293/294 stay unchecked, confirmed by Jako).
- **Pre-approved plan corrections in the PR:** engine keeps `await select_model` (tests made async); added `get_provider()` → `get_providers()["openrouter"]` in `gateway/chat.py` (plan imported a non-existent symbol).
- **Security added beyond plan:** SSRF guard `backend/safety/ssrf.py` `assert_public_url` on `http_fetch` (HIGH finding) + `follow_redirects=False`.

**Gates before exposing conversations to a live provider (NOT done in this session):**
- Run the manual live smoke (Task 16 curl) — one real OpenRouter call that triggers `web_search`/`http_fetch` and a second hop. Phase-2 tests are all stub-based; real tool-call serialization (now `json.dumps`'d on persist) was never exercised against a live provider.
- DNS-rebinding TOCTOU in the SSRF guard is a known residual (mitigated by `follow_redirects=False`); pin resolved IP / custom transport for full coverage.
