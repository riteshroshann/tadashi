# Bespoke: flows, copy and product thinking

Reference for building a new product with the same premium feel, without opening the repo. Product: Bespoke (repo riteshroshann/onestyle). A customer describes a garment in English or Hinglish, answers a few questions, pins pictures on a board, and gets a tailor sheet in English or Hindi, shop searches, and a way to send it to a maker. Next.js app in `web/`, Tailwind v4, `motion/react` for every animation.

All file paths below are relative to the repo root. Two shared constants appear everywhere:

```ts
// web/components/site/Motion.tsx
export const SPRING = { type: "spring", stiffness: 420, damping: 34 };  // snappy: presses, bubbles, switches
export const SOFT   = { type: "spring", stiffness: 160, damping: 24 };  // soft: page entrances, cards
```

Palette tokens (`web/app/globals.css`): ink `#0d1117` (also `brand-ink`), one accent sky blue `#38bdf8` (focus rings, small moments only), error red `#b5121b`, soft grey grounds `#f2f3f5`, `#f4f5f7`, `#f5f5f7`. Greys are ink at opacity: `/55` and `/60` for body, `/45` and `/40` for hints, `/[.04]` to `/[.06]` for fills. The `display` utility is the headline style: weight 500, letter-spacing -0.045em, line-height 0.95. A `press` utility gives every button a scale-down spring and a sky focus ring.

---

## 1. Log in, sign up, reset

Files: `web/app/login/page.tsx`, `web/app/signup/page.tsx`, `web/app/makers/login|signup/page.tsx` (each is one line: `<AuthPage role="customer" mode="login" />`), `web/app/reset/page.tsx` (renders `ResetPage`), `web/components/market/AuthPage.tsx`, `ResetPage.tsx`, `SignInGate.tsx`, `Gate.tsx`, `web/lib/market/rules.ts` (all wording), `web/lib/market/cloud.ts` (Supabase errors mapped to that wording).

### The frame

A two-column split that collapses on phones.

- Left half (md and up only): sticky, `h-[100svh]`, ink ground. A full-bleed photograph with `opacity-70 grayscale`, scaled 1.1. The word "Bespoke" top-left in white display type (34px, `left-10 top-8`). Bottom-left, one huge display word in white, `clamp(56px,7vw,120px)`. The word depends on door and mode:

| Door | Log in | Sign up |
|---|---|---|
| Customer | "Welcome back." | "Join." |
| Maker | "Your studio." | "Make with us." |

- Right half: ground `#f4f5f7`, the card centred vertically, `px-4 py-10 md:px-10`. On a phone the left image disappears and "Bespoke" (30px display) sits above the card, left aligned.
- The card is one white rounded rectangle, no border, a hairline ring plus a long soft shadow. It rises in with `SOFT` from `opacity 0, y 24, scale .98`.
- Inside the card, panes swap with `AnimatePresence mode="wait"`: each pane enters from `opacity 0, y 14, blur 4px` and leaves to `y -10, blur 4px`, 300ms. The card never changes size abruptly because panes are short and share the same left edge.

```tsx
// the card
<motion.section animate={shake} initial={{ opacity: 0, y: 24, scale: 0.98 }} whileInView={{ opacity: 1, y: 0, scale: 1 }} viewport={{ once: true }} transition={SOFT}
  className="w-full max-w-[460px] rounded-[32px] bg-white p-7 shadow-[0_0_0_1px_rgba(13,17,23,.05),0_40px_90px_-40px_rgba(13,17,23,.35)] sm:p-10">
```

### The field

`Field` is a label above a soft pill. The fill is ink at 4%, rises to 6% on hover, and on focus turns white with a lifted shadow and an ink 20% ring. Radius 16px (not a full pill, so a password and a button read as one family). Input height 52px, text 16px (stops iOS zoom). Label 13px, medium, ink 55%.

```tsx
<label htmlFor={id} className="text-[13px] font-medium text-brand-ink/55">{label}</label>
<div className="mt-1.5 flex items-center rounded-[16px] bg-brand-ink/[.04] ring-1 ring-transparent transition-[background-color,box-shadow] duration-200
  focus-within:bg-white focus-within:shadow-[0_8px_24px_-14px_rgba(13,17,23,.3)] focus-within:ring-brand-ink/20 hover:bg-brand-ink/[.06] focus-within:hover:bg-white">
  <input className="auth-input h-[52px] min-w-0 flex-1 rounded-[16px] bg-transparent px-4 text-[16px] ..." />
  {trailing}
</div>
```

Autofill fix (commit "curved fields even when the browser autofills them"): the `.auth-input:-webkit-autofill` rules in `web/app/globals.css` paint `box-shadow: 0 0 0 1000px #f5f5f6 inset`, keep `border-radius: 16px`, force ink text, and delay the browser's colour transition by 9999s. When focused the inset flips to white. The Edge built-in reveal and clear buttons are hidden (`::-ms-reveal`, `::-ms-clear`) so the product's own button is the only one ("one show-password button").

Password field: an eye icon button (40px round, ink 45%) as the trailing element; its slash is a `pathLength` animation (250ms) that draws or erases. `aria-label` "Show password" or "Hide password", `aria-pressed`. On sign up, under the field, a live length meter: a 96px by 4px track with a fill that springs to `length/8`, amber `#f59e0b` while short, green `#22c55e` once 8 or more. Text beside it: "N more characters" in grey, then "Good length" in green `#15803d`. The placeholder is "At least 8 characters". Minimum is 8 (`MIN_PASSWORD`).

### Panes and exact copy

Pane state machine: `form`, `forgot`, `sent`, `reset-sent`, `expired`.

Form pane (heading is a display type at `clamp(36px,4vw,46px)`, leading none):

