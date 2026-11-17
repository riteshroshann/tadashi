# The login kernel

Every product with accounts gets this login, signup and reset system. It is taken line for line from Bespoke (`bespoke: web/components/market/AuthPage.tsx`, `ResetPage.tsx`, `SignInGate.tsx`, `Gate.tsx`, `web/lib/market/rules.ts`) and written so it drops into any product. Replace `<Product>`, the two audiences and the photos; keep every value, curve and sentence pattern.

Tokens assumed (see tokens.md): ink `#0d1117` as `brand-ink`, `display` utility (font weight 500, tracking -0.045em, line-height .95), `press` utility, springs `SPRING` (420/34) and `SOFT` (160/24) from `Motion.tsx`.

## Anatomy

```
desktop (md and up)                         phone
+--------------------+--------------------+  +------------------+
| <Product>          |                    |  | <Product>        |
|                    |   +------------+   |  | +--------------+ |
|  grayscale photo   |   |  card 32px |   |  | |  card 32px   | |
|  70% on ink        |   |  Log in    |   |  | |  Log in      | |
|                    |   |  fields    |   |  | |  fields      | |
| Welcome back.      |   |  [ pill ]  |   |  | |  [  pill  ]  | |
+--------------------+---+------------+---+  +--------------+---+
   sticky door pane      #f4f5f7 ground          #f4f5f7 ground
```

Two halves: a **door** (photo, wordmark, one huge greeting) and a **desk** (soft grey ground with one white card). The door names who this is for and makes the page feel like arriving somewhere. The card does the work. On phones the door disappears and the wordmark moves above the card.

## Two doors, one component

Products with two kinds of user (customers and pros, buyers and sellers, students and teachers) get two doors from the same component, selected by `role`. Each door has its own photo, greeting, base path and one-line audience note:

```ts
const DOOR = {
  customer: { photo, alt, words: { login: "Welcome back.", signup: "Join." }, base: "",        who: "For customers" },
  maker:    { photo, alt, words: { login: "Your studio.",  signup: "Make with us." }, base: "/makers", who: "For designers, tailors and boutiques" },
};
```

Routes: `/login/`, `/signup/`, `/<pro>/login/`, `/<pro>/signup/`, `/reset/`. Each route file is eight lines: metadata with the title `Log in · <Product>` and `<AuthPage role=".." mode=".." />`. Set `robots: { index: false }` on `/reset/`.

Greetings are two words or fewer, a statement with a full stop, and in the audience's own register: "Welcome back." and "Join." for the public; "Your studio." and "Make with us." for professionals.

## Step by step

### 1. The page grid

```tsx
<main className="grid min-h-[100svh] md:grid-cols-2">
```

Use `100svh`, never `100vh`, so the phone's browser bar never cuts the card.

### 2. The door pane

```tsx
<div className="sticky top-0 hidden h-[100svh] overflow-hidden bg-foreground md:block">
  <img src={door.photo} alt={door.alt} className="absolute inset-0 size-full scale-110 object-cover opacity-70 grayscale" />
  <a href="/" aria-label="<Product> home" className="display absolute left-10 top-8 text-[34px] text-white no-underline"><Product></a>
  <p className="display absolute inset-x-10 bottom-10 text-[clamp(56px,7vw,120px)] text-white">{door.words[mode]}</p>
</div>
```

The photo is grayscale at 70% opacity over ink, scaled 1.1 so the edges never show. The colour stays out of the frame so the card's ink button stays the loudest thing on screen. The wordmark sits top left at 34px. The greeting sits bottom left at `clamp(56px,7vw,120px)`. The pane is sticky, so a long signup form scrolls past a still photo. Pick a real, human photograph of the craft or the people the product serves, never a stock gradient or an illustration.

### 3. The desk and the card

