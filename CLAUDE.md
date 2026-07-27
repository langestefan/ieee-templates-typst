# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

Conference and journal layouts both render and are verified against the reference PDFs. Build either
template with:

```bash
typst compile --root . template/main.typ out.pdf              # bare conference demo
typst compile --root . template/conference-062824.typ out.pdf # IEEE's official wrapper, 6 authors
typst compile --root . template/journal.typ out.pdf           # journal
```

Everything under `reference/` is third-party material and is the **specification to port from**, not code
to modify or wrap.

### Verification

`scripts/baselines.sh <pdf> [page] [max-x]` prints true text baselines using Ghostscript's `txtwrite`
device. Use it, not `pdftotext`: `pdftotext` only exposes ink bounding boxes, which shift by up to 2pt
depending on whether a line contains descenders. That is the same magnitude as the spacing being
verified, and early measurements taken that way were wrong.

`scripts/verify-geometry.sh` compares text-block extent and line counts between two PDFs.

Current agreement with the references, in points:

| landmark | conference | 062824 | journal |
|---|---|---|---|
| title | exact | exact | exact |
| authors | exact | row 1 exact, row 2 +1 | +1 |
| abstract | exact | exact | exact |
| first section | exact | — | −5 |

### Known gaps

- `\IEEEPARstart` drop caps are not implemented. Typst cannot indent only the first two lines of a
  paragraph, so the usual approaches do not work.
- Author biographies and appendices are not implemented; the journal reference shows a `PLACE PHOTO HERE`
  box that this port omits.
- The gap between the References heading and the first entry is 11pt against the reference's 15pt, from
  LaTeX list `\topsep`.
- Bibliography entry-to-entry spacing is unverified, as `template/refs.bib` holds a single entry.
- `compsoc`, `comsoc`, `transmag`, `technote` and `peerreview` are untouched.

### Calibrated constants

Several spacing constants are calibrated against the reference renders rather than derived from the
class, and are marked as such in the source. They are the title-internal gaps, which depend on TeX's
`\topskip` rule for the first line of a box, and the `title-slack` used for quantising. In both modes the
class's stated `\@IEEENORMtitlevspace` lands the columns a slot high. Treat these as load-bearing: if a
layout drifts after a change, check them first.

## Critical context: upstream is frozen

`IEEEtran` has not been updated since **V1.8b, 2015/08/26**, verified against
`reference/IEEEtran-1.8b/changelog.txt`, whose newest entry is that release. There is no newer class, and
stale-looking third-party mirrors reflect upstream rather than neglect. Do not go looking for a more
recent version.

The only artifact IEEE still revises is the *wrapper document* for conferences, currently dated
2024-06-28. The class underneath it is unchanged. The editorial specs, meaning the IEEE Reference Guide
and Editorial Style Manual, are also still updated and are **not** in this repo. Fetch them when working
on bibliography or heading rules.

## `reference/` — do not edit, these are upstream artifacts

Everything third-party lives here, kept separate from the Typst package so it can be excluded from a
published release. IEEEtran itself is LPPL and redistributable, but IEEE's template wrapper and the
compiled reference PDFs are IEEE copyright.

### `reference/IEEEtran-1.8b/` — the complete CTAN package, authoritative

From `https://mirror.ctan.org/macros/latex/contrib/IEEEtran.zip`.

- `IEEEtran.cls` V1.8b — authoritative for page geometry, sectioning, floats, author blocks.
  Heavily commented, so grep it rather than guessing.
- `bare_*.tex` — **the best porting specs.** Minimal skeletons showing exactly which commands each mode
  uses, without the prose and sample content that bloat the official wrappers:
  `bare_conf`, `bare_conf_compsoc`, `bare_jrnl`, `bare_jrnl_compsoc`, `bare_jrnl_comsoc`,
  `bare_jrnl_transmag`, and `bare_adv` for advanced features.
