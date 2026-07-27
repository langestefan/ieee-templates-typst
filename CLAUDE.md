# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository status

Conference and journal layouts both render and are verified against the reference PDFs. Build either
template with:

```bash
typst compile --root . template/main.typ out.pdf              # bare conference demo
typst compile --root . template/conference-062824.typ out.pdf # IEEE's official wrapper, 6 authors
typst compile --root . template/journal.typ out.pdf           # journal
scripts/check.sh                                              # regression suite, 29 checks
```

Both modes take `paper: "us-letter"` or `paper: "a4"`. Beyond the layout functions, `src/lib.typ`
exports `parstart` for the journal drop cap, `appendices`, `biography` and `biography-no-photo`, and
`author-mark` for affiliation symbols.

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
| index terms | — | — | exact |
| first section | exact | — | exact |
| drop cap | — | — | −1 |

### Known gaps

- **Last-page column balancing.** Typst fills page-level columns sequentially and offers no balancing,
  so a final page leaves column one full and column two short. `#colbreak()` at the right point is the
  manual remedy and works fine.
- `IEEEeqnarray` multi-line equation layout has no Typst analogue and is not attempted.
- `compsoc`, `comsoc`, `transmag`, `technote` and `peerreview` modes are untouched, as are point sizes
  other than 10pt. Four of those modes already have reference renders in `reference/pdf/`.
- `author-row-gap` in `conference.typ` rests on a single document: 062824 is the only reference render
  with more than one author row.

### Calibrated constants

A few spacing constants are calibrated against the reference renders rather than derived from the class,
and are marked as such in the source: the title-internal gaps, which depend on TeX's `\topskip` rule for
the first line of a box, and the per-mode `slack` in `geometry.typ`'s `vertical` table.

The slack is documented there with the measured bounds for all three references. The short version: the
class's `\@IEEENORMtitlevspace` sits below every valid range, short by roughly one line advance in each
case, which matches the `[-\topskip]` offset `\IEEEquantizevspace` applies. Adding exactly one advance
fixes journal but leaves the bare conference demo 0.66pt short, so the cause is narrowed rather than
settled. The three ranges do intersect, but in a window under a point wide, so per-mode values are kept.

Treat these as load-bearing: if a layout drifts after a change, check them first, and run
`scripts/check.sh`.

### Two conversions that bite

Both caused real, hard-to-spot errors here.

**Heading skips differ by mode.** Conference uses 1.5ex above sections and subsections; journal uses
3.0ex and 3.5ex (`IEEEtran.cls:5466-5476`). Applying one mode's values to the other is silent and shifts
everything below.

**`\vspace` and `v()` are not the same.** LaTeX's `\vspace` adds to the baselineskip, which already
contains the interline gap. Typst's `v()` adds on top of `par.spacing`. A class value carried over
directly overshoots by exactly that spacing, 1.99pt at 10pt. `journal.typ` has a `vspace()` helper that
does the conversion.

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

Compiled 2026-07-27 with pdfTeX 1.40.27. US Letter unless the name says `_A4`.

| File | Renders |
|---|---|
| `IEEE_Journal_Paper_Template.pdf` | `bare_jrnl.tex` |
| `IEEE_Bare_Demo_Template_for_Conferences_A4.pdf` | `bare_conf.tex` with `a4paper` |
| `IEEE_Journal_Paper_Template_A4.pdf` | `bare_jrnl.tex` with `a4paper` |
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

## Key layout constants

### Units: the single most important fact

**TeX's point is 1/72.27in; PDF and Typst points are 1/72in.** Every dimension and font size in the class
is in TeX points and must be scaled by 72/72.27. Skipping it drifts the layout 0.37%, about 2.5pt down a
column, enough to lose a line off the page. It shows up as a 12pt class value rendering at 11.955pt.
`geometry.typ` defines `tpt` and `tpc` for this; use them for anything read out of the class.

### Vertical geometry is mode-specific

Conference **overrides** the class defaults rather than inheriting them (`IEEEtran.cls:1741-1748`).
Getting this backwards is an easy mistake: the defaults at 1722-1734 are the *journal* values.

| | conference | journal |
|---|---|---|
| requested height | 9.25in | 58pc |
| lines per column | **56** | **58** |
| top margin | 0.75in, then error-split → 52.45 TeX pt | 58 TeX pt |

Conference quantises 9.25in up to 56 lines and splits the resulting 3.5 TeX pt error evenly between top
and bottom. Journal's 58pc already divides evenly.

### Shared by both modes and both paper sizes

- Base font 10pt Times; the ladder is in `geometry.typ`'s `sizes`.
- Text block `\textwidth` 43pc = 2 × 21pc + 1pc gutter (`IEEEtran.cls:1734-1735`).
- `a4paper` changes only the sheet. `\if@IEEEusingAfourpaper` is referenced once outside the option
  declaration and that occurrence is inside the compsoc branch (1773), so vertical landmarks are
  identical to US Letter and only the side margins move, 48.96pt → 40.60pt. Verified against A4 renders.

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
