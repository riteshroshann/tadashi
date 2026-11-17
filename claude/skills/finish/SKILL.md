---
name: finish
description: The house finishing touches for any web page, with working source to copy. Ghost effects from Helios (a slowly breathing blurred echo behind the hero headline, a mirrored fading reflection under a product preview, and a still greyscale "Built with" logo strip that wakes into brand colour on hover) and the Bespoke about page's 3D lanyard (a draggable, flippable photo ID card on a strap, rendered in plain three.js with real physics and a glossy, matte, metallic or holographic finish). Use when polishing a landing, product, portfolio or about page, when a page feels flat or unfinished, or when the user asks for ghost effects, a tech or "built with" strip, a reflection, a lanyard, a badge, or a 3D photo card.
---

# Finish

Two finishing systems, both shipped in real sites. Copy the files from `assets/`; never rewrite them from memory. They assume the onestyle tokens (`--spark` accent, `--ease: cubic-bezier(0.32, 0.72, 0, 1)`, ink `#0d1117`); define those if the project has none.

## Ghost effects (from Helios)

Copy `assets/ghost/ghost.css` into the site stylesheet and `assets/ghost/GhostStrip.tsx` into the components. Use at most two per page.

1. **Hero ghost.** A huge blurred copy of the headline in the accent colour, breathing over 9 seconds behind the real one. Put it first inside the hero grid:

   ```tsx
   <div className="hero-grid">
     <span className="hero-ghost" aria-hidden="true">{headline}</span>
     <h1 className="hero-h1">{headline}</h1>
   </div>
   ```

2. **Stage ghost.** A flipped, blurred, fading reflection of the product shot directly under it, as if the preview stands on glass:

   ```tsx
   <img src={shot} alt="The app" />
   <div className="stage-ghost" aria-hidden="true"><img src={shot} alt="" /></div>
   ```

3. **Ghost strip.** Logos at 42% opacity in greyscale; hovering the row dims the rest to 22% and lifts the one under the pointer into full brand colour with its role underneath. Brand paths come from `simple-icons` (`siReact.path`, `` `#${siReact.hex}` ``); tools with no icon get a two-letter `mono`.

   ```tsx
   import { siReact } from "simple-icons";
   <GhostStrip logos={[{ name: "React", role: "Interface", path: siReact.path, hex: `#${siReact.hex}` }]} />
   ```

   Add a trademark line under the strip when it names other companies' products.

Reduced motion stops the breathing; everything else is static or hover-only, so it costs nothing at load.

## 3D lanyard about page (from Bespoke)

A photo ID card hanging from a strap. Drag it, throw it, flip it to see the back. Plain `three` (0.186 or newer): no react-three-fiber, drei or rapier; the physics step and card textures are hand-written.

1. `bun add three`, then copy `assets/lanyard/Lanyard.jsx`, `Lanyard.css` and `Lanyard.d.ts` into `components/about/`, and `band.png` into `public/lanyard/`.
2. Make the card photos: `card-front.jpg` (the person's photo with name and role) and `card-back.jpg`, portrait 1.6 : 2.25, about 1024 px wide. Ask the user which photo goes on each side.
3. Load it client-only so the first paint pays nothing:

   ```tsx
   const Lanyard = dynamic(() => import("./Lanyard"), { ssr: false, loading: () => null });

   <div className="relative h-[560px]">
     <Lanyard frontImage="/lanyard/card-front.jpg" backImage="/lanyard/card-back.jpg"
       strapImage="/lanyard/band.png" strapColor="#0d1117" finish="glossy"
       size={0.62} strapLength={0.55} breeze={0.4} />
     <p className="pointer-events-none absolute inset-x-0 bottom-5 text-center text-[13px] opacity-40">
       Drag the card. Flip it over.
     </p>
   </div>
   ```

   In Vite, use `lazy(() => import("./Lanyard"))` inside `Suspense` instead of `next/dynamic`.

4. Lay the author block out as two columns: lanyard on one side, heading, two short paragraphs and social pills on the other, alternating sides for each person.

Props worth knowing: `finish` is `glossy`, `matte`, `metallic` or `holographic`; `orientation` portrait or landscape; `anchor` left, center or right; `gravity`, `damping`, `elasticity` and `breeze` tune the swing; `interactive={false}` makes it decorative; `intro` drops it in on load. Credit React Bits in `licenses.txt`.

## Before calling it done

Screenshot the page at 1440 and 390 wide. Check the hero ghost never sits over body text, the reflection ends before the next section, the strip wraps cleanly on a phone, and the lanyard canvas has a fixed height and drags with a finger.
