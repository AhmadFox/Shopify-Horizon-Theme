# Dkhoun customizations vs vanilla Horizon

Baseline: **Horizon 4.1.1** (`horizon-upstream/4.1.1` = [Shopify/horizon](https://github.com/Shopify/horizon) `main`).

Regenerate this report anytime:

```bash
./scripts/list-customizations.sh main upstream/main
```

## Summary (vs upstream 4.1.1)

| Tier | Count | Upgrade handling |
|------|-------|------------------|
| **New files** | 7 | Auto-copied by `apply-customizations.sh` |
| **Manifest hooks** | 10 | Auto-copied; re-test after each upgrade |
| **RTL / bulk edits** | 232 | Manual merge on upgrade branch |

## Tier 1 — New files (Dkhoun-only)

| File | Purpose |
|------|---------|
| `snippets/account-menu-translations.liquid` | Arabic/English strings for `<shopify-account>` popup |
| `snippets/account-menu-styles.liquid` | 50/50 Orders/Profile button grid in shadow DOM |
| `snippets/cart-tax-note.liquid` | Editable, hideable cart tax/shipping note |
| `snippets/empty-cart-heading.liquid` | Theme-editor empty cart title + perfume subtitle |
| `locales/ar.json` | Full Arabic storefront translations |
| `config/markets.json` | Market configuration |
| `.gitignore` | Repo hygiene |

## Tier 2 — Feature hooks (small, intentional edits)

| File | What changed |
|------|----------------|
| `layout/theme.liquid` | `dir="rtl"` for RTL locales; renders account + empty-cart snippets |
| `snippets/cart-summary.liquid` | Cart tax note snippet; discount/seller-note locale keys |
| `snippets/cart-drawer.liquid` | Empty cart heading snippet |
| `blocks/_cart-title.liquid` | Empty cart heading in cart page |
| `snippets/text.liquid` | Footer brand description from theme settings |
| `config/settings_schema.json` | Empty cart, tax note, footer brand EN/AR settings |
| `config/settings_data.json` | Default values (tax note hidden, Arabic copy) |
| `locales/en.default.json` | Matching locale keys for new settings |
| `locales/en.default.schema.json` | Theme editor labels for new settings |
| `sections/header-group.json` | Customer account menu block reference |

## Tier 3 — High conflict risk (manual merge)

These files differ from vanilla Horizon 4.1.1, mostly for **RTL layout**, **performance**, and **broad theme tuning**. The largest edits are typically:

- `assets/base.css` — RTL mirroring, account dialog, empty cart styles
- `sections/header.liquid` — header / mega menu RTL
- `snippets/header-actions.liquid`, `snippets/localization-form.liquid` — mirrored UI
- Many `blocks/`, `sections/`, and `templates/*.json` — structural or JSON template changes

List all Tier 3 paths:

```bash
./scripts/list-customizations.sh --tier3
```

## Design principle for future work

When adding features:

1. Prefer **new snippet + one-line render** in an existing file
2. Add strings to `locales/ar.json` and `en.default.json`
3. Add theme-editor settings only when merchants need to edit copy
4. Update `customizations/manifest.txt` if the file is new or becomes a stable hook

See [UPGRADE.md](./UPGRADE.md) for the full release workflow.
