---
name: feedback-fast-pr-merges
description: Jako reviews and merges PRs quickly; remote branches auto-delete on merge — fetch before pushing follow-up commits
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 041bd856-d05f-4c36-b0a8-6d2972710f9a
---

Jako merges PRs fast (often within minutes), and the GitHub org auto-deletes the head branch on merge.

**Why:** Twice in one session (persistence PR #7, then #8) a follow-up `git push` to the same feature branch printed `* [new branch]` because the branch had already been merged + deleted remotely — recreating an orphaned branch not attached to any open PR.

**How to apply:** Before pushing a follow-up commit to a feature branch, `git fetch origin --prune` and check whether the PR merged. If it did, branch the fix off the **updated** `develop` (cherry-pick the new commit), open a fresh PR, and delete the stray recreated branch. Don't assume a pushed branch still exists. Relevant to the multi-repo workflow in [[project-org-migration]] and [[project-infra-consolidation-phase2]].
