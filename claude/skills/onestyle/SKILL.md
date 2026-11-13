---
name: onestyle
description: The house style for every product Ritesh builds, taken from onestyle (Bespoke, riteshroshann/onestyle). Covers the look (white, ink, one sky spark, Google Sans, glass pill nav, springs), the flows (login frame, chat composer, pet in bubbles, halo reading), the voice, the stack (Supabase, email, Gemini with fallback, Vercel, GitHub Pages docs, MCP) and the questions to ask before building. Use when starting or designing any new product, site, web app, landing page, login page, docs site or about page, alongside atelier.
---

# Onestyle

Onestyle is how Ritesh's products look, read and ship. It is distilled from Bespoke (repo `riteshroshann/onestyle`, local checkout `~/Desktop/ta&bda`), a product that turns a garment described in English or Hinglish into a tailor sheet. Every new project starts from this, not from a blank page. **Atelier** sets the general craft bar; onestyle is the specific house taste, and where they disagree onestyle wins.

## The feel in one paragraph

Pure white page, ink `#0d1117` text, and one sky-blue spark (`#38bdf8`) used only for focus rings, selection and the logo mark. Black is the real accent. Enormous Google Sans headlines at weight 500, set tight. Almost no words. A floating glass pill nav, pill buttons that squash on press, and springy motion that rises from below. One full-bleed black band carries the "how it works". No boxes, badges, check-mark lists, emoji icons, stats or gradients. The one colourful moment is the halo while a picture is being read.

## How to use this skill

1. **Ask before building.** Run through "Questions to ask" below and ask only the ones the request leaves open, in one batch. Do not guess the ones marked *always ask*.
2. **Read the reference for the part you are building.** Each one is self-contained and has exact values, copy and code excerpts:
   - [references/look.md](references/look.md): tokens, type scale, motion springs, navbar, buttons, home, about page with the 3D lanyard, halo, third-party components, docs site look, dependencies. Read its "Brief vs code" section first.
   - [references/flows.md](references/flows.md): the login, signup and reset frame with every error string, the Talk composer and questions, the Ask helper, the board, the pet and its bubbles, the halo reading, sheet, shop, orders, loading and empty states, the voice rules and the product principles.
   - [references/stack.md](references/stack.md): runbooks for Supabase auth, email, model APIs with fallback, image generation, shop search, the MCP server, Vercel deploy, GitHub Pages docs, tests and performance.
3. **Look at the real thing when a detail is unclear.** The source is in `~/Desktop/ta&bda` (`web/` app, `site/` docs). Copy patterns, not product copy.
4. **Finish through essentials**, as for any site.

## The system at a glance

**Colour.** `#ffffff` ground, ink `#0d1117`. Greys are ink at 75, 60, 45 and 10 percent; never a new grey hex. `#f5f5f5` for quiet fills, `#b5121b` for destructive and recording. Sky `#38bdf8` only on focus (`outline: 3px solid rgba(56,189,248,.7)`, offset 2px), on selection (`rgba(56,189,248,.28)`) and in the mark. Light only.

**Type.** Google Sans through `next/font/google` (weights 400/500/700, `display: swap`, self-hosted at build). Headings 500. Display `clamp(56px, 9vw, 160px)`, line-height .92, tracking -0.03em. Ledes 17-20px at 60% ink, max 52ch. Tiny labels are uppercase only when tracked at 0.14em.

**Layout.** Max width 1440px, gutters 20px then 40px from `md`. Sections breathe at `clamp(64px, 9vw, 128px)`. The first screen holds a headline and one action, nothing else.

**Shape.** Pills `rounded-full` for buttons, inputs and nav. Menus 22px radius, inner rows 16px, big picture cards 36px, chat bubbles 20px with a 6px tail corner. Soft long shadows, no borders, no nesting.

**Motion.** The `motion` library (v14) with springs only: SPRING stiffness 420, damping 34 for UI; SOFT 160/24 for reveals. Things rise 10-16px as they enter, staggered 50-80ms. Headlines reveal line by line from a mask (y 105% to 0, 100ms stagger). Every press scales to .97. Active tabs slide with `layoutId`. All of it turns off under `prefers-reduced-motion`.

**Navigation.** A floating glass pill near the top: `bg-white/65`, `backdrop-blur-2xl`, saturate 1.8, a hairline ink/6% ring and a soft shadow. Logo left, links beside it. The docs site's active link is an ink pill that slides between links. Glass appears only on things that float.

## Signature pieces

Build these the onestyle way whenever a project has the equivalent. Details and code are in the references.

