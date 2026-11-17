# Voice: microcopy and product principles

Two halves. The first is how the product speaks, as rules you can apply to any product. The second is the thinking behind the product, as principles distilled from Bespoke's commit log. Bespoke strings are the examples; replace them with the new product's own words, keep the rules. Login and account copy is in login.md.

## Microcopy rules

1. Sentence case everywhere. Never Title Case. Never uppercase except a tiny tracked slot label. Headings that are statements end in a full stop ("Find it.", "Your studio."); one to five words.
2. Short. Buttons are one to four words and start with a verb. Body sentences stay under about 20 words. A lede is one or two sentences at most 52 characters wide per line (`52ch`).
3. Plain, warm, second person. "You" and "your" a lot. The product says "we" for the studio side ("We ask what is missing") and "I" for a helper character. Spell contractions out: "I did not", not "I didn't".
4. Every error says what happened, then what to do, in one or two sentences. No blame, no codes, no jargon, no apology theatre. "Those pictures are not ones I can read. Try clothes, colours, places or art you love."
5. No exclamation marks, no emoji, no "Oops", no "Please" except in rate-limit lines. Few em dashes (none in the UI). A colon introduces a list or an example.
6. Say what the technology really did. "Your device read this alone." "Read on this device." Never imply a cloud or a person that is not there.
7. Numbers and units are written for a human: "13 to 19", "over 8,000 rupees", "bust 36 in", "0:07".
8. Use the names your user would use, not the engine's. "classic" for traditional, "pants" for trousers, "Waiting on details" for needs-info. Put one naming function between the data and every screen.
9. Welcome the user's own language. Examples show real mixed-language phrasing ("Ek maroon lehenga, gota patti ke saath"), and a second-language output is first-class, not a translation afterthought.
10. Hierarchy comes from size, weight and space, not bold or capitals. The ink step (100%, 60%, 45%) carries importance.
11. Verbs for busy states are in the -ing form and are specific: "One moment", "Sending", "Saving", "Writing down what you said".
12. Every empty state gives a next step. Every dead end gives a way out.
13. Placeholders are real examples, not instructions. "A pastel blue kurti for my farewell" beats "Type your request".
14. Reasons are one sentence and concrete: "Your maker gets the design, the sheet and your measurements, and you talk it through in one thread."

### Real strings, by kind

Buttons: "Start a design", "Read the board", "Use this direction", "Circle a detail", "Print or save as PDF", "Send to a maker", "Got it", "Skip", "New chat", "Try again", "Back to the board".

Headings: "Describe it. Wear it.", "How it works.", "Tailor sheet.", "Find it.", "Pin what you love.", "Reading your board.", "Here is a direction.", "No requests yet.", "Pick a conversation."

Ledes, one or two sentences: "Tell us the garment you want, the way you would tell a friend, in English or Hinglish. We ask what is missing, one question at a time, and turn it into a sheet any tailor can follow." / "Everything your tailor needs, written from your design."

Errors: "That did not send. Check your connection and try again." / "That did not save. Try again." / "Write a message first." / "Pictures only: JPG, PNG or WebP." / "That picture would not open. Try another." / "This browser could not save your data. Free some space and try again." / "Shorten it to 2000 characters to send. It is 2143 now."

Rate limit (the one place "please" appears): "You have asked a lot of questions in a short time. Please wait a few minutes and try again."

Off-topic refusal, naming what the helper does cover: "I can only help with Bespoke: describing a garment, the moodboard, measurements, the tailor sheet and working with a maker."

Recovery with examples the user can tap: "I did not catch a garment in that. Try describing what you would like made, for example:" followed by example pills.

Honest degradation: "You are offline, so your device read this alone. Connect for ideas from any picture." / "Saved on this device. Log in to keep it everywhere."

Empty states: "Nothing sent yet." / "Describe a garment in the studio, then send its sheet to a maker. Your conversation starts here." / "You are all caught up."

Helper voice (first person, short, true): "Reading 3 pictures." / "I wrote it all on your board." / "Those pictures are not ones I can read. Try clothes, colours, places or art you love."

