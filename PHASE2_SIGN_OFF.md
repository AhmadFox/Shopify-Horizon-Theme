# Phase 2 — Admin & production sign-off

Theme code for Lighthouse Phase 2 is largely complete on `horizon-enhance-lighthous`.  
These items need **Shopify Admin**, **Markets**, or a **production HTTPS** re-audit.

Store: `dkhount-partner-test.myshopify.com` (adjust if different)

---

## T-11 — Collection heading contrast (WCAG AA)

**Lighthouse failure:** low-contrast `<h4>` in a group-block on collection pages (e.g. `/collections/العطور`).

**Fix in Admin (not Liquid structure):**

1. Online Store → **Themes** → **Customize**
2. Open a collection template (e.g. العطور)
3. Select the heading / rich-text / collection title block that fails
4. Set **Text color** to a dark color (prefer Theme settings → Colors → **Foreground** `#272c45` or darker)
5. Ensure background is light enough for **≥ 4.5:1** contrast  
   Tip: [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
6. Save → re-run Lighthouse Accessibility on that collection URL

Theme helper: `collection-title` setting now shows contrast guidance in the editor (`t:info.collection_title_contrast`).

---

## T-18 — Production HTTPS Lighthouse re-audit

Local `theme dev` (HTTP) will always fail: HTTPS, CORS, bf-cache, TTFB, some cookies.

**Run on the published / preview HTTPS URL:**

```bash
# Example — replace THEME_ID / host
npx lighthouse "https://YOUR-STORE.myshopify.com/?preview_theme_id=THEME_ID" \
  --only-categories=performance,accessibility,best-practices \
  --form-factor=mobile --output=json \
  --output-path=../docs/lighthouse-reports/prod-home-mobile.json
```

Repeat for: `/`, `/collections`, one collection handle, one product, `/blogs/news`, privacy policy, cart, search.

Save JSON under `docs/lighthouse-reports/` (outside theme root).

**Pass criteria:** Performance / Accessibility / Best Practices → goal 100 (or document residual platform-only fails).

---

## T-20 — Shop Pay third-party cookies

| Finding | Action |
|---------|--------|
| Lighthouse flags `shop.app` / Shop Pay cookies | Usually **platform**, not theme-fixable |
| Dev HTTP worsens cookie / mixed-content noise | Ignore on local; verify on HTTPS |
| Optional | Theme settings → disable accelerated checkout on pages where not needed (trade-off) |

**Status:** Document as platform limitation unless merchant disables Shop Pay / accelerated checkout.

---

## T-21 — `Unsupported locale: "ar"` (shop-js)

| Finding | Action |
|---------|--------|
| Console: `Unsupported locale: "ar"` from Shopify shop-js | Shopify account / Shop Pay i18n gap |
| Theme already has `locales/ar.json` + RTL | Theme side OK |
| Admin check | Settings → Languages: Arabic published; Markets include SA |

**Status:** Monitor Shopify changelog; not fixable by theme Liquid alone. Does not block storefront Arabic strings from `ar.json`.

---

## T-22 — Publish generic CMS page

1. Admin → **Online Store** → **Pages** → **Add page**
2. Title e.g. `About` / `من نحن`
3. Theme template: **page** (`page.json`)
4. **Save** + visible on storefront
5. Lighthouse that URL (mobile + desktop)

---

## T-23 — Publish contact page

1. Pages → Add page → template **page.contact** (`page.contact.json`)
2. Handle ideally `contact` → `/pages/contact`
3. Save → Lighthouse `/pages/contact`

---

## T-24 — Publish blog article

1. **Online Store** → **Blog posts** → Create post in `news` (or default blog)
2. Add title, body, featured image
3. Publish → Lighthouse `/blogs/news/HANDLE` (article template)

---

## T-25 — Cart + search regression matrix

| URL | Checks |
|-----|--------|
| `/cart` | Layout RTL/LTR, quantity, discounts, empty state Arabic |
| `/search?q=test` | Results grid, filters, keyboard, no console errors |
| Cart drawer (header) | Open/close, add from product, Esc + focus return |
| Search modal / predictive | Arabic results, lazy images |

Add both to final Lighthouse pass after T-18.

---

## Sign-off checklist

- [ ] T-11 contrast fixed in theme editor + A11y audit green on collection
- [ ] T-18 prod HTTPS reports saved under `docs/lighthouse-reports/`
- [ ] T-20 Shop Pay documented / accepted
- [ ] T-21 Arabic Markets verified; shop-js warning noted as platform
- [ ] T-22 page published
- [ ] T-23 contact published
- [ ] T-24 article published
- [ ] T-25 cart + search manually tested + Lighthouse
- [ ] Merge `horizon-enhance-lighthous` → `main` only after above
