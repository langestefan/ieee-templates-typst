# API

Five layout functions and five helpers, all exported from `src/lib.typ`.

## `ieee-conference`

| Argument | Type | Default | Notes |
|---|---|---|---|
| `paper` | `"us-letter"` \| `"a4"` | `"us-letter"` | Both verified against IEEE renders |
| `pt` | `"9pt"` … `"12pt"` | `"10pt"` | Only 10pt is verified; see [Status](../README.md#status) |
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

The `bibliography` argument is a convenience for the common case. Documents needing the reference list
somewhere else, such as before author biographies, can omit it and write `#bibliography(..)` into the
body instead; it is styled either way.

## `ieee-journal`

Everything above, plus:

| Argument | Type | Notes |
|---|---|---|
| `columns` | `2` \| `1` | `1` matches the `onecolumn` class option |
| `peerreview` | bool | Cover page carrying the authors, then the title repeated overleaf for double-blind review |
| `technote` | bool | Title in the first column rather than spanning, set `\large` bold |
| `header-left` | content | Journal line. Shown on page 1 and on even pages |
| `header-right` | content | Author line, e.g. `Shell et al.: Title`. Shown on odd pages after the first |

With `columns: 1` the abstract and index terms are no longer run in: each gets a centred bold label with
its text indented beneath, which is what IEEEtran does in single-column mode.

`authors` is a single content value here, not an array of blocks, matching how IEEE sets journal author
lines: `Michael Shell, _Member, IEEE,_ John Doe, _Fellow, OSA_`.

## `ieee-transmag`

Transactions on Magnetics. Takes `paper`, `title`, `authors`, `header-left`, `header-right`, `thanks`,
`abstract`, `index-terms` and `bibliography` as `ieee-journal` does, and adds one of its own:

| Argument | Type | Notes |
|---|---|---|
| `affiliations` | array of content | Numbered affiliation lines set beneath the author line |

There is no `pt`, `columns`, `technote` or `peerreview`: the class fixes all four for this mode.

## `ieee-compsoc` and `ieee-compsoc-conference`

Both take the same arguments as `ieee-transmag` minus `affiliations`, and likewise have no `pt` or
`columns`.

`ieee-compsoc` is a different design rather than a variant of the others: Palatino body at 9.5pt on
11.54pt leading, 61 lines per column, Helvetica bold small-caps headings numbered `1`, `1.1`, and a
diamond rule closing the title block. It is the only mode needing fonts beyond Times:
[TeX Gyre Pagella](https://ctan.org/pkg/tex-gyre-pagella) and Nimbus Sans are the free choices, and
`--font-path` works if they are not installed system wide.

`ieee-compsoc-conference` is set in Times and needs no extra fonts. Its sections are numbered `1.`,
`1.1.` with trailing periods, in bold roman.

## Helpers

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

## Headings

Four levels, numbered the way IEEEtran numbers them: `I.` centred small caps, `A.` left italic, then
`1)` and `a)` running into the paragraph that follows.

The displayed number shows only its own level's counter, so a subsection reads `B.`, not `I-B`.

## Figures and tables

Standard Typst figures. The templates supply IEEE's conventions:

```typst
#figure(caption: [Example of a figure caption.], image("fig1.png"))   // Fig. 1. below
#figure(caption: [Table Type Styles], table(columns: 2, [a], [b]))    // TABLE I above
```

Figures number in arabic and caption below; tables number in uppercase roman and caption above, with the
caption text in small caps. In prose a reference reads `Table I` and `Fig. 1`, while the caption itself
reads `TABLE I`. IEEE distinguishes the two, and LaTeX never had to because `\ref` emits only the
number.

## Equations

Equations number as `(1)` flush right, and `@eq` references render as a bare `(1)`.

`IEEEeqnarray` has no port and needs none: Typst's native math already aligns on `&` and breaks on `\`,
which is what that environment exists to work around in LaTeX. The one thing IEEE uses that Typst lacks
is sub-numbering, so `subequations` supplies it:

```typst
#subequations[
  $ a + b &= c $ <a>
  $ d     &= e $ <b>
]
```

The group takes one equation number and its members are lettered `(2a)`, `(2b)`, with numbering resuming
at `(3)` afterwards. References follow suit.