- **The login frame.** A split layout with a calm card, big pill fields that stay curved even when the browser autofills them, one show-password button, and a password meter. Every error is one plain sentence and a next step, for example "That email is already registered. Log in instead." Ask for sign-in only at the moment of need, give a one-sentence reason, and return the person to where they were with their draft intact. See flows.md section 1.
- **The composer.** The first screen of the app is the composer, with a cycling placeholder and voice input. The "How it works" sits below in the black band. Ask at most four questions, one at a time, each skippable. Never ask age or budget. See flows.md section 2.
- **Bubbles and the pet.** One helper per page. The board has a small pet that speaks only in bubbles and has no text box. Elsewhere, Ask sits in the corner and answers only from the product's own guides. See flows.md sections 3-4.
- **The halo.** While a picture is read, a conic-gradient aura (`#4285f4, #9b72cb, #d96570, #f2a93b, #2fa7a0`) turns around it full screen. It is the only colour in the product, so it means "thinking". See look.md "Halo and aura effects".
- **The about page lanyard.** The author's photo is printed on a 3D badge hanging from a lanyard you can drag. It uses plain three.js 0.186.1 with a hand-written verlet rope, canvas-painted card textures from `public/lanyard/`, an environment map built in code and a still fallback. The vision sits in the black band below it. See look.md "Lanyard".
- **Docs.** A plain HTML, CSS and JS site on GitHub Pages in the same face and palette, with sections for guide, developers, contributing and MCP, and a React Bits FolderFloat on the overview. See look.md "Docs site" and stack.md "Deploy docs".
- **Loading.** A dot-matrix loader and splash instead of spinners. Empty and error states get one warm sentence and a clear next step.

Third-party UI is always adapted to the palette and credited in `public/licenses.txt`: Cult UI (halo dropzone), React Bits (FolderFloat), the dot-matrix loader, shadcn primitives. Skiper UI pieces were tried and removed, and stay credited. Never ship unused libraries; Bespoke still lists `gsap`, `lenis` and `metal-fx` without using them.

## Voice

Sentence case everywhere. Buttons are one to four words and start with a verb ("Describe a garment", "Send to a maker"). Headings are short statements that end in a full stop ("Describe it. Wear it.", "Tailor sheet."). Write in the second person, plainly and warmly. Never use exclamation marks, "Oops" or emoji. Every error says what happened, then what to do. Say honestly what the technology did ("Read on this device"). Use the customer's words, not the engine's. The full rules and about 30 real strings are in flows.md section 7.

## Product principles

These come from the commit history; flows.md section 8 has the evidence.

- **Ask less, infer more.** Use few questions, and let the output absorb whatever is still open.
- **Names are correctness.** Fix the vocabulary once in one naming function, and route every surface through it.
- **Match what the outside world can do.** Short shop searches, no price filter, links that return results.
- **Say the true thing in the true place.** Show where each value came from, and say when a cloud model was unavailable.
- **Make the first screen almost nothing.** Revert experiments that fight the system.
- **Own your surfaces.** Clean URLs, metadata, a share image, a sitemap, the mark as favicon, security headers, tests for every flow, docs and an MCP server shipped with the product.

## Stack defaults

Next.js static export with React 19 and Tailwind 4, plus plain `api/*.js` serverless functions on Vercel. Supabase handles auth and data, with row-level security and a local fallback when no cloud is configured. Models are Gemini through its OpenAI-compatible endpoint, as an ordered fallback (flash-lite, then flash), 9 s per model inside a 20 s budget, per-IP rate limits, and keys only on the server. Images come from Gemini image models, falling back to Pollinations. Docs deploy to GitHub Pages through Actions. Unit tests are plain Node scripts and e2e tests use Playwright, with a black-box security suite and one command that runs everything. Follow **genesis** for the repo itself: add the `justfile` and CSP header that Bespoke lacks.

## Questions to ask

Ask these in one short batch before building. Skip any the request already answers.

- *Always ask:* **What is the product, in one sentence, and who is it for?** This becomes the headline and the meta description.
- *Always ask:* **Which email sender should auth use?** Bespoke's sender was set up in the Supabase dashboard and is not recorded anywhere. Default to Brevo SMTP (free tier, `smtp-relay.brevo.com:587`) and confirm the sending domain and the From name. stack.md "Set up Brevo email" has the steps and the dashboard checklist.
- *Always ask:* **Is there a photo or asset for the about page?** The lanyard needs a front and a back for the card.
- Does it need accounts at all, or can it run signed-out like Bespoke's studio, asking only at the moment of need?
- Which helper fits: an Ask corner, a pet in bubbles, or neither? There is one per page at most.
- Is there a picture-reading moment that earns the halo? If not, keep the product colourless.
- Does it need a docs site and an MCP server now, or later?
- Is there a custom domain for Vercel and for the docs?
- Is Hindi or Hinglish a first-class output, as in Bespoke?

When a choice is not covered here, recommend the onestyle answer and say why in one line. Do not offer a menu.
