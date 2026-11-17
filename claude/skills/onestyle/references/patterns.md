# Patterns: components and pages

Each pattern is: what it is, when to use it, how to build it, and the Bespoke example. Values come from tokens.md; read it first. Paths are written `bespoke: web/...` and point into the example repo (`C:\Users\roshh\Desktop\ta&bda`, GitHub riteshroshann/onestyle). Utilities `text-ink`, `bg-spark`, `press`, `display` and the `SPRING` and `SOFT` constants are defined in tokens.md.

Login, sign-up, reset and the sign-in gate are in login.md, not here.

---

## Glass pill navbar

**What it is.** A floating pill pinned near the top, centred, with the logo left and links right. It is the one place glass lives besides menus and the help panel.

**When to use.** Every product with more than one page. App variant for a product, docs variant for a static docs site.

**How to build (app variant).**

1. A fixed, full-width, click-through wrapper (`pointer-events-none`) holds a centred pill that re-enables events.
2. Pill: height 60px, max width 1180px, `rounded-full`, `pl-5 pr-2`, `bg-white/65 backdrop-blur-2xl backdrop-saturate-[1.8]`, the nav shadow and ring from tokens.md.
3. Logo is the mark plus the name at 21px; links are right-aligned (`ml-auto`), not centred.
4. Active link is `bg-quiet` via `aria-current="page"`. Links `hidden sm:block`; under 640px only the logo and one action show.
5. Dark tone for a black page: `bg-ink/70 ring-white/10`, links white, hover and active `bg-white/10`.

```tsx
<header className="pointer-events-none fixed inset-x-0 top-3 z-40 px-3 md:top-4 md:px-6">
  <div className="pointer-events-auto mx-auto flex h-[60px] max-w-[1180px] items-center gap-3 rounded-full pl-5 pr-2
    bg-white/65 ring-1 ring-black/[.06] backdrop-blur-2xl backdrop-saturate-[1.8]
    shadow-[0_8px_32px_-12px_rgba(13,17,23,.18),inset_0_1px_0_rgba(255,255,255,.6)]">
    <a href="/" className="inline-flex items-center gap-2 text-[21px] font-medium tracking-[-0.03em]"><Mark className="size-5" />Name</a>
    <nav className="ml-auto flex items-center gap-1">
      <a aria-current={current === href ? "page" : undefined}
         className="press hidden rounded-full px-4 py-2 text-[15px] font-medium hover:bg-quiet aria-[current=page]:bg-quiet sm:block">Label</a>
    </nav>
  </div>
</header>
```

A menu from the nav (for example a two-row chooser) is a 260px glass card, `rounded-[22px] bg-white/90 p-1.5 backdrop-blur-2xl`, rows `rounded-[16px] hover:bg-black/[.04]`, title 15px, note 13px ink/55; it closes on outside pointerdown and Escape.

**Docs variant (true sliding pill).** Same 60px glass (`rgba(255,255,255,.7)`, `blur(40px) saturate(1.8)`, max 1120px). The links container holds an absolutely positioned ink `.pill`. JS sets its `left` and `width` from the current link's `offsetLeft` and `offsetWidth`, with `transition: left .45s, width .45s cubic-bezier(.32,.72,0,1)`. On hover it moves to the hovered link (text turns white); on leave it returns. Re-measure on `document.fonts.ready` and resize. Links hide under 860px. The right side is an ink CTA, 44px.

```js
function place(a){ pill.style.left = a.offsetLeft + "px"; pill.style.width = a.offsetWidth + "px"; }
links.querySelectorAll("a").forEach(a => {
  a.addEventListener("mouseenter", () => place(a));
});
links.addEventListener("mouseleave", () => place(current));
document.fonts.ready.then(() => place(current));
addEventListener("resize", () => place(current));
```

**Bespoke example.** `bespoke: web/components/site/Header.tsx` (app, static `bg-quiet` active link, no slide), `bespoke: site/style.css` and `bespoke: site/app.js` (docs, sliding pill).

---

## Buttons and inputs

**What it is.** Pill buttons that squash on press, ring-only secondaries, and soft pill or 16px-radius inputs.

**When to use.** Everywhere. One primary per screen.

**How to build.**

- Primary: `press inline-flex items-center justify-center whitespace-nowrap rounded-full font-medium leading-none tracking-[-0.01em]`. Dark tone `bg-ink text-white hover:bg-ink-hover`; light tone (on black) `bg-white text-ink hover:bg-white/85`. Sizes: md `h-11 px-6 text-[15px]`, lg `h-14 px-9 text-[17px]`. Hero uses lg.
- Secondary: `ring-1 ring-ink/15 hover:bg-ink/[.04] hover:ring-ink/30`, or a text link with `underline decoration-ink/25 underline-offset-[6px]` that goes to full ink on hover.
- Chip: `h-10 rounded-full px-4 text-[14px] font-medium ring-1 ring-ink/10 hover:bg-ink/[.04] hover:ring-ink/25`.
- Icon button: `size-9`, `size-11` or `size-12` circle, ink fill, `focus-visible:ring-4 ring-spark/50`, `whileTap={{ scale: 0.9 }}`.
- Busy label: a verb in -ing form ("Sending", "Saving", "One moment"), disabled at 50% opacity.
- Input (search, big fields): height 48px to 52px, `rounded-full` or 16px, fill ink/4, ink/6 on hover, on focus white with the field shadow and ring ink/20. Text 16px. Label above at 13px medium ink/55.
- Native widgets leak: under browser autofill keep the radius with `-webkit-box-shadow: 0 0 0 1000px #f5f5f6 inset`, `-webkit-text-fill-color` ink and a long `transition: background-color 9999s`; hide Edge's `::-ms-reveal` and `::-ms-clear`.
- Segmented control or language switch: track `relative flex h-11 items-center rounded-full bg-ink/[.05] p-1 text-[14px] font-medium`; the selected option renders `<motion.span layoutId={id} transition={SPRING} className="absolute inset-0 rounded-full bg-ink" />` behind white text.