- Heading: "Log in" or "Create account". Under it, 15px grey: "For customers" or "For designers, tailors and boutiques".
- Fields on log in: Email, Password, then a right-aligned underlined link "Forgot password?" tucked up under the password (`-mt-2`).
- Fields on sign up: Name, Email, Password, City (placeholder "Where you live or work"). Makers also get a "You are a" radio group of three rows (rounded 16px, selected row turns ink with white text and a spring-in dot): "Fashion designer / You design collections or one-offs", "Tailor / You cut and stitch to measure", "Boutique / You run a shop with a team"; then "What you make" with placeholder "Blouses, lehengas, sherwanis" (comma separated, stored as specialties). Default craft is Tailor.
- Primary button: full width, 56px tall (`h-14`), rounded-full, ink, white 16px medium, `mt-8`. Label: "Log in" or "Create account". While busy: "One moment", disabled at 50% opacity. Hover goes to `#232c3b`, press scales to .98.
- Footer lines, centred 14px grey, `mt-7`: "New to Bespoke? Create an account" or "Already have an account? Log in" (the action is an underlined link in ink with a 25% underline that darkens on hover). Below it a quieter link switches doors: "I am a maker" on customer pages, "I am a customer" on maker pages.
- Switching between log in and sign up keeps the query string (`?next=...`) so the return address survives.

Forgot pane: "Reset your password." / "Enter the email you use for Bespoke and we send you a link to choose a new password." / Email / button "Send reset link" (busy: "Sending", disabled while the email is empty) / link "Back to log in".

Expired pane (arrived from a dead email link, detected from the URL hash `error_code=otp_expired` or `error=access_denied`): "That link has expired." / "Links in our emails work once and only for a while. Enter your email and we send a fresh one." / button "Send a new link". The inline error beneath reads "That link has expired or was already used. Send a new one below."

Sent panes (`sent` after sign up, `reset-sent` after a reset request): a 56px ink circle with a white envelope icon springs in. Heading "Check your email." Body: "We sent a link to **address**. Open it to confirm your account; it brings you straight back here, logged in." (reset variant: "Open it to choose a new password."). Small grey line: "Nothing after a few minutes? Look in spam, or send it again." Two buttons: ghost "Send again" (busy "Sending") and ink "Go to log in".

Confirmed banner on the log in form, sky tint (`bg-[#38bdf8]/10`, text `#0369a1`, 14px, rounded 14px): "Your email is confirmed. Log in to continue."

### Errors, word for word

The error line is 14px `#b5121b`, `role="alert"`, animates open with height 0 to auto, sits above the button. On every failure the whole card shakes (`x: [0,-8,8,-5,5,0]`, 400ms) and the button re-enables. Strings from `web/lib/market/rules.ts` and `cloud.ts`:

- Wrong credentials: "That email or password is not right."
- Address already has an account (commit "an address that already has an account says so instead of 'check your email'"): "That email is already registered. Log in instead." Detected two ways: Supabase code `user_already_exists`, and the quiet case where Supabase returns a user with an empty `identities` array and no session.
- Needs confirming: "Check your email to confirm your account, then log in." (this one is not shown as an error; it switches to the `sent` pane). Logging in before confirming: "Confirm your email first. We sent you a link."
- Wrong door: "This account is a maker account. Use the maker sign-in." (and customer).
- Validation: "Enter your name." / "Enter a valid email address." / "Use a password of at least 8 characters."
- Weak: "That password is too easy to guess. Choose a longer or less common one."
- Rate limit: "Too many attempts. Wait a minute and try again."
- Reused password on reset: "Choose a password you have not used here before."
- Fallback: "Something went wrong. Check your connection and try again." (the page-level catch-all is the shorter "Something went wrong. Try again.")

### Redirect logic

- `safeNext(next, fallback)` allows only a path on this site. It rejects anything not starting with "/", "//", backslashes, whitespace and control characters (browsers treat them as slashes). After sign in, `leave()` goes to `next` if safe, else `homeFor(me)` (customers to `/orders/`, makers to `/makers/`).
- On mount, a signed-in person on their own side is bounced home immediately. A customer opening the maker door is allowed through (commit "no longer bounce a signed-in customer to their requests").
- A session per tab; designs begun while signed out are parked for two hours so they survive the trip through sign up, even in a new tab, and join the account afterwards. Signing out clears the draft so the next person starts blank.
- No OAuth. Email and password only. Without Supabase keys the app runs on a local browser store with demo makers; email-link flows then say "Email links need the online service, which is not connected here."

### The reset page (`/reset/`)

A single centred card on `#f4f5f7`, same shadow. "Bespoke" at 22px, then:

- Waiting for the link's session (up to 4 seconds): "Set a new password." / "One moment."
- Ready: "Set a new password." / "For name@example.com." / the Password component in signup mode / button "Save new password" (busy "Saving", disabled under 8 characters).
- Done: "Password changed." / "Taking you to your account." then redirects after 1.6s.
- Dead link: "That link has expired." / "Reset links work once and only for an hour. Ask for a new one from the log in page." / ink button "Go to log in".

### The sign-in gate (ask for an account only when needed)

`SignInGate.tsx`, used as `const { requireSignIn, gate } = useRequireSignIn()`. A modal that slides up from the bottom on phones and centres on desktop: backdrop `bg-brand-ink/40` with 2px blur, panel `rounded-t-[32px]` (mobile) or `rounded-[32px]`, max width 480px, close button 40px, Escape closes and returns focus. Title default "Sign in to keep going." Body: the caller's reason plus "Whatever you were doing waits right here, and you come straight back to it." Buttons: ink "Log in" and ringed "Create an account", both carrying `?next=` of the current page. If signed in with the wrong role the title becomes "This needs a customer account." and the body begins "You are signed in as a maker."

Real reasons passed in: "Save this design to your account so it follows you to any device." and, on the sheet, "Your maker gets the design, the sheet and your measurements, and you talk it through in one thread." The requests page when signed out shows a ghosted display word "Requests." in ink 10% with this gate over it: title "Your requests live in your account.", reason "Log in to see the designs you sent and talk them through with your makers."

