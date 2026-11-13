# Backend, integrations and deployment: runbooks

Source: repo riteshroshann/onestyle (product Bespoke), read from `C:\Users\roshh\Desktop\ta&bda`. Paths are relative to the repo root. Use these as runbooks for a new product. Anything marked UNCONFIRMED was done in a dashboard and is not recorded in the repo; check it rather than assume.

Shape of the stack, in one paragraph. `web/` is a Next.js 16 static export (`output: "export"`) deployed to Vercel with Root Directory `web`. Server logic is not Next route handlers: it is plain Vercel functions in `web/api/*.js` that sit beside the static output. Accounts, the marketplace and per-user data live in Supabase, behind row-level security, with a full local (browser storage) fallback when no keys are set. Model calls go through one OpenAI-compatible endpoint (Gemini by default) with an ordered model list. The on-device tagger and CLIP run in the browser from ONNX. The docs site in `site/` is hand-written static HTML deployed to GitHub Pages by Actions. `mcp/` is a stdio MCP server that calls the deployed site.

Design rule that recurs everywhere and is worth copying: the product works with zero environment variables. Every cloud feature is an upgrade over a working local default.

## Environment variables, all of them

| name | where used | exposure | purpose |
|---|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | `web/lib/supabase.ts`, `web/lib/market/index.ts` | public, inlined at build | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | same | public by design, safe only because of RLS | anon key |
| `LLM_API_KEY` | `web/api/*.js` | server only | Gemini key, also used by image generation |
| `LLM_BASE_URL` | `web/api/*.js`, `web/lib/studio/server.js` | server only, optional | default `https://generativelanguage.googleapis.com/v1beta/openai/` |
| `LLM_MODEL` | same | server only, optional | comma list, default `gemini-flash-lite-latest,gemini-flash-latest` |
| `AVATAR_MODEL` | `web/api/avatar.js` | server only, optional | default `gemini-2.5-flash-image,gemini-2.0-flash-preview-image-generation` |
| `BESPOKE_URL` | `mcp/server.js` | client machine | which deployment the MCP server calls, default the Vercel URL |
| `PLAYWRIGHT_CORE` | `web/tests/run-all.ts` | local | path to a playwright-core install for the browser walks |

No Brevo, SMTP or Resend variable exists in the repo: email is configured entirely inside Supabase (see the Brevo runbook). No `.env*` file is committed; `.gitignore` exists at the repo root. Secrets live in Bitwarden and are pasted into Vercel and the Supabase dashboard.

Every function returns `501 {"error":"not configured"}` when `LLM_API_KEY` is missing, and the browser treats any non-200 as "use the on-device answer". README still says the `LLM_MODEL` default is `gemini-3.8-flash`; that is stale, the code default is the two-model list above.

---

## Set up Supabase auth

What the repo contains: four SQL files in `web/supabase/`, a lazy shared client, and two store implementations behind one interface.

1. Create a Supabase project (free tier). Note the project URL and the anon key (Project Settings, API).
2. In the SQL editor run, in this order, each once: `web/supabase/schema.sql`, `boards.sql`, `designs.sql`, `inbox.sql`. `inbox.sql` is additive and safe to run twice; it is optional and adds read-sync and typing. The first line of each file says when to run it.
3. Authentication, Providers: keep Email enabled with "Confirm email" ON. The code assumes this: `signUp` creates the account and returns no session until the link is clicked (`web/lib/market/cloud.ts`, comment above `signUp`). Minimum password length is enforced client-side (`MIN` in `web/components/market/AuthPage.tsx`); the Supabase-side minimum is a dashboard setting and UNCONFIRMED.
4. Authentication, URL Configuration: set Site URL to the production origin (`https://onestyle-tawny.vercel.app`) and add Redirect URLs for `/login/`, `/makers/login/` and `/reset/` on that origin and on `http://localhost:3000`. The code sends `emailRedirectTo` and `redirectTo` from `location.origin`, so Supabase rejects them unless the origin is on the allow list. The allow list itself is UNCONFIRMED (dashboard only).
5. Realtime: `schema.sql` adds `requests` and `messages` to the `supabase_realtime` publication; `inbox.sql` adds `reads` and two policies on `realtime.messages` for private broadcast channels. Private channels need "Allow public access" OFF in Realtime settings; UNCONFIRMED.
6. Storage: `boards.sql` creates the private `boards` bucket (5 MB, jpeg/png/webp) with policies keyed on the first path segment equal to `auth.uid()`.
7. Put the two `NEXT_PUBLIC_` variables in Vercel (all environments) and in `web/.env.local`. They are read at build time, so redeploy after changing them.
8. Verify with `bun tests/security/pentest.mjs` against the live site: it checks that anonymous callers cannot read rows and that the shipped JavaScript contains only an `anon` role JWT, never `service_role`.

