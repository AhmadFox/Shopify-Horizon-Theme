# Upgrading Shopify Horizon

This repo is **not a direct git fork** of [Shopify/horizon](https://github.com/Shopify/horizon). It was initialized separately, so `git merge upstream/main` reports **unrelated histories** and would create hundreds of false conflicts.

Use the **upstream tracking branch + manifest copy** workflow below instead.

## One-time setup (already done locally)

```bash
git remote add upstream https://github.com/Shopify/horizon.git
./scripts/horizon-upstream-fetch.sh 4.1.1
```

This creates `horizon-upstream/4.1.1`, a local branch that mirrors vanilla Horizon 4.1.1.

## When Shopify releases a new Horizon version (e.g. 4.2.0)

### 1. Fetch upstream

```bash
./scripts/horizon-upstream-fetch.sh 4.2.0
```

### 2. Create an upgrade branch from vanilla Horizon

```bash
./scripts/upgrade-horizon.sh 4.2.0 main
```

This will:

1. Create `upgrade/horizon-4.2.0` from Shopify’s release
2. Copy **Tier 1 + Tier 2** files from `main` (see `customizations/manifest.txt`)
3. Leave **Tier 3** RTL/performance edits for manual review

### 3. Merge Tier 3 changes manually

```bash
./scripts/list-customizations.sh --tier3
```

For each file, compare three versions:

```bash
# Your current custom version
git show main:assets/base.css | less

# New vanilla Horizon
git show horizon-upstream/4.2.0:assets/base.css | less

# Working copy on upgrade branch
code assets/base.css
```

Re-apply RTL and performance rules on top of upstream changes. Prefer keeping upstream structure and adding small Dkhoun hooks in snippets when possible.

### 4. Test and release

```bash
shopify theme dev --store your-store.myshopify.com
shopify theme check
```

When stable:

```bash
git add -A
git commit -m "Upgrade to Horizon 4.2.0 with Dkhoun customizations"
git push -u origin upgrade/horizon-4.2.0
gh pr create --base main --title "Upgrade Horizon to 4.2.0"
# After PR merge → push to main auto-deploys via Shopify GitHub integration
```

See [DEPLOY.md](./DEPLOY.md) for the production deploy workflow.

After merge, tag the release:

```bash
git tag v1.1.0-horizon-4.2.0
git push origin v1.1.0-horizon-4.2.0
```

## Branch model

| Branch | Purpose |
|--------|---------|
| `main` | Stable Dkhoun production theme |
| `feature/horizon-RTL-support` | Active RTL/localization work |
| `horizon-upstream/X.Y.Z` | Read-only mirror of vanilla Shopify Horizon |
| `upgrade/horizon-X.Y.Z` | Short-lived upgrade integration branch |

## Reducing future upgrade pain

1. **Add new behavior in new snippets** — e.g. `snippets/cart-tax-note.liquid`
2. **Minimize edits to core Horizon files** — especially `assets/base.css`, `sections/header.liquid`
3. **Document every core override** in `docs/CUSTOMIZATIONS.md`
4. **Update `customizations/manifest.txt`** when you add new Dkhoun-only files

## What not to do

- Do **not** run `git merge upstream/main --allow-unrelated-histories` on `main` — it flags ~240 add/add conflicts.
- Do **not** force-push `main` unless you intentionally re-root history (not needed with this workflow).

## GitHub settings (optional, in repo Settings)

- Protect `main`: require PR + passing checks before merge
- Enable “Allow squash merging” for clean upgrade PRs
- Add collaborators with write access only on feature/upgrade branches

These are configured in GitHub UI, not in theme code.
