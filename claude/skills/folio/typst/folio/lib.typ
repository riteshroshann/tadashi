// folio: book-grade typesetting.
// white page, one serif, lots of air. no rules, no boxes, no fills.

#let ink = rgb("#151515")
#let quiet = rgb("#6f6f6f")

// content -> plain string, for pdf metadata
#let plain(it) = {
  if it == none { "" }
  else if type(it) == str { it }
  else if it.has("text") { it.text }
  else if it.has("children") { it.children.map(plain).join() }
  else if it.has("body") { plain(it.body) }
  else if it == [ ] { " " }
  else { "" }
}

// letterspaced small caps for labels, bylines, table heads
#let caps(body, tracking: 0.12em) = text(tracking: tracking, smallcaps(lower(body)))

#let folio(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  note: none,             // one quiet line under the byline: edition, version, place
  style: "book",          // "book", or "lab" for a university lab record
  logo: none,             // lab: cover image, e.g. image("logo.png", width: 8.5cm)
  course: none,           // lab: course code and name, shown under the title
  roll: none,             // lab: register or roll number
  guide: none,            // lab: faculty name
  guide-label: "Under the guidance of",
  paper: "a4",
  lang: "en",
  size: 12pt,
  contents: true,
  depth: 2,
  chapter-label: "Chapter",
  serif: auto,
  mono: "JetBrains Mono",
  body,
) = {
  let lab = style == "lab"
  let serif = if serif == auto { if lab { "Times New Roman" } else { "EB Garamond" } } else { serif }
  let authors = if author == none { () }
    else if type(author) == array { author }
    else { (author,) }

  set document(
    title: if title == none { none } else { plain(title) },
    author: authors.map(plain),
  )

  // page and text
  set page(paper: paper, fill: white, margin: (x: 42mm, top: 34mm, bottom: 40mm))
  set text(
    font: serif, size: size, fill: ink, lang: lang,
    number-type: if lab { "lining" } else { "old-style" }, hyphenate: true,
  )
  set par(
    justify: true, leading: 0.74em, spacing: 1.3em, linebreaks: "optimized",
    justification-limits: (tracking: (min: -0.012em, max: 0.018em)),
  )
  // bold must read as bold at a glance, not as a heavier regular
  set strong(delta: 300)

  // headings
  set heading(numbering: "1.1")
  show heading: set text(weight: "regular", hyphenate: false)
  show heading: set par(justify: false, leading: 0.5em)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    // the contents title isn't outlined itself; start it higher so long contents fit
    v(if it.outlined { 26mm } else { 10mm })
    if it.numbering != none {
      // times has no small caps, so the lab style tracks plain capitals
      let label = [#chapter-label #counter(heading).display("1")]
      text(size: 9.5pt, fill: quiet, if lab { text(tracking: 0.14em, upper(label)) } else { caps(label) })
      v(6mm, weak: true)
    }
    block(text(size: 26pt, it.body))
    v(15mm, weak: true)
  }

  show heading.where(level: 2): it => block(
    above: 2.7em, below: 1.15em, sticky: true,
    text(size: 15pt, it.body),
  )

  show heading.where(level: 3): it => block(
    above: 2.2em, below: 0.9em, sticky: true,
    text(size: 12pt, style: "italic", it.body),
  )

  show heading.where(level: 4): it => block(
    above: 1.9em, below: 0.8em, sticky: true,
    text(size: 10pt, caps(it.body, tracking: 0.08em)),
  )

  // contents
  set outline(depth: depth)
  set outline.entry(fill: none)

  show outline.entry.where(level: 1): it => {
    v(0.95em, weak: true)
    link(it.element.location(), box(width: 100%, {
      box(width: 2.2em, text(fill: quiet, it.prefix()))
      it.body()
      h(1fr)
      it.page()
    }))
  }

  show outline.entry.where(level: 2): it => {
    v(0.44em, weak: true)
    link(it.element.location(), box(width: 100%, {
      h(2.2em)
      text(size: 0.94em, it.body())
      h(1fr)
      text(size: 0.94em, fill: quiet, it.page())
    }))
  }

  // body elements
  set list(marker: text(fill: quiet)[–], indent: 0.3em, body-indent: 0.75em, spacing: 0.8em)
  set enum(indent: 0.1em, body-indent: 0.6em, spacing: 0.8em)
  // definition lists read like a dictionary: term on its own line, description below
  show terms.item: it => block(above: 1.35em, below: 1.35em, breakable: false, {
    block(below: 0.35em, sticky: true, text(weight: "medium", {
      show raw: set text(size: size * 0.86)
      it.term
    }))
    pad(left: 1.6em, par(justify: false, it.description))
  })

  show link: set text(fill: ink)
  show std.divider: v(2.4em)

  set raw(theme: "folio.tmTheme")
  // absolute sizes, since typst already scales raw text and em would compound.
  // inline code matches the text's x-height; headwords sit a touch larger.
  show raw: set text(font: mono, size: size * 0.76)
  show raw.where(block: true): set text(size: 8.8pt)
  show raw.where(block: true): set par(justify: false, leading: 0.6em)
  // listings that fit on a page (~40 lines) never split
  show raw.where(block: true): it => block(
    width: 100%, inset: (left: 1.6em), above: 1.6em, below: 1.6em,
    breakable: it.lines.len() > 40, it,
  )

  show quote.where(block: true): it => pad(x: 2.2em, block(above: 1.6em, below: 1.6em, {
    set text(style: "italic")
    it.body
    if it.attribution != none {
      v(0.4em)
      align(right, text(style: "normal", size: 0.9em, fill: quiet, it.attribution))
    }
  }))

  set table(stroke: none, inset: (x: 0.55em, y: 0.5em))
  set table.hline(stroke: none)
  set table.vline(stroke: none)
  show table: set par(justify: false)
  show table: set text(size: 0.93em, number-type: "lining", number-width: "tabular")
  show table.cell.where(y: 0): it => text(size: 0.92em, fill: quiet, caps(it, tracking: 0.06em))

  set figure(gap: 1.1em)
  show figure: set block(above: 2em, below: 2em)
  show figure.caption: set text(size: 0.88em, style: "italic", fill: quiet)
  set figure.caption(separator: [. ])

  set footnote.entry(separator: none, clearance: 1.8em, gap: 0.55em)
  show footnote.entry: set text(size: 8.8pt)
  show footnote.entry: set par(justify: false)

  // lab records number sections i., ii. within each chapter, frame code,
  // rule tables, and keep code operators exactly as typed
  let roman(nums) = numbering("i.", nums.at(1, default: 1))
  show heading.where(level: 2): it => if lab {
    block(above: 2.7em, below: 1.15em, sticky: true, text(size: 15pt)[
      #box(width: 2.2em, text(fill: quiet, counter(heading).display((..n) => roman(n.pos()))))#it.body
    ])
  } else { it }
  show outline.entry.where(level: 2): it => if lab {
    v(0.44em, weak: true)
    link(it.element.location(), box(width: 100%, {
      h(2.2em)
      box(width: 2.2em, text(size: 0.94em, fill: quiet, roman(counter(heading).at(it.element.location()))))
      text(size: 0.94em, it.body())
      h(1fr)
      text(size: 0.94em, fill: quiet, it.page())
    }))
  } else { it }
  show heading.where(level: 3): it => {
    show raw: set text(size: 10.5pt, weight: "bold", style: "normal") if lab
    it
  }
  show raw: set text(ligatures: false, features: (calt: 0)) if lab
  show raw.where(block: true): it => if lab {
    block(width: 100%, inset: (right: 10pt, y: 9pt), radius: 3pt,
      stroke: 0.6pt + luma(175), fill: luma(248), breakable: it.lines.len() > 40, it)
  } else { it }
  set table(stroke: 0.6pt + luma(140), inset: (x: 7pt, y: 6pt),
    fill: (_, y) => if y == 0 { luma(236) }) if lab
  show table.cell.where(y: 0): it => if lab { pad(x: 7pt, y: 6pt, align(left, strong(it.body))) } else { it }

  // front page. the title scales with its length and the subtitle wraps
  // to a column barely wider than the title, so a short title over a long
  // caption still reads as one compact, centred unit.
  let title-size(t) = {
    let n = plain(t).len()
    if lab { if n <= 28 { 28pt } else if n <= 56 { 24pt } else { 20pt } }
    else if n <= 22 { 38pt } else if n <= 44 { 31pt } else if n <= 80 { 25pt } else { 21pt }
  }
  let title-block(max) = {
    let size = title-size(title)
    let weight = if lab { "bold" } else { "regular" }
    block(width: 100%, text(size: size, weight: weight, hyphenate: false, title))
    let sub = if lab and course != none { course } else { subtitle }
    if sub != none {
      v(if lab { 5mm } else { 6.5mm })
      context {
        let tw = measure(text(size: size, weight: weight, title)).width
        let w = calc.min(max, calc.max(tw * 1.15, 92mm))
        block(width: w, par(leading: 0.55em, text(size: 13pt,
          style: "italic", fill: quiet, hyphenate: false, sub)))
      }
    }
  }
  if title != none and lab {
    page(margin: (x: 30mm, top: 26mm, bottom: 30mm), footer: none, {
      set align(center)
      set par(justify: false, leading: 0.5em)
      if logo != none { logo }
      v(2fr)
      title-block(150mm)
      v(3fr)
      let label(body) = text(size: 10pt, tracking: 0.14em, fill: quiet, upper(body))
      if authors.len() > 0 {
        label[Submitted by]
        v(3mm)
        text(size: 15pt, authors.join(", "))
        if roll != none { v(2mm); text(size: 12pt, roll) }
      }
      if guide != none {
        v(9mm)
        label(guide-label)
        v(3mm)
        text(size: 15pt, guide)
      }
      if date != none { v(12mm); text(size: 11pt, fill: quiet, date) }
      v(0.5fr)
    })
  } else if title != none {
    page(margin: (x: 30mm, top: 30mm, bottom: 32mm), footer: none, {
      set par(justify: false, leading: 0.42em)
      set align(center)
      v(2.3fr)
      title-block(118mm)
      v(3fr)
      if authors.len() > 0 {
        text(size: 10.5pt, caps(authors.join(", "), tracking: 0.16em))
      }
      if date != none {
        v(3mm)
        text(size: 10.5pt, fill: quiet, date)
      }
      if note != none {
        v(2mm)
        text(size: 9.5pt, fill: quiet, style: "italic", note)
      }
      v(0.6fr)
    })
  }

  if contents {
    outline()
  }

  // body: arabic page numbers from 1, centred at the foot
  set page(footer: context align(center, text(size: 9pt, fill: quiet, counter(page).display("1"))))
  counter(page).update(1)
  body
}