```tsx
export function Cta({ href, tone = "dark", size = "md", children }: Props) {
  const tones = { dark: "bg-ink text-white hover:bg-ink-hover", light: "bg-white text-ink hover:bg-white/85" };
  const sizes = { md: "h-11 px-6 text-[15px]", lg: "h-14 px-9 text-[17px]" };
  return <a href={href} className={`press inline-flex items-center justify-center whitespace-nowrap rounded-full
    font-medium leading-none tracking-[-0.01em] ${tones[tone]} ${sizes[size]}`}>{children}</a>;
}
```

**Bespoke example.** `bespoke: web/components/site/Cta.tsx`; the segmented control in `bespoke: web/components/App.tsx` (language switch, EN and Hindi).

---

## Cards

**What it is.** A white surface with a hairline ring and a long soft shadow. Never a border, never nested.

**When to use.** Only for things you click or pick (link cards, choice cards, results). For plain marketing content use an open column with a top hairline instead.

**How to build.**

1. Radius 24px, white, `shadow-[0_0_0_1px_rgba(13,17,23,.09)]`.
2. Lift on hover: `whileHover={{ y: -3 }}`, shadow deepens to the card-hover value; an arrow inside drifts 3px up-right. On touch skip the lift (`fine-hover` variant).
3. Choice cards (pick one of several) rest on `bg-quiet`; the selected card goes white with a spark ring and a long shadow.
4. Icon tile inside is 44px, radius 12px.

```tsx
<motion.a whileHover={{ y: -3 }} transition={SPRING} href={href} target="_blank" rel="noreferrer"
  className="block rounded-[24px] bg-white p-6 shadow-[0_0_0_1px_rgba(13,17,23,.09)]
    hover:shadow-[0_0_0_1px_rgba(13,17,23,.12),0_24px_50px_-28px_rgba(13,17,23,.4)]">
  <h3 className="text-[24px] font-medium tracking-[-0.02em]">{title}</h3>
  <p className="mt-2 text-[16px] leading-[1.55] text-ink/60">{note}</p>
</motion.a>
```

**Bespoke example.** The shop result cards in `bespoke: web/components/App.tsx` (ShopView) and the docs "Start here" grid in `bespoke: site/index.html`.

---

## First-screen hero: one headline, one action

**What it is.** The home page. A giant two-line headline, one pill button, the footer. No lede, no image, no band.

**When to use.** The front page of any product. Explaining belongs below the action, in the black band, or on its own page.

**How to build.**

1. Page is `flex min-h-[100svh] flex-col bg-white text-ink` with the navbar, a `main` that centres, and the footer.
2. Headline: `display text-[clamp(56px,9vw,160px)] leading-[0.92]`, broken into two lines by hand. A statement, ending in a full stop, five words or fewer.
3. Action: one lg primary button `mt-16 md:mt-24` under the headline.
4. Inner pages use the mask reveal on the h1 (each line clips and slides up on SOFT with a 100ms stagger). The home headline can stay static so the first paint is instant.

```tsx
<main className="flex flex-1 items-center pb-24 pt-40 md:pb-32 md:pt-48">
  <div className="mx-auto w-full max-w-[1440px] px-5 md:px-10">
    <h1 className="display text-[clamp(56px,9vw,160px)] leading-[0.92]">Line one<br />line two.</h1>
    <div className="mt-16 md:mt-24"><Cta href="/start/" size="lg">Start</Cta></div>
  </div>
</main>
```

Mask reveal for an inner page head:

```tsx
{["First line,", "second line."].map((line, i) => (
  <span key={line} className="block overflow-hidden pb-[0.08em]">
    <motion.span className="block" initial={{ y: "105%" }} animate={{ y: 0 }}
      transition={{ ...SOFT, delay: 0.08 + i * 0.1 }}>{line}</motion.span>
  </span>))}
```

**Bespoke example.** Home: "Made from / your words." and a button "Start a design" (`bespoke: web/components/home/HomePage.tsx`). Page title "Bespoke · Clothes made from your words", share image 1200x630.

---

## The black band

**What it is.** One full-bleed ink section, white type, near the foot or below the first action. It is where the product explains itself.

**When to use.** Once per page at most. It is the only place black fills a section.

**How to build.**

1. `bg-ink text-white`, container `max-w-[1440px] px-5 md:px-10 py-[clamp(64px,9vw,128px)] mx-auto`.
2. Heading: display, `clamp(36px,4.6vw,64px)`, `max-w-[12ch]`.
3. Steps: `grid gap-10 sm:grid-cols-3`; each item `border-t border-white/15 pt-5` with a 13px number at white/40, a 20px medium title, a 15px body at white/60 `max-w-[34ch]`. They rise once on scroll (`y: 14`).
4. Close with a white pill button (light tone), h-12.
5. A quote variant: heading left, two paragraphs right in the quote size, a 15px white/60 byline, then a light lg button.

```tsx
<section className="bg-ink text-white">
  <div className="mx-auto max-w-[1440px] px-5 py-[clamp(64px,9vw,128px)] md:px-10">
    <h2 className="display max-w-[12ch] text-[clamp(36px,4.6vw,64px)]">How it works.</h2>
    <ol className="mt-16 grid gap-10 sm:grid-cols-3">{steps.map((s, i) => (
      <motion.li key={s.title} {...rise} className="border-t border-white/15 pt-5">
        <span className="text-[13px] text-white/40">{i + 1}</span>
        <h3 className="mt-2 text-[20px] font-medium">{s.title}</h3>
        <p className="mt-2 max-w-[34ch] text-[15px] text-white/60">{s.text}</p>
      </motion.li>))}</ol>
  </div>
</section>
```

