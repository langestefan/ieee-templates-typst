# Known gaps

Where this port differs from IEEEtran, measured against IEEE's compiled PDFs in
`reference/pdf/`. Every fixture that carries its reference's text agrees with it
to about 0.1pt on every line; `scripts/check.sh` asserts that.

## Typst cannot do it

- **Last-page column balancing.** Use `#colbreak()`.
- **Flush column bottoms.** TeX stretches the space around headings; Typst does
  not, so a column can end up to a line short of its neighbour.
- **Space limits when justifying.** Typst shrinks a space by up to a third. The
  class's limits differ (`IEEEtran.cls:1011-1033`): bold text cannot be set as
  tightly as in TeX, and Palatino is set tighter.
- **Line breaks.** Typst has no tolerance or `\hbadness`. The hyphenation cost
  is calibrated on one published paper, so a few lines break at other words.
- **Words with punctuation inside** are not hyphenated. TeX breaks
  `IEEEtran.cls` after `IEEE`; here it needs a soft hyphen.
- **Reference list internals.** The gap after a label is 0.65em where the class
  has 0.5em, so entries start 0.2pt right. A list of one two-line entry is not
  justified.

## Differences that remain

- **Running heads are uppercased whole**, including an "et al." that
  `bare_jrnl.tex` keeps lowercase.
- **Computer Society `\thanks`.** The class overlaps the plain note with the
  last item (`IEEEtran.cls:4903`). Here it takes its own line, so the items sit
  4.5pt higher.
- **Biographies on a page without footnotes** move to the next column up to
  2.7pt sooner than in TeX.
- **The first biography is taken to follow the reference list.** After anything
  else its skip is 2pt too large.
- **The second conference author row** is 0.2pt out in one of its two
  references.
- **A URL written as text breaks after a slash.** TeX keeps it whole.

## Small caps

The Times layouts set small caps as LaTeX's Times does: capitals at 0.8 of the
size, letterspaced 0.05em. Text copied from the PDF comes out in capitals, and
a word in small caps is not hyphenated. The Computer Society journal keeps
Palatino's own.

## `parstart` and `biography`

Both split their body between words. Markup survives, with three limits:

- The first word of a `parstart` body becomes plain text.
- Styling other than emphasis, strong, underline, overline, strike, highlight,
  small caps or `text` moves as one piece.
- A paragraph break inside becomes a line break and an indent.

## Unverified

No reference render exists for these, so they follow the class unchecked:

- **Computer Society on A4** (`IEEEtran.cls:1773-1796`).
- **Computer Society conference index terms** (`IEEEtran.cls:5292`, 5307).
- **Point sizes other than 10pt.** The title-block gaps are the 10pt ones.
- **Pages after the first**, beyond the two-page peer review and one-column
  references.

## Calibrated, not derived

- **`title-excess`** in `geometry.typ`: seven renders bound it to a window
  1.25pt wide.
- **`author-row-gap`**: 26.5pt, from two documents.
- **Footnote clearance**: 7.89pt, from the technote fixture.
- **Computer Society** heading skips, journal title gaps and footnote drop: one
  render each.

## Not ported

- **`comsoc`** only swaps math fonts in V1.8b; use `ieee-journal`.
- **`IEEEeqnarray`.** Typst's math already aligns on `&`. `subequations` covers
  the sub-numbering.
- **The LaTeX logo.** The fixtures draw their own in `tests/logo.typ`.