Maker landing (`Gate.tsx`, signed out at `/makers/`): full-bleed grayscale photograph at 45%, one display line "Your studio.", two buttons: white "Log in" and outlined "Join as a maker".

Header menu: "Log in" in the nav opens a glass popover (260px, `bg-white/90` blur) titled for screen readers "Log in as", with two rows: "I am a customer / Design and order clothes" and "I am a maker / Receive and make requests".

---

## 2. Talk: the conversation

Files: `web/components/App.tsx` (the whole studio: Talk, Sheet, Shop, header, composer), `web/app/studio/Studio.tsx` (mounts App once in the layout so moving between pages keeps state), `web/app/studio/[view]/page.tsx` (each page only supplies metadata), `web/lib/engine/spec.ts` (questions), `web/api/next.js` (model picks the next question), `web/api/understand.js`.

Routes: `/studio/talk/`, `/studio/board/`, `/studio/sheet/`, `/studio/shop/`. `/studio/` itself redirects to `/studio/talk/` (or to the page an old `?view=` link named). `?new` opens a blank design. Every visit to Talk starts blank unless signed in; signed-in designs are saved and the latest resumes, with the loading line "Opening your last design".

### Empty Talk (the first screen)

White page, big hero, then a black band.

- Headline, two lines, each revealed from a mask (`y: 105% to 0`, `SOFT`, 100ms stagger): "Describe it." / "Wear it." Size `clamp(56px,9vw,160px)`, line-height .92.
- Lede (52ch, 17-20px, ink 60%): "Tell us the garment you want, the way you would tell a friend, in English or Hinglish. We ask what is missing, one question at a time, and turn it into a sheet any tailor can follow."
- The composer, big. It opens focused. The first screen holds only these three things.
- Below the fold, the "how it works" band: a full-bleed ink section (`bg-brand-ink text-white`), padding `clamp(64px,9vw,128px)`, heading "How it works." (display, white, `max-w-[12ch]`), three columns with a hairline `border-white/15` top rule, each with a 13px number in white 40%, a 20px medium title, a 15px body in white 60% at 34ch. They rise once on scroll. After them, a white pill button: "Have pictures instead? Start with a moodboard".

```
1  Describe it            Type or speak: the garment, who it is for, the occasion, anything you already know.
2  Answer a few questions One at a time, only what is missing. Skip any you like.
3  Take it to a maker     Get a tailor sheet in English or Hindi, or send it to a maker on Bespoke.
```

Commit b7f18ba: "Talk opens on the composer with how it works in a black band". The earlier empty Talk was a black tunnel with white type (ac97485) and was reverted to white (ac6c20b "Talk stays white") with the black reserved for this one band.

### The composer

One white rounded form. Big variant: radius 32px, padding 12px (left 28px), textarea grows to 180px, text `clamp(19px,1.7vw,24px)`. Compact variant (docked at the foot once a chat has started): radius 28px, 17px text, grows to 120px. Ring is ink 10%, 25% on focus, red 40% while recording; shadow deepens on focus. Max 600 characters. Enter sends, Shift+Enter makes a new line.

- The placeholder is a live example that cycles every 3.4s with a blur-slide swap (`y 8 to 0`, blur 4px): "A pastel blue kurti for my farewell", "Ek maroon lehenga, gota patti ke saath", "A linen shirt with a mandarin collar", "A black blouse with a deep back". Static once a chat has started: "Add a detail or change anything", or when a question is open "Type your own answer, or anything to change".
- The send button is a 44-48px ink circle with an arrow; it springs between scale .86 and 1 and opacity .3 and 1 as the field gains text. Disabled while thinking or recording.
- Hint line under the big composer: empty, nothing; with text, "Enter to send, Shift and Enter for a new line"; after voice, "Check the words, then send."
- Voice: mic button (44px) beside send, only where supported. A two-way switch "EN" and "हिं" (aria "Speak in English" and "Speak in Hindi or Hinglish") slides an ink pill between sides with a shared `layoutId`. While recording: the mic turns red `#b5121b` with a halo that scales with the volume, five bars follow the voice, a `0:07` clock, "Listening. Pause when you are done." and a Cancel text button. While transcribing: dots and "Writing down what you said". The transcript lands in the composer for the person to check and is never sent by itself (commit 7c68bb4: the model must say it heard a voice, so noise never becomes a made-up request). Mic errors are one line with the fix and a "Try again" link: "The microphone is blocked. Allow it from the icon in the address bar, then try again." / "No microphone was found. Plug one in or type instead." / "The microphone could not start. Close other apps using it, then try again."
- Commit ae28838: "drop the voice bars and the sample briefs" from the empty state; the examples live only in the rotating placeholder and in the "I did not catch" recovery.

### Message styling in Talk

Talk is not a chat-bubble wall. The studio's voice is typography, the customer's is a bubble.

- The customer's message: right aligned, `max-w-[min(560px,88%)]`, ink fill, white 18px text, radius 26px with the bottom-right corner cut to 8px, entering with `SPRING` from `y 14, scale .97`. Every phrase the engine understood is underlined with a dashed stitch line that fades from transparent to sky blue; hover title "Understood as maroon". A skipped answer renders in a grey bubble (ink 5%).
- The studio's reply: no bubble. A 36px round ink-5% avatar with the chevron mark, then 21-26px medium text with tight tracking, revealed word by word (`Reveal`, blur 4px to 0, 12ms stagger capped at 1.2s). Earlier replies dim to 55% and brighten on hover. An optional second paragraph (the "advice" note) in 16px ink 60%.
- Thinking: the avatar plus three bouncing dots in a `#f2f3f5` bubble with a 6px bottom-left corner.
- The reply to a first garment reads as a plain sentence: "Pastel blue kurti, for a woman." Before a garment is known: "Got it, for a woman. What should we make?", "Noted. What should we make?", or "Tell me a little more. What should we make, and for which occasion?"
- Recovery when the engine finds nothing: "I did not catch a garment in that. Try describing what you would like made, for example:" (or, mid design, "I did not catch a change to your design. You could say something like:") followed by tappable example pills that drop the text into the composer. Examples: "A pastel blue kurti for my farewell", "Ek maroon lehenga, gota patti ke saath", "A linen shirt with a mandarin collar for my brother"; changes: "Make the sleeves full length", "Change the colour to maroon", "No embroidery, keep it simple".
- Off-topic or unsafe input is answered on the device and never reaches a model: "I can only help design clothes here. Tell me what you would like made, for example:".