The docs equivalent is a `.dark` section on `#000` with `radial-gradient(120% 80% at 50% -20%, #1b1f27 0%, #07080a 55%, #000 100%)`, the only band gradient. A whole page turned black (a tunnel) was tried and reverted; keep black as a band.

**Bespoke example.** "How it works." on the Talk page (Describe it, Answer a few questions, Take it to a maker) and "The vision" on About, both in `bespoke: web/components/App.tsx` and `bespoke: web/components/about/AboutPage.tsx`.

---

## The footer

**What it is.** A white footer with a tag line, two link columns, a giant wordmark and a bottom bar.

**When to use.** Every page.

**How to build.**

1. Same 1440 container. Tag line 28px (34px from `md`), a short imperative sentence. Two link columns: a title at 15px ink/55, links 16px with `space-y-3`, no underline, hover ink/60.
2. Wordmark: `display text-[clamp(88px,25.2vw,386px)] leading-[0.95] tracking-[-0.06em] -ml-[0.05em] pb-[0.06em] whitespace-nowrap select-none`, `aria-hidden`, `mt-20 md:mt-28`. Flat, not curved.
3. Bottom bar: `border-t border-ink/10`, the mark plus name at 16px, "Engineered by <author>" at 14px ink/65, and `pr-24 md:pr-28` so the corner helper never covers it.
4. Include a Credits link to `licenses.txt` when any third-party component ships.

```tsx
<footer className="mx-auto max-w-[1440px] px-5 pt-24 md:px-10">
  <div className="grid grid-cols-2 gap-y-12 md:grid-cols-12">
    <p className="col-span-2 text-[28px] leading-[1.15] tracking-[-0.025em] md:col-span-6 md:text-[34px]">Tag line.</p>
    <nav className="md:col-span-3"><h4 className="text-[15px] text-ink/55">Group</h4>
      <ul className="mt-4 space-y-3 text-[16px]"><li><a className="hover:text-ink/60" href="/about/">About</a></li></ul></nav>
  </div>
  <div aria-hidden className="display -ml-[0.05em] mt-20 select-none whitespace-nowrap pb-[0.06em]
    text-[clamp(88px,25.2vw,386px)] leading-[0.95] tracking-[-0.06em] md:mt-28">Name</div>
  <div className="flex justify-between border-t border-ink/10 py-6 pr-24 text-[14px] text-ink/65 md:pr-28">...</div>
</footer>
```

**Bespoke example.** `bespoke: web/components/site/Footer.tsx`; tag line "Say it. We will cut it.", columns "Make" and "Bespoke".

---

## The composer

**What it is.** The one input where a person types or speaks a request in their own words. A big rounded form with a cycling example placeholder, optional voice, and a staged reveal for the reply.

**When to use.** When the product's first act is "tell it what you want" (describe, ask, search). Not for forms with many fields.

**How to build.**

1. Big variant (empty state): radius 32px, padding 12px (left 28px), textarea grows to 180px, text `clamp(19px,1.7vw,24px)`, opens focused. Compact variant (docked once a conversation starts): radius 28px, 17px text, grows to 120px. Ring ink/10, ink/25 on focus, destructive/40 while recording. Cap length (600 characters). Enter sends, Shift+Enter breaks the line.
2. Cycling placeholder: a live example that swaps every 3.4s with a blur-slide (`y 8 to 0`, blur 4px). Static once a conversation has started ("Add a detail or change anything"). The examples are real, specific requests, not "Type here".
3. Send: a 44px to 48px ink circle with an arrow, springing between scale .86 and 1 and opacity .3 and 1 as text appears. Disabled while thinking or recording.
4. Hint line under the big form: nothing when empty; with text "Enter to send, Shift and Enter for a new line".
5. Voice (only where supported): a 44px mic beside send, plus a two-option language switch that slides an ink pill via `layoutId`. Recording state: mic turns destructive, a halo scales with volume, five bars follow the voice, a `0:07` clock, "Listening. Pause when you are done." and a Cancel link. Transcribing: dots and "Writing down what you said". The transcript lands in the field for review and is never sent by itself; the server must say it heard a voice, so noise never becomes a made-up request.
6. Mic errors are one line with the fix and a "Try again" link.
7. Staged reveal of the reply: the product's answer has no bubble; a 36px avatar with the mark, then 21px to 26px medium text revealed word by word (`Reveal`). Earlier replies dim to 55% and brighten on hover. The person's message is a right-aligned ink bubble (see Chat bubbles).

```tsx
const [i, setI] = useState(0);
useEffect(() => { const t = setInterval(() => setI((n) => (n + 1) % EXAMPLES.length), 3400); return () => clearInterval(t); }, []);
<div className="relative">
  <textarea value={v} onChange={(e) => setV(e.target.value)} maxLength={600} rows={1}
    onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); } }}
    className="w-full resize-none bg-transparent text-[clamp(19px,1.7vw,24px)] outline-none" />
  {!v && <AnimatePresence mode="wait"><motion.span key={i} className="pointer-events-none absolute inset-0 text-ink/40"
    initial={{ opacity: 0, y: 8, filter: "blur(4px)" }} animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
    exit={{ opacity: 0 }}>{EXAMPLES[i]}</motion.span></AnimatePresence>}
</div>
```

**Bespoke example.** `bespoke: web/components/App.tsx` (the composer, voice switch EN and Hindi). Placeholders: "A pastel blue kurti for my farewell", "Ek maroon lehenga, gota patti ke saath", "A linen shirt with a mandarin collar", "A black blouse with a deep back". Mic error: "The microphone is blocked. Allow it from the icon in the address bar, then try again."

---

## Questions after the composer

**What it is.** The product asks only what is missing, one question at a time.

**When to use.** After a free-text request that leaves gaps.

