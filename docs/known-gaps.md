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

**Pages after the first.** Only the peer-review and one-column references run
to a second page. Running heads and the page grid match there; nothing else on
later pages has a reference.

## Measured differences that remain

Every landmark asserted by `scripts/check.sh` matches its reference to within a
point, which is the resolution of that script.

Measured at a hundredth of a point with `scripts/diff-columns.sh`, the
conference, journal, Magnetics and Computer Society journal fixtures agree with
their references to under 0.1pt on every body line of the first column, from
the title through headings, appendices and the reference list to the
footnotes. What remains:

- **Running heads are uppercased whole**, including an "et al." that
  `bare_jrnl.tex` keeps lowercase with `\MakeLowercase`.
- **Superscript marks** on the Magnetics author line sit 0.3pt low, and the
  second conference author row is out by 0.2pt in one of its two references.
- **Biographies that move to a new column.** LaTeX discards the stretchable
  skip above a biography at a column break; Typst leaves it behind, where it
  takes a share of the old column's free space. The biographies before the
  break then sit higher than in the reference, by 28pt in the technote
  fixture. Biographies that share one column match to 0.02pt.
- **`\@IEEEtranneedspace` is not emulated.** The class starts a new column
  unless a biography has room for its photo, the skip and a line to spare.
  Typst only asks whether the block fits, so near the foot of a column a
  biography can stay where LaTeX would have moved it. The one-column fixture
  shows it.
- **Computer Society biographies** start 20pt lower in the reference than
  here when they open a column. The cause is not known.
- **Computer Society `\thanks`** is an itemised list in the class, with
  bullets and its own spacing. Here it is a plain footnote: the last line
  matches and the lines above it sit 4.5pt high.
- **The photo placeholder text** sits 1.1pt high inside its frame.

## Content the helpers do not preserve

`parstart` and `biography` have to split a paragraph to set its opening beside
the drop cap or photo, and they do it on plain text. Citations, math, emphasis
and footnotes inside the body are lost, and a biography of several paragraphs
is run together. Keep such content out of those two bodies for now.

Computer Society heading spacing was previously off by 8pt after the first
section and about 3pt per heading after that. The class's stated skips carried
over directly do not reproduce the reference, so the values are calibrated to it
and now match exactly. `\IEEEraisesectionheading` was investigated as the cause
and ruled out: it raises content, while the reference sat lower than this port.

## Deliberately not done

**Point sizes other than 10pt** are partly wired. `ieee-conference` and
`ieee-journal` take `pt`, which selects the ladder and, through it, the page
geometry and body text: an 11pt document gets a 13.33pt advance and 50 lines per
column, matching what the class documents.

What is *not* done is everything else. Headings, the abstract, captions,
footnotes and the reference list stay on the 10pt ladder, and the title block
is quantised to the 10pt advance, so the columns beneath it start off the body
grid. No
reference render exists at any other size, and IEEE papers are 10pt in practice,
so this is deliberately left partial rather than finished blind.

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

**The title quantisation slack is calibrated, not derived.** The class's
`\@IEEENORMtitlevspace` sits below every valid range, short by roughly one line
advance, which matches the `[-\topskip]` offset `\IEEEquantizevspace` applies.
Adding exactly one advance fixes journal but leaves the bare conference demo
0.66pt short, so the cause is narrowed rather than settled. Measured bounds for
all three references are recorded in `geometry.typ`.
