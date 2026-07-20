# Shopify Horizon Theme

Enhanced fork of Shopify **Horizon** with production-ready **RTL (right-to-left)** support, performance tuning for **Lighthouse / Core Web Vitals**, and Dkhoun-specific customizations across **sections**, **blocks**, and **snippets**.

## Highlights

- **RTL storefront** — `dir="rtl"` for Arabic and other RTL locales; mirrored header, mega menu, mobile drawer, cart drawer, localization UI, and account popup
- **Localization** — Arabic locale coverage for cart, account menu, empty cart, footer brand copy, and theme-editor overrides
- **Performance** — Layout stability and rendering improvements aimed at better Lighthouse scores and Web Vitals (CLS, LCP-friendly patterns)
- **Custom theme assets** — Dedicated snippets and settings for cart tax note, empty cart messaging, account translations, and account menu layout
- **Horizon fixes** — Patches for known Horizon UX issues on RTL markets and customer account web component timing

## Theme structure

| Area | Examples |
|------|----------|
| **Sections** | `header.liquid`, `header-group.json`, cart and footer groups |
| **Blocks** | Cart title/summary, header menu, product cards |
| **Snippets** | `localization-form`, `cart-drawer`, `account-menu-translations`, `empty-cart-heading`, `cart-tax-note` |
| **Locales** | `ar.json`, `en.default.json`, and schema labels in `en.default.schema.json` |

## Requirements

- Shopify store with **Online Store 2.0**
- **Customer accounts** enabled (for `<shopify-account>` popup features)
- [Shopify CLI](https://shopify.dev/docs/api/shopify-cli) for local development

## Development

```bash
shopify theme dev --store your-store.myshopify.com
```

```bash
shopify theme check
```

## Auto-deploy (GitHub → Shopify)

The store is connected to this repo’s **`main`** branch via Shopify’s GitHub integration (`Shopify-Horizon-Theme/main`).

**Every push or merge to `main` automatically updates the connected theme.** No GitHub Actions needed.

```bash
# Release workflow
git checkout main
git merge feature/horizon-RTL-support
git push origin main   # → Shopify auto-syncs
```

- Publish the connected theme once in Admin → **Online Store** → **Themes** → **Publish** for live traffic.
- Develop on `feature/*` branches locally; only merge to `main` when ready to deploy.
- Full guide: [../docs/horizon/DEPLOY.md](../docs/horizon/DEPLOY.md)

## Branches

- `main` — stable release
- `feature/horizon-RTL-support` — RTL, localization, and performance work
- `horizon-upstream/X.Y.Z` — read-only mirror of vanilla [Shopify Horizon](https://github.com/Shopify/horizon)

## Upgrading Horizon

This repo uses a **manifest-based upgrade workflow** (not a direct git fork). When Shopify ships Horizon 4.2.0 or later:

```bash
./scripts/upgrade-horizon.sh 4.2.0 main
```

Documentation:

- [../docs/horizon/UPGRADE.md](../docs/horizon/UPGRADE.md) — step-by-step merge and release process
- [../docs/horizon/CUSTOMIZATIONS.md](../docs/horizon/CUSTOMIZATIONS.md) — what Dkhoun changed vs vanilla Horizon
- [customizations/manifest.txt](customizations/manifest.txt) — files auto-applied on upgrade

## License

Based on Shopify Horizon. Custom modifications © Dkhoun.
