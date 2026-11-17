# Tokens: the visual system

The look in one paragraph: pure white page, near-black ink, one small spark of colour, enormous medium-weight geometric sans headlines set tight, almost no copy, floating glass pill navigation, pill buttons that squash on press, springy motion that rises from below, and one full-bleed black band near the foot. No boxes, no badges, no decorative gradients.

This file is the system as values. patterns.md builds components from it, voice.md covers words. The worked example is Bespoke (`bespoke: web/app/globals.css`, `bespoke: web/components/site/Motion.tsx`). Where Bespoke's brief and its shipped code disagreed, the code values are used here because they are what was tested on screens.

## What changes per product, what never does

Change per product, and only these:

- The spark accent (one hue, used in the places listed under Colour). Bespoke uses sky `#38bdf8`.
- The ink hue if the product wants a warmer or cooler black. Keep it below lightness 12% so it still reads as black. Bespoke uses `#0d1117`.
- The display face, and only if the user asks. Default is Google Sans.
- The product name, mark and copy.

Never change: the white ground, ink-at-opacity greys, one family at weights 400 and 500, headline tracking and leading, the two springs, pill shapes on controls, glass only on floating things, black only as a full-bleed band or the primary button, one primary action per screen, no gradients except the thinking aura. A new product that breaks one of these has stopped being in the house style; fix the product, not the rule.

## Colour

Colour is roles, not a palette. Define each role once as a CSS variable, expose it to Tailwind through `@theme inline`, and never write a hex in a component except the few listed under "Fixed hexes".

| role | value | use |
|---|---|---|
| ground | `#ffffff` | the page, cards, popovers |
| ink | `#0d1117` | text, primary button fill, black band, favicon ground |
| ink hover | `#232c3b` | primary button hover (ink lifted about 8% lightness) |
| quiet fill | ink at 4% to 6% | inputs, tracks, hover wash, selected chip rest |
| quiet ground | `#f5f5f5` or `#f4f5f7` | a calm panel ground (auth right half, image stage, assistant bubble `#f2f3f5`) |
| destructive | `#b5121b` | errors, recording, delete. Soft form: fill `#fdf1f1`, text `#8a1c1c` |
| spark | `#38bdf8` | focus ring, text selection, logo mark strokes, one small moment per screen (a back-to-top arrow, a "changed" flash at 18%) |
| spark ink | `#0369a1` | spark-coloured text on a light tint, because the spark itself fails contrast as text |

The spark is allowed in: focus rings, selection, the mark, a one-off highlight on something that just changed, a tinted confirmation banner (`bg-spark/10` with spark-ink text). It is never a button fill, a heading colour, a link colour or a decoration. Ink is the real accent; the spark only tells you where you are.

### The grey scale is ink at opacity

There are no grey hexes. Write `text-ink/60`, `ring-ink/15`, `bg-ink/[.04]`.

| opacity | job |
|---|---|
| 75% | long body copy on a reading page |
| 60% | ledes, secondary body, footer link hover |
| 55% | field labels, footer column titles, notes under a title |
| 45% to 40% | hints, source lines, step numerals, thinking dots |
| 25% | underline decoration on text links (darkens to full on hover) |
| 15% to 10% | ghost button ring (hover 30%), hairlines between sections |
| 6% to 4% | segmented-control track, hover wash, input fill |

On a black band: text white, secondary `white/60`, numerals `white/40`, hairlines `border-white/15`.

Selection and focus:

```css
::selection { background: rgba(56,189,248,.28); }
:focus-visible { outline: 2px solid var(--ring); outline-offset: 3px; }
```

### Fixed hexes allowed outside the roles

Button hover ink, the quiet grounds above, the soft error fill, the thinking-aura gradient stops (patterns.md, Halo). Everything else is a role.

### Light only

There is no dark theme. Dark appears as a band or a navbar tone, never as a mode. If a product genuinely needs dark mode, flip ground and ink and keep the opacity scale; do not invent new greys.

## Type

One family, Google Sans, weights 400 and 500 in use (700 is loaded but unused; drop it for a new product). Hierarchy comes from size, weight and space, never from bold or capitals.

```tsx
// app/layout.tsx
import { Google_Sans } from "next/font/google";
const sans = Google_Sans({ subsets: ["latin"], weight: ["400", "500"], variable: "--font-ui", display: "swap" });
<html lang="en" className={sans.variable}>
```

