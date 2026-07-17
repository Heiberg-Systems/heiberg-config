---
name: project_pwa_standard_rollout
description: "Mobile-first PWA standard — spec+plan+docs MERGED (root #115); Nourish reference retrofit (Part B) MERGED nourish #36 (2026-07-02); Forge deferred; greenfield apps inherit"
metadata: 
  node_type: memory
  type: project
  originSessionId: 0023beb6-75b9-48c1-9369-19ac091eda0b
---

Thread 1 of [[project_platform_pwa_tally_standard]] (the "every app like Heiway / installable PWA" directive), 2026-06-29.

**MERGED to develop (root #115)** — spec + plan + CLAUDE.md/design-system wiring. Planning-doc reconcile (status + roadmap + changelog) = **PR #116 OPEN**.
- Spec `docs/designs/2026-06-29-platform-pwa-mobile-first-standard.md` — installable-PWA contract (hand-rolled manifest + pass-through `sw.js` + `PwaRegister` + maskable icons; Serwist = documented per-app offline upgrade) + a mobile-first UX bar.
- **App-shell (§4.1), decided via visual mockups:** mobile = persistent **bottom tabs** (Meal Plans · Recipes · Shopping · Health, +More for >5) + **top-right account menu** (always SSO-auth, never login/register); desktop = left side-nav **collapsible to an icon rail**, state remembered (localStorage). No hamburger for primary nav.
- Plan `docs/plans/2026-06-29-platform-pwa-standard-rollout.md`; CLAUDE.md + design-system pointers wired.

**Scope decisions:** SaaS apps installable; marketing sites = UX-bar only. **Forge deferred** (bare-stub frontend). **Greenfield apps (Callout/Stay/Tally/Heiway) inherit** from birth.

**Part B DONE — MERGED nourish #36 (2026-07-02);** root #130 reconciled the planning docs + bumped the nourish pointer (`41e7550→68d761c`). Built exactly as planned via a background agent (283 tests / 100% cov; build clean; live Lighthouse/320px deferred → static equivalents passed). The build notes below proved accurate — keep for the next app's retrofit. Branch was `feature/installable-pwa-shell` off nourish develop. Plan Part B = 8 TDD tasks: PWA assets → PwaRegister → `src/lib/nav.ts` + `src/lib/navPref.ts` → `AppShell.tsx` → globals.css app-shell → layout/middleware wiring → verify+PR. Key gotcha: **Nourish enforces 100% coverage via an explicit allow-list** (`jest.config.js` `collectCoverageFrom`) — `src/lib/**` auto-gated; add `PwaRegister.tsx` to the list; `AppShell.tsx`/`layout.tsx` stay off-list (presentational, logic extracted to covered libs). Nourish frontend: `nourish/app/frontend`, jest+jsdom, `@/`→`src/`, server `layout.tsx` calls `auth()`/`signOut` from `@/lib/auth`.

Threads 2+3 (universal Tally cost-feed + Tally AI invoice import) still un-started.