**How to build.** Cap at four questions. Rank them and ask the best first. Every question is skippable, and skipped ones are remembered and never asked again. Options render as pictures when every option has one, otherwise as 44px pills (ink/5 fill, solid ink with white text on hover). The skip row is a ringed pill "Skip" and grey text "or type your own answer below". When nothing is left to ask, hand over to the next step instead of listing a menu. Never ask for what can be inferred or edited later (see voice.md, Ask less, infer more).

**Bespoke example.** `bespoke: web/lib/engine/spec.ts` (`QUESTION_CAP = 4`); "Who is it for?" with "a woman", "a man", "anyone".

---

## Chat bubbles

**What it is.** Two-sided message bubbles with one cut corner as the tail.

**When to use.** Help panels, threads, the pet. In the main conversation, prefer typography for the product's voice and a bubble only for the person.

**How to build.**

- Person: ink fill, white text, radius 20px with 6px bottom-right (26px and 8px for large), right-aligned, `max-w-[85%]`, 15px.
- Product: `#f2f3f5` fill, ink text, 6px bottom-left.
- Pop in on SPRING from `{opacity 0, y 12, scale .96}`, `transformOrigin` from the speaking side.
- Thinking: the avatar plus `Dots` in a `#f2f3f5` bubble.
- Failed: blush `#fdf1f1`, text `#8a1c1c`, a "Try again" text button that re-asks in place.
- Skipped answer: grey bubble (ink/5).

```tsx
<motion.div initial={{ opacity: 0, y: 12, scale: 0.96 }} animate={{ opacity: 1, y: 0, scale: 1 }} transition={SPRING}
  style={{ transformOrigin: mine ? "bottom right" : "bottom left" }}
  className={`max-w-[85%] px-4 py-2.5 text-[15px] leading-[1.45] ${mine
    ? "ml-auto rounded-[20px] rounded-br-[6px] bg-ink text-white"
    : "rounded-[20px] rounded-bl-[6px] bg-[#f2f3f5]"}`}>{text}</motion.div>
```

**Bespoke example.** The customer bubble in Talk and the assistant bubbles in `bespoke: web/components/site/Assistant.tsx`. Recognised phrases in the person's bubble get a dashed spark underline (`.stitched`) with a title of what they were understood as.

---

## The corner Ask helper

**What it is.** A round launcher in the bottom-right that opens a small glass chat panel answering from the product's own guides.

**When to use.** Products with guides or a docs site. One helper per page: hide it wherever another helper lives.

**How to build.**

1. Launcher: 68px ink speech-bubble icon (a smile inside), drop shadow, hover `-translate-y-1 scale-[1.07]` on `cubic-bezier(.34,1.56,.64,1)` over 500ms. Rises to `bottom-24` where a dock sits; hidden on a `HIDDEN` list of routes with their own helper.
2. Panel (floating, so glass): 400px wide, up to 600px tall, radius 28px, `bg-white/90 backdrop-blur-2xl` with a hairline ring. Opens from the launcher corner on SPRING from `{scale .92, y 24, blur 6px}`. Escape closes and returns focus. Header: icon, "Ask", "Answers from <product>'s guides", "New chat" once there is a conversation.
3. Empty state: a 26px greeting and three starter pills. With context open (a design, a document), starters switch to prompts about that context.
4. Answers: word-by-word reveal over a full answer (a staged reveal, not a network stream). Under an answer, up to two action buttons to the page the answer is about (first ink, second ringed) and a source line "From <guide> and <guide>".
5. Composer inside: 24px radius field on `#f2f3f5` that lifts to white on focus, grows to four lines, 600 characters, a round ink send arrow that fades in with text.
6. Failure: blush bubble with "Try again". If not configured: "I am not switched on yet."
7. Server rules: POST only; rate limit per caller; input guard first; redact personal data; BM25 retrieval over the guides and answer only if the passages cover the question, otherwise a fixed refusal naming what it can help with; two or three sentences, 60 words at most, answer first, no invented features, prices or policies; light model first, full model as fallback, inside one time budget; never log message text. See stack.md, model APIs.

```tsx
<AnimatePresence>{open && (
  <motion.section role="dialog" aria-label="Ask" transition={SPRING} style={{ transformOrigin: "bottom right" }}
    initial={{ opacity: 0, y: 24, scale: 0.92, filter: "blur(6px)" }} animate={{ opacity: 1, y: 0, scale: 1, filter: "blur(0px)" }}
    exit={{ opacity: 0, y: 16, scale: 0.94, filter: "blur(4px)" }}
    className="fixed bottom-24 right-4 flex max-h-[600px] w-[min(400px,calc(100vw-32px))] flex-col rounded-[28px]
      bg-white/90 ring-1 ring-black/[.06] backdrop-blur-2xl md:right-6">{children}</motion.section>)}</AnimatePresence>
```

**Bespoke example.** `bespoke: web/components/site/Assistant.tsx`, `bespoke: web/api/assistant.js`. Greeting "Hi. What are you making today?"; starters "How do I measure my bust?", "What is ease?".

---

## The pet that speaks in bubbles

**What it is.** A small animated character with a mood and no text box. It talks in short stacked bubbles and reacts to what the person does.

**When to use.** A work surface (a canvas, a board, a long task) where a text helper would be in the way. It replaces the Ask helper on that page.

**How to build.**

1. Body: a 60px ink squircle with a small tuft and white eyes, anchored bottom-left of the work area (`bottom-[150px]` on phones to clear a toolbar, `bottom-[76px]` from `md`). It breathes (scale 1 to 1.035 over 3.2s), blinks at random 2.6s to 5.2s, and its eyes follow the cursor by up to 3px.
2. Moods: idle; thinking (bobs and tilts, eyes up-right, dots bubble); happy (eyes become arcs, hops 10px, 1.4s). Reduced motion: holds still.
3. Speech: bubbles stack at most three above it. The newest is ink with white text; older ones are `bg-white/95` glass at 62% opacity and drift away. The tail is the 6px corner, not a drawn tail.
4. Pacing: queue sentences with `setTimeout` at 1.1s intervals so it feels like talking.
5. Tapping the pet hides or shows its words (`aria-label` "Hide what your board buddy says"); new words bring the bubbles back.
6. Lines are short, warm, first person, and report what actually happened ("I wrote it all on your board."). Say the true state, including failure with the fix.