`next/font/google` self-hosts at build, so there is no runtime font request. Fallback stack: `var(--font-ui), -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif`. Static docs sites without Next load Google Fonts CSS with preconnect to googleapis and gstatic and the fallback `ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif`. Mono for code: `ui-monospace, "SF Mono", "Cascadia Code", Consolas, monospace`.

The `display` utility is the headline style, always paired with a size:

```css
@utility display { font-weight: 500; letter-spacing: -0.045em; line-height: 0.95; }
```

### Scale

| element | size | notes |
|---|---|---|
| hero h1 | `clamp(56px,9vw,160px)` | lh `.92`, the page's one big line |
| page h1 (inner pages) | `clamp(52px,8.4vw,152px)` | lh `.92` |
| docs h1 | `clamp(52px,8.6vw,132px)` | |
| band h2 | `clamp(36px,4.6vw,64px)` | `max-w-[12ch]` |
| section h2 | `clamp(30px,3vw,44px)` | weight 500, lh 1.1, tracking -0.03em |
| lede | `clamp(18px,1.6vw,22px)` | lh 1.5, ink/60, `max-w-[56ch]`. App pages use `clamp(17px,1.4vw,20px)` at 52ch |
| reading body | `clamp(18px,1.5vw,21px)` | lh 1.6, ink/75 |
| quote | `clamp(20px,1.8vw,26px)` | lh 1.5, tracking -0.01em |
| card h3 | 24px | weight 500, tracking -0.02em |
| body | 16px | lh 1.55, ink/60 in cards |
| nav logo | 21px | weight 500, tracking -0.03em |
| nav link, button md | 15px | weight 500, button tracking -0.01em |
| button lg | 17px | |
| chat, small UI | 15px | lh 1.45 |
| label, hint | 12px to 14px | field label 13px |
| footer tag line | 28px, 34px from `md` | lh 1.15, tracking -0.025em |
| footer wordmark | `clamp(88px,25.2vw,386px)` | tracking -0.06em, lh .95, `whitespace-nowrap`, `aria-hidden` |

Uppercase tracked labels are nearly absent. If one is needed (a tiny slot tag), use 11px at 0.14em tracking and nothing larger.

Inputs are 16px minimum so iOS does not zoom on focus.

## Layout

- Max width `max-w-[1440px] mx-auto`. Gutters `px-5 md:px-10` (20px, then 40px from 768px). A docs site narrows to 1120px with 24px padding.
- First section under the fixed nav: `pb-24 pt-40 md:pb-32 md:pt-48`, action `mt-16 md:mt-24` under the h1.
- Section rhythm: content sections `py-24 md:py-32`; black band `py-[clamp(64px,9vw,128px)]` or `py-28 md:py-40`. A hairline `border-t border-ink/10` separates sections instead of a card.
- Editorial grid at `md`: 12 columns, heading `md:col-span-4`, body `md:col-span-7 md:col-start-6`.
- Breakpoints are Tailwind defaults (640, 768, 1024). Nav links `hidden sm:block`, so under 640px only the logo and one action remain.
- Footer grid `grid-cols-2 md:grid-cols-12`: tagline span 6, link columns span 3.
- Full-height pages use `min-h-[100svh]` (svh, not vh, so mobile browser chrome does not clip).

## Shape

Radius follows what the surface is. Controls are pills; containers step down in radius as they nest in size, and nothing is a sharp rectangle.

| surface | radius |
|---|---|
| buttons, chips, nav pill, search input, toggles | `rounded-full` |
| form fields beside buttons | 16px |
| menus and popovers | 22px |
| composer (large / compact) | 32px / 28px |
| help panel, docs panel | 28px |
| cards, docs cards | 24px |
| modal, auth card | 32px |
| picture stage, hero image card | 36px |
| code blocks | 20px |
| chat bubble | 20px, with 6px on the tail corner (26px and 8px for a large user bubble) |
| inline code | 8px |

Cards use a ring or a shadow, never a border, and are never nested. Marketing "cards" are open columns with a top hairline: `border-t border-ink/10 pt-6`.

## Shadows and rings

Long, soft, negative-spread shadows; a hairline ring does the edge.

