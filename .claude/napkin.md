# Napkin

## Mistakes & Corrections

### GITHUB_TOKEN cannot push workflow file changes
- `GITHUB_TOKEN` (the built-in Actions token) fundamentally cannot create or modify files under `.github/workflows/`. This is a GitHub security restriction, not a permissions misconfiguration.
- `workflows: write` is NOT a valid GitHub Actions permission key. Valid keys: `actions`, `attestations`, `checks`, `contents`, `deployments`, `discussions`, `id-token`, `issues`, `models`, `packages`, `pages`, `pull-requests`, `security-events`, `statuses`.
- The only fix is using a PAT (Personal Access Token) with `workflow` scope, stored as a repo secret.

### Fork sync workflow: upstream workflows cause CI noise
- When rebasing a fork on upstream, all of upstream's `.github/workflows/` files get pulled in.
- These upstream CI workflows (Quality checks, Android CI, etc.) run and fail on the fork because they expect upstream-specific configuration/secrets.
- Fix: after rebase, remove all upstream workflow files and keep only the fork's own workflows. Amend the top commit.

### jj revset syntax notes
- `main@upstream` is correct for referencing upstream remote bookmark (NOT `git_head(upstream/main)`)
- `@-5::@` is invalid; use `@---::@` with repeated `-` characters
- `jj git push` may fail with "stale info" after force-pushing; run `jj git fetch` first

## What Works

- `PAT_TOKEN` secret: created from user's `GH_TOKEN` env var (which has `repo` + `workflow` scope) via `printenv GH_TOKEN | gh secret set PAT_TOKEN`
- Sync workflow saves/restores our workflow files around the rebase to prevent upstream workflow leakage
- Tag creation via GitHub API (`gh api repos/.../git/refs`) triggers the release workflow correctly
- `JJ_CONFIG=/dev/null` prefix needed for clean diff output in non-interactive contexts