### The questions

Rules, and why:

- One question at a time, best first, chosen by cost (a model proposes, the engine validates and falls back). Commit 30ec0be: "one ranked question at a time".
- Four questions at most (`QUESTION_CAP = 4` in `lib/engine/spec.ts`). The comment: "people tire after a few questions; past this the design is complete enough and the sheet takes the rest."
- Never ask age or budget (commit 0d32e07). Only wearer, then occasion, then garment details (and embellishment for dressy occasions). Age and budget change the cut when the customer states them, and stay editable on the sheet. An age is never read as a length ("an age is not a length", commit a15f24d, and the app filters model updates for any length slot whose evidence mentions years or saal).
- Every question can be skipped. Skipped questions are remembered so they are never asked again.
- Wording: "Who is it for?" with options "a woman", "a man", "anyone"; "What is it for?"; "Which style feels like you?" with "classic" and "modern" as friendly labels for traditional and western; "Any work on it?". The skip row is a ringed pill "Skip" then grey text "or type your own answer below".
- Options render as pictures (small drawn looks) when every option has one, otherwise as 44px pills: ink 5% fill that turn solid ink with white text on hover.

When the design has a garment and no open questions left, the "Finale" appears: "Your design is ready. Opening your moodboard, where we build the direction together." followed by shop cards (Shop similar, Ideas on Pinterest) and buttons "Open the tailor sheet" (primary) and "All ideas and shopping". Between questions a quiet row offers "Back", "Add pictures", "Tailor sheet", "Ideas and shopping".

### The design panel

Beside the chat on wide screens, an `aside` titled by the garment ("Your design" until one exists). Meta line: "Draft 3. Select any detail to change it." Empty: "Each detail you mention settles here, part by part, with where it came from." Each row is label, value (with a thumbnail and a chevron when editable), and a grey "from your words", "from your answer", "from your pictures", "from a note on your board", "from your edit". New or changed rows flash sky blue at 18% and fade over 1.4s. Notes show "for your tailor". Selecting a row opens a picker sheet with a search box ("Search garments"). Values go through a naming table so users see "classic" not "traditional", "pants" not "trousers".

Titling rule (commits a15f24d, 8bfb372): a kurti for a man is titled a kurta, everywhere: the panel, the sheet, the title of a sent request, the Ask context, and shop searches (which add "men" only when the garment name does not already imply the wearer).

---

## 3. Ask: the help assistant in the corner

Files: `web/components/site/Assistant.tsx` (UI), `web/api/assistant.js` (server), `web/lib/assistant/guard.js`, `retrieve.js`, `web/components/site/Motion.tsx` (`Reveal`, `Dots`, `Arrow`).

A round launcher (68px, the bubble-with-a-smile `AskIcon`, drop shadow, springy hover lift) sits bottom-right; it rises to `bottom-24` on the studio where a dock lives and is hidden entirely on `/orders`, `/makers` (the inbox has its own composer) and `/studio/board` (the board has its own buddy).

The panel: 400px by up to 600px, radius 28px, `bg-white/90` with `backdrop-blur-2xl` and a hairline ring (this is a floating element, so it gets glass). It opens from the launcher corner with `SPRING`, from `scale .92, blur 6px`. Header: icon, "Ask", "Answers from Bespoke's guides", and "New chat" once there is a conversation. Escape closes and returns focus.

- Empty state: big 26px "Hi. What are you making today?" and three starter pills: "How do I measure my bust?", "What is ease?", "How does the moodboard work?". With a design open the starters become choosing prompts: "Which colour palette suits my design?", "Give me three neckline options", "What fabric works best for it?".
- Bubbles: yours are ink with white text, radius 20px with a 6px bottom-right corner; the assistant's are `#f2f3f5` with a 6px bottom-left corner; max 85% width; 15px text. Answers reveal word by word (it is a staged reveal over a full answer, not a network stream). Dots while waiting.
- Under an answer: up to two action buttons to the page the answer is about (first one ink, second ringed), for example "Open the moodboard", "Open the tailor sheet", "Add measurements", "My requests", "Ideas and shopping", "Start a design"; and a source line "From Measuring guide and Glossary". Styling answers link "Open your design".
- Composer: 24px radius soft field on `#f2f3f5` that lifts to white on focus, placeholder "Ask about Bespoke", grows to four lines, 600 characters, round ink send arrow that fades in when there is text.
- Failure: the bubble turns blush (`#fdf1f1`, text `#8a1c1c`) with a "Try again" text button that re-asks in place. Copy: "I could not reach the assistant. Check your connection and try again." and, when not configured, "I am not switched on yet."

Server rules (`api/assistant.js`): POST only; 20 questions per caller per 5 minutes (429: "You have asked a lot of questions in a short time. Please wait a few minutes and try again."); an input guard before anything else; personal data redacted; BM25 retrieval over the guides, answering only if the passages cover the question; otherwise a fixed refusal "I can only help with Bespoke: describing a garment, the moodboard, measurements, the tailor sheet and working with a maker."; replies in the user's register (English or Hinglish), two or three sentences, at most 60 words, answer first, no emoji, no invented features, prices or policies (90 words for styling advice, two to four concrete options and a stated pick). Light model first, full model as fallback, one 20s budget with a 9s cap per model "so the fallback always gets a turn". Message text is never logged, only status codes. Questions that name clothes and ask for a choice go to a styling mode that sees the open design (trimmed to 300 characters, angle brackets stripped so it cannot close the fencing tags).