```tsx
<div className="flex flex-col items-center justify-center bg-[#f4f5f7] px-4 py-10 md:px-10">
  <a href="/" className="display mb-8 self-start text-[30px] text-brand-ink no-underline md:hidden"><Product></a>
  <motion.section animate={shake} initial={{ opacity: 0, y: 24, scale: 0.98 }} whileInView={{ opacity: 1, y: 0, scale: 1 }}
    viewport={{ once: true }} transition={SOFT}
    className="w-full max-w-[460px] rounded-[32px] bg-white p-7 shadow-[0_0_0_1px_rgba(13,17,23,.05),0_40px_90px_-40px_rgba(13,17,23,.35)] sm:p-10">
```

The card values that make it feel premium:
- **Size and padding:** max width 460px, padding 28px on phones and 40px from `sm` up.
- **Curve:** radius 32px.
- **Edge:** no border. A 1px ring of ink at 5% gives the edge, and a long, low shadow (`0 40px 90px -40px`, ink at 35%) lifts it.
- **Ground:** `#f4f5f7`, so the white card reads without any line around it.
- **Entrance:** it rises 24px from scale .98 on the soft spring.

### 4. The field

One component for every input. It is a soft grey pill that lifts to white with a shadow when focused. The label sits above, never inside.

```tsx
export function Field({ label, hint, trailing, ...input }) {
  const id = useId();
  return (
    <div>
      <label htmlFor={id} className="text-[13px] font-medium text-brand-ink/55">{label}</label>
      <div className="mt-1.5 flex items-center rounded-[16px] bg-brand-ink/[.04] ring-1 ring-transparent
        transition-[background-color,box-shadow] duration-200 hover:bg-brand-ink/[.06]
        focus-within:bg-white focus-within:ring-brand-ink/20 focus-within:shadow-[0_8px_24px_-14px_rgba(13,17,23,.3)] focus-within:hover:bg-white">
        <input id={id} {...input} className="auth-input h-[52px] min-w-0 flex-1 rounded-[16px] bg-transparent px-4
          text-[16px] text-brand-ink outline-none placeholder:text-brand-ink/30" />
        {trailing}
      </div>
      {hint}
    </div>
  );
}
```

The field's exact values:
- **Size:** height 52px, radius 16px, text 16px. Never go below 16px: iOS zooms into smaller inputs.
- **Fill:** ink at 4% at rest and 6% on hover.
- **Focus:** the fill turns white with a 20% ink ring and a soft shadow. The wrapper owns focus (`focus-within`), so a trailing button sits inside the same curve.
- **Label:** 13px, weight 500, ink at 55%.
- **Spacing:** fields are 20px apart (`space-y-5`), and the stack sits 32px below the heading.

### 5. Autofill and browser chrome

Browsers paint autofilled fields as square blue boxes and add their own password buttons. Both break the curve. Add this once to `globals.css`:

```css
/* autofill keeps the field's own curve and colour instead of the browser's square blue box */
.auth-input:-webkit-autofill,
.auth-input:-webkit-autofill:hover,
.auth-input:-webkit-autofill:focus {
  -webkit-box-shadow: 0 0 0 1000px #f5f5f6 inset;
  -webkit-text-fill-color: #0d1117;
  caret-color: #0d1117;
  font-family: inherit;
  border-radius: 16px;
  transition: background-color 9999s ease-out;
}
.auth-input:autofill { box-shadow: 0 0 0 1000px #f5f5f6 inset; border-radius: 16px; }
div:focus-within > .auth-input:-webkit-autofill { -webkit-box-shadow: 0 0 0 1000px #fff inset; }
/* our own show-password button is the only one: hide Edge's built-in reveal and clear buttons */
.auth-input::-ms-reveal, .auth-input::-ms-clear { display: none; }
```

Test this with a real saved password in Chrome and Edge. It is the detail people notice first.

### 6. The password field

The field takes a trailing eye button. The slash through the eye draws itself in and out, and on signup a length meter sits underneath.

