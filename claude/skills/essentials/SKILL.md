---
name: essentials
description: The minimal but non-negotiable pieces every site must ship, scaled to its type and feel (landing, portfolio, blog, docs, SaaS app, store). Use before calling any website or web app done, or when planning one.
---

# Essentials

Ship what the site needs and nothing it doesn't. A portfolio needs no cookie banner. A store can't skip legal pages.

## Every site

- `<title>`, a meta description, a canonical URL and `lang` on `<html>`.
- A favicon set: SVG icon, 32 px PNG, 180 px Apple touch icon, plus `theme-color` matched to the design.
- An Open Graph image at 1200×630, designed rather than a screenshot.
- A designed 404 page with one way home. Errors have a voice too.
- `robots.txt` and `sitemap.xml`.
- Responsive layouts from 360 px to 2560 px, with no horizontal scroll.
- Visible keyboard focus, alt text, AA contrast and reduced motion respected.
- HTTPS, plus security headers: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`, `Referrer-Policy`.
- A Lighthouse score of 100 on performance, accessibility and SEO, or a written reason why not.

## By type

| Type | Also ship | Skip |
|---|---|---|
| Landing | one clear action above the fold, privacy-friendly analytics (Plausible or Umami), a contact route | feature grids of icon cards |
| Portfolio | work with real images and outcomes, an about page, contact, fast image delivery | blogs nobody updates |
| Blog | RSS, reading time only if long, article JSON-LD, a good print stylesheet | comment widgets by default |
| Docs | search, a sidebar, prev/next links, copy buttons on code, an edit-on-GitHub link, versioning | marketing hero |
| SaaS app | auth flows (sign in, sign up, reset), empty, loading and error states, settings, privacy and terms | landing-page flourishes inside the app |
| Store | product JSON-LD, clear prices and taxes, returns, privacy, terms and a cookie notice where the law requires it, accessible checkout | dark patterns, fake urgency |

### Code blocks and scrollbars

Every docs page, and any page with code, ships these. They're easy to get wrong, so check them in a render with a long line scrolled sideways.

- Put the copy button on a wrapper around `<pre>`, never inside the scrolling `<pre>`. Inside, it scrolls away with the code and lands on top of the text.
- Pin the button to the top-right corner of the wrapper. Give it a solid backing and a short fade on its left edge, so code that scrolls beneath it disappears cleanly. Show it on hover and focus, and always on touch screens. It says "Copied" for about 1.5 seconds.
- Copy `pre.innerText`, never text that includes the button's own label.
- Scrollbars are slim: 6 px, a rounded thumb, a transparent track, no arrow buttons, and brighter on hover. Use `::-webkit-scrollbar` for Chromium and Safari, with `scrollbar-width: thin` as the fallback inside `@supports not selector(::-webkit-scrollbar)`. Setting `scrollbar-width` everywhere makes Chromium ignore the custom style and draw the default bar with arrows.

## Matched to the feel

- **Luxury and editorial:** fewer pages, larger images, longer load budgets for photography with blurred placeholders, no chat widgets.
- **Playful and seasonal:** the creative layer from atelier's `references/motion.md`, removable with one flag.
- **Tool and utility:** keyboard shortcuts, instant search, remembered state, a dark mode that's tuned, not inverted.

## Before launch

Click every link, submit every form, load on a slow 4G profile, read every page aloud once, and check the OG card in a link preview.