Commit history for Ask worth remembering: shorter answers with buttons to the page each answer is about (a1af229); questions about the app point to the studio first (d0b1147); page buttons follow what the question names, not just which guide ranked first (aa5660d); reasoning turned off so answers return in seconds (155727e).

---

## 4. The board, the pet, the reading

Files: `web/components/Board.tsx` (Excalidraw canvas, pasting, saving, orchestration), `web/components/board/Pet.tsx`, `Reading.tsx`, `notes.ts`, `cards.ts`, `palette.ts`, `BoardsMenu.tsx`, `web/components/ui/halo-dropzone.tsx`, `web/lib/engine/board.ts`, `web/api/vision.js`, `web/lib/boards.ts`.

### The board

An infinite canvas (Excalidraw) that opens blank on every visit, with a history of past boards in a menu. Pictures are dropped, pasted (a window-level paste handler adds any clipboard image to the canvas, except when focus is in a text field) or chosen, shrunk to 1280px for storage and 768px for sending. Boards save to Supabase when signed in (scene in a table, pictures in a private bucket) and to IndexedDB otherwise. Status pill at the top: "Saving", "Saved to your account", or "Saved on this device. Log in to keep it everywhere." Save failure: "This board could not be saved. Check your connection; it saves again with your next change."

Empty board overlay: display heading "Pin what you love." / "A board shows what words cannot. Add pictures of anything, point at the details, and we turn them into your design." / a halo dropzone with "Drop or paste pictures, or click to choose" (success "Added", hint "JPG, PNG or WebP") / three numbered steps: "Drop or paste pictures: Anything you love: clothes, art, anime, places, a colour." "Mark what matters: Circle a detail, or add a note such as "this neckline" or "not this colour"." "Read the board: We chart what each picture shows and write the direction right on the board."

Floating action pill (glass, bottom centre; on phones lifted above the pet): status text "Start with a picture", then "Circle a detail or add a note, then read"; "Clear notes"; ink "Read the board" (disabled while empty). A coach toast appears once: "Draw a circle round the detail you love, then read the board again." with "Got it". Wrong file: "Pictures only: JPG, PNG or WebP." Unopenable: "That picture would not open. Try another."

Reading writes its results back onto the canvas as cards under each picture ("chart what the image model sees", commit 8eed26d) and a Direction card to the right (`notes.ts` places them so they never overlap; they are typeset in the site's own face and tagged `bespokeNote` so they are never read back as the customer's words). A design coming from Talk opens the board on its creative direction (commit b7f18ba): the pet says "Here is your board for pastel blue kurti.", the assistant is asked for "a short creative direction for my design: the mood, a colour palette, the fabric, and two details that make it special", the answer is split into at most five sentences said one at a time, then "Now pin pictures that feel like it."

### The pet

A 60px ink squircle with a small tuft and white eyes, anchored bottom-left of the canvas (`bottom-[150px]` on phones, `bottom-[76px]` from md). It breathes (scale 1 to 1.035 every 3.2s), blinks at random 2.6-5.2s intervals, and its eyes follow the cursor by up to 3px. Moods: idle, thinking (bobs and tilts, eyes look up-right, dots bubble), happy (eyes become arcs, hops 10px, lasts 1.4s). It has no text box. It speaks in short bubbles above it, stacked at most three, older ones fade to 62% and then drift away. Tapping the pet hides or shows its words (aria "Hide what your board buddy says"). New words bring bubbles back. Under reduced motion it holds still.

```tsx
<motion.li key={s.id} layout={!still}
  initial={{ opacity: 0, y: 14, scale: 0.9 }} animate={{ opacity: i === shown.length - 1 ? 1 : 0.62, y: 0, scale: 1 }}
  exit={{ opacity: 0, y: -8, scale: 0.94, transition: { duration: 0.2 } }} transition={SPRING} style={{ transformOrigin: "bottom left" }}
  className={cn("rounded-[20px] rounded-bl-[6px] px-4 py-2.5 text-[15px] leading-[1.45] shadow-[0_14px_40px_-18px_rgba(13,17,23,.35)] ring-1 ring-black/[.05]",
    i === shown.length - 1 ? "bg-brand-ink text-white" : "bg-white/95 text-brand-ink backdrop-blur-xl")}>
```

The newest bubble is ink with white text; older ones are glass white. Sentences are queued with `setTimeout` at 1.1s intervals so it feels like talking. The tail is the 6px corner, not a drawn tail. The pet is hidden while the reading overlay is open.

Pet lines, verbatim: "Hi. Drop or paste anything you love: clothes, art, places, a colour." / "Welcome back. Read the board whenever you are ready." / "Lovely. Add a few more, or circle what you love, then read the board." / "3 lovely pictures. Circle a detail or add a note, then read the board." / "Reading your board." / "Reading 3 pictures." / "I charted what the image model sees under each picture." / "I wrote it all on your board." / ""Pastel and floral" is in your design now. Keep pinning." / "Those pictures are not ones I can read. Try clothes, colours, places or art you love." / "The pictures could not be read just now. Check your connection, then try again."

The buddy panel is the pet plus the action pill together; the Ask launcher steps aside on the board (`HIDDEN` list) so there is one helper per page.

### Full-screen reading with a halo

`Reading.tsx` is a modal (`role="dialog"`, `absolute inset-0 z-20`, white) with three phases.