- `bibtex/` — `IEEEtran.bst` v1.14 plus the S/SN/N/SA variants and the `.bib` databases.
- `tools/IEEEtrantools.sty` — the `IEEEeqnarray` family. Multi-line equation layout that IEEE papers rely
  on heavily, with no direct Typst analogue. Read before designing the math API.
- `testflow/` — float-placement torture test with pre-rendered Letter and A4 reference output. Typst's
  float algorithm differs substantially from LaTeX's, so this is a ready-made conformance suite for the
  hardest part of the port.

### `reference/pdf/` — rendered ground truth for visual diffing

All US Letter, compiled 2026-07-27 with pdfTeX 1.40.27.

| File | Renders |
|---|---|
| `IEEE_Journal_Paper_Template.pdf` | `bare_jrnl.tex` |
| `One_column_IEEE_journal_article.pdf` | `bare_jrnl.tex` with `onecolumn` |
| `IEEE_Bare_Demo_Template_for_Conferences.pdf` | `bare_conf.tex` |
| `IEEE_Demo_Template_for_Computer_Science_Journals.pdf` | `bare_jrnl_compsoc.tex` |
| `IEEE_Advanced_Demo_Template_for_Computer_Science_Journals.pdf` | `bare_adv.tex` |
| `IEEE_Demo_Template_for_Computer_Society_Conferences.pdf` | `bare_conf_compsoc.tex` |
| `IEEE_LaTeX_Template_for_Transactions_on_Magnetics.pdf` | `bare_jrnl_transmag.tex` |

These were compiled by hand and are not reproducible by any command in this repo. They are the baseline
every Typst layout gets diffed against.

Every `bare_*.tex` has a rendered reference except `bare_jrnl_comsoc.tex`. That gap is harmless: per
`changelog.txt`, V1.8b's comsoc mode "only invokes the use of the newtxmath math fonts", a math-font swap
with no layout consequence, so `bare_jrnl` is its geometric equivalent.

### `reference/conference-template-062824/`

IEEE's current official conference wrapper, the only part of their distribution not duplicated by CTAN.

- `IEEE-conference-template-062824.tex` — the wrapper document, dated 2024-06-28.
- `IEEE-conference-template-062824.pdf` — authoritative rendered conference reference.
- `fig1.png` — sample figure used by the document.

IEEE's site is behind a bot challenge, so re-fetching these means doing it manually in a browser.

## Key layout constants for `conference` mode

From `IEEEtran.cls`, where the defaults are set around lines 1715–1740. What a Typst page setup must match:

- Paper: US Letter 8.5in × 11in. `a4paper` gives 210 × 297mm, `technote` gives 7.875 × 10.75in.
- Base font 10pt, Times.
- Text block: `\textwidth` 43pc, `\textheight` 58pc, roughly 9.63in or 696pt, top margin 58pt, sides centred.
- Two columns of 21pc with a 1pc gutter, so 43pc = 2 × 21pc + 1pc.
- Text height quantised to whole lines per column, 58 lines/column at 10pt. The class documents 9pt/63,
  10pt/58, 11pt/52, 12pt/50. Residual error is split evenly top and bottom.

The `compsoc` and `technote` branches use different values. Plain `conference` is what the bundled `.tex` uses.

## Working notes

- Port scope is really **two layouts**, two-column conference and two-column journal. `technote`,
  `compsoc`, `comsoc`, and `peerreview` are option-driven variants of the same geometry engine rather than
  separate templates.
- Verify visually against `reference/pdf/` and the 062824 PDF, not by reading `.tex` alone. Most
  formatting lives in the class rather than the document.
- When porting a construct, cite the `IEEEtran.cls` line it came from. The class encodes non-obvious
  tweaks such as baselineskip-dependent `\topskip` and `\maxdepth`, and quantised text height, which look
  like arbitrary magic numbers otherwise.
- IEEE requires Times. Decide early whether to vendor a metric-compatible face or depend on system fonts.
  It affects reproducibility of every output and is painful to retrofit.
- IEEE validates submitted PDFs via PDF eXpress, which checks font embedding and PDF version. Worth
  knowing those constraints before discovering Typst output fails them.