```tsx
<motion.li key={s.id} layout={!still} style={{ transformOrigin: "bottom left" }} transition={SPRING}
  initial={{ opacity: 0, y: 14, scale: 0.9 }} animate={{ opacity: last ? 1 : 0.62, y: 0, scale: 1 }}
  exit={{ opacity: 0, y: -8, scale: 0.94, transition: { duration: 0.2 } }}
  className={`rounded-[20px] rounded-bl-[6px] px-4 py-2.5 text-[15px] leading-[1.45]
    shadow-[0_14px_40px_-18px_rgba(13,17,23,.35)] ring-1 ring-black/[.05]
    ${last ? "bg-ink text-white" : "bg-white/95 text-ink backdrop-blur-xl"}`}>{s.text}</motion.li>
```

**Bespoke example.** `bespoke: web/components/board/Pet.tsx`. Lines: "Hi. Drop or paste anything you love: clothes, art, places, a colour." and "Reading 3 pictures."

---

## The halo and aura for thinking moments

**What it is.** The one colourful thing in the product: a blurred rotating conic gradient behind the object being analysed, with a scanning light sweep over it.

**When to use.** A single long machine-thinking moment where the person watches something being read. Colour appears only then; the rest stays ink and white.

**How to build.**

1. Register an angle property so the gradient can animate: `@property --aura-angle`.
2. `.aura` sits behind the object, `inset: -14%`, blurred 54px, opacity .55, spinning 7s and breathing 3.4s.
3. The object is a white card (`rounded-[36px]`, picture-card shadow, `ring-white/60`, entering with `scale .92 rotate -2deg` on SOFT, size `min(300px,70vw)`).
4. `.sweep::after` is a light band across it.
5. Steps beside it: dots that pulse spark while working, ink when done, destructive/70 when failed, grey when skipped. Under reduced motion, freeze the halo and drop the sweep.

```css
@property --aura-angle { syntax: "<angle>"; inherits: false; initial-value: 0deg; }
.aura { position: absolute; inset: -14%; border-radius: 42%;
  background: conic-gradient(from var(--aura-angle), #4285f4, #9b72cb, #d96570, #f2a93b, #2fa7a0, #4285f4);
  filter: blur(54px) saturate(1.25); opacity: .55; animation: aura-spin 7s linear infinite, aura-breathe 3.4s ease-in-out infinite; }
@keyframes aura-spin { to { --aura-angle: 360deg; } }
@keyframes aura-breathe { 50% { opacity: .82; transform: scale(1.05); } }
.sweep::after { content: ""; position: absolute; inset: 0 0 auto 0; height: 38%; mix-blend-mode: soft-light;
  background: linear-gradient(180deg, transparent, rgba(255,255,255,.5) 55%, rgba(255,255,255,.85) 60%, transparent 62%);
  animation: sweep 2.2s cubic-bezier(.45,0,.25,1) infinite; }
@keyframes sweep { from { transform: translateY(-110%); } to { transform: translateY(290%); } }
```

A full-screen version is a `role="dialog"` modal with three phases: reading (halo, thumbnails dimmed to 50% except the active one, step list, a Cancel), done (heading, summary, choices, a floating glass footer on desktop and a bottom sheet on phones), and stopped (the message always includes the fix, with "Try again" and "Back").

The drop zone on that screen's empty state was a Cult UI Halo Dropzone, kept in its own rainbow rim as the single colourful moment there. For a new product, recolour a drop zone to ink and spark or skip it.

**Bespoke example.** `bespoke: web/components/board/Reading.tsx`, `bespoke: web/app/globals.css` (`.aura`, `.sweep`, `.shimmer-text`), `bespoke: web/components/ui/halo-dropzone.tsx`. Notices are honest about what ran: "Read on this device. Ideas from any picture arrive once the reader is switched on for this site."

---

## The dot-matrix loader and splash

**What it is.** A quiet ink loader made of a small grid of dots, used on a splash that covers fresh loads.

**When to use.** To cover the moment before the font and first paint are ready, so nothing shows half-dressed.

**How to build.**

1. A full-screen white cover shown until `document.fonts.ready` plus a 700ms minimum (long enough to register, short enough not to feel like a wait), then a 500ms fade out.
2. Centre a 7x7 dot grid masked to a shape (Bespoke: a triangle), dot size 7, size 44, cycling opacities base .06, mid .38, high .96, `--dmx-cycle: 1500ms`, fill `currentColor` so it inherits ink.
3. `aria-label="Loading"`. Stops under reduced motion.
4. Source: the shadcn registry `@dotmatrix` (MIT) at `https://dotmatrix.zzzzshawn.cloud/r/{name}.json`. Use one component; do not ship the whole library.

```tsx
const [gone, setGone] = useState(false);
useEffect(() => {
  const min = new Promise((r) => setTimeout(r, 700));
  Promise.all([document.fonts.ready, min]).then(() => setGone(true));
}, []);
<AnimatePresence>{!gone && (
  <motion.div exit={{ opacity: 0 }} transition={{ duration: 0.5 }}
    className="fixed inset-0 z-50 grid place-items-center bg-white text-ink"><Loader size={44} dotSize={7} ariaLabel="Loading" /></motion.div>)}</AnimatePresence>
```

Lighter loading, in order of weight: the splash; three bouncing dots in a grey bubble for chat waits; one grey sentence for a page resume ("Opening your last design"); verb-ing button labels.

