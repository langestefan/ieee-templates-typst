// Page geometry and the font-size ladder, ported from IEEEtran.cls V1.8b.

#import "textsplit.typ": map-text

// TeX's point is 1/72.27in; PDF and Typst points are 1/72in. Every dimension
// and font size taken from the class is in TeX points and must be converted,
// or the layout drifts by 0.37% — about 2.5pt across a column, which is enough
// to lose a line off the bottom of the page.
#let tpt = 72pt / 72.27
#let tpc = 12 * tpt

// Times, metric-compatible fallbacks in descending preference.
#let body-font = ("Times New Roman", "TeX Gyre Termes", "Nimbus Roman")

// Font ladders, IEEEtran.cls:625-711. Each entry is (size, baseline-to-baseline
// advance) in TeX points; convert with tpt at the point of use.
//
// The layouts take the ladder `pt` names and size everything from it. IEEE
// papers are 10pt in practice and there is no reference render at any other
// size, so only that ladder is verified.
#let ladders = (
  "9pt": (
    normal: (9, 11.0476),
    small: (8.5, 10),
    footnote: (8, 9),
    sublarge: (10, 12),
    large: (10, 12),
    huge: (20, 24),
  ),
  "10pt": (
    normal: (10, 12),
    small: (9, 10),
    footnote: (8, 9),
    sublarge: (11, 13.4),
    large: (12, 14),
    huge: (24, 28),
  ),
  "11pt": (
    normal: (11, 13.3846),
    small: (10, 12),
    footnote: (9, 10.5),
    sublarge: (12, 14),
    large: (12, 14),
    huge: (24, 28),
  ),
  "12pt": (
    normal: (12, 13.92),
    small: (10, 12),
    footnote: (9, 10.5),
    sublarge: (14, 17),
    large: (14, 17),
    huge: (24, 28),
  ),
)

#let scale(entry) = entry.map(x => x * tpt)

#let sizes-for(pt) = (
  ladders.at(pt).pairs().map(((k, e)) => (k, scale(e))).to-dict()
)

// The 10pt ladder, which is what every default below refers to.
#let sizes = sizes-for("10pt")

// The ladder of the document being set, for helpers the author calls from the
// body, which have no other way to learn it.
#let ladder-state = state("ieee-ladder", sizes)

#let line-advance = sizes.normal.at(1)

// IEEEtran.cls:1011-1018. The class widens the space between words from the
// 0.25em Times carries to 0.35em, and to 0.375em in bold. The Palatino of the
// Computer Society journals takes 0.28em and 0.305em (1023-1032).
//
// The class also sets the limits a justified line may reach, 0.23em and 0.50em
// in regular Times. Typst has no setting for either. It shrinks a space by up
// to a third, which from 0.35em measures 0.235em.
#let word-space = (
  times: (regular: 0.35em, bold: 0.375em),
  palatino: (regular: 0.28em, bold: 0.305em),
)

// Only the roman family in its upright and italic shapes is retuned
// (IEEEtran.cls:1052-1070): small caps and typewriter keep the font's own
// space.
//
// Typst hangs hyphens and punctuation into the margin by default. pdfTeX does
// not without microtype, which the class does not load, so lines end on the
// margin.
//
// LaTeX's Times has no drawn small caps. Its \scshape is the capitals at 0.8
// of the size, every letter spaced out by 0.05em, which is what the reference
// renders show. The small caps drawn into TeX Gyre Termes are narrower: a
// section heading came out a tenth shorter with them. `tex-small-caps` sets
// them the LaTeX way.
#let small-cap-ratio = 0.8
#let small-cap-tracking = 0.05
#let tex-small-caps(body) = context {
  let gap = small-cap-tracking * text.size
  set text(tracking: gap, spacing: 100%)
  // The space belongs half to each side of a letter. Typst tracks between the
  // glyphs of a run only, so the halves at the ends of each run of capitals,
  // small capitals or other marks are added by hand. That spacing would let a
  // line break inside a word, so each word is boxed, up to a hyphen.
  let runs = regex("\\p{Lu}+|\\p{Ll}+|[^\\p{L}\\s]+")
  map-text(body, s => {
    show regex("[^\\s\\-]+-*|-+"): word => box(
      word
        .text
        .matches(runs)
        .map(m => {
          let run = m.text
          h(gap / 2)
          if lower(run) == run and upper(run) != run {
            text(size: small-cap-ratio * 1em, upper(run))
          } else { run }
          h(gap / 2)
        })
        .join(),
    )
    s
  })
}