```tsx
const Eye = ({ open }) => (
  <svg viewBox="0 0 24 24" className="size-5" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
    <path d="M2.5 12s3.5-6.5 9.5-6.5 9.5 6.5 9.5 6.5-3.5 6.5-9.5 6.5S2.5 12 2.5 12z" />
    <circle cx="12" cy="12" r="2.8" />
    <motion.path d="M4 4l16 16" initial={false} animate={{ pathLength: open ? 0 : 1, opacity: open ? 0 : 1 }} transition={{ duration: 0.25 }} />
  </svg>
);
// trailing:
<button type="button" onClick={() => setShow(!show)} aria-label={show ? "Hide password" : "Show password"} aria-pressed={show}
  className="press mr-1.5 grid size-10 shrink-0 place-items-center rounded-full text-brand-ink/45 transition-colors hover:bg-brand-ink/[.06] hover:text-brand-ink">
  <Eye open={show} />
</button>
```

The meter is length only. There are no strength rules to fail, and the minimum is 8:

```tsx
<div className="mt-2 flex items-center gap-2 text-[13px]">
  <span className="h-1 w-24 overflow-hidden rounded-full bg-brand-ink/[.08]">
    <motion.span className={cn("block h-full rounded-full", short ? "bg-[#f59e0b]" : "bg-[#22c55e]")}
      animate={{ width: `${Math.min(100, (value.length / MIN) * 100)}%` }} transition={SPRING} />
  </span>
  <span className={value.length >= MIN ? "text-[#15803d]" : "text-brand-ink/45"}>
    {value.length >= MIN ? "Good length" : `${Math.max(0, MIN - value.length)} more characters`}
  </span>
</div>
```

Other password rules:
- **Autocomplete:** `current-password` on login and `new-password` on signup and reset, so password managers do the right thing.
- **Placeholder:** "At least 8 characters", on signup only.

### 7. Buttons and links

The primary button fills the card's width:

```ts
const primary = "press mt-8 h-14 w-full rounded-full bg-brand-ink text-[16px] font-medium text-white transition-[background-color,opacity,transform] hover:bg-[#232c3b] active:scale-[0.98] disabled:opacity-50";
const link = "font-medium text-brand-ink underline decoration-brand-ink/25 underline-offset-[5px] transition-[text-decoration-color] hover:decoration-brand-ink";
```

- **Primary:** a 56px pill in ink that lightens to `#232c3b` on hover and scales to .98 on press. While busy, its label becomes the present tense: "One moment", "Sending", "Saving". Never a spinner.
- **Secondary** (used in the panes): a 48px pill with a hairline 15% ink ring that fills to 4% ink on hover.
- **Text links:** underlined with a 25% ink decoration, 5px offset, that darkens on hover. Links never turn blue.

### 8. The form pane, top to bottom

```
h1      "Log in" | "Create account"     display, clamp(36px,4vw,46px), leading-none
lede    door.who                        15px, ink 55%, 12px below
notice  (only after confirming email)    14px on sky 10%, text #0369a1, radius 14px, 24px below
fields  Name (signup) / Email / Password / City (signup) / pro fields (pro signup)
        "Forgot password?" right-aligned under the password on login, 14px link, pulled up 8px
error   one line, 14px, #b5121b, slides open
button  primary
switch  "New to <Product>? Create an account" | "Already have an account? Log in"   14px, ink 55%, centred, 28px below
door    "I am a maker" | "I am a customer"   quieter link to the other door, 12px below
```

The notice is the only place sky appears on the page, and it means good news: "Your email is confirmed. Log in to continue."

### 9. Pro signup: choosing a kind

When the second audience comes in kinds (designer, tailor, boutique; freelancer, agency), show radio cards, not a dropdown:

```tsx
<motion.button type="button" aria-pressed={selected} onClick={...} whileTap={{ scale: 0.98 }}
  className={cn("flex items-center gap-3 rounded-[16px] px-4 py-3 text-left ring-1 transition-[background-color,box-shadow]",
    selected ? "bg-brand-ink text-white ring-brand-ink" : "bg-white ring-brand-ink/10 hover:bg-brand-ink/[.03] hover:ring-brand-ink/20")}>
  <span className={cn("grid size-5 shrink-0 place-items-center rounded-full ring-1", selected ? "ring-white/60" : "ring-brand-ink/25")}>
    <AnimatePresence>{selected && <motion.span initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }} transition={SPRING} className="size-2.5 rounded-full bg-white" />}</AnimatePresence>
  </span>
  <span><span className="block text-[15px] font-medium">{value}</span>
        <span className={cn("block text-[13px]", selected ? "text-white/65" : "text-brand-ink/50")}>{note}</span></span>
</motion.button>
```

Each card has a name and a note in the second person ("You cut and stitch to measure"). The selected card inverts to ink, and its dot springs in. Add a "What you make" field with a concrete placeholder ("Blouses, lehengas, sherwanis").

### 10. Errors and the shake

```ts
const shake = useAnimationControls();
const fail = (err) => {
  setError(err instanceof AppError ? err.message : "Something went wrong. Try again.");
  setBusy(false);
  void shake.start({ x: [0, -8, 8, -5, 5, 0], transition: { duration: 0.4 } });
};
```

```tsx
<AnimatePresence>
  {error && <motion.p role="alert" initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: "auto" }} exit={{ opacity: 0, height: 0 }}
    className="mt-5 text-[14px] text-[#b5121b]">{error}</motion.p>}
</AnimatePresence>
```

The whole card shakes once, like a head saying no. The error line opens above the button and announces itself to screen readers. Forms use `noValidate`, so the product's own sentences replace the browser's tooltips.

### 11. Panes and how they swap

There is one card and five panes: `form`, `forgot`, `expired`, `sent` and `reset-sent`. They swap with `AnimatePresence mode="wait"`:

```ts
const swap = { initial: { opacity: 0, y: 14, filter: "blur(4px)" }, animate: { opacity: 1, y: 0, filter: "blur(0px)" },
               exit: { opacity: 0, y: -10, filter: "blur(4px)" }, transition: { duration: 0.3 } };
```

Each pane rises out of a blur, and the old one leaves upward. The card never changes page, so the person never loses their place.

- **forgot:** "Reset your password." with "Enter the email you use for <Product> and we send you a link to choose a new password." Then the email field, "Send reset link" and a "Back to log in" link.
- **expired:** opened when the address arrives with `#error_code=otp_expired` or `error=access_denied`. It says "That link has expired." and "Links in our emails work once and only for a while. Enter your email and we send a fresh one.", with a "Send a new link" button.
- **sent / reset-sent:** a 56px ink circle with a white envelope springs in from scale .6, then "Check your email." and "We sent a link to **<email>**." Signup adds "Open it to confirm your account; it brings you straight back here, logged in." and reset adds "Open it to choose a new password." A quiet line follows: "Nothing after a few minutes? Look in spam, or send it again." Then two buttons: secondary "Send again" and primary "Go to log in".

### 12. The reset page

`/reset/` uses the same card on the `#f4f5f7` ground, centred, with no door. It has the wordmark at 22px and headings at 40px:
- **Waiting for the session:** the session from the email link arrives a moment after load, so the page listens for it and waits up to 4 s before deciding the link is dead.
- **Form:** "Set a new password." and "For <email>.", then the password field with the meter and "Save new password" (disabled until 8 characters).
- **Done:** "Password changed." and "Taking you to your account.", then a redirect after 1.6 s.
- **Dead link:** "That link has expired." and "Reset links work once and only for an hour. Ask for a new one from the log in page.", with a "Go to log in" button.

### 13. The sign-in gate: asking at the moment of need