- Reading: display heading "Reading your board." The current picture sits large (300px, radius 36px, deep shadow) over a slowly spinning conic-gradient halo (`.aura`) with a scanning light sweep across it. Thumbnails below (88-112px, radius 22px) dim to 50% except the active one, which gets a sky ring. Then a list of up to three steps, each with a dot (pulsing sky when working, ink when done, red 70% when failed, grey when skipped): "Your notes: Reading what you wrote / Your words lead", "Ideas from every picture: Colour, motif, shape and mood / Found what to borrow / Offline, so your device reads alone", "A close look on this device: Colour, print and the details you circled / Finished". First-run model download shows "Getting the reader ready, once on this device" with a 3px progress bar. A quiet "Cancel" button.
- Done: display heading "Here is a direction." (or "Here is what we see."), summary at 19px ink 65%, optional dot-prefixed notice. "Pick a direction" cards in a two-column grid (radius 28px, `#f5f5f7`, selected card goes white with a sky ring and long shadow), each with title, why, an ideas line like "anarkali, flared, v neck, georgette, pink" and colour dots. "From each picture": thumbnail, "Picture 2", what it shows, swatches (spring-in dots, names under), what to borrow, detail lines such as "Motifs: cherry blossoms". Footer: a floating glass pill on desktop, a bottom sheet on phones: ink "Use this direction", then "Circle a detail" and "Keep the notes on the board". Escape keeps the notes.
- Stopped: "Could not read it." or "Let's try other pictures." with a message that always includes the fix, and "Try again" / "Back to the board".

```css
/* web/app/globals.css: the halo */
.aura { position:absolute; inset:-14%; border-radius:42%;
  background: conic-gradient(from var(--aura-angle), #4285f4, #9b72cb, #d96570, #f2a93b, #2fa7a0, #4285f4);
  filter: blur(54px) saturate(1.25); opacity:.55; animation: aura-spin 7s linear infinite, aura-breathe 3.4s ease-in-out infinite; }
```

Colour only appears while pictures are being read; the rest of the product is ink and white (comment in `globals.css`: "black is the accent"). Notices when the cloud reader is unavailable are honest and specific: "Read on this device. Ideas from any picture arrive once the reader is switched on for this site.", "The idea reader is busy, so your device read this alone. Read again in a minute for ideas from any picture.", "You are offline, so your device read this alone. Connect for ideas from any picture." Left-out pictures: "Picture 3 was left out, as it could not be read here." Rule stated on the board: "Your words always come first; pictures only suggest."

---

## 5. Sheet, shop, makers and orders

### Tailor sheet (`/studio/sheet/`, `SheetView` in `App.tsx`)

Page head pattern shared by Sheet and Shop (`PageHead`): one huge display word masked in from below, one sentence of lede at 52ch. Sheet: "Tailor sheet." / "Everything your tailor needs, written from your design. Add your measurements, then print it or send it to a maker on Bespoke." With no design: a 28px sentence "Your sheet fills in as you describe the garment. Start in Talk, then come back here." and an ink 56px button "Describe a garment".

The sheet itself is a paper article with a sliding language switch (English or Hindi, ink pill on a grey track, `layoutId` spring), part and value rows with a grey source column, a "Drawings" figure grid, and measurements: "Measurements, in inches" with six bubbly inputs (Bust, Waist, Hip, Shoulder, Length, Sleeve; Hindi labels छाती, कमर, कूल्हा, कंधा, लंबाई, आस्तीन; placeholder an en dash; decimal keyboard; typing "34." survives until it becomes 34.5). Hint: "Measure over light clothing, tape snug but not tight. Ask in the corner explains each one." The finished-garment line: "Finished garment: bust 36 in, waist 30 in, hip 38 in." (Hindi variant exists). Actions: ringed "Print or save as PDF", ink "Send to a maker". Hindi is typeset in its own face class and was measured against references (commit 0e08d61, "translation score after the Hindi sheet fix").

Send to a maker (`SendToMaker.tsx`): requires a customer login via the gate, then a modal (`rounded-[32px]`, 560px): title "Choose a maker." with "They get your design, the sheet and your measurements, and you talk it through in one thread."; logged out "Log in to send it." with "Your design stays right here while you log in or create an account, and you come straight back to this sheet."; maker account "This is for customers." with "You are signed in as a maker. Log in with a customer account to send designs, or print this sheet instead." A note field "Add a note, for example when you need it by". Button "Choose a maker above" until one is picked, then "Send to Asha" (busy "Sending"). Empty: "No makers have joined Bespoke yet. Print the sheet or save it as a PDF and take it to any tailor; it says everything they need." The request freezes a snapshot of the design so the maker cuts from what the customer approved. Title is short and plain: "navy kurta".

### Shop (`/studio/shop/`, `ShopView`)

Head: "Find it." / "Searches written from your design and who it is for. Change the words if a shop finds too little. Every link opens on the shop's own site." Empty: "Describe the garment first, and the searches here write themselves."

Product decisions, from the commits and code comments:

- Short searches (commit a4db99b). `shopQuery` in `lib/engine/describe.ts` is only what a shop's search box can match: who it is for, one colour, the print, the garment. Comment: "Shops return nothing for long phrases ("men blue silk wedding classic embroidery kurta"), so the rest stays on the sheet and in Pinterest."
- No price filter. Comment: "a price filter on top of a search empties it too often; budget is shown on the sheet instead."
- The search box is the person's: a pill labelled "Search shops for" (80 characters), pre-filled with the short query, with a "Reset" button when changed. A three-way switch "Shopping for": Women, Men, Anyone.
- Print themes survive (commits 0d32e07, cd25c03): a named theme ("Harry Potter print") replaces the bare word "printed" in searches, and routes to fan-merch shops.
- Gender filters use each shop's own parameter (Myntra, Ajio, Flipkart); the note on each card says what happened: "Opens the women's section", "Searches women's styles", or "Opens a search on their site".
- Price comparison (commit cd25c03 "wider shops with price comparison"): `moreShops` adds "Google Shopping: Prices from every store, side by side" and "Google: Every store that sells it" always, plus The Souled Store, Redwolf and Bewakoof for printed designs, and Tata CLiQ Luxury and Farfetch for dressy or silk, velvet and brocade ones.
- Groups, in order, as 28px headings: "Ideas" (Pinterest), "Compare prices everywhere", "Buy something close, ready-made", "The fabric" (note "By the metre"), "Have it made" ("Tailors near you / Take your tailor sheet along"). Left, a sticky outfit drawing (`OutfitLook`) redrawn after every change on a generic model.
- Each result is a lifting card (radius 24px, white, hairline shadow that deepens on hover, `whileHover y -3`, favicon in a 44px tile, a small arrow that drifts up-right) that opens in a new tab.