**Bespoke example.** `bespoke: web/components/site/Splash.tsx`, `bespoke: web/components/ui/dotm-triangle-7.tsx`, `bespoke: web/lib/dotmatrix-core.tsx`.

---

## Empty and error states

**What it is.** The screens for "nothing here yet" and "that failed".

**When to use.** Every list, thread, board and request that can be empty or fail.

**How to build.**

- Empty: a ghosted display word at ink/10 or one warm sentence (28px), plus one clear next step as an ink 56px pill. Say how the space will fill ("Each detail you mention settles here, part by part").
- Error: destructive `#b5121b` text, `role="alert"`, 14px, animates open with height 0 to auto, sits above the button. Say what happened, then what to do, in one or two sentences. Never "Oops", never an exclamation mark, never a code. A card that took bad input may shake once (`x: [0,-8,8,-5,5,0]`, 400ms).
- Offline and degraded: name what ran instead ("your device read this alone").
- Failed bubbles: blush with a "Try again" button.

```tsx
<div className="py-24">
  <p className="max-w-[28ch] text-[28px] leading-[1.15] tracking-[-0.02em]">Your sheet fills in as you describe the thing. Start in Talk, then come back.</p>
  <Cta href="/talk/" size="lg">Describe it</Cta>
</div>
```

**Bespoke example.** "No requests yet." and "When a customer sends you a design, it lands here with the full sheet and their measurements."; "Describe a garment" button on an empty sheet.

---

## The author page with the 3D lanyard badge

The full working source (Lanyard.jsx, its CSS, types and strap texture) ships in the **finish** skill under assets/lanyard; copy it from there.

**What it is.** An about page that carries the author's name and a draggable 3D ID badge hanging on a rope. A reusable author-page pattern: any product that credits its maker can ship it.

**When to use.** A portfolio, an about page, a studio page. It is optional; ship it only when the page has room for one memorable object. Section order: hero (mask-reveal h1 and a lede), the problem (two paragraphs), how it works (four open columns with links), the author block (lanyard on one side, text and social pills on the other), then the black band with the vision.

**How to build.**

1. Source is React Bits "Lanyard", but as plain `three` (0.186.1): no react-three-fiber, no drei, no rapier. Imperative `THREE.WebGLRenderer` in a `useEffect`, a hand-written physics step, canvas-painted textures. Adapt, credit in `licenses.txt`.
2. Load with `dynamic(() => import("./Lanyard"), { ssr: false, loading: () => null })` so three runs only in the browser and the page's first paint pays nothing.
3. The card sits in a rounded stage `h-[560px] md:h-[640px] rounded-[36px] bg-[#f4f5f7]` with a hint at the foot: "Drag the card. Flip it over." (13px, ink/40).
4. Textures: card faces are 2D canvases painted at width 1024 from images (`front`, `back`, 1024x1440 JPG), wrapped as `THREE.CanvasTexture` with `SRGBColorSpace` and anisotropy `min(8, max)`. Strap from a 1600x256 PNG over the ink colour. Design the front as a real ID: photo, wordmark, name, role, a line of place and handle. Grain and weave textures are generated procedurally in canvas.
5. Renderer: `antialias, alpha, powerPreference: "high-performance"` inside try/catch; `setClearColor(0x000000, 0)` so the stage colour shows; `outputColorSpace = SRGBColorSpace`; `toneMapping = NeutralToneMapping`; `PerspectiveCamera(24, 1, 0.1, 200)`; two directional lights (1.6 at -2.5,4,6 and 0.35 at 3,-1,4).
6. Environment map: no HDRI download. Build a small studio scene (dark background 0.035, eight emissive plane softboxes with intensities 6, 4, 3.5, 2.6, 2.5, 1.4, 0.9, 0.5) and run it through PMREM into `scene.environment`.
7. Card: thickness 0.018, bevel 0.007, portrait 1.6 x 2.25; glossy finish `roughness .42, clearcoat 1, clearcoatRoughness .06` (matte, holographic and metallic also available). A metal ring, eyelet and clamp join it to the strap (72 samples, 4 columns).
8. Physics: a verlet chain of 4 joints plus an anchor and a rigid card body with position, quaternion, angular velocity and inverse inertia. Constants: `ITERATIONS 2`, `MAX_STEP 1/960`, `NODE_WEIGHT 20`, `FLIP_SPIN 9`, twist 30 and damping 3, grip 40 and damping 6, nodeDrag 2, nodeAir .2, broadside .5. Clamp `dt` to [1/240, 1/30]; on NaN reset to the hanging pose. Breeze adds a gentle sway.
9. Interaction: pointer events with `THREE.Raycaster`; drag grabs with a spring grip and release swings; a press under 450ms without movement flips the card (spin impulse); cursor `grab`; a non-passive `touchstart` so the page still scrolls off the card.
10. Performance and fallback: an `IntersectionObserver` pauses the loop off screen; `visibilitychange` restarts it; stop when at rest and restart on interaction; `ResizeObserver` resizes; pixel ratio `min(devicePixelRatio, 2)`; dispose every geometry, material, texture, environment and the renderer on unmount. No WebGL: the stage shows the grey panel and the hint only. Reduced motion skips the intro drop and zeroes the breeze. The canvas is `aria-hidden`.
11. Social pills beside it: GitHub filled ink first, others ringed, `h-14 rounded-full pl-5 pr-6 text-[16px] font-medium`, inline SVG glyph `size-5`, handle at 13px and 50% opacity, spring in with stagger `0.15 + i*0.06`.