Never put a login wall in front of the product. Let people use it signed out. When an action needs an account, open a pane that says why, in one sentence, and promises the return:

```ts
const { requireSignIn, gate } = useRequireSignIn();
const me = await requireSignIn("Save this design to your account so it follows you to any device.");
if (!me) return;   // the pane is open
```

The pane:
- **Phone:** a bottom sheet with a 32px top radius.
- **Desktop:** a centred 480px card with a 32px radius.
- **Backdrop:** ink at 40% with a 2px blur, entering on SPRING (rising 40px from scale .98).
- **Title:** `clamp(32px,4vw,42px)`, defaulting to "Sign in to keep going."
- **Lede:** the reason, plus "Whatever you were doing waits right here, and you come straight back to it."
- **Actions:** "Log in" (primary, 48px) and "Create an account" (secondary), both carrying `?next=<this page>`.
- **Close:** a 40px circle in the corner. Escape closes, and focus moves to the first action and back again on close.
- **Wrong account:** "This needs a customer account." with "You are signed in as a maker."
- **The draft survives the trip,** even into a new tab, and is cleared on sign-out.

For a page that is entirely private (an inbox), show the page's name huge at 10% ink as a ghost behind the gate ("Requests."), so the person sees where they are.

### 14. The pro landing

`/<pro>/` signed out is a full-screen ink page with a grayscale photo at 45% and a centred `clamp(64px,12vw,200px)` greeting ("Your studio."). Below it sit two 56px pills: "Log in" (white with black text) and "Join as a maker" (a 2px white outline that fills white on hover). The header switches to the pro audience.

### 15. Redirects and safety

- **`next` must stay on this site.** Reject anything not starting with a single `/`, and any backslash, whitespace or control character, because browsers turn those into `//host`:

  ```ts
  export function safeNext(next, fallback) {
    if (!next || next[0] !== "/" || next[1] === "/" || /[\\\s\u0000-\u001f\u007f]/.test(next)) return fallback;
    return next;
  }
  ```
- **Carry the return address.** The query string (minus `confirmed`) rides along when switching between log in and create account.
- **Leave the door if already signed in.** Someone already signed in on this door is sent to their home (`homeFor(me)`): customers to their requests, pros to their inbox. A customer may still open the pro door to switch.
- **Wrong door:** signing in with an account of the other kind fails with "This account is a maker account. Use the maker sign-in."
- **One rule set.** The local store and the cloud store share one rules file, so both refuse the same things in the same words. Emails are trimmed and lowercased.

### 16. The words, all of them

| Situation | Copy |
|:--|:--|
| Wrong password | That email or password is not right. |
| Email taken | That email is already registered. Log in instead. |
| No name | Enter your name. |
| Bad email | Enter a valid email address. |
| Short password | Use a password of at least 8 characters. |
| Must confirm | Check your email to confirm your account, then log in. |
| Link dead | That link has expired or was already used. Send a new one below. |
| Network | Something went wrong. Check your connection and try again. |
| Unknown | Something went wrong. Try again. |
| No email service (local mode) | Email links need the online service, which is not connected here. |
| Signed out action | Sign in to continue. |

Each line says what happened and what to do. There are no codes, no "Oops" and no exclamation marks. Say plainly when an email is already taken: a person stuck at "check your email" is worse served than one told the truth.

## Accessibility and the finishing pass

- Every input has a real `<label>`. Errors use `role="alert"`, notices and sent panes use `role="status"`, and the eye button has `aria-pressed`.
- The `press` utility gives every button a 2px sky focus ring with a 3px offset.
- Tab order runs heading, fields, forgot link, button, switch link, door link.
- Check at 390px (no sideways scroll, the card fills the width with 16px gutters), with a saved password autofilled in Chrome and Edge, with reduced motion on (springs off, panes still swap), and with a wrong password (shake, error line, button returns).
- The emails themselves (confirm, reset) must match the site. stack.md has the email setup.
