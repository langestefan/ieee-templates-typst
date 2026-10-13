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
port only swaps the sheet size, while the class also changes the journal top
margin to 24.675mm and derives the conference text block from the paper
(`IEEEtran.cls:1773-1796`), so A4 output in these two modes is not expected to
match.

**Pages after the first.** Only the peer-review and one-column references run
to a second page. Running heads and the page grid match there; nothing else on
later pages has a reference.

## Measured differences that remain

Every landmark asserted by `scripts/check.sh` matches its reference to within a
point, which is the resolution of the measurement. Two are a further point out:
the first section in one-column mode and the technote author line.

Comparing whole columns rather than landmarks shows more:

- **Heading gaps.** In journal mode the space above a section after the first
  is 29pt baseline to baseline where the reference has 25 to 26, and above a
  subsection 29 against 28. The space below a subsection is 13 against 15 in
  both Times modes. The space above the References heading is 3pt short in
  both.
- **The peer-review title overleaf** sits in the first column and wraps, where
  the reference spans both columns.
- **The footnote block** sits about 3pt lower than the reference.
- **Running heads are uppercased whole**, including an "et al." that
  `bare_jrnl.tex` keeps lowercase with `\MakeLowercase`.

## Content the helpers do not preserve

`parstart` and `biography` have to split a paragraph to set its opening beside
the drop cap or photo, and they do it on plain text. Citations, math, emphasis
and footnotes inside the body are lost, and a biography of several paragraphs
is run together. Keep such content out of those two bodies for now.

The journal drop cap was 1pt out for a long time. It turned out not to be the
cap at all: the space below a level-one heading was 1pt short in both Times
modes, so the whole first paragraph sat high and the cap with it. The class says
0.7ex; 0.8ex matches. The checks had asserted where headings sit but not where
the text after them starts, which is why it survived so long.

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