#let word-spacing(face: "times", body) = {
  let space = word-space.at(face)
  set text(spacing: space.regular, overhang: false)
  show strong: set text(spacing: space.bold)
  show smallcaps: it => if face == "times" { tex-small-caps(it.body) } else {
    set text(spacing: 100%)
    it
  }
  show raw: set text(spacing: 100%)
  body
}

// Column widths are shared by both modes and by both paper sizes.
// IEEEtran.cls:1734-1735. 43pc = 2 x 21pc + 1pc.
#let text-width = 43 * tpc
#let column-width = 21 * tpc
#let column-gutter = 1 * tpc

// The class keeps the text block the same size on A4 and centres it
// horizontally (\IEEEsetsidemargin{c}), while the fixed top margin means the
// extra height is absorbed at the bottom. Only the compsoc branch varies its
// vertical metrics by paper size.
#let papers = (
  "us-letter": (width: 612pt, height: 792pt),
  "a4": (width: 595.28pt, height: 841.89pt),
)

#let side-margin-for(paper) = (papers.at(paper).width - text-width) / 2

// Vertical geometry is mode-specific. All arithmetic below is in TeX points,
// converted only at the end.
//
// Conference, IEEEtran.cls:1741-1748. The class asks for 9.25in of text under a
// 0.75in top margin, quantises the height to a whole number of lines, then
// splits the resulting error evenly between top and bottom:
//
//   9.25in                    = 668.4975 TeX pt requested
//   56 lines: 12 + 55 x 12    = 672.0000 TeX pt after quantising
//   error                     =  -3.5025 TeX pt
//   0.75in - 3.5025 / 2       =  52.4513 TeX pt top margin
//
// Journal keeps the defaults at IEEEtran.cls:1722-1734, where 58pc of text
// already divides evenly into 58 lines.
// What each mode asks the class for, before quantising, in TeX points.
// Conference at IEEEtran.cls:1741-1748, journal at 1722-1734.
#let requested = (
  conference: (height: 9.25 * 72.27, top: 0.75 * 72.27),
  journal: (height: 58 * 12, top: 58),
)

// The class quantises the requested height to a whole number of lines and
// splits the resulting error between top and bottom. Deriving it rather than
// hardcoding reproduces every line count the class documents in its comments:
// conference 9pt/61, 10pt/56, 11pt/50, 12pt/48, and journal 9pt/63, 10pt/58,
// 11pt/52, 12pt/50.
//
// The class measures the top margin to the top of the ink, not to the top of a
// line box: \IEEEsettopmargin subtracts the height of the sample text "gT"
// (IEEEtran.cls:1104 and 1424-1427), so the first baseline sits one cap height
// below the margin. Typst puts it 0.7em below, so the margin is raised by the
// difference to land the baseline grid where the class has it.
#let cap-height = 0.662
#let vertical-for(mode, pt) = {
  let (size, advance) = ladders.at(pt).normal
  let want = requested.at(mode)
  let lines = calc.round(want.height / advance)
  let height = lines * advance
  let top = want.top - (height - want.height) / 2 - (0.7 - cap-height) * size
  (lines: lines, height: height * tpt, top: top * tpt)
}

// The space below the title block, in body lines, as (nominal, minimum).
// IEEEtran.cls:4969-4978: journals ask for 2.5 lines and accept no less than 2,
// conferences and technotes ask for 1 and accept no less than 0.75.
#let title-space = (
  conference: (nominal: 1, minimum: 0.75),
  journal: (nominal: 2.5, minimum: 2),
)

// What TeX counts as the height of the title block, less what `quantize`
// measures, in body lines. The class measures a vbox that ends in half a line
// of space and whose first line counts from its ink, then takes off \topskip
// (IEEEtran.cls:4772 and 5123-5152). None of that depends on the document, so
// it comes to a constant. Working it out from the class lands a third of a
// line away from what the renders show, so it is calibrated instead. Each
// render bounds it by the number of lines its title block takes:
//
//   bare_conf            12.00 lines natural, 15 taken   (1.254, 2.254]
//   062824               17.21, 20                       (1.039, 2.039]
//   nine-author probe    12.82, 15                       (0.435, 1.435]
//   a PowerTech paper     9.93, 12                       (0.316, 1.316]
//   bare_jrnl             6.18, 10                       [0.822, 1.822)
//   peerreview            4.55,  8                       [0.447, 1.447)
//   bare_jrnl_transmag   14.36, 17                       [0.640, 1.640)
//
// Together they leave (1.254, 1.316], three quarters of a point, and this is
// its middle. The first line's ink is the part that can move: every title
// above has ascenders, and one set in capitals alone would be 0.5pt shorter
// to TeX.
#let title-excess = 1.285

