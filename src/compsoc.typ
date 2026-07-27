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
#import "common/runninghead.typ": running-head

#let body-font = (
  "Palatino",
  "TeX Gyre Pagella",
  "URW Palladio L",
  "Palatino Linotype",
)
#let heading-font = ("Helvetica", "Nimbus Sans", "TeX Gyre Heros", "Arial")
#let conf-body-font = ("Times New Roman", "TeX Gyre Termes", "Nimbus Roman")

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

// IEEEtran.cls:826-828. Computer Society conferences use a 10bp body on 11.2bp
// rather than the journal's 9.5/11.54, and take their geometry from
// IEEEtran.cls:1785-1796: a 0.25in gutter inside 0.75in side margins, with 1in
// top and bottom quantised to whole lines.
#let conf-sizes = (
  normal: (10pt, 11.2pt),
  small: (9pt, 10pt),
  footnote: (8pt, 9pt),
  sublarge: (11pt, 13.5pt),
  large: (12pt, 14pt),
  Large: (14pt, 17pt),
)
#let conf-line-advance = conf-sizes.normal.at(1)
#let conf-gutter = 0.25in
#let conf-text-width = 612pt - 2 * 0.75in
#let conf-column-width = (conf-text-width - conf-gutter) / 2
#let conf-lines = 58
#let conf-text-height = conf-lines * conf-line-advance
#let conf-margin-top = 1in - (conf-text-height - (11in - 2in)) / 2

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

#let page-setup(paper: "us-letter", mode: "journal", body) = {
  let sheet-height = if paper == "a4" { 841.89pt } else { 792pt }
  let sheet-width = if paper == "a4" { 595.28pt } else { 612pt }
  let conf = mode == "conference"
  let sz = if conf { conf-sizes } else { sizes }
  // Computer Society conferences are set in Times; only the journals use the
  // Palatino and Helvetica pairing.
  let family = if conf { conf-body-font } else { body-font }
  let adv = if conf { conf-line-advance } else { line-advance }
  let tw = if conf { conf-text-width } else { text-width }
  let top = if conf { conf-margin-top } else { margin-top }
  let th = if conf { conf-text-height } else { text-height }
  set page(
    paper: paper,
    margin: (
      top: top,
      bottom: sheet-height - top - th,
      left: (sheet-width - tw) / 2,
      right: (sheet-width - tw) / 2,
    ),
    columns: 2,
  )
  set std.columns(gutter: if conf { conf-gutter } else { column-gutter })
  set text(
    font: family,
    size: sz.normal.at(0),
    top-edge: 0.7 * sz.normal.at(0),
    bottom-edge: -0.3 * sz.normal.at(0),
  )
  set par(
    justify: true,
    leading: adv - sz.normal.at(0),
    spacing: adv - sz.normal.at(0),
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

// IEEEtran.cls:4844-4850. The diamond rule is not a bare glyph: it is a 0.5pt
// rule, 7.5pt of space, ZapfDingbats character 70 at 11pt dropped 3.5pt below
// the baseline, then the same again. There are two widths; the 2.5cm one is the
// double-column form.
//
// D050000L is the URW ZapfDingbats clone the class's pzd family maps to. The
// same glyph is U+2726, which most fonts carry, so this degrades gracefully if
// D050000L is absent.
#let diamond-rule-width = 4cm
#let diamond-gap = 7.5pt

// A filled box rather than line(), which is block level and would break the row.
#let diamond-rule = box(width: diamond-rule-width, height: 0.5pt, fill: black)

#let diamond-line = align(center, box({
  diamond-rule
  h(diamond-gap)
  text(font: ("D050000L", "DejaVu Sans"), size: 11pt, baseline: 3.5pt)[\u{2726}]
  h(diamond-gap)
  diamond-rule
}))

// IEEEtran.cls:4809 adds \vskip 0.75\baselineskip before the title in compsoc
// non-conference mode, on top of \IEEEtitletopspace. Calibrated to put the
// title baseline at 74pt as the reference does.
#let title-top-space = 13pt
#let title-author-gap = 12pt
#let abstract-above = 18pt
#let index-terms-above = 11pt
#let diamond-above = 3pt

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

#let header-ascent = 7pt

