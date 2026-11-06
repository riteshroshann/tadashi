---
name: folio
description: Make any PDF a person will read (report, essay, analysis, manual, notes, university lab record), including requests for a "LaTeX" PDF: Typst gives LaTeX-grade output. Only when .tex source itself is required, use the installed `tectonic -X compile file.tex`. Never install a TeX engine. Not for editing existing PDFs.
---

# Folio

Everything is installed and works. Do not read the template or scripts, and do not install anything.

1. Write `doc.md`. `#` is a chapter (new page), `##` a section, `###` a subsection; `# Preface {.unnumbered}` has no number.

   ```markdown
   ---
   title: Title
   subtitle: Optional caption, any length
   author: Ritesh Roshan    # the default; change only if the user names someone else
   date: October 2026
   ---

   # TL;DR {.unnumbered}

   **The single most important finding, in one sentence.**

   **The decision or recommendation, in one sentence.** One plain
   sentence of supporting detail with the **key number** in bold.

   **The main risk or caveat, in one sentence.** What happens if it
   occurs.

   # First chapter

   Prose.
   ```

   The cover sizes itself: the title scales with its length and the subtitle wraps to a column just wider than the title, so a short title over a long caption stays one compact, centred block. Keep titles under about eight words and put the rest in `subtitle`.

2. Build. It lints the prose, then typesets:
   `python ~/.claude/skills/folio/scripts/folio.py build doc.md --sheet sheet.png`
   If it reports prose errors, rewrite those sentences and build again. A `flat` warning means too little bold; fix it.

3. Read `sheet.png` once. It shows every page on one image. Fix only what is visibly wrong: a near-empty page, a split table, a stranded heading, a cover whose caption sprawls. To inspect one page closely, add `--png pages` and read only that page.

4. Reply with the PDF path.

## Structure and emphasis

No page should be a wall of plain paragraphs. A skimmer reading only the headings and the bold text must get the whole argument.

- **TL;DR first.** Every document opens with `# TL;DR {.unnumbered}`, the first page after the contents: three or four short paragraphs, each led by one bold sentence a reader can act on.
- **Real hierarchy.** Chapters split into `##` sections every page or so, and `###` subsections where a section has parts. Headings are short and specific, never a bare "Overview" or "Introduction".
- **Bold on every page.** In each paragraph bold the sentence that carries the finding, plus the **key terms, numbers and names** a reader scans for: usually two to four bold spans per paragraph, never a whole paragraph.
- **Lists where content is a list.** Steps, options, properties and comparisons go in bullets or numbered lists, each item led by a **bold term** and then its explanation, as in this list. Reasoning stays in paragraphs.
- **Tables for data**, at most five columns, with a `Table: caption` line.

The output is a white A4 page in EB Garamond, with a title page, contents, and chapters on new pages, and no lines, boxes or fills. Don't add any. Write concretely, with no filler, no emoji and few em dashes. Code lines stay within 64 characters.

## Lab records

For a university lab record or practical file, add `style: lab` and follow [references/lab.md](references/lab.md): Amrita cover with logo, course, roll number and guide, Times New Roman, framed code, ruled tables and a fixed experiment structure.

## Typst

To write Typst instead, start with `#import "@local/folio:1.0.0": folio` and `#show: folio.with(title: [Title], author: "Name")`, then build the `.typ` the same way. Lab records take the same keys as arguments: `style: "lab", logo: image("amrita-logo.png", width: 8.5cm), course: [...], roll: [...], guide: [...]`.
