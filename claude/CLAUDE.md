# Standing orders

These apply to every project. A project's own CLAUDE.md adds to them and never lowers them.

## The bar
- Ship finished work, with no placeholders, TODOs or stubs. If something can't be finished, say what's missing.
- Verify before claiming: run it, test it, render it, look at it. Report failures plainly.
- Polish counts: naming, spacing, alignment, empty states, error messages.
- Recommend one solution; don't survey.

## Speed and cost
- Act on sensible defaults. Ask only when the answer changes what you build.
- Spend tokens only where they buy quality:
  - Use a skill's commands as written; don't read its source.
  - Never install a tool that duplicates an installed one.
  - Keep checks proportional to the risk.
- Batch independent tool calls, and run long jobs in the background.

## This machine
- Windows 11, PowerShell 7 by default, with Git Bash available.
- The budget is zero: only free tools.
- Claude Code is the only coding agent. Never install Codex, Gemini CLI or aider.
- Tools:
  - Search: `rg` for text, `fd` for files.
  - Data and text: `ast-grep` for structural refactors, `jq`/`yq`, `sd`.
  - Python: `uv` and `ruff`; never global pip.
  - JavaScript and TypeScript: `bun` and `biome`; run tools with `bun x`, not `bunx`.
  - Tasks and speed: `just` as the task runner, `hyperfine` before any speed claim.
  - Git: `gh`, `delta`, `lazygit`, and `gitleaks` before pushing.
- Start anything new with the **genesis** skill.

## Authorship
- The user is Ritesh Roshan (riteshroshansahoo01@gmail.com, GitHub riteshroshann). His name goes wherever work carries a name: author on documents, "Submitted by" on reports, "Engineered by" in READMEs and his sites' footers, package author fields, and `<meta name="author">`.
- The user is the sole author. Never add AI attribution to commits, pull requests, code, comments or docs: no Co-Authored-By trailers and no "generated with" lines.
- Comments and commit messages are brief and plain, in Karpathy's style (see the **authorship** skill).

## Code
- Match the surrounding code. Write small functions with honest names. Comments explain why. Leave no dead code.
- Add types where they're cheap: TypeScript strict, Python hints. Test the behaviour that matters. Fix the cause of a failure; never weaken a test.
- Keep secrets out of code and logs; they live in Bitwarden (`bw`).

## Design
- Any web UI goes through the **atelier** skill. Nothing ships before the **essentials** check passes.
- Build hierarchy from size, weight and space. Use at most two typefaces and one accent colour.
- Glass only on floating elements. No badges, check-mark lists, emoji icons, nested cards or decorative gradients.
- Render or screenshot visual work and look at it before calling it done.

## Writing
- Default tone is the **vibe** skill: warm, kind, high-energy and brilliant. Formal and professional writing uses **voice**.
- Lead with the point. Prefer prose to bullets, and concrete to abstract. Use plain words.
- No slop: "delve", "seamless", "leverage", "it's not X, it's Y", "In conclusion".
- No emoji, and few em dashes.

## Documents
- Every PDF goes through the **folio** skill, including requests for a "LaTeX" PDF.
- When .tex source itself is required (a journal or university template), compile it with `tectonic -X compile file.tex`. It is installed and fetches packages itself. Never install another TeX engine.
- Word, PowerPoint and Excel files are handled by their skills, and LibreOffice, QPDF, Tesseract and their Python and Node libraries are preinstalled. Never pip or npm install for a document task.

## Privacy
- Install only open-source, audited software, using Privacy Guides as the bar.
- Never send the user's data to a third party without asking.
- OSINT stays passive-first, within the limits of the **osint** skill.

## Communication
Be terse. Give the result first, then what was verified and what's still open.
