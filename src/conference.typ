// Conference layout, ported from IEEEtran.cls V1.8b [conference].

#import "common/geometry.typ": (
  column-gutter, em-box, line-advance, page-setup, par-indent, sizes,
  text-width, tpc, tpt,
  with-size,
)
#import "common/headings.typ" as headings
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements

// Space above the title and between the title and the author blocks. The class
// specifies 0.5\baselineskip (IEEEtran.cls:4748) and \vskip1.0em (4809), but
// those are measured against TeX's \topskip rule for the first line of a box,
// which Typst has no equivalent of. These are calibrated to put the title
// baseline at 71pt and the author names at 131pt, matching the reference.
#let title-top-space = 2pt
#let title-author-gap = 15pt

// IEEEtran.cls:5277. The abstract label is bold italic, but \bfseries is not
// scoped, so the dash and the whole abstract body are bold as well. The
// reference render confirms it: NimbusRomNo9L-Medi throughout.
#let abstract-label = "Abstract"
#let index-terms-label = "Index Terms"

#let runin-section(label, body) = with-size(
  sizes.small,
  text(weight: "bold")[#text(style: "italic")[#label]---#body],
)

// Author fields accept either content or an array of lines. The array form
// mirrors the \\ separators in \IEEEauthorblockA and avoids escaping trouble,
// since an unescaped @ in markup would parse as a reference and a bare URL
// would autolink.
#let as-lines(x) = {
  if type(x) == array { x.map(l => [#l]).join(linebreak()) } else { x }
}

// IEEEtran.cls:4583-4584. Author blocks set their own interline spacing rather
// than inheriting the body advance: 2.6ex between name lines and 2.75ex between
// affiliation lines. At 10pt Times, ex is 4.463pt, so affiliations advance
// 12.27pt where the body advances 11.955pt. Over four affiliation lines that is
// most of a point and a half, which shows up as drift in the second author row.
#let ex = 0.448 * sizes.normal.at(0)
#let name-advance = 2.6 * ex
#let aff-advance = 2.75 * ex

#let author-cell(a) = align(
  center,
  {
    with-size(
      (sizes.sublarge.at(0), name-advance),
      as-lines(a.at("name", default: [])),
    )
    let aff = a.at("affiliation", default: none)
    if aff != none {
      with-size((sizes.normal.at(0), aff-advance), as-lines(aff))
    }
  },
)

// Vertical separation between wrapped author rows. Calibrated against the
// 062824 wrapper, which is the only reference render with more than one row.
#let author-row-gap = 27pt - line-advance

// Author blocks sit in naturally sized cells separated by equal glue, not in
// equal-width columns: an even three-way split would centre the first block at
// x=134.7 where the reference has it at 154.
//
// \and is \hfill between separate halign groups (IEEEtran.cls:4731), so the
// blocks form one horizontal list that TeX line-breaks when it overruns. Six
// authors therefore wrap to two rows of three. Typst grids do not wrap, so the
// packing is done explicitly here.
#let author-row(authors) = context {
  let cells = authors.map(author-cell)
  let widths = cells.map(c => measure(c).width)

  let rows = ()
  let current = ()
  let used = 0pt
  for (i, c) in cells.enumerate() {
    // Each additional block needs at least a gutter's worth of glue beside it.
    let needed = widths.at(i) + if current.len() > 0 { column-gutter } else { 0pt }
    if current.len() > 0 and used + needed > text-width {
      rows.push(current)
      current = (c,)
      used = widths.at(i)
    } else {
      current.push(c)
      used += needed
    }
  }
  if current.len() > 0 { rows.push(current) }

  stack(
    dir: ttb,
    spacing: author-row-gap,
    ..rows.map(r => block(width: 100%, grid(
      columns: (auto,) * r.len(),
      column-gutter: 1fr,
      ..r,
    ))),
  )
}

// Slack added below the author blocks before quantising. IEEEtran.cls:4969-4974
// specifies 1\baselineskip for conference mode, but that lands the columns two
// lines high against the reference. The shortfall is internal author-block
// spacing that IEEEtran adds and this port does not yet model, so the value is
// calibrated rather than derived: 2.5 reproduces the reference exactly.
#let title-slack = 2.5 * line-advance

// IEEEtran.cls:4772 wraps the title in \IEEEquantizevspace, which rounds the
// whole block to a whole number of body lines so the columns below start on the
// baseline grid. Without this the abstract sits off-grid and every following
// line inherits the error.
#let quantize(body) = context {
  let natural = measure(block(width: text-width, body)).height
  let slots = calc.ceil((natural + title-slack) / line-advance)
  block(height: slots * line-advance, body)
}

#let title-block(title, authors) = quantize({
  set align(center)
  v(title-top-space)
  with-size(sizes.huge, title)
  v(title-author-gap)
  author-row(authors)
})

#let ieee-conference(
  title: [],
  authors: (),
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(mode: "conference")
  show: headings.rules
  show: floats.rules
  show: elements.rules

  // The title spans both columns; everything after it flows in the columns.
  // clearance must be zero: the quantised block height is what puts the columns
  // on the baseline grid, and any float clearance on top of it breaks that.
  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, title-block(title, authors)),
  )

  // The reference list is set at footnotesize under an unnumbered heading, which
  // the heading rules already render as centred small caps. std.bibliography is
  // needed because the parameter of the same name shadows the element function.
  set std.bibliography(title: [References], style: "ieee")

  // \thanks notes are footnotes without a marker: IEEEtran.cls:4756-4758 kills
  // \thefootnote and \@makefnmark so the funding note carries no superscript.
  // It must ride inside the first paragraph rather than stand alone, or it forms
  // an empty paragraph of its own and pushes the columns a line down.
  let note = if thanks != none { footnote(numbering: _ => "", thanks) } else { [] }
  let placed = false

  if abstract != none {
    runin-section(abstract-label, [#note#abstract])
    placed = true
  }
  if index-terms != none {
    let lead = if placed { [] } else { note }
    runin-section(index-terms-label, [#lead#index-terms])
    placed = true
  }
  if not placed { note }

  body

  if bibliography != none { with-size(sizes.footnote, bibliography) }
}