### Orders and makers

Files: `web/components/market/Workspace.tsx`, `Composer.tsx`, `DesignSummary.tsx`, `Notifier.tsx`, `Avatar.tsx`, `web/lib/market/*` (types, rules, local, cloud, inbox).

One inbox for both sides, `/orders/` for customers and `/makers/` for makers, gated by role (`Gate.tsx`). Conversation list on the left, open thread on the right, the design pinned on top; on a phone the list and the thread are two screens with a back chevron ("All conversations"). Filter pills: All, Unread, Open. Rows: avatar (initials: "Kavya Rao" is "KR"), name, time as briefly as possible (clock today, weekday this week, "12 Nov"), "Navy kurta · Waiting on details", and the last line.

Statuses: New, Waiting on details, Accepted, Being made, Ready, Declined. Status changes post a system note, "Marked as being made." Makers can "Flag missing details": a picker titled "What is missing from the sheet?" with a button "Ask for it" or "Ask for these 3" (disabled "Nothing is missing"); if they write nothing, the message is composed for them: "Could you share the bust and waist?" The thread shows "Sent you a design" or "Design sent", and a small label "You asked for details" or "Kavya needs a few details". Quick replies for makers land in the composer to be edited: "Can you share a reference photo?", "What is your bust measurement?", "When do you need it by?", "What budget do you have in mind?", "Thanks, I have everything I need." Messages up to 2000 characters; the composer shows "N characters left" in the last 200 and "Shorten it to 2000 characters to send. It is 2143 now."

Live: a notifier toast on every page (except where the inbox composer sits), a badge, typing indicators over private realtime channels, and browser alerts behind a "Turn on alerts" link.

Empty states: "No requests yet." / "When a customer sends you a design, it lands here with the full sheet and their measurements." (maker); "Nothing sent yet." / "Describe a garment in the studio, then send its sheet to a maker. Your conversation starts here." plus a "Start a design" button (customer); filters "You are all caught up." and "Nothing open right now."; the right pane's ghosted display word "Pick a conversation." / "Quiet for now." / "Your threads appear here."

Errors: "That conversation is not available to you." / "Only the maker on this request can change it." / "That maker could not be found." / "Only customers can send a design to a maker." / "That did not send. Check your connection and try again." / "That did not save. Try again." / "Write a message first." / "This browser could not save your data. Free some space and try again."

Role-aware navigation: makers see their own nav; "Log in" asks customer or maker (commit f22108f).

---

## 6. Loading, empty and error states

Loading, in order of weight:

- Splash (`web/components/site/Splash.tsx`): a full-screen white cover on every fresh load until fonts are ready, minimum 700ms ("long enough to register as a loader, short enough not to feel like a wait"), then it fades out in 500ms. A 7 by 7 dot-matrix triangle (`DotmTriangle7`, size 44, dot 7, label "Loading") cycles dot opacities. The dot-matrix library is `web/lib/dotmatrix-core.tsx`, `dotmatrix-hooks.ts` and `web/components/dotmatrix-loader.css`; cells sit at 6% opacity, mid 38%, high 96%, in ink.
- Three bouncing dots (`Dots`, `aria-label="Thinking"`) in a grey bubble for chat waits.
- A single sentence in grey for page resumes: "Opening your last design".
- Reading overlay: halo, sweep, step list (section 4).
- Buttons say a verb in the -ing form: "One moment", "Sending", "Saving", "Writing down what you said".
- All of it stops under `prefers-reduced-motion`; `Reveal` renders plain text.

Empty states give a ghosted display word or one warm sentence and a clear next step: "Describe a garment" button, "Start a design" button, "Start with a picture".

Error states: red `#b5121b` text, `role="alert"`, always say what to do next. Failed assistant bubbles are blush with a "Try again" button. Never an exclamation mark, never "Oops".

---

## 7. Voice and microcopy rules

Thirty real strings:

Buttons: "Log in", "Create account", "Send reset link", "Send a new link", "Send again", "Go to log in", "Save new password", "Describe a garment", "Start a design", "Read the board", "Use this direction", "Circle a detail", "Keep the notes on the board", "Print or save as PDF", "Send to a maker", "Got it", "Skip", "New chat", "Try again", "Back to the board".

Headings: "Describe it. Wear it.", "How it works.", "Tailor sheet.", "Find it.", "Pin what you love.", "Reading your board.", "Here is a direction.", "Check your email.", "That link has expired.", "Password changed.", "No requests yet.", "Pick a conversation."

Rules inferred:

