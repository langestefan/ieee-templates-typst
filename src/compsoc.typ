// IEEE Computer Society journal layout, ported from IEEEtran.cls V1.8b
// [journal,compsoc].
//
// This is a different design rather than a variant of the plain journal, and it
// shares almost nothing with the other modes but the float and element rules:
//
//   - Palatino body text, Helvetica headings, where the rest of IEEE uses Times
//   - dimensions and font sizes in big points, so none of the 72/72.27 TeX
//     point conversion the other modes need applies here
//   - 9.5bp body on 11.54bp leading, 61 lines per column (IEEEtran.cls:871-876,
//     where the class notes the official 11.4 spec does not give 61 lines)
//   - sections numbered 1, 1.1, 1.1.1 rather than I, A, 1
//   - a diamond rule closing the title block
//
// Fonts: needs a Palatino and a Helvetica clone. TeX Gyre Pagella and Nimbus
// Sans are the free ones; pass --font-path if they are not installed system
// wide.

#import "common/floats.typ" as floats
#import "common/elements.typ" as elements

#let body-font = ("Palatino", "TeX Gyre Pagella", "URW Palladio L", "Palatino Linotype")
#let heading-font = ("Helvetica", "Nimbus Sans", "TeX Gyre Heros", "Arial")

// IEEEtran.cls:744-765 and 875. All big points, unlike every other mode.
// Each entry is (size, baseline-to-baseline advance).
#let sizes = (
  normal: (9.5pt, 11.54pt),
  small: (9pt, 10pt),
  footnote: (8pt, 9pt),
  script: (7pt, 8pt),
  sublarge: (11pt, 13.5pt),
  large: (12pt, 14pt),
  huge: (24pt, 28pt),
)

#let line-advance = sizes.normal.at(1)

// IEEEtran.cls:1753-1757. 7in of text plus one 12bp gutter, so each column is
// 3.5in; the class notes the 6.875in in the CS spec disagrees with their proofs.
#let column-gutter = 12pt
#let text-width = 7in + column-gutter
#let column-width = (text-width - column-gutter) / 2

// IEEEtran.cls:1765-1768. 0.625in margins give 9.75in of text, quantised to 61
// lines of 11.54bp, with the resulting error split between top and bottom.
#let lines-per-column = 61
#let text-height = lines-per-column * line-advance
#let requested-height = 11in - 2 * 0.625in
#let margin-top = 0.625in - (text-height - requested-height) / 2

#let with-size(entry, body) = {
  let size = entry.at(0)
  set text(size: size, top-edge: 0.7 * size, bottom-edge: -0.3 * size)
  set par(leading: entry.at(1) - size)
  body
}

#let page-setup(paper: "us-letter", body) = {
  let sheet-height = if paper == "a4" { 841.89pt } else { 792pt }
  let sheet-width = if paper == "a4" { 595.28pt } else { 612pt }
  set page(
    paper: paper,
    margin: (
      top: margin-top,
      bottom: sheet-height - margin-top - text-height,
      left: (sheet-width - text-width) / 2,
      right: (sheet-width - text-width) / 2,
    ),
    columns: 2,
  )
  set std.columns(gutter: column-gutter)
  set text(
    font: body-font,
    size: sizes.normal.at(0),
    top-edge: 0.7 * sizes.normal.at(0),
    bottom-edge: -0.3 * sizes.normal.at(0),
  )
  set par(
    justify: true,
    leading: line-advance - sizes.normal.at(0),
    spacing: line-advance - sizes.normal.at(0),
    first-line-indent: (amount: 1em, all: true),
  )
  body
}

// IEEEtran.cls:2548-2551 and 2579-2582. Arabic and hierarchical: 1, 1.1, 1.1.1.
#let numbering-fn(..nums) = numbering("1.1.1.1", ..nums.pos())

// The class's ex-based skips are relative to the font in force for that
// heading, not the body. A level-one compsoc heading is set at sublargesize, so
// its 3.5ex is 17.3pt rather than the 14.9pt the body size would give.
#let ex-of(entry) = 0.448 * entry.at(0)
#let ex = ex-of(sizes.normal)

