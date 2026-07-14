# Auto-deploy: GitHub → Shopify

Your store is connected to **GitHub** via Shopify’s native integration:

| Setting | Value |
|---------|-------|
| Repository | `AhmadFox/Shopify-Horizon-Theme` |
| Branch | `main` |
| Theme name | `Shopify-Horizon-Theme/main` |

**No GitHub Actions required.** Shopify watches the connected branch and updates the theme automatically on every push.

Official docs: [Shopify GitHub integration for themes](https://shopify.dev/docs/storefronts/themes/tools/github)

---

## How auto-deploy works

```
feature branch  →  PR / merge  →  push to main  →  Shopify syncs theme  →  live storefront (if published)
```

1. You merge and push to `main` on GitHub.
2. Shopify pulls the latest commit into the connected theme.
3. The theme card **Last saved** timestamp updates (click **View logs** to confirm).
4. If this theme is **published**, visitors see the changes immediately.

---

## One-time: publish for live traffic

The connected theme must be **published** for `main` pushes to affect the live storefront.

1. Shopify Admin → **Online Store** → **Themes**
2. On `Shopify-Horizon-Theme/main`, click **⋯** → **Publish**

After publishing, every push to `main` updates the live theme automatically.

---

## Recommended workflow

### Daily development (no auto-deploy)

Work on a feature branch locally — **do not** connect feature branches to the live theme.

```bash
git checkout feature/horizon-RTL-support
shopify theme dev
# edit files, test at http://127.0.0.1:9292
shopify theme check
git add <files>
git commit -m "[rtl] header: fix mega menu mirroring"
git push origin feature/horizon-RTL-support
```

### Release to live (auto-deploy)

```bash
# On GitHub: open PR feature/horizon-RTL-support → main
# After review and tests pass, merge PR

# Or locally:
git checkout main
git pull origin main
git merge feature/horizon-RTL-support
git push origin main   # ← triggers Shopify auto-deploy
```

### Verify deploy

1. Admin → **Online Store** → **Themes**
2. On `Shopify-Horizon-Theme/main`, check **Last saved** matches your commit time
3. Click **View logs** if sync failed
4. Hard-refresh the storefront (or open incognito) to confirm changes

---

## Branches and Shopify connections

| Branch | Connect to Shopify? | Purpose |
|--------|---------------------|---------|
| `main` | **Yes** (already connected) | Production — auto-deploy on push |
| `feature/*` | No | Local dev with `shopify theme dev` |
| `upgrade/horizon-*` | No (optional preview theme) | Horizon version upgrades |
| `horizon-upstream/*` | Never | Read-only vanilla Horizon mirror |

Only connect `main` to the **published** theme. Connect a feature branch to a separate **unpublished** theme only when a client needs a preview URL.

---

## Two-way sync (important)

Shopify commits **back to GitHub** when you save changes in:

- Theme editor (Customize)
- Code editor
- Theme apps

Those commits appear on `main` as `shopify` bot. To keep Git as the source of truth:

- Prefer code changes in the repo, not the Shopify code editor
- Pull after any theme-editor session: `git pull origin main`
- Avoid editing the same file in Shopify admin and GitHub at the same time

### If theme and GitHub are out of sync

On the theme card: **Actions** → **Reset to last commit** (pulls latest `main` into Shopify).

### If a push was rejected by GitHub

Shopify may commit while you push. Resolve on GitHub, then push again or use **Reset to last commit**.

---

## Pre-push checklist

Before merging to `main`:

- [ ] `shopify theme check` — zero errors
- [ ] RTL + LTR visual check (Arabic locale)
- [ ] Account popup, cart drawer, header tested
- [ ] No secrets in committed files (`.env`, tokens)
- [ ] `customizations/manifest.txt` updated if new Dkhoun snippets were added

---

## Horizon upgrades + deploy

```bash
./scripts/upgrade-horizon.sh 4.2.0 main
# test on upgrade branch locally
# merge upgrade/horizon-4.2.0 → main via PR
git push origin main   # auto-deploys to Shopify
```

See [UPGRADE.md](./UPGRADE.md).

---

## Optional: GitHub branch protection

In GitHub → **Settings** → **Branches** → protect `main`:

- Require pull request before merging
- Require status checks (if you add CI later)

This prevents accidental direct pushes to `main` and therefore accidental live deploys.