### Tables and row-level security

| table | owner key | who may read | who may write |
|---|---|---|---|
| `profiles` | `id` = `auth.users.id` | signed-in people see makers and themselves | own row, columns `name, city, craft, specialties, bio` only (`revoke update`, then column `grant`) |
| `requests` | `customer_id`, `maker_id` | the two parties | customer inserts with `status='new'`, `missing='{}'`, role checks both ways; maker updates `status`, `missing` only |
| `messages` | `request_id` | parties, via `is_party()` | sender is self; non-text kinds only by the maker |
| `reads` | `user_id` | own rows | own rows, parties only |
| `boards` | `owner_id default auth.uid()` | owner | owner (select, insert, update, delete) |
| `designs` | `owner_id default auth.uid()` | owner | owner |

Patterns worth reusing verbatim:

```sql
-- profile row built by a trigger from sign-up metadata, so it works before the email is confirmed
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
declare meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
begin
  insert into public.profiles (id, role, name, email) values (
    new.id,
    case when meta ->> 'role' = 'maker' then 'maker' else 'customer' end,
    coalesce(nullif(trim(meta ->> 'name'), ''), 'Unnamed'), new.email);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();
```

```sql
-- security-definer helper so a policy can ask "am I a party to this row's parent" without recursion
create function public.is_party(rid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.requests r
    where r.id = rid and auth.uid() in (r.customer_id, r.maker_id)) $$;
```

Rules the schema follows: RLS enabled on every table; `to authenticated` on every policy (nothing for `anon`); role and email immutable after sign-up; server-side triggers (`touch_request`) keep derived fields honest; the server clock (`mark_read`, `now()`) is the only clock; check constraints on lengths (`messages.body <= 2000`, `boards.title <= 120`, `cover <= 40000`). Sign-up role is trusted from metadata only to choose between `customer` and `maker`, with anything else falling to `customer`.

### Client wiring

`web/lib/supabase.ts` builds one client per page, or `null` when keys are absent:

```ts
export function supabase(url = process.env.NEXT_PUBLIC_SUPABASE_URL, key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
  if (client === undefined) client = url && key ? createClient(url, key) : null;
  return client;
}
```

Boards and designs use the same client so one session serves everything.

### Auth flows implemented (`web/lib/market/cloud.ts`, `web/components/market/AuthPage.tsx`, `web/app/reset/page.tsx`)

- Sign up: `db.auth.signUp({ email, password, options: { emailRedirectTo, data: { role, name, ... } } })`. The redirect is `${location.origin}/login/?confirmed=1`, or `/makers/login/?confirmed=1` for makers.
- Existing address: Supabase returns a user with empty `identities` and sends no email; the code detects that and says the address already has an account instead of "check your email" (commit a171423). `user_already_exists` and "already registered" map to the same message.
- Unconfirmed login: `email_not_confirmed` becomes "Confirm your email first. We sent you a link."
- Expired or reused link: Supabase redirects with `#error_code=otp_expired` or `#error=access_denied`; `AuthPage` reads the hash and shows a pane with a resend button calling `db.auth.resend({ type: "signup", ... })`.
- Forgot password: `db.auth.resetPasswordForEmail(email, { redirectTo: `${location.origin}/reset/` })`. The `/reset/` page then calls `db.auth.updateUser({ password })` using the recovery session the link establishes.
- Session: `getSession()` for reads; `onAuthStateChange` wrapped so Supabase methods are not called inside the callback (deferred with `setTimeout`, as Supabase asks).
- Sign-out clears studio drafts (commit c770a7d). A `safeNext()` rule in `web/lib/market/rules.ts` restricts post-login return paths to same-site paths.
- Error text is normalised through one function so users never see raw provider messages.

### Local fallback (`web/lib/market/local.ts`)

