# Known gaps

What this port does not do, and why. Every entry was established by measurement
against IEEE's own compiled PDFs in `reference/pdf/`, not by inspection.

## Not reproducible in Typst

**Last-page column balancing.** Typst fills page-level columns sequentially and
offers no balancing; neither `set page(columns:)` nor the `columns()` function
balances a final page, which was verified rather than assumed. `#colbreak()` is
the manual remedy.

**Flush column bottoms.** LaTeX stretches the space around headings so every
column ends on the same line. Typst does not, so a column containing headings
can end up to a line short of its neighbour.

## Unverified

**Computer Society on A4.** No A4 render of either compsoc mode exists. The
geometry follows the class, which sets the journal margins to 24.675mm and
derives the conference text block from the sheet (`IEEEtran.cls:1773-1796`),
but nothing below the margins has been compared with a render.

**Computer Society conference index terms.** The space above and below
them follows the class (`IEEEtran.cls:5292` and 5307). `bare_conf_compsoc.tex`
has none, so no render shows them.

**Point sizes other than 10pt.** `ieee-conference` and `ieee-journal` take
`pt`, which selects the font ladder. Page geometry, body text, headings,
abstract, captions, footnotes and the reference list all follow it. The gaps
inside the title block are calibrated at 10pt and carried over as they are, and
no reference render exists at any other size, so none of it has been compared
with the class's output.

**Pages after the first.** Only the peer-review and one-column references run
to a second page. Running heads and the page grid match there; nothing else on
later pages has a reference.

## Measured differences that remain

Every landmark asserted by `scripts/check.sh` matches its reference to within a
point, which is the resolution of that script.

Measured at a hundredth of a point with `scripts/diff-columns.sh`, every
fixture that carries its reference's text agrees with it to about 0.1pt on
every line: both columns of the journal, Magnetics, technote and Computer
Society journal fixtures, both pages of the one-column and peer review
fixtures, and the left column of the two conference fixtures. That runs from the title
through headings, appendices, the reference list and biographies to the
footnotes, and the suite asserts it. What remains:

- **Running heads are uppercased whole**, including an "et al." that
  `bare_jrnl.tex` keeps lowercase with `\MakeLowercase`.
- **The second conference author row** is out by 0.2pt in one of its two
  references.
- **A biography moves to the next column a little sooner on a page without
  footnotes.** The class asks for room for the photo, the skip and a line
  (`IEEEtran.cls:5997-6001`), and TeX measures that room against a page goal
  that counts the depth of the last footnote line. The port allows for that
  depth on every page, so without notes it is cautious by 2.7pt.
- **The first biography is taken to follow the reference list.** Its skip
  includes the 2pt a list ends with. After anything else it is 2pt too large.
- **The reference list's label gap and justification are Typst's.** The
  list is laid out natively and no show rule reaches inside it. The gap after
  a label is 0.65em of the list's size where the class has 0.5em, so entries
  start 0.2pt further right, and a list of one entry that runs to two lines
  is not justified.
- **Computer Society `\thanks`.** The reference sets the plain note half a
  line below the last `\IEEEcompsocitemizethanks` item, over it, because the
  class takes a line back after the list (`IEEEtran.cls:4903`). Here the note
  takes a line of its own, so the items sit 4.5pt higher than in the
  reference and the rule above them with them.
- **The Computer Society journal title block is not quantised.** Its gaps are
  calibrated to the one reference render.
- **A word with punctuation inside it is not hyphenated.** TeX breaks
  `IEEEtran.cls` after `IEEE`; Typst leaves it whole and sets the lines around
  it looser. The conference fixture carries a soft hyphen there to follow its
  reference.
- **The limits on a justified space are Typst's.** The class lets a space
  shrink to 0.23em and stretch to 0.50em, or 0.55em in bold
  (`IEEEtran.cls:1011-1018`). Typst shrinks a space by up to a third and has
  no setting for either limit. From the regular 0.35em that is 0.233em, close
  enough. From the bold 0.375em it is 0.25em, so a bold abstract cannot be
  set as tightly as TeX sets it and can break at different words. In one
  published paper TeX closed an abstract line to 0.235em. Palatino goes the
  other way: the class stops at 0.21em and Typst closes its 0.28em to 0.187em,
  so the Computer Society journal fixture fits a word into a thanks item that
  TeX hyphenates.
- **A URL written as text breaks after a slash.** TeX keeps it whole. The
  fixtures box theirs to follow their references; a real paper is better off
  with the break.
- **The LaTeX logo is not provided.** The fixtures draw it themselves in
  `tests/logo.typ`, because the word in plain letters is 5.7pt wider and
  moved a line break.
- **Line breaks follow TeX closely, not exactly.** The hyphenation cost is
  calibrated on the first page of one published conference paper, where the
  regular text then breaks as TeX broke it in all but three lines. Typst has
  no tolerance past which a loose line is refused, and no `\hbadness`.

## Content the helpers split

`parstart` and `biography` have to split a paragraph to set its opening beside
the drop cap or photo. They cut it between words and keep what each word
carries, so citations, math, emphasis and footnotes survive. Three limits
remain:

- The first word of a `parstart` body is reduced to plain text, since the drop
  cap takes its first letter.
- Styling set with a function other than emphasis, strong, underline, overline,
  strike, highlight, small caps or `text` moves as one piece and is not broken
  across the split.
- A paragraph break inside either body becomes a line break and an indent, as
  the class does inside a biography (`IEEEtran.cls:6033`).

Computer Society heading spacing was previously off by 8pt after the first
section and about 3pt per heading after that. The class's stated skips carried
over directly do not reproduce the reference, so the values are calibrated to it
and now match exactly. `\IEEEraisesectionheading` was investigated as the cause
and ruled out: it raises content, while the reference sat lower than this port.

## Small caps

LaTeX's Times has no drawn small caps: `\scshape` is the capitals at 0.8 of the
size, letterspaced by 0.05em. The Times layouts set `smallcaps` that way, in
headings and anywhere the document uses it, because the small caps drawn into
TeX Gyre Termes are narrower and made a section heading a tenth shorter than
the reference. Two consequences:

- Text copied from the PDF comes out in capitals, as it does from a pdfTeX one.
- A word in small caps is not hyphenated. It still breaks after a hyphen it
  contains.

The Computer Society journal keeps Palatino's own small caps in running text.

## Deliberately not done

**`comsoc`.** Per the class changelog, V1.8b's Communications Society option
only swaps in the newtxmath math fonts, leaving it geometrically identical to a
plain journal. There is nothing to port.

**`IEEEeqnarray`.** Typst's native math aligns on `&` and breaks on `\`, which
is what that environment exists to work around in LaTeX. Only its sub-numbering
was missing, and `subequations` supplies that.

## Verification debt

**`author-row-gap` rests on two documents**, IEEE's 062824 wrapper and a
nine-author probe compiled for the purpose. 26pt satisfies the first and leaves
the probe 1pt short; 27pt the reverse; 26.5 satisfies both. A third document
would test it further.

**One constant in the title quantisation is calibrated.** The rounding itself
is the class's (`IEEEtran.cls:5165-5188`). What TeX counts as the height of
the title block differs from what Typst measures by a constant, `title-excess`
in `geometry.typ`, and working that out from the class lands a third of a line
from what the renders show. Seven renders bound it to a window a point and a
quarter wide. A title with no ascenders in its first line is 0.5pt shorter to
TeX, which the window only just has room for.
