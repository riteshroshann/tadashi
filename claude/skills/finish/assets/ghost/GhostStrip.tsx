import type { CSSProperties } from "react";

// one tool in the strip: a simple-icons path, an image, or a two-letter monogram
export type Logo = { name: string; role: string; path?: string; hex?: string; img?: string; mono?: string };

// a still, ghosted strip: every tool rests faint and grey, and comes alive in its own colour under the pointer
export function GhostStrip({ title = "Built with", logos }: { title?: string; logos: Logo[] }) {
  return (
    <section className="ghost-sec" aria-label={title}>
      <div className="wrap">
        <p className="ghost-title reveal">{title}</p>
        <ul className="ghost-row reveal">
          {logos.map((l) => (
            <li key={l.name} className="ghost" style={{ "--brand": l.hex ?? "#0d1117" } as CSSProperties}>
              <span className="ghost-mark">
                {l.path && (
                  <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d={l.path} />
                  </svg>
                )}
                {l.img && <img src={l.img} alt="" width={24} height={22} />}
                {l.mono && <span className="ghost-mono">{l.mono}</span>}
              </span>
              <span className="ghost-name">{l.name}</span>
              <span className="ghost-role">{l.role}</span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