// Unlike the other modes, the compsoc title block is not quantised to the body
// grid: no slot count reproduces the reference's first section position, and the
// diamond rule ends the block on its own terms. A fixed trailing gap does match.
#let title-below = 23pt

#let quantize(body) = block(width: 100%, body + v(title-below))

// Computer Society conferences are set in Times, not Palatino: only the
// journals use the Palatino and Helvetica pairing. Sizes are still big points.
// IEEEtran.cls:2573-2577 numbers them "1.", "1.1.", with trailing periods, and
// 5490-5496 sets the headings in bold roman, flush left.
#let conf-numbering(..nums) = numbering("1.1.1.", ..nums.pos())

// IEEEtran.cls:5490-5492 puts 1\baselineskip above a compsoc conference
// heading; measured against the reference it needs 5pt more, the same kind of
// v() versus \vskip difference seen in the other modes.
#let conf-heading-above = conf-line-advance + 5pt

#let conf-heading-rules(body) = {
  set heading(numbering: conf-numbering)
  show heading: it => {
    let n = if it.numbering != none {
      conf-numbering(..counter(heading).at(it.location()))
    } else { none }
    let size = if it.level == 1 { conf-sizes.large } else if it.level == 2 {
      conf-sizes.sublarge
    } else { conf-sizes.normal }
    let own-ex = ex-of(size)
    block(above: conf-heading-above, below: 0.7 * own-ex, width: 100%)[
      #set text(size: size.at(0), weight: "bold")
      #if n != none [#n#h(0.5em)]#it.body
    ]
  }
  body
}

#let conf-runin-section(label, body) = with-size(
  conf-sizes.small,
  text(weight: "bold")[#text(style: "italic")[#label]---#body],
)

// IEEEtran.cls:4808. \Large bold under two baselineskips of space.
#let conf-title-top-space = 2 * conf-line-advance + 5pt
#let conf-title-author-gap = 26pt
#let conf-author-row-gap = 12pt
#let conf-title-below = 37pt

#let conf-author-cell(a) = align(center, {
  with-size(conf-sizes.sublarge, if type(a.name) == array {
    a.name.map(l => [#l]).join(linebreak())
  } else { a.name })
  let aff = a.at("affiliation", default: none)
  if aff != none {
    with-size(conf-sizes.normal, if type(aff) == array {
      aff.map(l => [#l]).join(linebreak())
    } else { aff })
  }
})

#let conf-author-row(authors) = context {
  let cells = authors.map(conf-author-cell)
  let widths = cells.map(c => measure(c).width)
  let rows = ()
  let current = ()
  let used = 0pt
  for (i, c) in cells.enumerate() {
    // \and is \hfill, which has zero natural width, so no gap is reserved: the
    // blocks only have to fit the text width between them.
    let needed = widths.at(i)
    if current.len() > 0 and used + needed > conf-text-width {
      rows.push(current)
      current = (c,)
      used = widths.at(i)
    } else {
      current.push(c)
      used += needed
    }
  }
  if current.len() > 0 { rows.push(current) }
  stack(dir: ttb, spacing: conf-author-row-gap, ..rows.map(r => block(
    width: 100%,
    grid(columns: (auto,) * r.len(), column-gutter: 1fr, ..r),
  )))
}

#let ieee-compsoc-conference(
  paper: "us-letter",
  title: [],
  authors: (),
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(paper: paper, mode: "conference")
  show: conf-heading-rules
  show: floats.rules
  show: elements.rules

  set std.bibliography(title: [References], style: "ieee")

  place(top, scope: "parent", float: true, clearance: 0pt, block(width: 100%, {
    set align(center)
    v(conf-title-top-space)
    with-size(conf-sizes.Large, text(weight: "bold", title))
    v(conf-title-author-gap)
    conf-author-row(authors)
    v(conf-title-below)
  }))

  if thanks != none {
    place(top + left, box(footnote(numbering: _ => "", thanks)))
  }

  if abstract != none { conf-runin-section(abstract-label, abstract) }
  if index-terms != none { conf-runin-section(index-terms-label, index-terms) }

  body

  if bibliography != none { with-size(conf-sizes.footnote, bibliography) }
}

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

  set page(
    header: running-head(header-left, header-right),
    header-ascent: header-ascent,
  )
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
