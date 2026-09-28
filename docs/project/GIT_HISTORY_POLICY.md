# Git History and Branch Hygiene

Merge settings verified 2026-09-27 with `gh api repos/davisbuilds/agentmonitor-ios`.
Query GitHub again before relying on current remote settings.

## Repository Merge Settings

Configured on GitHub repository `davisbuilds/agentmonitor-ios`:

- `allow_squash_merge`: `false`
- `allow_merge_commit`: `true`
- `allow_rebase_merge`: `true`
- `delete_branch_on_merge`: `true`
- `merge_commit_title`: `PR_TITLE`
- `merge_commit_message`: `PR_BODY`

Result:

- PR branches retain their full commit history when merged.
- `main` receives either a merge commit (preserving the PR boundary) or rebased commits (linear history), depending on which strategy the merger picks for that PR.
- Squash merging is disabled — full per-commit history is preserved.
- Merged remote branches are auto-deleted.

## Merge Strategy

Merge commits and rebase merges are both allowed; squash merges are disabled. This
is this repository's standing merge policy.

- **Default — merge commit.** Preserves the PR as a discoverable boundary in `main`'s history. Best when the PR contains multiple meaningful commits worth keeping addressable individually.
- **Rebase merge.** Use when the PR's commits are clean and the linear history reads better without an extra merge node. Avoid if the PR's commits are noisy (WIP, fixups) — clean them up locally first.
- **Authoring expectation.** Because squash is gone, individual PR commits land in `main`. Keep PR commit messages tidy: meaningful subjects, no WIP markers, no fixup chains. Squash or reword locally before opening the PR if needed. Attribute actual contributors accurately.

## CI Gates

The publication-hygiene workflow does not build or test the app. Build and test
gates run locally via `xcodebuild` against the iOS Simulator.

Quality gates before merge (also the pre-push expectation locally):

- `xcodebuild build -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- `xcodebuild test  -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`

## Branch Protection Status

Query `gh api repos/davisbuilds/agentmonitor-ios/branches/main/protection` for
effective branch rules before relying on them. Local build and test expectations
remain relevant regardless of remote enforcement.

## Recommended Ongoing Hygiene

1. Create short-lived feature branches from `main` (`feat/*`, `fix/*`, `docs/*`, `chore/*`).
2. Open PRs early; keep them focused on one intent.
3. Tidy your PR commit history *before* merging — reword/squash locally so what lands on `main` reads cleanly.
4. Pick **Create a merge commit** by default; pick **Rebase and merge** when linear history is materially better.
5. Periodically prune local branches:

```bash
git fetch --prune
git branch --merged main | grep -v ' main$' | xargs -n 1 git branch -d
```