```tsx
const Lanyard = dynamic(() => import("./Lanyard"), { ssr: false, loading: () => null });
<motion.div {...rise} className="relative h-[560px] overflow-hidden rounded-[36px] bg-[#f4f5f7] md:col-span-6 md:h-[640px]">
  <Lanyard frontImage="/lanyard/card-front.jpg" backImage="/lanyard/card-back.jpg" strapImage="/lanyard/band.png"
    strapColor="#0d1117" finish="glossy" size={0.62} strapLength={0.55} breeze={0.4} />
  <p className="pointer-events-none absolute inset-x-0 bottom-5 text-center text-[13px] text-ink/40">Drag the card. Flip it over.</p>
</motion.div>
```

Props and defaults: `frontImage`, `backImage`, `imageFit 'cover'|'contain'`, `cardColor '#ffffff'`, `finish 'glossy'|'matte'|'holographic'|'metallic'`, `cornerRadius 0.3`, `size 0.6`, `anchor 'center'|'left'|'right'`, `strapLength 0.5`, `strapColor '#111111'`, `strapWidth 0.65`, `gravity 1`, `damping 0.5`, `elasticity 0.5`, `breeze 0.5`, `interactive true`, `intro true`.

**Bespoke example.** `bespoke: web/components/about/Lanyard.jsx` (1296 lines, self-contained, with `Lanyard.css` and `Lanyard.d.ts` for strict TS), assets in `bespoke: web/public/lanyard/`. The shader and physics internals are summarised above, not reproduced; to rebuild, copy the React Bits source and swap its imports for plain `three`.

---

## The docs site

**What it is.** A static, hand-written docs site in the same language as the product, on GitHub Pages.

**When to use.** Any product with more than one thing to explain, or an API or MCP server.

**How to build.**

1. Structure: `index.html` (overview), `guide/` (user-facing, one section per product room), `developers/` (how it is built: the map, the pipeline, run it, how we build), `contributing/` (the bar, checks, rules), `mcp/` (tools, connect, try it) when there is one. One folder per page with `index.html`, so URLs have no `.html`, and `<base href="/<repo>/">` for the project path.
2. Each page is a hero (`h1.display` plus a lede) then `section#id > .wrap.cols` with an `h2` left and content right (grid 4fr/7fr, stacks under 860px). Alternate sections get `.dark`. Sections `padding: 88px 0` (64px narrow) with a top hairline. `.wrap` max 1120px, padding 0 24px. Body 17px, lh 1.6.
3. Tokens mirror the product: `--ink`, `--ink-2 rgba(13,17,23,.62)`, `--ink-3 rgba(13,17,23,.45)`, `--line rgba(13,17,23,.09)`, `--fill rgba(13,17,23,.04)`, `--accent`, `--accent-ink`, `--paper #fff`.
4. Shared files: `style.css` (about 150 lines), `app.js` (about 110 lines, no libraries: sliding nav pill, `.reveal` observer, copy buttons, ranked heading search). Edit sources, never the built bundle.
5. Code blocks: `#0d1117` ground, `#e6edf3` text, 20px radius, 14px/1.6 mono, `white-space: pre-wrap; overflow-wrap: anywhere; padding-right: 92px`, with a pinned 32px "Copy" pill (`rgba(255,255,255,.1)`, turns spark with ink text when "Copied", always visible on touch, hover-revealed otherwise). Inline code on `--fill`, radius 8px. Tables in a 20px-radius overflow container with a hairline ring, header 13px ink-3. Steps as 36px numbered circles on `--fill`. Repo map as a `dl` grid `minmax(170px,34%) 1fr`.
6. Search: a 52px ink pill button with a `kbd` hint opens a 420px glass panel (radius 28px) searching every h1 to h3 of every page, fetched once and ranked by word overlap.
7. Each page carries its own OG and Twitter meta, the shared CSS and JS, a footer with "Engineered by <author>" and a link back to the product.
8. Rules that held: every number is reproducible from the repo; planned work is labelled planned with its exit test; docs and in-app help guides are updated together.

### The sliding pill

See Glass pill navbar, docs variant.

### FolderFloat

**What it is.** A React Bits component: a tabbed folder (back panel with tab, paper, front flap tilting open with `perspective(600px) rotateX`) from which pill notes spring out and, with physics, become Matter.js bodies that can be dragged and drift.

**When to use.** The overview page's "pick a guide" section, once. It is the docs site's one playful object; skip it for a tiny docs site.

**How to build.** It is the only bundled JS in the docs. Source in `site/src/` (`FolderFloat.jsx`, `main.jsx`, `package.json`, `bun.lock`; deps `matter-js` 0.20.0, `react` and `react-dom`). Build and commit the output, because CI does not build: `cd site/src && bun install && bun run build`, where the script is `bun build main.jsx --outdir .. --entry-naming folder.[ext] --minify`, producing `site/folder.js` and `site/folder.css`. Restyle through props to the product's ink and paper. Touch devices (`hover: none`) get click-to-open and start open. Layout: two columns 5fr text, 7fr folder, `align-items: end`; the stage needs `padding-top: 150px` (190px under 860px) for the notes above the folder.

```jsx
<FolderFloat items={GUIDES} label="<product> docs" sublabel={touch ? "Tap to open" : "Hover to open"}
  trigger={touch ? "click" : "hover"} defaultOpen={touch} closeOnSelect physics drift={0.5}
  onSelect={(href) => { location.href = href; }}
  folderColor="#0d1117" frontColor="#232c3b" paperColor="#ffffff" itemColor="#ffffff" itemTextColor="#0d1117" labelColor="#f2f3f5"
  width={220} height={156} radius={18} spread={touch ? 150 : 230} lift={30} tilt={7} openDuration={540} stagger={50} bounce={0.3} />
```

Pills are 38px high, 19px radius, shadow `0 0 0 1px rgba(13,17,23,.07), 0 10px 24px -10px rgba(13,17,23,.35)`, focus ring spark. Easing: `--ff-spring: cubic-bezier(0.34,1.57,0.64,1)`.

**Bespoke example.** `bespoke: site/src/FolderFloat.jsx`; eight guide pills: Using Bespoke, How it is built, The tagging ladder, Text analytics, Reading pictures, Big data, MCP server, Contributing.

