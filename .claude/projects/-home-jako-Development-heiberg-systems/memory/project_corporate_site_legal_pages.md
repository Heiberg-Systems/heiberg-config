---
name: project-corporate-site-legal-pages
description: Corporate site /privacy + /terms shipped to develop for Meta/POPIA; first full release (develop→staging→prod) HELD 2026-06-26
metadata: 
  node_type: memory
  type: project
  originSessionId: 86f2948e-a400-4bc3-a417-a207ad1414a2
---

heiberg-systems-website (`heiberg.systems`) gained `/privacy` + `/terms` pages (LegalPage.jsx + Privacy.jsx + Terms.jsx, POPIA-aligned, discloses WhatsApp/Meta + SMS phone-number processing; responsible party "Heiberg Systems"; contact support@heiberg.systems). PR #16 merged to **develop**; root submodule pointer bumped via root PR #96 (both merged 2026-06-26). It IS a root **submodule** despite CLAUDE.md calling it a "separate repo".

**Key state:** the corporate site has **never been promoted out of develop**. staging + production both sit at the initial scaffold commit `cb95eb8` (2026-06-07); develop is the whole site — **72 commits ahead**. So promoting is the site's *first real release*, not just shipping the pages. Jako chose **Hold — don't promote yet** on 2026-06-26.

Deploy triggers: `deploy.yml` → push to `production`; `deploy-staging.yml` → push to `staging` (mock mode, .pages.dev, STAGING banner). Merging to develop deploys nothing.

**Why:** the legal pages exist to satisfy Meta/WhatsApp Business go-live (Meta requires a public Privacy Policy URL to leave Development mode) and POPIA — see [[project_org_migration]] context. GitHub org/repo visibility is irrelevant to Meta; what Meta needs public is a business website + privacy URL.

**How to apply:** to actually make `heiberg.systems/privacy` reachable for Meta, still required: (1) promote corporate site develop→staging→production (currently HELD), (2) configure the heiberg.systems custom domain/DNS on Cloudflare Pages (manual — `cloudflare-dns-setup.md`), (3) make support@heiberg.systems a routable mailbox. Webhooks (`/webhooks/whatsapp` in portal-api) are NOT needed for send-only OTP/invite launch — only for receiving.