`getStore()` in `web/lib/market/index.ts` picks the store: cloud when both public variables are set at build time, otherwise `createLocalStore()` plus `seedDemoMakers`. The local store implements the same `Store` interface (`mode: "cloud" | "local"`). Details worth copying: passwords are kept only as SHA-256 with a per-account salt (demo only, never claim it is secure); storage is read fresh on every call; a `BroadcastChannel` (with a `storage`-event fallback) refreshes other tabs; each tab remembers its own signed-in user in `sessionStorage` so a customer and a maker can be tried side by side; storage access is wrapped so blocked storage falls back to memory. Unit tests run against this store with `createMemoryStorage()` (`web/tests/market.test.ts`, `inbox.test.ts`).

---

## Set up Brevo email

Finding: nothing in the repo mentions Brevo, SMTP, Resend, Sendgrid or Mailgun. A search of README, `docs/`, `site/`, `web/` and the full commit history found no email provider. The only email behaviour in code is the Supabase auth calls above. So either Bespoke uses Supabase's built-in mailer, or custom SMTP (the brief suggests Brevo) was configured in the dashboard and never written down. This runbook is therefore the standard setup, not a reconstruction. First action in any session that depends on it: ask the user which it is, or open Supabase, Authentication, Emails, SMTP Settings and look.

Why it matters: Supabase's built-in mailer is limited to a few messages an hour per project and only delivers to addresses on the project team. Sign-up confirmation for real users needs custom SMTP.

1. Create a Brevo account (free plan, about 300 emails a day). Brevo then asks for a business address and a sender.
2. Add and authenticate a sender domain: Brevo, Senders, Domains and IPs, Add a domain. Add the DKIM (two CNAME or one TXT depending on the screen), the Brevo code TXT, and a DMARC TXT (`v=DMARC1; p=none; rua=mailto:...`) at the DNS host. Wait for Brevo to show the domain as authenticated. Without a domain of your own, add a single sender address and click the verification link; mail from a free-mail address will land in spam more often. UNCONFIRMED which of these Bespoke used.
3. Create an SMTP key: Brevo, SMTP & API, SMTP tab, Generate a new SMTP key. The key is the password. Store it in Bitwarden.
4. Brevo SMTP values: host `smtp-relay.brevo.com`, port `587` (STARTTLS; `465` for SSL), username the Brevo account login email shown on the SMTP tab, password the SMTP key. These are Brevo's documented values; the repo does not record that they were used.
5. In Supabase: Authentication, Emails (older UI: Settings, Auth), SMTP Settings, Enable custom SMTP. Enter sender email (a verified sender or an address on the authenticated domain), sender name (`Bespoke`), host, port, username, password. Save.
6. Raise the auth email rate limit: Authentication, Rate Limits. With custom SMTP the default is low; set it to something that fits the Brevo daily cap.
7. Templates: Authentication, Emails, Templates. Edit "Confirm signup" and "Reset password". Keep `{{ .ConfirmationURL }}` as the link target; it already carries the `emailRedirectTo` / `redirectTo` the app sends. Plain subject lines in the product voice. No template files exist in the repo, so any customised text is dashboard-only and UNCONFIRMED.
8. Redirect URLs must already be allow-listed (Supabase auth step 4), or the link lands on the Site URL instead of `/login/?confirmed=1`.
9. Test: sign up with a fresh address, confirm the mail arrives in the inbox (not spam), click it, land on `/login/?confirmed=1`, see "Your email is confirmed. Log in to continue." Then forgot password and the `/reset/` page. Then reuse the link to see the expired pane.

Checklist to run against the existing project before trusting it: custom SMTP enabled and host/port/user; sender domain authenticated (DKIM, DMARC) in Brevo; Site URL and Redirect URLs; Confirm email ON; template text; email rate limit; minimum password length.

---

## Wire model APIs with fallback

Provider: Google Gemini through its OpenAI-compatible endpoint, free tier. Any OpenAI-compatible provider works by changing `LLM_BASE_URL` (README lists OpenAI and Groq). No other provider is wired. Keys never reach the browser.

### Functions

| file | route | does | `maxDuration` (`web/vercel.json`) | rate limit per IP |
|---|---|---|---|---|
| `web/api/assistant.js` | `/api/assistant` | Ask: retrieval-grounded help, or styling advice | 25 s | 20 per 5 min |
| `web/api/vision.js` | `/api/vision` | reads moodboard pictures (multimodal) | 25 s | 12 per 5 min |
| `web/api/understand.js` | `/api/understand` | open-vocabulary parse of a request | 15 s | via `limiter()` in `web/lib/studio/server.js` |
| `web/api/next.js` | `/api/next` | picks the next question | 12 s | same |
| `web/api/transcribe.js` | `/api/transcribe` | speech to text, WAV up to about 30 s | 25 s | same |
| `web/api/avatar.js` | `/api/avatar` | outfit image | 30 s via `export const config` (not listed in vercel.json) | 30 per 10 min |