---

## Third-party component policy

**What it is.** The rule for borrowing UI from React Bits, Cult UI, Skiper UI, shadcn registries and the like.

**When to use.** Any time a component comes from outside.

**How to apply.**

1. Adapt to the palette. Recolour to ink and white, inherit `currentColor`, map to the role variables in tokens.md, use the product's springs and radii. The only exception is a deliberate single colourful moment (the thinking aura).
2. Inline its dependencies and strip what it does not use; use lucide icons for glyphs.
3. Credit every one in `public/licenses.txt` and link it as "Credits" in the footer. Record author, source and licence: Skiper UI (free, attribution required), Cult UI (MIT), Dot Matrix (MIT), React Bits, Metal FX (Apache-2.0), Motion.
4. Never ship an unused library. If a dependency is not imported, remove it from `package.json` (Bespoke carried `gsap`, `lenis`, `metal-fx` unused). Remove credits for components removed, and keep `licenses.txt` current (Bespoke's still credited an old font pair).
5. Prefer copying one component over adding a package. Heavy pieces load with `next/dynamic` and `ssr: false`.
6. Register shadcn registries in `components.json` only for the ones in use: `@cult-ui` (`https://www.cult-ui.com/r/{name}.json`), `@skiper-ui` (`https://skiper-ui.com/registry/{name}.json`), `@dotmatrix`.
7. Artwork and photos: use CC0 or licensed sources and record them (Open Peeps CC0, Openverse and rawpixel CC0 photographs).

**Bespoke example.** `bespoke: web/public/licenses.txt`, `bespoke: web/components.json`.

---

## Favicon and mark rules

**What it is.** One small mark used as logo, favicon and home-screen icon.

**When to use.** Every product, before the first deploy.

**How to build.**

- The mark is simple, made of strokes: 24x24 viewBox, `stroke currentColor`, width 2.25, round caps and joins, no fill, coloured with the spark in the nav. Bespoke: two chevrons "><", path `M5 6.5l5 5.5-5 5.5M19 6.5l-5 5.5 5 5.5`. `size-5` in the nav, `size-4` in the footer.
- Favicon: `app/icon.svg`, 24x24, a `rect rx=6` in ink with the mark in the spark (chevrons apart for legibility at 16px: `M5.5 7l4.6 5-4.6 5M18.5 7l-4.6 5 4.6 5`, stroke 2.3). `app/apple-icon.png` 180x180 of the same.
- The corner helper icon is a 64x64 ink speech bubble in `currentColor` with a white 3.8px smile; open state swaps to a white X.
- Arrows (send, back-to-top) are 2.2px round-cap strokes (`M12 19V5M6 11l6-6 6 6`). Social glyphs are inline filled SVG. No emoji, no icon-in-a-badge.
- Back to top: appears after `scrollY > innerHeight`, a 56px ink circle at `bottom-4 left-4` (md 6) with a spark arrow, `{opacity 0, y 12}`, spring `{duration .35, bounce 0}`; the helper sits right so they never collide.
- Share image `public/og.png`, 1200x630, under 50 KB, with alt text.

**Bespoke example.** `bespoke: web/components/site/Mark.tsx`, `bespoke: web/app/icon.svg`, `bespoke: web/public/og.png`.

---

## SEO surfaces

**What it is.** The set of things that make each page findable and shareable.

**When to use.** Every product, at launch.

**How to build.**

1. Each page has its own URL, its own `<title>` ("Page · Product"), description and share image. Pages are static routes with `trailingSlash: true`; keep a shared app mounted in the layout so navigation keeps state.
2. `app/layout.tsx`: `metadataBase`, `authors: [{ name: "Ritesh Roshan" }]`, `openGraph` and `twitter` (`summary_large_image`) with `/og.png`, and a JSON-LD `SoftwareApplication` script with `creator` as a Person, `inLanguage`, and an `Offer`.
3. `app/robots.ts` (`dynamic = "force-static"`): allow `/`, disallow `/api/` and any private route, set sitemap and host.
4. `app/sitemap.ts`: a priority table of the public routes.
5. Define the site URL once (a `SITE` constant) and import it; Bespoke hard-coded it in six files.
6. Icons as above. `<meta name="author">` carries the author.
7. Run the essentials check (the **essentials** skill) before calling it done.

```ts
// app/robots.ts
export const dynamic = "force-static";
export default function robots() {
  return { rules: [{ userAgent: "*", allow: "/", disallow: ["/api/"] }], sitemap: `${SITE}/sitemap.xml`, host: SITE };
}
```

**Bespoke example.** `bespoke: web/app/layout.tsx`, `bespoke: web/app/robots.ts`, `bespoke: web/app/sitemap.ts` (commit dcc33d1).

---

## Work-surface patterns from the example

These two are product-shaped but reusable as ideas.

**Design panel (a live record beside a conversation).** An `aside` titled by the thing being made, a meta line ("Draft 3. Select any detail to change it."), and rows of label, value and a grey source ("from your words", "from your edit"). New or changed rows flash spark at 18% and fade over 1.4s. Selecting a row opens a picker sheet with a search box. Values go through one naming function so people see their own words. Use it whenever the product turns loose input into a structured record: show where each value came from and let the person correct it.

**One inbox for two sides.** A conversation list left and the open thread right, the item pinned on top; on a phone the list and thread are two screens with a back chevron. Filter pills (All, Unread, Open), status notes posted into the thread, quick replies that land in the composer to be edited, a character counter in the last 200 characters, a notifier toast and typing indicators over private realtime channels. Empty panes show a ghosted display word ("Pick a conversation."). Use it for any two-party workflow.

**Bespoke example.** `bespoke: web/components/App.tsx` (design panel), `bespoke: web/components/market/Workspace.tsx` (inbox).
