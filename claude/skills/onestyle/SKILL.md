---
name: onestyle
description: The house kernel for every product Ritesh builds, any kind (SaaS, tool, marketplace, portfolio, landing page). A complete system for the look (white, ink, one spark accent, Google Sans, glass pill nav, springs), the premium login and signup kernel with every curve and sentence, page patterns (hero, black band, composer, helper bubbles, halo, 3D lanyard about page, docs site), voice, product principles, the stack (Supabase, Brevo, Gemini with fallback, Vercel, GitHub Pages, MCP) and the questions to ask first. Distilled from Bespoke (riteshroshann/onestyle). Use when starting, designing or polishing any product, page, login, docs or about page, alongside atelier.
---

# Onestyle

Onestyle is the kernel every new product starts from. It is a generalized system: tokens, components, page patterns, voice, principles and runbooks that fit any product. It was distilled from Bespoke (repo `riteshroshann/onestyle`, local `~/Desktop/ta&bda`), which appears only as the worked example. **Atelier** sets the general craft bar; onestyle is the house taste, and where they disagree onestyle wins.

## The feel

A product built on onestyle feels quiet, expensive and sure of itself:
- **Colour:** a white page with ink text. One spark colour, used only for focus, selection and the mark. Black is the real accent.
- **Type:** huge medium-weight headlines set tight, and almost no words.
- **Surfaces:** a floating glass pill for navigation, pill buttons that squash on press, white cards with long soft shadows instead of borders.
- **Motion:** springs that rise from below.
- **Rhythm:** one full-bleed black band explains how it works. Colour appears only when the product is thinking (the halo).
- **Never:** badges, check-mark lists, emoji icons, stats or decorative gradients.

## Kernel versus product

The kernel stays the same in every product: the ink scale, white ground, Google Sans, type scale, radii, shadows, springs, the press, glass only on floating things, the login kernel, the voice, the principles and the stack conventions.

Each product sets its own:
- the spark colour (sky `#38bdf8` by default)
- the wordmark and the mark
- the photographs (real, human and grayscale on dark panes)
- the greeting words
- which patterns it uses (a composer, a helper, the halo, a lanyard)
- whether there is a second audience with its own door

## How to use it

1. **Ask first.** Run through "Questions to ask" and ask what the request leaves open, in one batch.
2. **Lay the tokens down before any component.** [references/tokens.md](references/tokens.md) has a paste-ready `globals.css` token block and the `Motion.tsx` springs.
3. **Build the pieces you need from the references.** Each has exact values, steps and short code:
   - [references/login.md](references/login.md): **the login kernel.** It covers the split door and card, the field, autofill fixes, the password eye and meter, buttons, panes, errors and the shake, the reset page, the sign-in gate, the pro door and landing, safe redirects and every sentence. Build it exactly; it is the most polished surface and people judge the product by it.
   - [references/patterns.md](references/patterns.md): the navbar, buttons, inputs and cards, the hero, the black band, the footer, the composer, chat bubbles, the corner helper, the pet in bubbles, the halo, the dot-matrix loader, empty and error states, the 3D lanyard about page, the docs site, the third-party component policy, the mark and favicon, SEO surfaces.
   - [references/voice.md](references/voice.md): microcopy rules with real strings, and the product principles.
   - [references/stack.md](references/stack.md): runbooks for Supabase auth, Brevo email, model APIs with fallback, image generation, Vercel, GitHub Pages docs, the MCP server, tests and performance.
4. **Look at Bespoke when a detail is unclear.** The source is at `~/Desktop/ta&bda` (`web/` app, `site/` docs, `commits.txt` here for the reasoning). Copy patterns and values, never Bespoke's product copy.
5. **Finish through essentials,** and screenshot every page at 390px and 1440px before calling it done.

## The system at a glance

