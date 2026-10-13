// Conference layout, ported from IEEEtran.cls V1.8b [conference].

#import "common/geometry.typ": (
  ex-ratio, leading-for, line-advance, page-setup, quantize, sizes-for,
  text-width, with-size,
)
#import "common/authorblocks.typ": as-lines, author-rows
#import "common/authormark.typ": author-mark
#import "common/headings.typ" as headings
#import "common/headings.typ": appendices
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements
#import "common/elements.typ": runin-depth, runin-height, runin-section

// Space above the title and between the title and the author blocks. The class
// specifies 0.5\baselineskip (IEEEtran.cls:4748) and \vskip1.0em (4809), but
// those are measured against TeX's \topskip rule for the first line of a box,
// which Typst has no equivalent of. These are calibrated to put the title
// baseline at 71pt and the author names at 131pt, matching the reference.
#let title-top-space = 2.62pt
#let title-author-gap = 14.54pt

#let abstract-label = "Abstract"
#let index-terms-label = "Index Terms"

// IEEEtran.cls:4583-4584. Author blocks set their own interline spacing rather
// than inheriting the body advance: 2.6ex between name lines and 2.75ex between
// affiliation lines. At 10pt Times, ex is 4.483pt, so affiliations advance
// 12.33pt where the body advances 11.955pt. Over four affiliation lines that is
// most of a point and a half, which shows up as drift in the second author row.
// Each is in ex of its own font: names are set at sublargesize, so two name
// lines in one block sit 12.82pt apart.
#let name-advance = 2.6
#let aff-advance = 2.75
// Calibrated: the first affiliation line sits this much further below the
// name than the paragraph spacing alone gives.
#let name-aff-gap = 0.23pt

#let author-cell(sz, a) = align(
  center,
  {
    let ex = ex-ratio * sz.normal.at(0)
    with-size(
      (sz.sublarge.at(0), name-advance * ex-ratio * sz.sublarge.at(0)),
      as-lines(a.at("name", default: [])),
    )
    let aff = a.at("affiliation", default: none)
    if aff != none {
      v(name-aff-gap)
      with-size((sz.normal.at(0), aff-advance * ex), as-lines(aff))
    }
  },
)

// Vertical separation between wrapped author rows, calibrated against two
// reference renders: IEEE's 062824 wrapper (six authors, two rows) and a
// nine-author probe compiled for the purpose (two rows of five and four). 26pt
// satisfies the first but leaves the probe 1pt short, and 27pt the reverse.
#let author-row-gap = 26.5pt - line-advance

#let title-block(sz, title, authors) = quantize(
  "conference",
  advance: sz.normal.at(1),
  {
    set align(center)
    v(title-top-space)
    with-size(sz.huge, title)
    v(title-author-gap)
    author-rows(
      authors.map(author-cell.with(sz)),
      width: text-width,
      gap: author-row-gap,
    )
  },
)

#let ieee-conference(
  paper: "us-letter",
  pt: "10pt",
  title: [],
  authors: (),
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  let sz = sizes-for(pt)
  show: page-setup.with(mode: "conference", paper: paper, pt: pt)
  show: headings.rules.with(mode: "conference", body: sz.normal)
  show: floats.rules.with(size: sz.footnote, advance: sz.normal.at(1))
  show: elements.rules.with(
    footnote-size: sz.footnote,
    footnote-drop: elements.footnote-drop-for(sz),
  )
  show: headings.bibliography-rules.with(size: sz.footnote, body: sz.normal)
  let runin = (size: sz.small, body: sz.normal)

  // The title spans both columns; everything after it flows in the columns.
  // clearance must be zero: the quantised block height is what puts the columns
  // on the baseline grid, and any float clearance on top of it breaks that.
  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, title-block(sz, title, authors)),
  )

  // The note must ride inside the first paragraph rather than stand alone, or
  // it forms an empty paragraph of its own and pushes the columns a line down.
  let note = elements.thanks-note(thanks)
  let placed = false

  if abstract != none or index-terms != none { v(runin-height(..runin)) }
  if abstract != none {
    runin-section(abstract-label, [#note#abstract], size: sz.small)
    placed = true
  }
  if index-terms != none {
    let lead = if placed { [] } else { note }
    // \endabstract adds no space in conference mode (IEEEtran.cls:5283), so the
    // index terms follow at the abstract's own advance, not the body's.
    if placed { v(leading-for(sz.small) - leading-for(sz.normal)) }
    runin-section(index-terms-label, [#lead#index-terms], size: sz.small)
    placed = true
  }
  // IEEEtran.cls:5292. \endIEEEkeywords adds 0.67ex in the 9pt bold still in
  // force, whose x-height is 0.461em. \endabstract adds nothing here (5283).
  if index-terms != none { v(0.67 * 0.461 * sz.small.at(0)) }
  if placed { v(runin-depth(..runin)) } else { note }

  body

  // A convenience for the common case. Documents that need the list elsewhere
  // write #bibliography(..) into the body instead; it is styled either way.
  if bibliography != none { bibliography }
}
