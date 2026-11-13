# Bespoke look and feel: the visual system

Source: repo riteshroshann/onestyle, product "Bespoke" (clothes made from your words). App in `web/` (Next.js 16.3.8 static export, React 19.3.0, Tailwind 4.3.5), docs in `site/` (plain HTML/CSS/JS plus one bundled React widget). This file is enough to rebuild the look without the repo. Paths are relative to the repo root. Where the original brief (`design-prompts/home-page-aesthetic.txt`) and the shipped code disagree, the code is recorded here and the difference is flagged "Brief vs code".

The feel in one paragraph: pure white page, near-black ink, one sky-blue spark used only for focus and the logo mark, enormous medium-weight geometric sans headlines set tight, almost no copy, floating glass pill navigation, pill buttons that squash on press, springy motion that rises from below, and one full-bleed black band near the foot. No boxes, no badges, no gradients (except the "reading" aura, below).

## Brief vs code (read first)

- Accent: brief says sky blue #38bdf8 is the one accent. Code: `--primary` is ink; #38bdf8 is `--ring` and `--brand`, used for focus rings, text selection, the logo mark strokes and the back-to-top arrow. Globals comment: "Noir editorial: black is the accent. Colour appears only while pictures are being read."
- Radius: brief says cards 24-28px. Code: shadcn `--radius` is 0.25rem (4px) for generic tokens, but real surfaces use explicit radii: pills `rounded-full`, menus 22px, inner rows 16px, About photo stage 36px, big picture cards 36px, chat bubbles 20px (6px on the tail corner), docs cards 24px, docs panel 28px, code blocks 20px.
- Active nav link: brief says an ink pill that slides via shared layout. App header (`web/components/site/Header.tsx`): the active link is a static `bg-secondary` (#f5f5f5) pill, no slide. The sliding ink pill exists in two other places: the docs site nav (`site/app.js` + `.links .pill`, CSS left/width transition) and the studio segmented controls (framer `layoutId`, see Motion).
- Nav pill glass: brief says white 85%. Code: `bg-white/65` with blur-2xl and saturate 1.8 (docs: 70%). Links sit right-aligned next to the logo, not centred (the legacy `.top .inner` grid with `1fr auto 1fr` centres them on old studio pages).
- Headline mask reveal: not on the home page. Home headline is static text. The reveal lives in `AboutPage.tsx` and `App.tsx` `PageHead` (studio pages), with the soft spring and 100ms line stagger as briefed.
- Max width 1440px, gutters 20px / 40px from `md`: as briefed. Section padding `clamp(64px,9vw,128px)`: used in the black band in `App.tsx`; About uses py-24/32 and py-28/40 steps instead.
- Font: brief says "Google Sans or similar"; code uses Google Sans via `next/font/google`, weights 400/500/700, but only 400 and 500 are used visually (headings 500).
- Home page: brief wants headline, lede, action, then contrast band. Final home (commit "Clear the home page back to a headline and one button") is headline + one button + footer. No lede, no band on home; the black band lives on About ("The vision") and the studio Talk page ("How it works").
- Dependencies `gsap`, `metal-fx` and `lenis` are listed but unused in code (only `useLenis` in ToTop, with no provider, so it falls back to `window.scrollTo`). Do not carry them over.

## Tokens

### Colour
Defined in `web/app/globals.css` `:root`, exposed to Tailwind through `@theme inline` (`--color-*`). Light only; no dark theme (a `dark` custom variant exists but is unused).

```
--background #ffffff        --foreground #0d1117 (ink)
--card #ffffff              --card-foreground #0d1117
--popover #ffffff           --popover-foreground #0d1117
--primary #0d1117           --primary-foreground #ffffff
--secondary #f5f5f5         --secondary-foreground #0d1117
--muted #f5f5f5             --muted-foreground #5c5c5c
--accent #f5f5f5            --accent-foreground #0d1117
--destructive #b5121b       --border #e6e6e6      --input #d4d4d4
--ring #38bdf8              --brand #38bdf8       --brand-ink #0d1117
--radius 0.25rem   (sm = radius-2px, md = radius, lg = radius+4px)
--ease-spring cubic-bezier(.32,.72,0,1)
```

Ink at opacity is the whole grey scale, written as Tailwind `text-brand-ink/NN` or `ring-brand-ink/NN`:
- 75%: long body copy on About ("The problem").
- 70%: developer paragraph; footer bottom row 65%.
- 60%: ledes (`text-brand-ink/60`), footer link hover, step text in black band is white/60.
- 55%: footer column titles, secondary notes (menu descriptions).
- 50% / 45% / 40%: micro text, source lines, step numerals, "Drag the card" hint (40%), thinking dots (45%).
- 10%: hairlines (`border-brand-ink/10`) between sections and above the footer bottom row. 12-15%: ghost button rings (`ring-brand-ink/15`, hover /30). 5%: segmented control track (`bg-brand-ink/[.05]`). 4%: hover wash (`hover:bg-brand-ink/[.04]`).
- On the black band: text white; secondary white/60; numerals white/40; hairlines `border-white/15`.

Fixed hexes outside the tokens: button hover ink `#232c3b`; assistant bubble grey `#f2f3f5`; failed bubble `#fdf1f1` on text `#8a1c1c`; listening red `#b5121b`; About photo stage `#f4f5f7`; studio grouped fill `#f5f5f7` (legacy `--fill`), pressed `#e8e8ed`, separator `#d2d2d7`, ink-2 `#424245`, ink-3 `#6e6e73`; thread (understood words) `#b5121b`.

Selection: `::selection { background: rgba(56,189,248,.28) }`. Focus ring: `outline: 3px solid rgba(56,189,248,.7); outline-offset: 2px` (legacy and docs), or `2px solid var(--ring)` offset 3px via the `press` utility.

The only colourful thing in the app is the "reading" aura while a moodboard picture is analysed: conic gradient `#4285f4, #9b72cb, #d96570, #f2a93b, #2fa7a0, #4285f4`, see Halo.

### Typeface
One family, Google Sans. Loaded in `web/app/layout.tsx` with `next/font/google` (self-hosted at build time, no runtime font request):

```tsx
const sans = Google_Sans({ subsets: ["latin"], weight: ["400", "500", "700"], variable: "--font-ui", display: "swap" });
<html lang="en" className={sans.variable}>
```
`--font-display` and `--font-sans` both resolve to `var(--font-ui), -apple-system, BlinkMacSystemFont, "Helvetica Neue", Arial, sans-serif`. Docs site loads it from Google Fonts CSS (`Google+Sans:wght@400;500`, preconnect to googleapis and gstatic) with fallback `ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif`. Mono for docs code: `ui-monospace, "SF Mono", "Cascadia Code", Consolas, monospace`. Legacy.css still lists Bodoni 72/Didot/Georgia as `--display` fallback; unused in practice. `public/licenses.txt` still credits Bodoni Moda and Jost from an earlier version.

A splash (`Splash.tsx`) covers every fresh load until `document.fonts.ready` plus a 700ms minimum, then fades out in 500ms, so nothing shows half-dressed.

### Type scale
Display utility (`@utility display` in globals.css): `font-weight 500; letter-spacing -0.045em; line-height 0.95`. Always paired with a size and often `leading-[0.92]`.

- Home h1: `display text-[clamp(56px,9vw,160px)] leading-[0.92]`.
- About h1: `clamp(52px,8.4vw,152px)`, lh .92. Docs h1: `clamp(52px, 8.6vw, 132px)`. Studio PageHead: `clamp(56px,9vw,160px)`, lh .92.
- Board hero h2: `clamp(44px,6vw,80px)`. Reading h2: `clamp(40px,6vw,84px)`. Black band h2: `clamp(36px,4.6vw,64px)`, `max-w-[12ch]`.
- Section h2 (About): `text-[clamp(30px,3vw,44px)] font-medium leading-[1.1] tracking-[-0.03em]`. Docs h2: `clamp(30px, 3.2vw, 46px)`, weight 500, tracking -.035em, lh 1.08.
- Lede: `clamp(17px,1.4vw,20px)` (studio, `max-w-[52ch]`) or `clamp(18px,1.6vw,22px)` (About, `max-w-[56ch]`), line-height 1.5, ink/60.
- Body on About: `clamp(18px,1.5vw,21px)` lh 1.6. Vision quote: `clamp(20px,1.8vw,26px)` lh 1.5 tracking -0.01em.
- Card/article h3: 24px weight 500 tracking -0.02em; body 16px lh 1.55 ink/60. Docs h3 21px.
- Footer tag line: 28px (34px from md) lh 1.15 tracking -0.025em; footer links 16px; column titles 15px at ink/55; bottom row 14px.
- Nav: logo 21px weight 500 tracking -0.03em; links 15px weight 500. Buttons 15px (md) or 17px (lg) weight 500, tracking -0.01em.
- Small labels 12-14px; chat 15px lh 1.45. Uppercase tracked labels are essentially absent in code (brief: only when tracked 0.14em).
- Body base (legacy): 17px, lh 1.47, letter-spacing -.01em; at >=1024px the whole legacy studio scales by `--s: .8` (the look of 80% zoom). Docs body 17px lh 1.6.
- Footer wordmark: `display text-[clamp(88px,25.2vw,386px)] leading-[0.95] tracking-[-0.06em]`, `-ml-[0.05em] pb-[0.06em] whitespace-nowrap select-none aria-hidden`, margin-top 80px (112px from md).

### Layout
- Max width `max-w-[1440px] mx-auto`, gutters `px-5 md:px-10` (20px, 40px from 768px). Legacy `.hero`: padding `clamp(56px,7vw,104px) 20px 96px`, 40px inline from 768px. Docs: `.wrap` max 1120px, padding 0 24px.
- Home main: `pb-24 pt-40 md:pb-32 md:pt-48` (room for the floating nav), CTA `mt-16 md:mt-24` under the h1.
- About sections: hero `pb-24 pt-40 md:pb-32 md:pt-52`; content sections `py-24 md:py-32` with a 12-column grid at `md`: heading `md:col-span-4`, body `md:col-span-7 md:col-start-6`; hairline `border-t border-brand-ink/10` between sections; black band `py-28 md:py-40`.
- Breakpoints: Tailwind defaults (sm 640, md 768, lg 1024). Docs: 860px and 600px and 560px custom. Nav links `hidden sm:block`, so under 640px only logo and Log in show.
- Grids: four-up "How it works" `sm:grid-cols-2 lg:grid-cols-4` with `gap-x-8 gap-y-14`; footer `grid-cols-2 md:grid-cols-12` (tagline span 6, link columns span 3 each).

### Shadows and rings
- Nav pill: `shadow-[0_8px_32px_-12px_rgba(13,17,23,.18),inset_0_1px_0_rgba(255,255,255,.6)] ring-1 ring-black/[.06]`.
- Menu: `shadow-[0_24px_60px_-20px_rgba(13,17,23,.35)] ring-1 ring-black/[.06]`.
- Back-to-top: `shadow-[0_12px_40px_-12px_rgba(0,0,0,.6)]`. Picture card: `shadow-[0_40px_90px_-30px_rgba(13,17,23,.55)] ring-1 ring-white/60`. Ask bubble: `drop-shadow-[0_12px_20px_rgba(13,17,23,.32)]`.
- Docs: card `0 0 0 1px var(--line)` hover `0 0 0 1px rgba(13,17,23,.12), 0 24px 50px -28px rgba(13,17,23,.4)`; panel `0 30px 90px -24px rgba(13,17,23,.45), 0 0 0 1px rgba(0,0,0,.06)`.
- Cards use ring or shadow, never border (hairline `0 0 0 1px`). Long soft negative-spread shadows are the pattern.

## Motion

Library: `motion` ^14.12.0, imported from `motion/react` (formerly framer-motion). Shared constants in `web/components/site/Motion.tsx`:

```ts
export const SPRING = { type: "spring", stiffness: 420, damping: 34 } as const; // snappy: press, menus, chips, layoutId slides
export const SOFT   = { type: "spring", stiffness: 160, damping: 24 } as const; // soft: headlines, sections, enters
```
The same Motion.tsx exports `Reveal` (text arriving word by word: each word `opacity 0 -> 1` and `blur(4px) -> 0`, duration .35s, delay `min(i*0.012, 1.2)`s; skipped when `still`) and `Dots` (three 6px ink/45 dots bouncing `y [0,-4,0]`, 0.9s, delay i*0.14s).

Patterns:
- Rise on enter: `initial {opacity 0, y 10-16} animate {opacity 1, y 0} transition {...SOFT, delay}`. Lede delay .15-.3s; stagger of siblings 0.05-0.08s (`delay: i * 0.08`); list items 0.05-0.07s with SPRING.
- Scroll reveal, once: `whileInView` with `viewport {once: true, margin: "-80px"}` (About `rise`: `y: 24`; black band steps `y: 14`, margin -60px).
- Headline mask reveal (About and studio PageHead): outer span `overflow-hidden pb-[0.08em]` clips each line, inner span slides from 105%:
```tsx
<h1 className="display text-[clamp(52px,8.4vw,152px)] leading-[0.92]">
  {["Clothes made for you,", "from your words."].map((line, i) => (
    <span key={line} className="block overflow-hidden pb-[0.08em]">
      <motion.span className="block" initial={{ y: "105%" }} animate={{ y: 0 }}
        transition={{ ...SOFT, delay: 0.08 + i * 0.1 }}>{line}</motion.span>
    </span>
  ))}
</h1>
```
- Press: the `press` utility in globals.css, on every button and nav link:
```css
@utility press {
  transition: transform .18s var(--ease-spring), background-color .2s, color .2s, box-shadow .2s, opacity .2s;
  &:active { transform: scale(.97); }
  &:disabled { opacity: .45; pointer-events: none; }
  &:focus-visible { outline: 2px solid var(--ring); outline-offset: 3px; }
}
```
  Brief said .95; code uses .97 (CSS) and `whileTap={{ scale: 0.96 }}` / `0.9` for icon buttons in framer. Hover lift on social links: `whileHover={{ y: -3 }}`.
- Shared-layout slider (studio segmented controls in `App.tsx`, lines ~213 and ~549): a track `relative flex h-11 items-center rounded-full bg-brand-ink/[.05] p-1 text-[14px] font-medium` (h-9, 13px for the language switch) containing the active fill `<motion.span layoutId={id} transition={SPRING} className="absolute inset-0 rounded-full bg-brand-ink" />` rendered inside the selected option; text turns white.
- Menus: `initial {opacity 0, y -6, scale .96} -> {1,0,1}`, exit `{opacity 0, y -4, scale .97}`, SPRING, `transformOrigin: top right`. Ask panel: `initial {opacity 0, y 24, scale .92, blur(6px)}` to clear, exit `{y 16, scale .94, blur(4px)}`, origin bottom right. Chat bubbles pop `{opacity 0, y 12, scale .96}` with SPRING, origin by side.
- Back to top (`ToTop.tsx`): appears after `scrollY > innerHeight`, `initial {opacity 0, y 12}`, `transition {type:"spring", duration .35, bounce 0}`, 56px ink circle at `bottom-4 left-4` (md: 6), cyan arrow; Ask launcher sits on the right so they never collide.
- Loader hover bounce on the Ask launcher: `duration-500 ease-[cubic-bezier(.34,1.56,.64,1)] hover:-translate-y-1 hover:scale-[1.07] active:scale-95`.
- Reduced motion: framer components read `useReducedMotion()` (Reveal's `still`, ToTop's immediate scroll, halo blobs frozen); CSS animations (`.aura`, `.sweep::after`, `.shimmer-text`) are switched off in a `@media (prefers-reduced-motion: reduce)` block in globals.css; Lanyard sets breeze to 0 and skips the intro; docs `.reveal` shows at once and drops transitions. The mask-reveal headline itself does not check reduced motion.
- Docs motion is CSS only: `.reveal` fades and rises 18px over .8s on the spring curve, triggered once by IntersectionObserver with `rootMargin: 0 0 -60px`. Easing tokens: `--spring: cubic-bezier(.32,.72,0,1)` and `--bounce: cubic-bezier(.34,1.56,.64,1)`.

## Navbar

File `web/components/site/Header.tsx`. Props: `current` (href of the active link), `tone` "light" | "dark", `audience` "customer" | "maker". Links: Studio (`/studio/talk/`), For makers (`/makers/`), About (`/about/`), Docs (external GitHub Pages). Makers do not see Studio and log in at `/makers/login/`.

Structure: a fixed full-width, click-through wrapper holds a centred pill.
```tsx
<header className="pointer-events-none fixed inset-x-0 top-3 z-40 px-3 md:top-4 md:px-6">
  <div className="pointer-events-auto mx-auto flex h-[60px] max-w-[1180px] items-center gap-3 rounded-full pl-5 pr-2 backdrop-blur-2xl backdrop-saturate-[1.8]
    shadow-[0_8px_32px_-12px_rgba(13,17,23,.18),inset_0_1px_0_rgba(255,255,255,.6)] ring-1 bg-white/65 ring-black/[.06]">
    <a className="inline-flex items-center gap-2 text-[21px] font-medium tracking-[-0.03em]"><Mark className="size-5" />Bespoke</a>
    <nav className="ml-auto flex items-center gap-1">
      <a aria-current={current === href ? "page" : undefined}
         className="press rounded-full px-4 py-2 text-[15px] font-medium hover:bg-secondary hidden aria-[current=page]:bg-secondary sm:block">...</a>
```
Dark tone (studio Talk tunnel, black pages): `bg-brand-ink/70 ring-white/10`, links `text-white hover:bg-white/10`, active `bg-white/10`.

Mobile: below 640px the text links are hidden; the logo and a "Log in" (or inbox link when signed in) remain. Pill height 60px, outer inset 12px / 24px. The legacy sticky `.top .inner` variant shrinks to 56px at <=560px and hides the wordmark text, keeping only the mark.

Log in menu (`SignInMenu`): a "Log in" pill opens a 260px glass card (`rounded-[22px] bg-white/90 p-1.5 backdrop-blur-2xl`, `top-[48px]`) with two rows ("I am a customer" / "I am a maker", 15px title, 13px ink/55 note, rows `rounded-[16px] hover:bg-black/[.04]`); closes on outside pointerdown and Escape.

Docs nav (`site/style.css`, `site/app.js`) is the true sliding pill: 60px, max 1120px, `rgba(255,255,255,.7)`, `backdrop-filter: blur(40px) saturate(1.8)`; `.links` contains an absolutely positioned `.pill` (ink background) whose `left` and `width` are set from `offsetLeft/offsetWidth` of the current link and transition `.45s cubic-bezier(.32,.72,0,1)`; on hover it moves to the hovered link (text turns white), on leave it returns; it re-measures on `document.fonts.ready` and resize. Links hidden under 860px. Right side holds an ink "Open Bespoke" CTA (44px).

## Buttons, inputs, cards

- Primary CTA (`web/components/site/Cta.tsx`): `press inline-flex items-center justify-center whitespace-nowrap rounded-full font-medium leading-none tracking-[-0.01em] transition-[background-color,transform] duration-300 active:scale-[0.97]`; tone dark `bg-brand-ink text-white hover:bg-[#232c3b]`, tone light `bg-white text-brand-ink hover:bg-white/85`; sizes `md: h-11 px-6 text-[15px]`, `lg: h-14 px-9 text-[17px]` (home uses lg). Brief said 44-48px; large is 56px.
- Secondary: ring only, `ring-1 ring-brand-ink/15 hover:bg-brand-ink/[.04] hover:ring-brand-ink/30`, or plain underlined text link `underline decoration-brand-ink/25 underline-offset-[6px]` going to full ink on hover.
- Chips ("pill" const in App.tsx): `h-10 rounded-full px-4 text-[14px] font-medium ring-1 ring-brand-ink/12 hover:bg-brand-ink/[.04] hover:ring-brand-ink/25`.
- Icon buttons: `size-9`/`size-11`/`size-12` circles, ink fill, `focus-visible:ring-4 ring-[#38bdf8]/50`.
- Inputs: big soft pills. Docs search input `height 48px; border-radius 999px; background var(--fill)` (ink 4%), focus becomes `#fff` with `0 0 0 1px rgba(13,17,23,.18), 0 8px 24px -14px rgba(13,17,23,.3)`. Auth inputs (`.auth-input`, 16px radius) keep their curve under browser autofill: `-webkit-box-shadow: 0 0 0 1000px #f5f5f6 inset` (white on focus), `-webkit-text-fill-color #0d1117`, and hide Edge's reveal/clear buttons.
- Cards: no nested cards. Marketing "cards" are open columns with a top hairline (`border-t border-brand-ink/10 pt-6`). Docs cards: white, 24px radius, hairline ring, lift `translateY(-3px)` on hover with the bounce curve, arrow nudges 3px.
- Stitched text: `.stitched` underline `text-decoration-thickness .06em; text-underline-offset .14em` marks phrases the engine understood.
- Error and empty states: one warm plain sentence plus a clear action (e.g. `NeedsDesign` in App.tsx: a sentence and an ink h-14 pill button "mt-8").

## Home page

Files: `web/app/page.tsx` renders `web/components/home/HomePage.tsx`. Complete structure:
```tsx
<div className="flex min-h-[100svh] flex-col bg-white text-brand-ink">
  <Header />
  <main className="flex flex-1 items-center pb-24 pt-40 md:pb-32 md:pt-48">
    <div className="mx-auto w-full max-w-[1440px] px-5 md:px-10">
      <h1 className="display text-[clamp(56px,9vw,160px)] leading-[0.92]">Made from<br />your words.</h1>
      <div className="mt-16 md:mt-24"><Cta href="/studio/talk/?new" size="lg">Start a design</Cta></div>
    </div>
  </main>
  <Footer />
</div>
```
Exact copy: headline "Made from / your words." (line break), button "Start a design". Nothing else. Page title "Bespoke · Clothes made from your words"; share image `/og.png` 1200x630 with alt "Bespoke: Describe it. Wear it."

Footer (`Footer.tsx`), white, same 1440 container:
- Tagline "Say it. We will cut it." (28/34px).
- Two link columns: "Make" (Studio, Start a design, My requests) and "Bespoke" (About, Docs, For makers, Log in, Credits). Column title 15px ink/55, `space-y-3` 16px links, no underline, hover ink/60.
- Giant wordmark "Bespoke" (spec above) cropped by nothing, aria-hidden.
- Bottom bar: `border-t border-brand-ink/10`, row with the mark + "Bespoke" (16px medium) and "Engineered by Ritesh Roshan" (14px ink/65), right padding `pr-24 md:pr-28` to clear the Ask launcher.

Contrast band (black, white text): `bg-brand-ink text-white`, container `max-w-[1440px] px-5 py-[clamp(64px,9vw,128px)] md:px-10`. In `App.tsx` it is "How it works." (h2 `clamp(36px,4.6vw,64px)` max 12ch) over a 3-column `sm:grid-cols-3 gap-10` ordered list: each item `border-t border-white/15 pt-5`, numeral 13px white/40, title 20px medium, text 15px white/60 `max-w-[34ch]`, then a white pill button "Have pictures instead? Start with a moodboard" (h-12 px-6). On About, "The vision" band (`py-28 md:py-40`): h2 left, quote right (two paragraphs), "Ritesh Roshan, founder" in 15px white/60, then a light-tone lg Cta "Start a design". Docs equivalent: `.dark` section, `#000` with radial gradient `120% 80% at 50% -20%, #1b1f27 0%, #07080a 55%, #000 100%` (the only band gradient).

## About page

Files: `web/app/about/page.tsx` (metadata "About · Bespoke"), `web/components/about/AboutPage.tsx`, `Lanyard.jsx` (1296 lines), `Lanyard.css`, `Lanyard.d.ts` (typed props for strict TS). Sections in order: hero ("Clothes made for you," / "from your words." mask reveal, lede "Most people know exactly what they want to wear. Few can say it in a tailor's language. Bespoke closes that gap."), "The problem" (two paragraphs), "How it works" (four articles Talk, Board, Sheet, Makers, each with a link: "Start a design", "Open a board", "See the sheet", "For makers"), the developer block with the lanyard and social pills, "The vision" black band. Social pills (GitHub filled ink first, X and LinkedIn ringed): `h-14 rounded-full pl-5 pr-6 text-[16px] font-medium`, inline SVG glyph `size-5`, handle in 13px at 50% opacity that nudges 0.5 on hover, springs in with stagger `0.15 + i*0.06`.

### Lanyard (the 3D badge of the author)

Source: React Bits "Lanyard" (https://reactbits.dev) but this is NOT the react-three-fiber + Rapier version. It is a plain `three` (0.186.1) implementation, no r3f, no drei, no rapier: imperative `THREE.WebGLRenderer` in a `useEffect`, a hand-written physics step, and canvas-painted textures. No other 3D libraries.

Usage (About page), the card sits in a rounded stage:
```tsx
const Lanyard = dynamic(() => import("./Lanyard"), { ssr: false, loading: () => null }); // three.js runs only in the browser
<motion.div {...rise} className="relative h-[560px] overflow-hidden rounded-[36px] bg-[#f4f5f7] md:col-span-6 md:h-[640px]">
  <Lanyard frontImage="/lanyard/card-front.jpg" backImage="/lanyard/card-back.jpg" strapImage="/lanyard/band.png"
    strapColor="#0d1117" finish="glossy" size={0.62} strapLength={0.55} breeze={0.4} />
  <p className="pointer-events-none absolute inset-x-0 bottom-5 text-center text-[13px] text-brand-ink/40">Drag the card. Flip it over.</p>
</motion.div>
```
Props (defaults): `frontImage`, `backImage`, `imageFit 'cover'|'contain'`, `cardColor '#ffffff'`, `orientation 'portrait'`, `finish 'glossy'|'matte'|'holographic'|'metallic'`, `cornerRadius 0.3`, `size 0.6`, `anchor 'center'|'left'|'right'` (0.5/0.27/0.73), `strapLength 0.5`, `strapImage`, `strapColor '#111111'`, `strapWidth 0.65`, `metal 'silver'`, `gravity 1`, `damping 0.5`, `elasticity 0.5`, `breeze 0.5`, `interactive true`, `intro true`.

Textures: the photo is not 3D-modelled; card faces are 2D canvases painted at width 1024 (`FACE_WIDTH`) from images, wrapped as `THREE.CanvasTexture` with `SRGBColorSpace` and anisotropy `min(8, max)`. Assets in `web/public/lanyard/`: `card-front.jpg` (1024x1440, 125KB), `card-back.jpg` (1024x1440, 60KB), `band.png` (1600x256, 33KB). The front is a designed ID card of Ritesh Roshan: a selfie against sky and sea fading to white at the bottom, ">< Bespoke" wordmark top left in white, "Ritesh Roshan" large in Google Sans near-black, "Founder and engineer, Bespoke" in grey, "Engineered in India" bottom left and "@RiteshRoshann" bottom right in blue. Strap uses `band.png` over `#0d1117`. Grain and weave textures are generated procedurally in canvas (`buildGrainTexture`, `buildWeaveTexture`).

Rendering setup:
```js
renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' }); // in try/catch: no WebGL means return, canvas simply absent
renderer.setClearColor(0x000000, 0);           // transparent, the stage colour shows
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.NeutralToneMapping;
// camera: PerspectiveCamera(FOV = 24, 1, 0.1, 200)
// lights: DirectionalLight 1.6 at (-2.5, 4, 6) and 0.35 at (3, -1, 4)
// scene.environment = PMREM of a hand-built studio scene: dark background (0.035) with 8 emissive
//   plane "softboxes" (intensities 6, 4, 3.5, 2.6, 2.5, 1.4, 0.9, 0.5), no external HDRI download
```
Card: thickness 0.018, bevel 0.007, portrait size 1.6 x 2.25, glossy finish `roughness .42, clearcoat 1, clearcoatRoughness .06` (matte, holographic foil shader and metallic with anisotropy also built in). A metal ring (radius .095, tube .0135), eyelet, and clamp hold card to strap. Strap band: 4 columns with bend profile, 72 samples.

Physics (custom, in-file, not Rapier): a verlet-style chain of `JOINTS = 4` nodes (+ anchor) with a rigid card body that has position, quaternion, angular velocity and inverse inertia; constants `ITERATIONS 2`, `MAX_STEP 1/960`, `NODE_WEIGHT 20`, `FLIP_SPIN 9`, twist 30 / damping 3, grip 40 / damping 6, nodeDrag 2, nodeAir .2, broadside .5. `dt` is clamped to [1/240, 1/30]; the loop guards against NaN by resetting to the hanging pose. Breeze adds a gentle sway (reduced motion sets it to 0).

Interaction: pointer events on the canvas with raycasting (`THREE.Raycaster`); drag grabs the card with a spring grip, release lets it swing; a quick press (<450ms) without moving flips the card (spin impulse) to show the back; cursor becomes `grab`; touch is handled with a non-passive `touchstart` (and touch hover ignored) so the page can still scroll when not touching the card. Canvas is `aria-hidden`.

Performance and fallbacks: dynamic import with `ssr:false` and `loading: () => null` (empty until ready); `IntersectionObserver` pauses the loop when off-screen; `visibilitychange` restarts it; the loop also stops when the sim is at rest (`calm > 1.2`, no grab, no breeze) and restarts on interaction; `ResizeObserver` resizes; pixel ratio capped at `min(devicePixelRatio, 2)`; full disposal of geometries, materials, textures, environment and renderer on unmount; `prefers-reduced-motion` skips the intro drop and zeroes the breeze. If WebGL is unavailable the stage shows only the grey rounded panel and the hint text. `Lanyard.css`: `.lanyard {position relative; width 100%; height 100%; overflow hidden}` `.lanyard-canvas {display block; width 100%; height 100%}`.

## Halo and aura effects

Three distinct "glow" pieces exist:

1. HaloDropzone (`web/components/ui/halo-dropzone.tsx`, 2040 lines): from Cult UI (cult-ui.com, MIT; registry `@cult-ui` in components.json). Used once, on the Board empty state (`components/Board.tsx` ~line 533: `<HaloDropzone accept="image/*" multiple onFiles={addPictures} successResetMs={1200} showSuccessThumbnails={false} emptyLabel="Drop or paste pictures, or click to choose" successLabel="Added" formatHint="JPG, PNG or WebP" />`). Built in pure CSS gradients plus motion, no canvas or shaders: a `<label>` card (`rounded-2xl`, 1px padding) containing (a) three blurred gradient "rim blobs" along the bottom 58% that slide left/right forever (`h-32 w-88 blur-2xl` 6s, `h-24 w-52 blur-2xl` 5s, `h-20 w-44 blur-xl` 4s, `ease: easeInOut`, `left` animating `["-5%","75%","-5%"]`, `["65%","10%","65%"]`, `["25%","55%","25%"]`), idle opacity 0.5-0.92 raised on hover/focus/drag/success; (b) a frosted fill `linear-gradient(to bottom, color-mix(in oklch, var(--card) 82%, transparent), color-mix(in oklch, var(--card) 70%, transparent))`; (c) a moving border trail: two blurred pills (184x32px, blur 12px and blur 4px) travelling the card outline using CSS `offset-path: rect(0 auto auto 0 round 16px)` and `offset-distance` driven by a requestAnimationFrame loop through a motion value, clipped to the 1px border with a `mask-composite: intersect` mask; active only on hover/focus/drag and removed under reduced motion; (d) inlined file-type glyph SVGs (Excel, Word, PDF, etc.) for success tiles. Default blob colours are Cult UI's rainbow (`#ff0080, #7928ca, #00d4ff, #0070f3`, secondary `#ff4d4d, #f9cb28, #ff0080`, tertiary `#0070f3, #00d4ff, #7928ca`), with green (`#047857...#14b8a6`) and red (`#991b1b...#f43f5e`) variants for success and destructive. It was NOT recoloured to ink/cyan; it keeps the colourful rim as the single colourful moment on the otherwise monochrome Board entry. Surface uses the shadcn tokens (`--card`, `--muted`, `--ring`).
2. Reading aura (`globals.css` `.aura`, used in `web/components/board/Reading.tsx` behind the picture being analysed): a conic-gradient halo that rotates through a registered CSS property:
```css
@property --aura-angle { syntax: "<angle>"; inherits: false; initial-value: 0deg; }
.aura { position: absolute; inset: -14%; border-radius: 42%;
  background: conic-gradient(from var(--aura-angle), #4285f4, #9b72cb, #d96570, #f2a93b, #2fa7a0, #4285f4);
  filter: blur(54px) saturate(1.25); opacity: .55;
  animation: aura-spin 7s linear infinite, aura-breathe 3.4s ease-in-out infinite; }
@keyframes aura-spin { to { --aura-angle: 360deg; } }
@keyframes aura-breathe { 50% { opacity: .82; transform: scale(1.05); } }
```
   Over the picture, `.sweep::after` is a scanning band (`linear-gradient(180deg, transparent, rgba(255,255,255,.5) 55%, rgba(255,255,255,.85) 60%, transparent 62%)`, 38% tall, `mix-blend-mode: soft-light`, 2.2s `cubic-bezier(.45,0,.25,1)` infinite from -110% to 290%). `.shimmer-text` is a 250%-wide gradient clipped to text (`#5c5c5c` with a blue/purple/red glint, 2.6s linear). The picture card itself: `rounded-[36px] bg-white shadow-[0_40px_90px_-30px_rgba(13,17,23,.55)] ring-1 ring-white/60`, size `min(300px,70vw)`, entering with `scale .92 rotate -2deg` on SOFT.
3. Dot-matrix loader halo/bloom (`--dmx-halo-level`, `.dmx-bloom`) is a property of the DotMatrix loader, below.

## Third-party components (all adapted, none installed from npm except libraries)

`web/components.json` is the shadcn config: style "new-york", rsc true, tsx, `tailwind.config ""` (Tailwind 4, CSS only), css `app/globals.css`, baseColor "neutral", cssVariables true, iconLibrary lucide, aliases `@/components`, `@/lib/utils`, `@/components/ui`, `@/lib`, `@/hooks`; registries `@cult-ui` (https://www.cult-ui.com/r/{name}.json), `@skiper-ui` (https://skiper-ui.com/registry/{name}.json), `@dotmatrix` (https://dotmatrix.zzzzshawn.cloud/r/{name}.json). `lib/utils.ts` is the standard `cn = twMerge(clsx(...))`. Credits live in `web/public/licenses.txt` (linked as "Credits" in the footer): Skiper UI by Gurvinder Singh, components 31, 39, 52, 66 (free, attribution required); Halo Dropzone from Cult UI (MIT); Dot Matrix loader (MIT); metal-fx by Jakub Antalik (Apache-2.0); Motion, GSAP, Lenis.

- Dot Matrix loader (shadcn registry `@dotmatrix`, MIT): `web/components/ui/dotm-triangle-7.tsx` (7x7 grid, triangle mask cells `1,3 2,2 2,4 3,1 3,3 3,5 4,0 4,2 4,4 4,6`, diagonal sliding bands, opacities base .06 / mid .38 / high .96), `web/lib/dotmatrix-core.tsx` (1650 lines: colour presets, shapes circle/square/diamond/hearts, patterns, bloom/halo helpers), `web/lib/dotmatrix-hooks.ts` (phase, cycle, reduced-motion hooks), `web/components/dotmatrix-loader.css` (`.dmx-root`, `--dmx-cycle: 1500ms`, `--dmx-opacity-base .16 / mid .32 / peak 1`, round dots, `currentColor` fill). Used only in `Splash.tsx`: `<DotmTriangle7 size={44} dotSize={7} ariaLabel="Loading" />` on the white splash. Adapted by inheriting `currentColor` (ink) so it reads as a quiet ink triangle of dots.
- HaloDropzone: from Cult UI, see Halo above; inlined its dependencies (no `halo-card`, `file-icons`, `file-type-placeholder` imports), uses lucide icons (Check, File, FileText, Upload, X).
- Lanyard and FolderFloat: React Bits (reactbits.dev); commit messages: "About: the developer, on a three.js lanyard (React Bits)" and "Docs: a floating folder of guides on the overview (FolderFloat from React Bits)".
- Skiper UI (skiper-ui.com): components 31, 39, 52, 66 were used in an earlier home "gallery" (commit "Gallery: stock Skiper 52 look and its original illustrations" and the "magazine cover / wall of photo panels" homes) and removed when the home was cleared back to a headline and button; credits remain in licenses. No Skiper component is in the current home. Open Peeps illustrations (CC0) under `public/images/peeps/` and archive photographs (`public/photos/*.webp`, CC0 via Openverse and rawpixel) feed the studio gallery and Board.
- lucide-react ^1.72.0 for icons in shadcn components; custom inline SVGs for everything in the brand (below). `class-variance-authority`, `tailwind-merge`, `clsx`, `tw-animate-css` come with shadcn.

### FolderFloat (docs overview)
Files: `site/src/FolderFloat.jsx` (372 lines), `site/src/FolderFloat.css` (49), mount in `site/src/main.jsx`, bundled by `bun build main.jsx --outdir .. --entry-naming folder.[ext] --minify` into `site/folder.js` and `site/folder.css` (script `build` in `site/src/package.json`; deps `matter-js` 0.20.0, `react` and `react-dom` 19.2.9). React Bits component: a tabbed folder (back panel with tab, paper, front flap that tilts open with `perspective(600px) rotateX`) from which pill notes spring out (`--ff-spring: cubic-bezier(0.34,1.57,0.64,1)`, `--ff-ease-out: cubic-bezier(0.23,1,0.32,1)`, stagger per pill) and, with `physics`, become Matter.js bodies (zero gravity, restitution .55, walls) that can be dragged and drift. Restyled in Bespoke's ink and paper via props:
```jsx
<FolderFloat items={GUIDES} label="Bespoke docs" sublabel={touch ? "Tap to open" : "Hover to open"}
  trigger={touch ? "click" : "hover"} defaultOpen={touch} closeOnSelect physics drift={0.5}
  onSelect={(href) => { location.href = href; }}
  folderColor="#0d1117" frontColor="#232c3b" paperColor="#ffffff" itemColor="#ffffff" itemTextColor="#0d1117" labelColor="#f2f3f5"
  width={220} height={156} radius={18} spread={touch ? 150 : 230} lift={30} tilt={7} openDuration={540} stagger={50} bounce={0.3} />
```
Pills: 38px high, 19px radius, `0 0 0 1px rgba(13,17,23,.07), 0 10px 24px -10px rgba(13,17,23,.35)`, focus ring `0 0 0 3px rgba(56,189,248,.7)`. Eight guide pills: Using Bespoke, How it is built, The tagging ladder, Text analytics, Reading pictures, Big data, MCP server, Contributing. Touch devices (`hover: none`) get click-to-open and start open. Reduced motion removes flap and pill transitions. Layout: `.find .wrap` two columns (5fr text / 7fr folder, `align-items: end`), `.folder-stage` padding-top 150px (190px under 860px) to leave room for notes above the folder.

## Icons, logo mark, favicon

- Mark (`web/components/site/Mark.tsx`): two chevrons closing in, "><", 24x24 viewBox, `stroke currentColor`, width 2.25, round caps and joins, path `M5 6.5l5 5.5-5 5.5M19 6.5l-5 5.5 5 5.5`, coloured `text-brand` (#38bdf8); `size-5` in the nav, `size-4` in the footer. In docs and the card it is rendered as the text glyphs `>` `<` coloured #38bdf8.
- Favicon `web/app/icon.svg`: 24x24, `<rect rx=6 fill=#0d1117>` with the chevrons in #38bdf8, stroke 2.3, path `M5.5 7l4.6 5-4.6 5M18.5 7l-4.6 5 4.6 5` (chevrons apart, per commit "Icon: chevrons apart, as in the mark"). `web/app/apple-icon.png` is 180x180 PNG of the same mark (commit "Tab and home-screen icon: the Bespoke mark").
- Ask launcher (`AskIcon.tsx`): 64x64 ink speech bubble (`currentColor`) with a white 3.8px smile ending in an arrow; open state swaps to a white X. Rendered at 68px, hover lift and scale as in Motion. Bubble path: `M10.5 7.5H42Q60 7.5 60 25.5V37.5Q60 58 39.5 58H36.5Q16 58 16 37.5V24.5Q16 18 11.6 15.2L8.2 13Q5.2 11 6.6 9.1Q7.7 7.5 10.5 7.5Z`.
- Back-to-top arrow and send arrow are simple 2.2px round-cap strokes (`M12 19V5M6 11l6-6 6 6`). Social glyphs are inline filled SVG paths. No emoji, no icon-in-badge patterns.
- Share image `web/public/og.png`.

## Docs site (`site/`)

Static, hosted on GitHub Pages at `/onestyle/` (`<base href="/onestyle/">`, clean folder URLs, no `.html`). Pages: `index.html` (overview), `guide/index.html`, `developers/index.html`, `mcp/index.html`, `contributing/index.html`. Shared: `style.css` (148 lines), `app.js` (107 lines, no libraries: sliding pill, `.reveal` observer, copy buttons, ranked heading search), `folder.js` + `folder.css` (built bundle, do not edit; edit `site/src` and rebuild with bun).

Matches the app by design ("Same language as the product: white, Google Sans, one accent, glass only on what floats"): tokens `--ink #0d1117, --ink-2 rgba(13,17,23,.62), --ink-3 rgba(13,17,23,.45), --line rgba(13,17,23,.09), --fill rgba(13,17,23,.04), --accent #38bdf8, --accent-ink #0369a1, --paper #fff`. Body 17px/1.6. Hero `padding 120px 0 72px`; `section {padding: 88px 0; border-top: 1px solid var(--line)}` (64px on narrow); `.cols` grid 4fr/7fr that stacks under 860px.

Overview content order: hero h1 "Clothes made / from your words." with lede and two buttons ("Read the guide" ink, "How it is built" ghost ring), "Pick a guide" section with the folder, "What it does", a black `.dark` band "Understanding that does not break", and a "Start here" grid of four lift cards (Using Bespoke, Developer guide, MCP server, Contributing). Footer: `>< Bespoke · Engineered by Ritesh Roshan` plus Product and GitHub links.

Details worth copying: code blocks `#0d1117` background, `#e6edf3` text, 20px radius, 14px/1.6 mono, wrapped (`white-space: pre-wrap; overflow-wrap: anywhere; padding-right: 92px`) with a pinned pill "Copy" button (32px, `rgba(255,255,255,.1)`, turns accent `#38bdf8` with ink text when "Copied"; always visible on touch, hover-revealed otherwise); inline code `background var(--fill)`, radius 8px; tables wrapped in a 20px-radius overflow container with hairline ring, header 13px ink-3; steps list with 36px numbered circles on `--fill`; repo map as a `dl` grid `minmax(170px,34%) 1fr`. The Ask-style search (`.ask-btn` 52px ink pill with a `kbd` hint, `.panel` 420px glass card radius 28px, results pop with `@keyframes pop`) searches every h1-h3 of all five pages, fetched once and ranked by word overlap.

## UI dependencies (web/package.json)

```
next 16.3.8 (output: "export", images unoptimized, trailingSlash true)   react / react-dom 19.3.0
tailwindcss ^4.3.5   @tailwindcss/postcss ^4.3.5   (postcss.config.mjs: { plugins: { "@tailwindcss/postcss": {} } })
motion ^14.12.0      three 0.186.1        tw-animate-css ^1.4.0
class-variance-authority ^0.7.1   clsx ^2.1.1   tailwind-merge ^3.7.0   lucide-react ^1.72.0
@excalidraw/excalidraw 0.18.1 (the moodboard canvas; restyled in legacy.css with ink primary tokens)
unused: gsap ^3.15.1, lenis ^1.3.27, metal-fx ^2.0.11
site/src: matter-js 0.20.0, react 19.2.9, react-dom 19.2.9
```
No `tailwind.config`; everything is in `app/globals.css`: `@import "tailwindcss"; @source not "../public"` (stops Tailwind scanning `public/`, which once held builds for minutes; commit 659ae8a), `@import "tw-animate-css"`, `@import "./legacy.css" layer(components)` (the older hand-written studio stylesheet sits above the reset, below utilities), `@custom-variant dark (&:is(.dark *))`, `@custom-variant fine-hover (@media (hover: hover) and (pointer: fine))` for hover effects only on real pointers. Tailwind arbitrary values (`text-[clamp(...)]`, `rounded-[36px]`, `shadow-[...]`) are the primary styling mode.

## Chronology of decisions (from commit messages)

- 2026-10-04: first build "Apple-style", then "Readable editorial design on white" and "Atelier redesign".
- 2026-11-12: ink and cyan palette with the chevron mark; magazine-cover and photo-wall homes tried and dropped ("Home, simplified: one ground, one image treatment, almost no copy" then "Clear the home page back to a headline and one button"); "plain text buttons with balanced padding"; "Google Sans throughout, floating glass nav, new footer, rounder Ask bubble"; a curved puffy footer wordmark was added and reverted (the wordmark is flat and cropped-tight now); studio rebuilt "in the home page look: glass pill nav, Google Sans display, quiet brief field"; Talk goes black for the empty state ("a tunnel with white type and a dark glass nav"), later "Talk stays white" with the how-it-works band in black; docs get the same nav and a floating FolderFloat; About adds the three.js lanyard.
- 2026-11-13: Board gets full-screen reading with a halo; Board pet talks in bubbles.
- Rule that emerged: almost no copy, one image treatment, one primary action per screen, glass only on floating things (nav, menus, Ask panel), black only as a full-bleed band or the primary button.

## Gaps

- Studio internals (Talk composer, Sheet paper, Shop cards, Board toolbars, Excalidraw skin, Pet) and auth pages are only touched where they share tokens; legacy.css (18KB) was skimmed, not catalogued line by line.
- The Lanyard's shader and physics internals are summarised, not reproduced; the file is self-contained (copy `Lanyard.jsx` and `Lanyard.css` from React Bits with the `three` import to rebuild).
- No screenshots were taken; values come from source.
