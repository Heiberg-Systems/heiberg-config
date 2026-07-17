---
name: ansible-17peppertree-sync
description: Monitor 17peppertree ansible changes to keep heiberg-systems provisioning plan current — check git log on ansible/ in 17peppertree at start of any ansible-related session
metadata: 
  node_type: memory
  type: project
  originSessionId: da581ead-7735-4831-ac3f-7cf69ff876eb
---

When working on `docs/plans/2026-06-12-ansible-provisioning.md`, always check for new commits on `ansible/` in the 17peppertree repo first:

```bash
cd /home/jako/Development/heiberg-systems/17peppertree
git log --oneline -10 -- ansible/
```

The 17peppertree ansible setup is the battle-tested reference implementation. Fixes there often reveal issues to pre-empt in the heiberg-systems plan.

**Why:** The user explicitly asked to keep tabs on 17peppertree ansible work to update the heiberg-systems provisioning plan.

**How to apply:** At the start of any session touching the ansible plan, run the git log command above and diff any recent commits before making changes.

## Current state (as of 2026-06-14, commit ecc4dea)

Key lessons already absorbed into `docs/plans/2026-06-12-ansible-provisioning.md`:

| Finding | Commit | Applied to plan |
|---|---|---|
| Encrypted vault file must be committed to git (not gitignored) — CI needs it | c7364b0 | ✅ Task 1 Step 7 |
| certbot HTTP-01 fails behind Cloudflare proxy → switch to DNS-01 (`certbot-dns-cloudflare`) | 4d56fe8 | ✅ Troubleshooting note (Caddy equivalent) |
| `StrictHostKeyChecking=accept-new` (TOFU) not `no` | 41592d7 | ✅ Already in plan |
| SSH key verification must run from control machine (`delegate_to: localhost`) | da1ff2d | ✅ Already in plan |
| `meta: flush_handlers` after security role to restart sshd immediately | 91c1493 | ✅ Already in plan |
| ansible-lint line-length rule applies to long URLs in task args | ecc4dea | ⚠️ Watch for this when writing tasks |
| Keycloak REST API realm creation does NOT assign `{realm}-realm` management roles to master admin — admin can't do write ops (user mgmt, password resets) via API | e588d05 | ✅ Troubleshooting note in plan (heiberg uses --import-realm so Ansible provision unaffected, but any future API automation will hit this) |
| Realm roles must be explicitly created and assigned — Keycloak does not auto-create app roles; users provisioned without roles get "Access Denied" on login | 6f4962b | ⚠️ Not applicable (heiberg realm JSON defines roles), but relevant if any future Ansible role bootstraps Keycloak for heiberg |
| Keycloak invalidates the admin token session after a management role assignment — subsequent API calls return 401; must re-fetch token before continuing | dcc1534 | ✅ Troubleshooting fix script updated to re-fetch token after role assignment |
| `/auth/callback` must be exempted from nginx basic auth — Keycloak OIDC redirect re-challenges mid-flow in private browsing, breaking PKCE exchange | 1226f69 | ⚠️ nginx staging-specific; not applicable (heiberg uses Caddy, no basic auth gate) — note if a staging environment is ever added |
| `/api/` must be exempted from nginx basic auth — Bearer-protected routes trigger browser popup loops on programmatic fetch calls | 0825411 | ⚠️ nginx staging-specific; same note as above |

## Files to watch in 17peppertree

- `ansible/roles/common/tasks/main.yml` — user/SSH setup patterns
- `ansible/roles/security/tasks/main.yml` + templates — hardening patterns
- `ansible/roles/docker/tasks/main.yml` — Docker install pattern
- `ansible/roles/certbot/tasks/main.yml` — TLS acquisition (proxy-aware)
- `ansible/requirements.yml` — collection versions
- `ansible/ansible.cfg` — inventory/vault config