// IEEEtran.cls:5498-5507. Sans-serif throughout, bold small caps at the top
// level. The negative before-skips in the class mark the following paragraph as
// unindented, which is handled separately.
#let heading-rules(body) = {
  set heading(numbering: numbering-fn)

  show heading: it => {
    let n = if it.numbering != none {
      numbering-fn(..counter(heading).at(it.location()))
    } else { none }

    let style = if it.level == 1 {
      (size: sizes.sublarge, weight: "bold", caps: true, style: "normal")
    } else if it.level == 2 {
      (size: sizes.normal, weight: "bold", caps: false, style: "normal")
    } else {
      (size: sizes.normal, weight: "regular", caps: false, style: "italic")
    }

    let own-ex = ex-of(style.size)
    let above = if it.level == 3 { 2.5 * own-ex } else { 3.5 * own-ex }

    block(above: above, below: 0.7 * ex, width: 100%)[
      #set text(
        font: heading-font,
        size: style.size.at(0),
        weight: style.weight,
        style: style.style,
      )
      #let label = [#if n != none [#n#h(0.5em)]#it.body]
      #if style.caps { smallcaps(label) } else { label }
    ]
  }

  body
}

// IEEEtran.cls:5239. A diamond rule closes the title block.
#let diamond-line = align(center, text(size: sizes.sublarge.at(0), sym.diamond.filled))

// IEEEtran.cls:4809 adds \vskip 0.75\baselineskip before the title in compsoc
// non-conference mode, on top of \IEEEtitletopspace. Calibrated to put the
// title baseline at 74pt as the reference does.
#let title-top-space = 13pt
#let title-author-gap = 12pt
#let abstract-above = 18pt
#let index-terms-above = 11pt
#let diamond-above = 6pt

#let abstract-label = "Abstract"
#let index-terms-label = "Index Terms"

// IEEEtran.cls:5269. compsoc sets the abstract and index terms at footnotesize,
// and the label is bold italic as elsewhere.
#let runin-section(label, body) = with-size(
  sizes.footnote,
  text(weight: "bold")[#text(style: "italic")[#label]---#body],
)

#let title-block(title, authors, abstract, index-terms) = {
  set align(center)
  v(title-top-space)
  with-size(sizes.huge, title)
  v(title-author-gap)
  with-size(sizes.sublarge, authors)
  set align(left)
  if abstract != none {
    v(abstract-above)
    runin-section(abstract-label, abstract)
  }
  if index-terms != none {
    v(index-terms-above)
    runin-section(index-terms-label, index-terms)
  }
  v(diamond-above)
  diamond-line
}

#let head-size = 7pt
#let header-ascent = 7pt

#let running-head(left-text, right-text) = context {
  let n = counter(page).at(here()).first()
  let text-for-page = if n == 1 or calc.even(n) { left-text } else { right-text }
  set text(size: head-size)
  block(width: 100%, grid(
    columns: (1fr, auto),
    align(left, text-for-page),
    align(right, [#n]),
  ))
}

// Unlike the other modes, the compsoc title block is not quantised to the body
// grid: no slot count reproduces the reference's first section position, and the
// diamond rule ends the block on its own terms. A fixed trailing gap does match.
#let title-below = 20pt

#let quantize(body) = block(body + v(title-below))

#let ieee-compsoc(
  paper: "us-letter",
  title: [],
  authors: [],
  header-left: [],
  header-right: [],
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(paper: paper)
  show: heading-rules
  show: floats.rules
  show: elements.rules

  set page(header: running-head(header-left, header-right), header-ascent: header-ascent)
  set std.bibliography(title: [References], style: "ieee")

  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, quantize(
      title-block(title, authors, abstract, index-terms),
    )),
  )

  // As in transmag: a footnote inside a float never registers, and emitting it
  // in the flow costs a paragraph, so it is placed without taking flow space.
  if thanks != none {
    place(top + left, box(footnote(numbering: _ => "", thanks)))
  }

  body

  if bibliography != none { with-size(sizes.footnote, bibliography) }
}