Rate limiting is an in-memory sliding window per `x-forwarded-for`. It is per function instance and resets on cold start, so it is a courtesy brake, not a quota. Map size is capped at 5000 entries.

### Fallback order and timeouts

1. Models are a comma list, tried in order: `gemini-flash-lite-latest` first (answers in about two seconds), then `gemini-flash-latest`. Commits d932e58 and 77909c6.
2. One time budget across the whole list (`BUDGET_MS = 20000`), inside the 25 s function limit. Each model gets at most `9000` ms (`Math.min(left, 9000)`), and the loop stops if under 1500 ms remain. Commits a2b6a31 and b8d8f4c: the cap exists so a stalled first model cannot starve the fallback, and the shared budget lets a long answer finish.
3. A non-OK status is logged as the status code only, never the body or user text (commit ee2e1ee). Abort or network error returns null and moves on.
4. All models failed: `502` with a friendly message. The browser then uses its on-device answer.
5. Reasoning is deliberately off. Commits 155727e, 94da1d9, 78938c3 record the sequence: hidden reasoning made answers slow, low effort was accepted, then the setting was dropped. Do not add a reasoning parameter; it hurt latency.

```js
async function askOne(model, messages, ms) {
  const ctl = new AbortController();
  const timer = setTimeout(() => ctl.abort(), ms);
  try {
    const r = await fetch(`${BASE}chat/completions`, { method: "POST", signal: ctl.signal,
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${process.env.LLM_API_KEY}` },
      body: JSON.stringify({ model, temperature: 0.2, max_tokens: 320, messages }) });
    if (!r.ok) { console.warn(`assistant: ${model} answered ${r.status}`); return null; }
    return String((await r.json())?.choices?.[0]?.message?.content ?? "").trim() || null;
  } catch { return null; } finally { clearTimeout(timer); }
}
```

`web/lib/studio/server.js` holds the shared `BASE()`, `MODELS()`, `limiter()`, `callerIp()`, `parseBody()`, `plain()`, `parseJSON()` and a `chat()` helper, used by `understand`, `next` and `transcribe`. `assistant.js` and `vision.js` keep their own copies of the same loop (older code; a new project should have one).

### Guardrails around the model (the reason the app is safe to expose)

1. Method check (POST only), rate limit, then input screen (`screen()` in `web/lib/assistant/guard.js`), then PII `redact()`.
2. Retrieval first: BM25 over the guides (`web/lib/assistant/retrieve.js`, index built by `web/scripts/build-assistant-index.mjs`). The model is called only if passages cover the question or the question is a styling question. Otherwise a fixed off-topic reply goes back with no model call.
3. User text is stripped of `<` and `>` and fenced in tags (`<passages>`, `<question>`, `<design>`); the system prompt says the fenced text is data.
4. `checkAnswer()` verifies the reply against the passages before returning; failures replace the answer and drop the sources.
5. Every value a model returns for the studio is validated against `web/lib/ontology.json`; anything unknown becomes a free-text note for the tailor, never a design value. Lengths are capped (`LIMITS` in `vision.js`).
6. No message, transcript, audio or picture is logged. Status codes only.

### Keys stay server-side

- Only `NEXT_PUBLIC_*` variables are inlined into the bundle. `LLM_API_KEY` is read inside `web/api/*.js`, which run only as Vercel functions.
- `bun tests/security/pentest.mjs` greps the shipped JavaScript for secrets and decodes any JWT it finds to check its role is `anon`.
- Gemini key creation: Google AI Studio, Get API key. Free tier, so the rate limits above matter.

### In-browser models (`web/lib/models.ts`)

No data leaves the device for these.

- Tagger: `web/public/models/bespoke-tagger/` (config, tokenizer, `onnx/model_quantized.onnx`, 33 MB int8). Loaded by transformers.js with `dtype: "q8"`, `local_files_only: true`, `localModelPath = "/models/"`. Output goes through constrained Viterbi (`web/lib/engine/decode.ts`) and is merged with the gazetteer: gazetteer spans first, model spans only where the gazetteer found nothing.
- transformers.js is not bundled. It is imported at runtime from `https://cdn.jsdelivr.net/npm/@huggingface/transformers@4.3.0` through `new Function("u", "return import(u)")` so the bundler never sees onnxruntime and the static bundle stays small. Pin the version.
- Failure is silent and safe: any load error calls `onState("rules")` and the gazetteer-only path continues (`tag()` returns `by: "rules"`).
- Whisper (`Xenova/whisper-base`, q8) and CLIP (`Xenova/clip-vit-base-patch32`, q8) come from the Hugging Face Hub via the same loader, only when needed: Whisper when the browser has no speech service, CLIP for the moodboard reader. `allowLocalModels` is flipped to false after the tagger so these skip local lookups.
- Latency timings are exposed on `window.__bespokeTimings` for tests, never sent anywhere.
- Training and export live in `engine/` (`engine/scripts/ladder.py`, `check_onnx.py`); results in `results/tagging.json`.

---

## Image generation for the outfit look

`web/components/OutfitLook.tsx` draws the design on a generic fashion model and redraws after every change. Two stages:

1. Main: POST `/api/avatar` with `{ prompt }`. The function calls Gemini's image model directly, `POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent` with header `x-goog-api-key: LLM_API_KEY`, models `gemini-2.5-flash-image` then `gemini-2.0-flash-preview-image-generation` (override with `AVATAR_MODEL`). It returns `{ image: "data:image/...;base64,..." }`. Client abort at 28 s (`MAIN_MS`); function limit 30 s; prompt capped at 1400 chars; 30 requests per 10 minutes per IP.
2. Fallback: on any failure the browser loads `https://image.pollinations.ai/prompt/<prompt>?width=832&height=1248&nologo=true&model=flux&seed=<n>` (`openImageUrl` in `web/lib/avatar.ts`). Free, no key, public service.

Details: the prompt is built on the device from the design alone (`avatarPrompt`), with no photo, face or measurements of the customer. `seedOf()` hashes garment plus wearer so the same model stays across redraws while details change. A 900 ms debounce (`WAIT_MS`) means a burst of edits draws once, a `Map` caches one image per prompt for the visit, and the previous look stays on screen softly blurred while the next draws. Reduced-motion is respected via `useReducedMotion`. Commit cd25c03 introduced this.

---

## Shop search and price comparison

There is no shopping API, scraping or server call. `web/lib/engine/describe.ts` builds deep-link search URLs from the design and opens them on the shop's own site, so prices are always live and nothing is stored.

- `shopLinks(spec)`: Myntra, Ajio, Amazon India, Flipkart, Nykaa Fashion, each narrowed with its own gender filter query parameter where the shop has one (`filtered: true`), using boys/girls for children.
- `moreShops(spec)`: Google Shopping (`https://www.google.com/search?tbm=shop&q=`) as the price-comparison across every store, plus "buy {query} online" on Google. Conditional extras: The Souled Store, Redwolf, Bewakoof when the design has a print; Tata CLiQ Luxury and Farfetch when it is for a wedding or similar occasion or in silk, velvet or brocade.
- `links(spec)`: Pinterest idea searches, a fabric-by-the-metre search on Amazon, and a Google Maps "boutique tailor near me" search.
- Decisions recorded in commits: short searches the shops can match (a4db99b), no price filter because it emptied results (comment above `amazon` in `shopLinks`; budget is printed on the sheet instead), men's searches say kurta not kurti (a15f24d, 8bfb372), print kept in the query (cd25c03), search box the user can edit.

To repeat: keep a pure function from structured design to URLs, add a test that every URL parses, and avoid price filters.

---

## MCP server (`mcp/`)

- Run: `cd mcp && npm install`, then `claude mcp add bespoke -- node /path/to/onestyle/mcp/server.js`. Transport is stdio (`StdioServerTransport`). Node 20 or later. `BESPOKE_URL` overrides the deployment it calls (default `https://onestyle-tawny.vercel.app`).
- Dependencies pinned exactly: `@modelcontextprotocol/sdk` 1.32.2, `zod` 4.6.7. `package.json` has a `bin` entry and `npm test` runs `mcp/test.js`, which exercises the tools over a real stdio connection.
- Tools, registered with `server.registerTool` and zod input schemas:
  - `ask_bespoke(question, design?)`: POSTs to `/api/assistant` with a 30 s timeout; returns the answer, up to two source titles and absolute links; errors come back with `isError: true`.
  - `search_guides(query, limit?)`: runs BM25 locally by importing `../web/lib/assistant/retrieve.js`; no network.
  - `studio_link(view?)`: returns a URL for `new`, `talk`, `board`, `sheet`, `shop` or `makers`.
- Pattern: expose the product's already-guarded public API plus one local read-only tool; never give the MCP server keys. Documented at `site/mcp/index.html`.

---

## Deploy app to Vercel

1. Import the GitHub repo in Vercel. Set Root Directory to `web`. Production branch `main`.
2. `web/vercel.json` carries the rest, so no dashboard build settings are needed:

```json
{
  "framework": null,
  "installCommand": "npm install",
  "buildCommand": "npm run build",
  "outputDirectory": "out",
  "functions": { "api/assistant.js": { "maxDuration": 25 }, "api/vision.js": { "maxDuration": 25 } },
  "git": { "deploymentEnabled": { "visual-picker": false } }
}
```

   `framework: null` stops Vercel treating it as a Next server; `outputDirectory: "out"` serves the static export; every file in `web/api/` becomes a function beside it. `git.deploymentEnabled` switches off preview deploys for one branch.
3. `web/next.config.mjs`: `output: "export"`, `images: { unoptimized: true }`, `trailingSlash: true`. Trailing slashes give each route a folder with `index.html`, which is why every link in the code ends in `/`.
4. Environment variables (Settings, Environment Variables): set `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `LLM_API_KEY` for Production, and Preview if previews should work. Optional `LLM_BASE_URL`, `LLM_MODEL`, `AVATAR_MODEL`. The README says set them for the deployment and redeploy; the exact per-environment split in the dashboard is UNCONFIRMED.
5. Security headers are set for all routes in `web/vercel.json`: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: camera=(), microphone=(self), geolocation=(), payment=(), usb=(), interest-cohort=()` (microphone allowed for voice input), `Cross-Origin-Opener-Policy: same-origin` (commit 3ed5875). No Content-Security-Policy is set; the app loads transformers.js from jsDelivr and models from the Hub, so adding one needs those hosts.
6. Caching: no custom `Cache-Control` headers. Vercel's defaults apply: fingerprinted `/_next/static/*` is immutable, HTML and public files revalidate. The 33 MB ONNX file relies on browser HTTP cache after first load (3.4 s cold, see Performance).
7. Domain: production is `https://onestyle-tawny.vercel.app`, a Vercel-assigned subdomain. No custom domain is recorded. The URL is hard-coded in `web/app/layout.tsx` (`SITE`), `web/app/robots.ts`, `web/app/sitemap.ts`, `web/tests/security/pentest.mjs`, `mcp/server.js`, README and the docs. For a new product, define it once.
8. SEO, from commit dcc33d1:
   - `web/app/layout.tsx`: `metadataBase`, title "Bespoke · Clothes made from your words", description, `authors: [{ name: "Ritesh Roshan" }]`, `openGraph` and `twitter` (`summary_large_image`) with `/og.png` (40 KB), and a JSON-LD `SoftwareApplication` script with `creator` as a Person, `inLanguage`, a free `Offer`.
   - `web/app/robots.ts` (`dynamic = "force-static"`): allow `/`, disallow `/api/` and `/orders/`, sitemap and host set.
   - `web/app/sitemap.ts`: a priority table of eight public routes.
   - Icons: `web/app/icon.svg` and `web/app/apple-icon.png` (the mark), commit 0df523b.
9. After deploy run `bun tests/security/pentest.mjs` (live) and open `/api/assistant` with GET to see a 405.

---

## Deploy docs to GitHub Pages

The docs are plain HTML in `site/`, not generated by a framework. Live at `https://riteshroshann.github.io/onestyle/`.

1. Repo Settings, Pages, Source: GitHub Actions. This is a dashboard step and UNCONFIRMED but required for the workflow to publish.
2. `.github/workflows/pages.yml` (whole file is short):

```yaml
name: docs
on:
  push:
    branches: [main]
    paths: ["site/**", ".github/workflows/pages.yml"]
  workflow_dispatch:
permissions: { contents: read, pages: write, id-token: write }
concurrency: { group: pages, cancel-in-progress: true }
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: { name: github-pages, url: "${{ steps.deployment.outputs.page_url }}" }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with: { path: site }
      - id: deployment
        uses: actions/deploy-pages@v4
```

3. The workflow publishes the `site/` folder as is. There is no build step in CI, so anything bundled must be committed. The one bundled widget is the React Bits folder: `site/src/` (`FolderFloat.jsx`, `main.jsx`, `package.json`, `bun.lock`) builds with `cd site/src && bun install && bun run build` into `site/folder.js` and `site/folder.css`, which are committed.
4. Clean addresses (commit bc65089): one folder per page with an `index.html` (`site/guide/`, `site/developers/`, `site/contributing/`, `site/mcp/`, and `site/index.html`), so links have no `.html`. Use root-relative or relative links that work under the `/onestyle/` project path.
5. Each page carries its own OG and Twitter meta, the shared `style.css` and `app.js`, a footer with "Engineered by Ritesh Roshan", and a link back to the product.
6. No custom domain and no CNAME file in `site/`.

### Docs structure to copy

Pages: `index.html` (overview with the floating folder of guides), `guide/` (user-facing), `developers/` (how it is built), `contributing/` (the bar, checks, rules), `mcp/` (tools, connect, try it). Each is a hero (`h1.display` plus a `lede`) followed by `section#id > .wrap.cols` with an `h2` on the left and content on the right; alternate sections get class `dark`.

- guide: Talk, Board, Sheet, Shop, Makers and the inbox, Ask. One section per product room.
- developers: The map (file by file), From words to a specification, The tagging ladder, The text analytics underneath, Reading pictures, Big data analytics (built versus planned, stated plainly), Run it (clone, install, run, build, test, env vars), How we build.
- contributing: The bar (numbered steps), Before you open a pull request, Design rules, Writing, Data and safety.
- mcp: Tools table, Connect it, Try it.

Docs rules that held: every number is reproducible from the repo; planned work is labelled planned with its exit test; docs and in-app Ask guides are updated together (commit e4ec51d).

### README structure to copy

One title line with the live URL and docs URL, then: what it does and the pipeline in numbered layers (device first, model optional), The tagging ladder (results table), The course syllabus topic by topic with where each lives, How a request becomes a specification, Layout (a code block mapping folders to purpose), Run the site, Tests (commands, then a kind/where/what table, then a latency table), Deploy (Vercel, env var table), Not done yet. Authorship: "Engineered by Ritesh Roshan" at the end of sub-READMEs (see `mcp/README.md`).

---

## Test

Runners: no Jest or Vitest. Unit suites are plain Node scripts using `node --experimental-strip-types`, so TypeScript runs with no build. Browser tests use Playwright in two flavours: Python pytest with sync Playwright (`web/tests/e2e/test_*.py`) and Node/Bun walks (`board.e2e.mjs`, `studio.e2e.ts`, `inbox.e2e.ts`) that launch Microsoft Edge through `playwright-core`. Python engine tests use pytest.

Commands (`web/package.json`, README):

```
cd web && npm test                      # 13 unit suites in series, node --experimental-strip-types
cd web && bun run test:all              # bun tests/run-all.ts: everything below in one run
cd web && bun run test:security         # bun tests/security/pentest.mjs [url] [--rate]
cd web && bun tests/run-all.ts --live            # also hit the deployed site
cd web && bun tests/run-all.ts --skip-e2e        # skip the browser walks
engine/.venv/Scripts/python -m pytest engine/tests -q     # engine unit, F1 floor, ONNX latency
engine/.venv/Scripts/python -m pytest web/tests/e2e -q    # Playwright: smoke ... latency
cd mcp && npm test                      # tools over a real stdio connection
```

`run-all.ts` runs types, the build, every unit suite, the three browser walks against the fresh build on port 4299, then the security checks; it prints pass, fail or skip per step. Set `PLAYWRIGHT_CORE` to a playwright-core `index.mjs` or the browser walks are skipped and the run says so. Screenshots go to a temp folder, never the repo (commit 3ed5875). The `test_*.py` fixtures (`conftest.py`) serve `web/out` with a small static server whose POST handler returns 501, which simulates a deployment with no `LLM_API_KEY`.

Unit suites in `web/tests/`: `engine`, `requests`, `api`, `unit`, `edge`, `looks`, `market`, `inbox`, `vision`, `board`, `studio`, `assistant`, `designs`. `parity_fixtures.json` holds 352 fixtures that prove the TypeScript engine matches the Python one.

Coverage by kind:

| kind | covers |
|---|---|
| unit and parity | tokenizer, gazetteer, decoding, spec fold, 352 fixtures against Python, F1 floor 0.93 |
| functional | 21 realistic requests end to end, editing, contradictions, Hindi sheet, shop links |
| integration | model fallback and validation (handlers called with a fake `fetch`), failure paths |
| market and inbox | the local store, RLS-shaped rules, threads, unread, two-tab behaviour |
| smoke | build serves, every page opens, model files shipped, no console errors |
| usability | axe-core WCAG 2 AA, keyboard-only, 32 px touch targets, no sideways scroll on a phone, reduced motion |
| edge | empty, 20,000 characters, emoji, Devanagari, gibberish, markup in input, double send, blocked storage, model CDN unreachable |
| security (`pentest.mjs`) | headers on `/`, `/studio/talk/`, `/login/`; each function's input handling and prompt injection; secrets in shipped JS; anonymous RLS reads; `--rate` proves the limits by bursting (skip at busy hours) |

Design for testability worth copying: handlers export their inner functions (`askModel`, `readBoard`, `limited`, `resetLimits`) and accept an injected `fetch`, `models` and `key`, so tests never call a provider. Local security checks are skipped when the base URL is localhost because a static server does not send Vercel headers.

Latency results (`results/latency-browser.json`, `latency-engine.json`, `latency-onnx.json`), laptop CPU, Chromium, no GPU: engine 0.04 ms p50; int8 tagger in ONNX Runtime 3.6 ms p50, 7.0 ms p95; tagger in browser WASM 20 ms p50, 53 ms p95; send to answer 75 ms p50, 130 ms p95; first contentful paint 340 ms; hero visible 535 ms; tagger first load, cold cache, 3.4 s. `web/tests/e2e/test_latency.py` writes these through `record()` and asserts FCP under 2000 ms and tagger load under 15000 ms. `hyperfine` is the standing tool for CLI speed claims.

Other result files in `results/` are evaluation outputs from the NLP studies (one JSON per study, plus `figures/`); regenerate them with the scripts in `web/scripts/eval-*.mjs` and `engine/`.

---

## Performance: why it loads near-instantly

Measured: first contentful paint 340 ms, hero 535 ms. The causes, each found in the repo:

1. Static export. Every page is pre-rendered HTML on Vercel's CDN; there is no server render on the request path.
2. Fonts are self-hosted at build time: `next/font/google` with `Google_Sans`, `subsets: ["latin"]`, three weights, `display: "swap"`, exposed as `--font-ui`. No request to a font service at runtime (comment in `web/app/layout.tsx`). One typeface family.
3. Heavy code is split: `next/dynamic` with `ssr: false` for the studio `App`, the Excalidraw `Board`, and the three.js `Lanyard` on About. The home page does not pay for them.
4. Models never block rendering. The tagger (33 MB) loads after the page is interactive, with a `loading` state; until then the gazetteer answers on its own, so the first request works instantly. transformers.js comes from a CDN at runtime and is not in the bundle.
5. Images: `images.unoptimized` (static export has no optimiser), so photos are pre-sized files in `web/public/photos` and `images`; the share image is 40 KB.
6. Tailwind was told to stop scanning `public/` (`@source not "../public"` in `web/app/globals.css`), which had stalled builds for minutes (commit 659ae8a). The ONNX file and photos live there.
7. The outfit image waits 900 ms after the last edit and is cached per prompt, so network calls are few.
8. Models on the server side are capped at 9 s each so a slow provider never blocks the UI beyond the budget, and every model failure has an on-device answer.

Checks to repeat for a new product: measure FCP in a real browser (`test_first_paint`), keep a latency JSON in `results/`, and fail the test on a regression.

---

## What could not be confirmed from the repo

- Which email sender is used and whether Brevo is involved: no mention anywhere. Brevo values above are the provider's standard ones.
- Supabase dashboard state: custom SMTP, email templates, Confirm email, Site URL, Redirect URL allow list, password length, auth email rate limit, Realtime "public access" setting, whether `inbox.sql` was applied.
- Vercel dashboard state: which environments hold which variables, any custom domain, deployment protection.
- GitHub Pages source set to GitHub Actions.
- No `justfile` in the repo, and no `.gitignore` inside `web/`; a new project should follow the genesis skill and add both.
- Stale docs: README's `LLM_MODEL` default and its mention of only `api/understand.js` as a function predate the current set of six.