// Typst derives line height from font metrics, so an exact baseline grid needs
// the em box pinned to 1em first. Leading then makes up the rest of the advance.
#let em-box = (top-edge: 0.7em, bottom-edge: -0.3em)
#let leading-for(entry) = entry.at(1) - entry.at(0)

// Applies a ladder entry as an exact baseline grid.
//
// The edges are absolute rather than em-relative so that a nested size change
// does not shrink the line box. TeX holds \baselineskip fixed for the whole
// paragraph, so a small line still sits a full advance below the one above it.
// The conference title relies on this: its subtitle is set at 8pt but still
// sits 28pt below the 24pt title baseline.
#let with-size(entry, body) = {
  let size = entry.at(0)
  set text(size: size, top-edge: 0.7 * size, bottom-edge: -0.3 * size)
  set par(leading: leading-for(entry))
  body
}

// IEEEtran.cls:4772 wraps the title in \IEEEquantizevspace, which pads the
// block to a whole number of body lines so the columns below start on the
// baseline grid. Without this the abstract sits off-grid and every following
// line inherits the error.
//
// The padding is the one nearest the nominal space that makes the total whole,
// and a line more if that falls below the minimum (5165-5188). `offset` is for
// a title block that TeX measures differently, in lines.
#let quantize(mode, body, advance: line-advance, offset: 0) = context {
  let natural = measure(block(width: text-width, body)).height
  let (nominal, minimum) = title-space.at(mode)
  let height = natural / advance + title-excess + offset
  let over = calc.fract(height + nominal)
  let space = if over < 1 - over { nominal - over } else { nominal + 1 - over }
  if space < minimum { space += 1 }
  let slots = calc.round(height + space)
  // width must be explicit: without it the block shrinks to its content and
  // `set align(center)` inside then centres against that narrower box rather
  // than the full text width.
  block(height: slots * advance, width: 100%, body)
}

// Typst has no ex unit. TeX takes it from the font metrics, where Times has an
// x-height of 0.45em. `ex` is that at the 10pt body size.
#let ex-ratio = 0.45
#let ex = ex-ratio * sizes.normal.at(0)

// LaTeX's \vspace adds to the baselineskip, which already contains the inter-
// line gap. Typst's v() adds on top of par.spacing instead, so a class value
// carried over directly overshoots by exactly that spacing. Every one of these
// gaps measured 2pt long before this correction, and par.spacing is 1.99pt.
#let vspace(x, body: sizes.normal) = x - leading-for(body)

// IEEEtran indents every paragraph, including the first after a heading, by
// 1em of the body size (IEEEtran.cls:1708). This is the 10pt one.
#let par-indent = sizes.normal.at(0)

// `pt` selects the font ladder and, through it, the page geometry: the line
// count and margins are derived, not tabulated. The gaps inside the title
// block are calibrated at 10pt and carried over unchanged, so at another size
// the title block has not been checked against anything.
#let page-setup(
  mode: "conference",
  paper: "us-letter",
  columns: 2,
  pt: "10pt",
  body,
) = {
  let body-size = scale(ladders.at(pt).normal)
  let v = vertical-for(mode, pt)
  let sheet = papers.at(paper)
  let side = side-margin-for(paper)
  set page(
    paper: paper,
    margin: (
      top: v.top,
      bottom: sheet.height - v.top - v.height,
      left: side,
      right: side,
    ),
    columns: columns,
  )
  set std.columns(gutter: column-gutter)
  ladder-state.update(sizes-for(pt))
  set text(font: body-font, size: body-size.at(0), ..em-box)
  set par(
    justify: true,
    leading: leading-for(body-size),
    spacing: leading-for(body-size),
    first-line-indent: (amount: body-size.at(0), all: true),
  )
  show: word-spacing
  body
}
