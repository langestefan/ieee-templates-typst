# ieee-templates-typst

[![Typst](https://img.shields.io/badge/typst-%E2%89%A50.15.0-239dad)](https://typst.app/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**IEEE conference and journal papers in Typst, ported from `IEEEtran.cls` v1.8b.**

Not a wrapper around LaTeX and not an approximation by eye. Every layout constant is taken from the
IEEEtran class source, and the output is checked baseline-for-baseline against IEEE's own compiled PDFs.

> [!IMPORTANT]
> Pre-release. The conference and journal layouts are complete and verified; the society variants
> (`compsoc`, `comsoc`, `transmag`, `technote`) are not implemented yet. See [Status](#status).

<p align="center">
  <img src="assets/preview-conference.png" alt="Conference paper: title, three author blocks, two-column body" width="380">
  <img src="assets/preview-journal.png" alt="Journal paper: running head, author line, drop cap, appendices" width="380">
</p>

## Quick example

```typst
#import "@preview/ieee-templates:0.1.0": ieee-conference

#show: ieee-conference.with(
  title: [A Paper About Something],
  authors: (
    (
      name: "Ada Lovelace",
      affiliation: (
        "Dept. of Analytical Engines",
        "Somewhere University",
        "London, United Kingdom",
        "ada@example.org",
      ),
    ),
    (
      name: "Alan Turing",
      affiliation: ("Dept. of Computing", "Elsewhere University", "Manchester, UK"),
    ),
  ),
  abstract: [The abstract goes here, set in bold at 9pt as IEEE requires.],
  index-terms: [component, formatting, style],
  bibliography: bibliography("refs.bib"),
)

= Introduction
Body text. Sections number themselves `I.`, `II.` in centred small caps.

== Subsection Heading
Subsections are italic and lettered `A.`, `B.`

=== Subsubsection
Subsubsections run into the paragraph, as IEEE sets them.

= Conclusion
Cite things normally @lovelace1843. References use Typst's built-in IEEE style.
```

## Installation

Via Typst Universe (once published):

```typst
#import "@preview/ieee-templates:0.1.0": ieee-conference, ieee-journal
```

Or locally, by cloning the repo and importing from a path:

```typst
#import "path/to/ieee-templates-typst/src/lib.typ": ieee-conference
```

Compiling a local file needs `--root` so the absolute imports resolve:

```bash
typst compile --root . paper.typ
```

### Fonts

IEEE requires Times. The templates ask for `Times New Roman`, then `TeX Gyre Termes`, then
`Nimbus Roman`, all metric-compatible. At least one is present on most systems; the latter two ship with
most TeX distributions and Linux desktops. Typst warns about the first missing family even when a
fallback is used, so `unknown font family: times new roman` on a machine without it is harmless.

## API

### `ieee-conference`

| Argument | Type | Default | Notes |
|---|---|---|---|
| `paper` | `"us-letter"` \| `"a4"` | `"us-letter"` | Both verified against IEEE renders |
| `title` | content | `[]` | Use `\` for a line break |
| `authors` | array of dicts | `()` | See below |
| `thanks` | content | `none` | Funding note; renders as an unmarked footnote on page 1 |
| `abstract` | content | `none` | Set bold at 9pt, run in after `Abstract—` |
| `index-terms` | content | `none` | Same treatment after `Index Terms—` |
| `bibliography` | content | `none` | Pass `bibliography("refs.bib")` |

Each author is a dict with `name` and `affiliation`. Both accept either content or an array of lines:

```typst
(name: "Ada Lovelace", affiliation: ("Dept. of Analytical Engines", "London, UK"))
(name: [Ada Lovelace#author-mark(1)], affiliation: [Dept. \ London, UK])
```

The array form is usually easier: it avoids escaping, since a bare `@` in Typst markup parses as a
reference and a bare URL autolinks.

Author blocks wrap automatically. Six authors become two rows of three, the same way `\and` and `\hfill`
break in LaTeX.

### `ieee-journal`

Everything above, plus:

| Argument | Type | Notes |
|---|---|---|
| `columns` | `2` \| `1` | `1` matches the `onecolumn` class option |
| `header-left` | content | Journal line. Shown on page 1 and on even pages |
| `header-right` | content | Author line, e.g. `Shell et al.: Title`. Shown on odd pages after the first |

With `columns: 1` the abstract and index terms are no longer run in: each gets a centred bold label with
its text indented beneath, which is what IEEEtran does in single-column mode.

`authors` is a single content value here, not an array of blocks, matching how IEEE sets journal author
lines: `Michael Shell, _Member, IEEE,_ John Doe, _Fellow, OSA_`.

### Helpers

| Function | Use |
|---|---|
| `parstart(body)` | `\IEEEPARstart`: the two-line drop cap opening a journal paper |
| `appendices` | `#show: appendices` switches sections to `Appendix A`, `Appendix B` |
| `biography(name:, photo:, body)` | Author biography with a photo box, or a framed placeholder |
| `biography-no-photo(name:, body)` | Same without the photo area |
| `author-mark(n)` | `\IEEEauthorrefmark`: `*`, `†`, `‡`, `§`, `¶`, `‖`, `**`, `††`, `‡‡`, then roman numerals |

A journal paper using all of them:

```typst
#import "@preview/ieee-templates:0.1.0": *

#show: ieee-journal.with(
  title: [A Paper About Something],
  authors: [Ada Lovelace, _Member, IEEE,_ and Alan Turing, _Fellow, IEEE_],
  header-left: [IEEE Transactions on Something, Vol. 1, No. 1, January 2026],
  header-right: [Lovelace #emph[et al.]: A Paper About Something],
  abstract: [The abstract goes here.],
  index-terms: [component, formatting, style],
)

= Introduction
#parstart[This first paragraph opens with a two-line drop cap, and the rest of
the first word is set in capitals, exactly as IEEEtran does it.]

= Conclusion
The conclusion goes here.

#show: appendices
= Proof of the First Zonklar Equation
Appendix text.

#biography(name: [Ada Lovelace])[Biography text here.]
#biography-no-photo(name: [Alan Turing])[Biography text here.]
```

### Figures and tables

Standard Typst figures. The templates supply IEEE's conventions:

```typst
#figure(caption: [Example of a figure caption.], image("fig1.png"))   // Fig. 1. below
#figure(caption: [Table Type Styles], table(columns: 2, [a], [b]))    // TABLE I above
```

Figures number in arabic and caption below; tables number in uppercase roman and caption above, with the
caption text in small caps. In prose a reference reads `Table I` and `Fig. 1`, while the caption itself
reads `TABLE I` — IEEE distinguishes the two, and LaTeX never had to because `\ref` emits only the
number.

Equations number as `(1)` flush right, and `@eq` references render as a bare `(1)`.

## Status

| | Conference | Journal |
|---|---|---|
| Page geometry, 56 / 58 lines per column | ✅ | ✅ |
| Title block, author blocks, wrapping | ✅ | ✅ |
| Abstract and index terms | ✅ | ✅ |
| Section heading hierarchy | ✅ | ✅ |
| Figures, tables, equations, footnotes | ✅ | ✅ |
| Bibliography | ✅ | ✅ |
| `\thanks` funding notes | ✅ | ✅ |
| US Letter and A4 | ✅ | ✅ |
| Running heads | — | ✅ |
| Drop cap, appendices, biographies | — | ✅ |
| Single column (`columns: 1`) | — | ✅ |

`ieee-transmag` covers IEEE Transactions on Magnetics, which differs from a plain journal in its title
area: a smaller bold title, numeric affiliation marks with one affiliation per line, and the abstract and
index terms carried full width inside the title block with no `Abstract—` label. Verified against
`bare_jrnl_transmag.tex`.

Not implemented: `IEEEeqnarray` multi-line equation layout, the `comsoc` / `technote` / `peerreview`
modes, point sizes other than 10pt, and automatic last-page column balancing
(`#colbreak()` is the manual remedy).

`ieee-compsoc` covers IEEE Computer Society journals. It is a different design rather than a variant:
Palatino body at 9.5pt on 11.54pt leading with 61 lines per column, Helvetica bold small-caps headings
numbered `1`, `1.1`, a diamond rule closing the title block, and dimensions in big points with none of
the TeX-point conversion the other modes need.

It needs a Palatino and a Helvetica clone. [TeX Gyre Pagella](https://ctan.org/pkg/tex-gyre-pagella) and
Nimbus Sans are the free ones; if they are not installed system wide, pass `--font-path`. The title
block, geometry and first section match the reference exactly. Body headings below that run about 3pt
tight per heading, and the reference's own source uses `\IEEEraisesectionheading` on its first section,
which this port does not implement.

## Verification

The point of this port is that it is checked, not eyeballed.

```bash
scripts/check.sh
```

Compiles every template and asserts 51 landmark baselines against IEEE's compiled reference PDFs in
`reference/pdf/`. Conference, journal and A4 all match their references exactly on title, authors,
abstract, index terms and first section; the largest remaining discrepancy anywhere is 1pt.

Two supporting tools:

- `scripts/baselines.sh <pdf> [page] [max-x]` — prints true text baselines via Ghostscript's `txtwrite`.
  Use this rather than `pdftotext`, which only exposes ink bounding boxes; those shift by up to 2pt
  depending on whether a line happens to contain descenders, which is the same magnitude as the spacing
  being measured.
- `scripts/verify-geometry.sh <pdf> <page> [ref] [page]` — text-block extent, line count, modal advance.

## Notes for anyone porting from LaTeX

Three things cost real time here and are not obvious from the class source.

**TeX's point is 1/72.27in; Typst's is 1/72in.** Every dimension and font size in `IEEEtran.cls` needs
scaling by 72/72.27. Skip it and the layout drifts 0.37%, roughly 2.5pt down a column — enough to lose a
line off the page. It shows up as the class's `12pt` rendering at 11.955pt.

**`\vspace` and `v()` are not the same.** LaTeX's `\vspace` adds to the baselineskip, which already
contains the interline gap. Typst's `v()` adds on top of `par.spacing`, so a class value carried over
directly overshoots by exactly that spacing.

**Typst cannot indent only the first N lines of a paragraph.** `par` offers first-line and
all-but-first, nothing between. Both the drop cap and the biography photo need it, so
`src/common/textsplit.typ` splits the paragraph explicitly, binary-searching word count against a
measured height.

## Repository layout

```
src/
  lib.typ            public API
  conference.typ     conference layout
  journal.typ        journal layout
  common/            geometry, headings, floats, elements, drop cap, biography
template/            runnable examples
scripts/             check.sh and measurement tools
reference/           IEEEtran v1.8b and IEEE's compiled PDFs (not part of the package)
```

`reference/` is third-party and excluded from the published package: IEEEtran itself is LPPL, while
IEEE's template wrapper and the compiled PDFs are IEEE copyright. See [LICENSE](LICENSE).

## License

MIT for `src/`, `template/` and `scripts/`. See [LICENSE](LICENSE) for the boundary with `reference/`.