| surface | value |
|---|---|
| nav pill | `shadow-[0_8px_32px_-12px_rgba(13,17,23,.18),inset_0_1px_0_rgba(255,255,255,.6)] ring-1 ring-black/[.06]` |
| menu, popover | `shadow-[0_24px_60px_-20px_rgba(13,17,23,.35)] ring-1 ring-black/[.06]` |
| card at rest | `0 0 0 1px rgba(13,17,23,.09)` |
| card hover | `0 0 0 1px rgba(13,17,23,.12), 0 24px 50px -28px rgba(13,17,23,.4)` |
| modal, auth card | `0 0 0 1px rgba(13,17,23,.05), 0 40px 90px -40px rgba(13,17,23,.35)` |
| picture card | `0 40px 90px -30px rgba(13,17,23,.55)` with `ring-1 ring-white/60` |
| field on focus | `0 8px 24px -14px rgba(13,17,23,.3)` with ring ink/20 |
| floating round button | `0 12px 40px -12px rgba(0,0,0,.6)` |
| speech bubble | `0 14px 40px -18px rgba(13,17,23,.35)` with ring black/[.05] |

## Motion

Library `motion` imported from `motion/react`. Two springs carry everything:

```ts
// components/site/Motion.tsx
export const SPRING = { type: "spring", stiffness: 420, damping: 34 } as const; // snappy: press, menus, chips, bubbles, layoutId slides
export const SOFT   = { type: "spring", stiffness: 160, damping: 24 } as const; // soft: headlines, sections, entrances, cards
```

Rules:

- Rise on enter: `initial {opacity 0, y 10-16}`, `animate {opacity 1, y 0}`, `transition {...SOFT, delay}`. Lede delay .15 to .3s. Siblings stagger 0.05 to 0.08s (`delay: i * 0.08`); list items 0.05 to 0.07s with SPRING.
- Scroll reveal runs once: `whileInView` with `viewport {once: true, margin: "-80px"}`, rise `y: 24` (bands `y: 14`, margin -60px).
- Mask reveal for the one big headline: each line sits in `overflow-hidden pb-[0.08em]` and its inner span slides from `y: "105%"` to 0 on SOFT, 100ms stagger per line (code in patterns.md, Hero).
- Press: scale .97 on every button and nav link, with focus ring.
- Slide: any selected-state fill that moves between options (segmented control, language switch, docs nav) is one element with a shared `layoutId` on SPRING. Never fade two separate fills.
- Menus: from `{opacity 0, y -6, scale .96}` to rest on SPRING, `transformOrigin` at the corner they open from; exit `{opacity 0, y -4, scale .97}`. Larger panels start `{y 24, scale .92, blur 6px}`.
- Chat bubbles pop from `{opacity 0, y 12, scale .96}` on SPRING.
- Word-by-word text (`Reveal`): each word `opacity 0 to 1` and `blur(4px) to 0`, 0.35s, delay `min(i*0.012, 1.2)`s. Skipped when `still`.
- Thinking dots (`Dots`): three 6px ink/45 dots, `y [0,-4,0]`, 0.9s, delay i*0.14s.
- Docs and static sites use CSS only: `.reveal` fades and rises 18px over .8s on `cubic-bezier(.32,.72,0,1)`, triggered once by IntersectionObserver with `rootMargin: 0 0 -60px`.
- Reduced motion: read `useReducedMotion()` in components (Reveal stops, halo freezes, back-to-top jumps, pet holds still, 3D breeze to 0 and no intro). CSS animations switch off in one `@media (prefers-reduced-motion: reduce)` block. Gap in Bespoke: the mask-reveal headline did not check it; check it in a new product.

### Paste-ready Motion.tsx