Confirmations that name the change: "Marked as being made." / "Pastel and floral is in your design now. Keep pinning."

## Product principles

Each principle is a rule for any product, with the Bespoke evidence as one line.

### Ask less, infer more

People tire after a few questions. Take a free-text request, infer what you can, ask only what the output cannot absorb, one question at a time, ranked, skippable and never repeated. Guard against confident mistakes with evidence checks, not model confidence, and never act on noise.

Bespoke evidence: four questions at most and never age or budget (commit 0d32e07, `QUESTION_CAP`); an age is never read as a length (a15f24d); voice must say it heard a voice, so noise cannot become a made-up request (7c68bb4).

### Names are correctness

Fix the vocabulary once in a naming function and route every surface through it: the panel, the document, the title of a sent request, the help context, the search query. A wrong word on one surface reads as a wrong product. Parsing precision is part of the product: values bind to the nearest part, typos look alike.

Bespoke evidence: a man's kurti is titled a kurta everywhere (a15f24d, 8bfb372); a sleeve length binds to the sleeve (cd25c03).

### Match what the outside world can do

Do not hand the user a link, search or option that returns nothing. Shape your output to what the outside system accepts, keep detail where the person can read it, and let them edit the query. Ask for an account at the moment of need, with a one-sentence reason, and return them to where they were.

Bespoke evidence: shop searches are only who, one colour, the print and the garment, because shops return nothing for long phrases, and there is no price filter because it emptied results (a4db99b); print themes are kept in searches (cd25c03).

### Say the true thing in the true place

Never mask a state to be clever when the user is better served by the plain statement. Show where a value came from and let them correct it. Say when the cloud was unavailable and the device did the work. The person's words always lead; machine output only suggests.

Bespoke evidence: an address that already has an account says so instead of "check your email" (a171423); rows read "from your words", "from your edit"; "Your words always come first; pictures only suggest."

### Make the first screen almost nothing

One headline, one action, the footer. Explaining belongs below the action, in the one place black is allowed. One ground, one image treatment, almost no copy. When an experiment fights the system, revert it. When a task finishes, hand over the next step instead of a menu.

Bespoke evidence: home cleared to a headline and one button (abe84fd, 907da12); the black "tunnel" empty state was reverted (ac6c20b "Talk stays white") and how-it-works moved to a band (b7f18ba); a finished design opens the board on its creative direction (b7f18ba).

### One helper per page, small and honest

Fewer voices, each with a clear job. A text helper where reading is the task; a pet with no text box where the work surface needs the space. Hide the corner helper wherever another lives. A helper answers only from the product's own material, refuses the rest plainly, abstains on weak matches, and never logs what people said.

Bespoke evidence: Ask is hidden on the inbox and the board (`HIDDEN`); the board has a pet that speaks in bubbles (3032b75); Ask answers less from weak matches (0ec0b5d); failures log status codes only (ee2e1ee).

### Own your surfaces

Give each page its own URL, metadata, share image, sitemap, robots and structured data. Use the product's mark as tab and home-screen icon. Ship security headers and a black-box security suite with one command for every test. Ship the explanation too: docs on GitHub Pages and an MCP server.

Bespoke evidence: `/studio/talk|board|sheet|shop/` with clean addresses (4d62064, bc65089, dcc33d1); the mark as favicon (0df523b); security headers and a pentest suite (3ed5875); docs and MCP (992dcb0).

### Native widgets leak, so fix the friction

Hide or restyle what the browser adds. Keep the layout working on a phone at every stage. Revert what a user actually trips on.

Bespoke evidence: curved fields even under autofill and one show-password button (8ffed89); phone studio keeps its home link (b8d8f4c); phone layout of the board (e4ec51d).

## The standing checklist for a new product

Before building, answer in one line each: who is the person and what do they say in their own words; what is the first screen's one headline and one action; what is the single question you would ask last; which outside systems must the output fit; what is the one helper on each page; what is the author line. Then build from tokens.md and patterns.md, write the copy under the rules above, and run the **essentials** check.
