# ieee-templates-typst

[![Tests](https://github.com/langestefan/ieee-templates-typst/actions/workflows/tests.yml/badge.svg)](https://github.com/langestefan/ieee-templates-typst/actions/workflows/tests.yml)
[![Lint](https://github.com/langestefan/ieee-templates-typst/actions/workflows/lint.yml/badge.svg)](https://github.com/langestefan/ieee-templates-typst/actions/workflows/lint.yml)
[![Typst](https://img.shields.io/badge/typst-%E2%89%A50.15.0-239dad)](https://typst.app/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**IEEE conference and journal papers in Typst, ported from `IEEEtran.cls` v1.8b.**

A pure Typst implementation of the IEEEtran class, with conference and journal layouts, plus several variants for specific IEEE journals. 

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
      affiliation: ("Dept. of Analytical Engines", "London, United Kingdom", "ada@example.org"),
    ),
    (
      name: "Alan Turing",
      affiliation: ("Dept. of Computing", "Manchester, UK"),
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

Full argument reference in [docs/api.md](docs/api.md).

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

The following points are important about fonts in IEEE papers:

- IEEE requires Times. The templates ask for `Times New Roman`, then `TeX Gyre Termes`, then `Nimbus Roman`. All three are metric-compatible, meaning identical character widths, so which one you have changes no measurement in the output. At least one is present on most systems, and the latter two ship with most TeX distributions and Linux desktops.
- Typst warns about the first missing family even when a
fallback is used, so `unknown font family: times new roman` on a machine without it is only a warning.
- `ieee-compsoc` additionally needs Palatino and Helvetica, for which [TeX Gyre Pagella](https://ctan.org/pkg/tex-gyre-pagella) and Nimbus Sans are free choices.

## Choosing a template

To apply a different template, only the function name has to be changed:

```typst
#import "@preview/ieee-templates:0.1.0": *

#show: ieee-conference.with(..)          // conference papers, incl. IEEE's 2024-06-28 wrapper
#show: ieee-journal.with(..)             // Transactions and journals
#show: ieee-transmag.with(..)            // Transactions on Magnetics
#show: ieee-compsoc.with(..)             // Computer Society journals
#show: ieee-compsoc-conference.with(..)  // Computer Society conferences
```

Variants of a template can be supplied as arguments:

```typst
#show: ieee-conference.with(paper: "a4", ..)    // A4 instead of US Letter
#show: ieee-conference.with(pt: "11pt", ..)     // base font size, "9pt" to "12pt"
#show: ieee-journal.with(columns: 1, ..)        // the onecolumn class option
#show: ieee-journal.with(technote: true, ..)    // brief technical note
#show: ieee-journal.with(peerreview: true, ..)  // double-blind cover page
```

`paper` applies to every template; `pt` to conference and journal; `columns`, `technote` and
`peerreview` to `ieee-journal` only.
`comsoc` needs no mode of its own: in v1.8b that option only swaps the math fonts, leaving the geometry
identical to `ieee-journal`. Every argument is listed in [docs/api.md](docs/api.md).

Notes:
- Only 10pt is verified against IEEE's references. The other sizes set the page geometry and body text correctly, but the title-block spacing is calibrated for 10pt.
- Last-page column balancing is not implemented because Typst cannot do it natively; `#colbreak()` can be applied manually. Further details are in [docs/known-gaps.md](docs/known-gaps.md).

## License

MIT for `src/`, `template/` and `scripts/`. See [LICENSE](LICENSE) for the boundary with `reference/`.