```tsx
"use client";
import { motion, useReducedMotion } from "motion/react";

export const SPRING = { type: "spring", stiffness: 420, damping: 34 } as const;
export const SOFT = { type: "spring", stiffness: 160, damping: 24 } as const;
export const rise = { initial: { opacity: 0, y: 24 }, whileInView: { opacity: 1, y: 0 },
  viewport: { once: true, margin: "-80px" }, transition: SOFT } as const;

export function Reveal({ text, still }: { text: string; still?: boolean }) {
  const calm = useReducedMotion() || still;
  if (calm) return <>{text}</>;
  return <>{text.split(" ").map((w, i) => (
    <motion.span key={i} className="inline-block" initial={{ opacity: 0, filter: "blur(4px)" }}
      animate={{ opacity: 1, filter: "blur(0px)" }}
      transition={{ duration: 0.35, delay: Math.min(i * 0.012, 1.2) }}>{w}&nbsp;</motion.span>))}</>;
}

export function Dots() {
  return <span role="img" aria-label="Thinking" className="flex gap-1.5">{[0, 1, 2].map((i) => (
    <motion.span key={i} className="size-1.5 rounded-full bg-ink/45"
      animate={{ y: [0, -4, 0] }} transition={{ duration: 0.9, repeat: Infinity, delay: i * 0.14 }} />))}</span>;
}
```

## Paste-ready globals.css token block

Tailwind 4, no `tailwind.config`. Everything lives in CSS.

```css
@import "tailwindcss";
@source not "../public";            /* stops Tailwind scanning public/, which stalled builds for minutes */
@import "tw-animate-css";
@custom-variant fine-hover (@media (hover: hover) and (pointer: fine));

:root {
  --background: #ffffff;   --foreground: #0d1117;
  --ink: #0d1117;          --ink-hover: #232c3b;
  --quiet: #f5f5f5;        --muted-foreground: #5c5c5c;
  --destructive: #b5121b;  --border: #e6e6e6;   --input: #d4d4d4;
  --spark: #38bdf8;        --spark-ink: #0369a1;  --ring: #38bdf8;
  --ease-spring: cubic-bezier(.32,.72,0,1);
  --ease-bounce: cubic-bezier(.34,1.56,.64,1);
}
@theme inline {
  --color-background: var(--background);  --color-foreground: var(--foreground);
  --color-ink: var(--ink);  --color-quiet: var(--quiet);
  --color-destructive: var(--destructive);  --color-spark: var(--spark);  --color-ring: var(--ring);
  --font-sans: var(--font-ui), -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif;
  --font-display: var(--font-sans);
}
body { background: var(--background); color: var(--foreground); font-family: var(--font-sans); }
::selection { background: rgba(56,189,248,.28); }

@utility display { font-weight: 500; letter-spacing: -0.045em; line-height: 0.95; }
@utility press {
  transition: transform .18s var(--ease-spring), background-color .2s, color .2s, box-shadow .2s, opacity .2s;
  &:active { transform: scale(.97); }
  &:disabled { opacity: .45; pointer-events: none; }
  &:focus-visible { outline: 2px solid var(--ring); outline-offset: 3px; }
}
@media (prefers-reduced-motion: reduce) { *, *::before, *::after { animation: none !important; transition-duration: .01ms !important; } }
```

Bespoke called the ink variable `brand-ink` and the spark `brand`; with the block above the same utilities read `text-ink/60`, `bg-spark/10`. A generic name keeps the rules portable.

Retheming means editing `--spark`, `--spark-ink` and `--ring` (and `--ink` if asked). Nothing else in the block changes.

## UI dependencies, house default

```
next (output: "export", images unoptimized, trailingSlash true)   react / react-dom
tailwindcss + @tailwindcss/postcss (postcss.config.mjs: { plugins: { "@tailwindcss/postcss": {} } })
motion   tw-animate-css   class-variance-authority   clsx   tailwind-merge   lucide-react
three 0.186.1 (only when a 3D piece ships)
```

Pin exact versions in a new project at the latest stable at the time. Bespoke carried `gsap`, `lenis` and `metal-fx` unused; never add a library the code does not import. Tailwind arbitrary values (`text-[clamp(...)]`, `rounded-[36px]`, `shadow-[...]`) are the main styling mode. The shadcn config (`components.json`: style "new-york", rsc true, baseColor neutral, cssVariables true, lucide, aliases `@/components`, `@/lib/utils`) is the base for third-party pieces; `cn = twMerge(clsx(...))`.

## Chronology of rules that emerged

Bespoke tried an Apple-style first build, then editorial, then ink and spark. A magazine-cover home and a photo-wall home were built and dropped; a black "tunnel" empty state was built and reverted ("Talk stays white"); a puffy curved footer wordmark was added and reverted. The rule left standing: almost no copy, one image treatment, one primary action per screen, glass only on floating things, black only as a full-bleed band or the primary button. When an experiment fights the system, revert it.
