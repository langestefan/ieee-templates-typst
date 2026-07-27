// Page geometry and the font-size ladder, ported from IEEEtran.cls V1.8b.

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
// Only the 10pt ladder is wired through the layouts. The others are recorded
// because the line counts below derive from them, and because supporting other
// point sizes is otherwise just a matter of threading a ladder through the
// modules. IEEE papers are 10pt in practice and there is no reference render at
// any other size to verify against.
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

#let sizes = {
  let l = ladders.at("10pt")
  let scale(e) = (e.at(0) * tpt, e.at(1) * tpt)
  (
    normal: scale(l.normal),
    small: scale(l.small),
    footnote: scale(l.footnote),
    sublarge: scale(l.sublarge),
    large: scale(l.large),
    huge: scale(l.huge),
  )
}

#let line-advance = sizes.normal.at(1)

// Column widths are shared by both modes and by both paper sizes.
// IEEEtran.cls:1734-1735. 43pc = 2 x 21pc + 1pc.
#let text-width = 43 * tpc
#let column-width = 21 * tpc
#let column-gutter = 1 * tpc

// The class keeps the text block the same size on A4 and centres it
// horizontally (\IEEEsetsidemargin{c}), while the fixed top margin means the
// extra height is absorbed at the bottom. Only the compsoc branch varies its
// vertical metrics by paper size, and compsoc is not ported.
#let papers = (
  "us-letter": (width: 612pt, height: 792pt),
  "a4": (width: 595.28pt, height: 841.89pt),
)

#let side-margin-for(paper) = (papers.at(paper).width - text-width) / 2

// Retained for callers that predate paper selection; US Letter is the default.
#let margin-side = side-margin-for("us-letter")

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
#let vertical-for(mode, pt) = {
  let advance = ladders.at(pt).normal.at(1)
  let want = requested.at(mode)
  let lines = calc.round(want.height / advance)
  let height = lines * advance
  (
    lines: lines,
    height: height * tpt,
    top: (want.top - (height - want.height) / 2) * tpt,
  )
}

// `slack` is the space added below the title block before quantising it to a
// whole number of body lines.
//
// IEEEtran.cls:4772 wraps the title in \IEEEquantizevspace with a nominal
// spacing of \@IEEENORMtitlevspace: 1 baselineskip for conference, 2.5 for
// journal (4969-4974). Neither reproduces the reference renders; both land the
// columns one slot high.
//
// Measuring the title block against each reference gives the slack that does
// reproduce it, as multiples of the line advance:
//
//   bare_conf   natural 142.81pt   valid (2.055, 3.055]
//   062824      natural 205.32pt   valid (1.826, 2.826]
//   bare_jrnl   natural  74.76pt   valid (2.747, 3.747]
//
// The class values sit below every range, short by roughly one advance in each
// case. That matches the [-\topskip] offset \IEEEquantizevspace applies to
// account for the first line of the following column, but adding exactly one
// advance still leaves bare_conf 0.66pt below its threshold, so the cause is
// not fully pinned down.
//
// All three ranges do intersect, at (2.747, 2.826], but that window is under a
// point wide and a fourth document could easily fall outside it. Per-mode
// values with margin on both sides are the safer choice.
#let vertical = (
  conference: vertical-for("conference", "10pt")
    + (slack: 2.5 * sizes.normal.at(1)),
  journal: vertical-for("journal", "10pt") + (slack: 3 * sizes.normal.at(1)),
)

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

// IEEEtran indents every paragraph, including the first after a heading.
#let par-indent = 1 * tpc

// `pt` selects the font ladder and, through it, the page geometry: the line
// count and margins are derived, not tabulated. Sizes above the body — the
// title block gaps and heading skips — are still calibrated for 10pt, so a
// different ladder gives correct page metrics and body text but a title block
// that has not been checked against anything.
#let page-setup(
  mode: "conference",
  paper: "us-letter",
  columns: 2,
  pt: "10pt",
  body,
) = {
  let ladder = ladders.at(pt)
  let scale(e) = (e.at(0) * tpt, e.at(1) * tpt)
  let body-size = scale(ladder.normal)
  let v = vertical-for(mode, pt) + (slack: vertical.at(mode).slack)
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
  set text(font: body-font, size: body-size.at(0), ..em-box)
  set par(
    justify: true,
    leading: leading-for(body-size),
    spacing: leading-for(body-size),
    first-line-indent: (amount: par-indent, all: true),
  )
  body
}