1. Sentence case everywhere. Never Title Case, never uppercase except tracked tiny labels (the board's slot tags such as GARMENT, NECKLINE). Headings end in a full stop when they are statements ("Find it.", "Your studio.") and are single words or short phrases.
2. Short. Buttons are one to four words and start with a verb. Headings are one to five words. Body sentences are under about 20 words. Ledes cap at one or two sentences and 52ch.
3. Plain, warm, second person. "You" and "your" a lot; the product says "we" for the studio ("We ask what is missing") and "I" for the pet and Ask. Contractions are rare; "Let's" and "I did not" both appear, so prefer the spelled-out form.
4. Every error says what happened, then what to do, in one or two sentences: "Those pictures are not ones I can read. Try clothes, colours, places or art you love." No blame, no jargon, no codes, no apologies beyond one "Sorry"-free tone.
5. No exclamation marks, no emoji, no "Oops", no "Please" except in rate-limit lines. Few em dashes (none found in UI copy). Colons introduce a list or an example.
6. Say what the technology did honestly: "your device read this alone", "Read on this device". Never imply a cloud or a person that is not there.
7. Numbers and units are spelled for a human: "13 to 19", "over ₹8,000", "bust 36 in", "0:07".
8. Names the customer would use, not the engine's: "classic" for traditional, "a woman" for women, "pants" for trousers, "Waiting on details" for needs-info.
9. Hinglish is welcomed in examples ("Ek maroon lehenga, gota patti ke saath") and the Hindi sheet is a first-class output, not a translation afterthought.
10. Hierarchy comes from size, weight and space; copy never relies on bold or capitals for emphasis. The ink-on-grey step (100%, 60%, 45%) carries importance.

---

## 8. Product thinking, from the commit log

Group these into principles to carry to a new product.

Ask less, infer more.
- Four questions at most, and never age or budget (0d32e07, QUESTION_CAP). People tire; the output absorbs what is still open. Age and budget are inferred from words if volunteered and editable later.
- One question at a time, ranked, skippable, never repeated (30ec0be, fdadae5 "one question with skip").
- An age is not a length (a15f24d). Guard cross-slot confusions with evidence checks, not just model confidence.
- Voice must declare it heard a voice (7c68bb4) so noise cannot become a confident made-up request. Transcripts go into the field for review; nothing sends itself.

Names are part of correctness.
- A man's kurti is titled a kurta, everywhere (a15f24d, 8bfb372): in the panel, the sheet, request titles, advice context, shop queries. Fix the vocabulary once in a naming function and route every surface through it.
- Values bind to the nearest part; inches beat "deep"; typos must look alike (0ec0b5d). A sleeve length binds to the sleeve (cd25c03). Precision in parsing is the product.

Match what the outside world can actually do.
- Short searches that shops can match; no price filter (a4db99b). Do not hand the user a link that returns nothing. Keep detail on the sheet and Pinterest, keep the shop search lean, and let the person edit it.
- Print themes are kept in searches (cd25c03, 0d32e07) because a theme is what the customer actually wants.
- Price comparison is one honest link, Google Shopping, plus extra shops only where the design suits them.
- Sign-in is asked at the moment of need, with a one-sentence reason, and returns you to where you were (14f24fd, 04d56d3, 855a878). The draft survives the trip, even through a new tab (c770a7d), and never outlives a sign-out.

Say the true thing in the true place.
- "An address that already has an account says so instead of 'check your email'" (a171423). Never mask a state to avoid a leak when the user is better served; here the clear message wins.
- Show where a value came from ("from your words", "from your edit") and let the customer correct it. Words lead; pictures suggest.
- Be explicit when a cloud model was unavailable and the device did the work (Reading notices).

Make the first screen almost nothing.
- Home was cleared to a headline and one button (abe84fd), then one ground, one image treatment, almost no copy (907da12), white theme (8c94b38), colour photographs of real craft instead of archive scans (ed13524). The brief (`design-prompts/home-page-aesthetic.txt`) fixes the system: white, ink `#0d1117`, one sky-blue accent, one geometric sans at weight 500, display `clamp(56px, 9vw, 160px)`, line-height .92, max width 1440, gutters 20 then 40px, section padding `clamp(64px, 9vw, 128px)`, floating glass pill nav with a sliding ink active tab, rounded-full buttons 44-48px with a .95 press, cards 24-28px with no borders or nesting, springs only (stiffness 420 and damping 34, or 160 and 24), 10-16px rise on entrance, one full-bleed ink band near the foot, no badges, check-mark lists, emoji icons, gradients or stats.
- Talk opens on the composer with "how it works" in a black band (b7f18ba). Explaining belongs below the action, in the one place black is allowed.
- Talk stays white (ac6c20b): the black tunnel (ac97485) was tried and reverted. When an experiment fights the system, revert it.
- A finished design moves to the board, which opens on its creative direction (b7f18ba): the next step is handed over, not menu-ed.

One helper per page, small and honest.
- Ask is hidden where another helper lives (`HIDDEN`: inbox, board). The board has a pet that speaks in bubbles (3032b75) and has no text box. Fewer voices, each with a clear job.
- Ask answers only from the product's own guides and refuses the rest (guard, retrieval, abstain on weak matches: 0ec0b5d "Ask answers less from weak matches"), with a light model first and a fallback inside a hard time budget (d932e58, a2b6a31). Failures log status codes, never text (ee2e1ee).

Own your surfaces.
- Each page has its own URL (4d62064 `/studio/talk|board|sheet|shop/`, bc65089 clean addresses, no `.html`), with metadata, a share image, sitemap, robots and structured data (dcc33d1). The studio lives in the layout so moving between pages keeps it mounted.
- The Bespoke mark is the tab and home-screen icon (0df523b), chevrons apart as in the mark (e27a1b3).
- Security headers and a black-box security suite plus one command for every test (3ed5875). Tests accompany each flow: board, inbox end to end in two tabs, studio, market.
- Docs on GitHub Pages and an MCP server for Bespoke (992dcb0), a launch kit (a25fb4c): ship the explanation as well as the product.

Layout details that came from fixing real friction.
- Curved fields even when the browser autofills them, one show-password button (8ffed89). Native widgets leak; hide or restyle them.
- Maker sign in no longer bounces a signed-in customer (a7c656e). Phone studio keeps its home link (b8d8f4c). Phone layout of the board (e4ec51d).

---

## 9. Gaps in this document

- Exact CSS for the studio shell (`.hero`, `.fitting`, `.dock`, `.order`, `.item`) lives in `web/app/legacy.css` and was not reproduced; it is a layout of a 52ch hero, a growing column of messages above a fixed dock, and a sticky design panel on wide screens.
- The Hindi translation templates and the engine's lexicon (`web/lib/engine/*`) are not described beyond the rules that surface in product behaviour.
- `halo-dropzone.tsx` (2040 lines, a React Bits style component) was only read at its call site.
- The About page copy (problem, how it works, founder's vision, a three.js lanyard) and the home page copy are outside this file's scope.