**Colour.** White ground, ink `#0d1117`. Greys are ink at 75, 60, 55, 45, 10 and 4 percent, never a new grey hex. Quiet fills are `#f5f5f5` and `#f4f5f7`; destructive is `#b5121b`. The spark appears only on focus (2px ring, 3px offset), selection (28%) and the mark, plus one good-news notice. Light only.

**Type.** Google Sans through `next/font/google` (400, 500, 700, self-hosted, `display: swap`), headings at 500. The `display` utility sets tracking -0.045em and line-height .95. The hero runs `clamp(56px, 9vw, 160px)` and pane headings `clamp(32px, 4vw, 46px)`. Ledes are 15-20px at 60% ink, max 52ch. Fields and body text never go below 16px on inputs.

**Layout.** Max width 1440px, gutters 20px then 40px. Sections run `clamp(64px, 9vw, 128px)`. The first screen is a headline and one action.

**Shape.** Pills for buttons (56px primary in forms, 48px elsewhere) and nav. Cards 32px, menus 22px, fields and inner rows 16px, bubbles 20px with a 6px tail corner. Edges come from a 5% ink ring plus `0 40px 90px -40px` ink at 35%, never a border.

**Motion.** `motion` v14 with springs only: SPRING 420/34 for UI, SOFT 160/24 for entrances. Things rise 10-24px, stagger 50-100ms and reveal headlines from a mask. Presses scale to .97. Panes swap through a 4px blur. Errors shake the card once. Everything respects reduced motion.

## Voice

Sentence case. Buttons are one to four words and start with a verb. Headings are short statements with a full stop. Write in the second person, plainly and warmly, with no exclamation marks, "Oops" or emoji. Every error says what happened and what to do. Say honestly what the machine did. While busy, buttons speak in the present tense ("One moment", "Sending"). voice.md has the full rules.

## Principles

- **Ask less, infer more.** Use few questions, each skippable, and let the output absorb the rest.
- **Names are correctness.** Fix vocabulary in one function, and route every surface through it.
- **Match what the outside world can do.** Never hand out a link that returns nothing.
- **Say the true thing in the true place,** even when it is "that email is already registered".
- **Make the first screen almost nothing.** Revert experiments that fight the system.
- **One helper per page,** small and honest.
- **Ask for an account only at the moment of need,** and bring the person straight back.
- **Own your surfaces:** clean URLs, metadata, share image, sitemap, the mark as favicon, security headers, tests for every flow, docs and an MCP server.

## Stack defaults

- **App:** Next.js static export, React 19 and Tailwind 4, with plain `api/*.js` functions on Vercel.
- **Data and auth:** Supabase with row-level security and a local fallback store that shares one rules file.
- **Email:** Brevo SMTP for auth email.
- **Models:** Gemini through its OpenAI-compatible endpoint as an ordered fallback, with a hard time budget, per-IP limits and keys only on the server.
- **Docs:** on GitHub Pages through Actions.
- **Tests:** Node unit scripts, Playwright e2e and a black-box security suite, all behind one command.
- **Repo:** follow **genesis** (justfile, CLAUDE.md, CSP header).

## Questions to ask

Ask in one short batch, and skip whatever the request already answers.

- *Always:* **What is the product in one sentence, and who is it for?** This becomes the hero line and the meta description.
- *Always:* **Is there one audience or two?** Two means two doors, two greetings and a pro landing.
- *Always:* **Which email sender and domain?** Default to Brevo SMTP (`smtp-relay.brevo.com:587`). Confirm the From name and verify the domain.
- *Always, if there is an about page:* **Which photo goes on the lanyard card,** front and back?
- Keep the sky spark, or another colour?
- Which photographs carry the doors and the black band?
- Can people use the product signed out, asking only at the moment of need? This is the default.
- Which helper fits the product (a corner Ask, a pet in bubbles, or none), and does any moment earn the halo?
- Docs site and MCP server now or later? Custom domains for the app and the docs?
- Any languages beyond English that are first-class outputs?

When something is not covered, recommend the onestyle answer in one line rather than offering a menu.
