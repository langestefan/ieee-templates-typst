// Page geometry and the font-size ladder, ported from IEEEtran.cls V1.8b.

// TeX's point is 1/72.27in; PDF and Typst points are 1/72in. Every dimension
// and font size taken from the class is in TeX points and must be converted,
// or the layout drifts by 0.37% — about 2.5pt across a column, which is enough
// to lose a line off the bottom of the page.
#let tpt = 72pt / 72.27
#let tpc = 12 * tpt

// Times, metric-compatible fallbacks in descending preference.
#let body-font = ("Times New Roman", "TeX Gyre Termes", "Nimbus Roman")

// Font ladder for a 10pt document, IEEEtran.cls:650-667.
// Each entry is (size, baseline-to-baseline advance), converted from TeX points.
#let sizes = (
  normal: (10 * tpt, 12 * tpt),
  small: (9 * tpt, 10 * tpt),
  footnote: (8 * tpt, 9 * tpt),
  sublarge: (11 * tpt, 13.4 * tpt),
  huge: (24 * tpt, 28 * tpt),
)

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
  conference: (
    lines: 56,
    height: 672 * tpt,
    top: 52.45125 * tpt,
    slack: 2.5 * sizes.normal.at(1),
  ),
  journal: (
    lines: 58,
    height: 696 * tpt,
    top: 58 * tpt,
    slack: 3 * sizes.normal.at(1),
  ),
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

#let page-setup(mode: "conference", paper: "us-letter", columns: 2, body) = {
  let v = vertical.at(mode)
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
  set text(font: body-font, size: sizes.normal.at(0), ..em-box)
  set par(
    justify: true,
    leading: leading-for(sizes.normal),
    spacing: leading-for(sizes.normal),
    first-line-indent: (amount: par-indent, all: true),
  )
  body
}
