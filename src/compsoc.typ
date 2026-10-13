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

#import "common/geometry.typ": body-font as times-font, papers, with-size
#import "common/authorblocks.typ": as-lines, author-rows
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements
#import "common/elements.typ": runin-section
#import "common/headings.typ": bibliography-rules, heading-below-extra
#import "common/runninghead.typ": running-head
#import "common/textsplit.typ": plain
#import "common/headings.typ": appendices, appendix-name, appendix-state
#import "common/parstart.typ": parstart as base-parstart
#import "common/biography.typ": biography as base-biography
#import "common/biography.typ": biography-no-photo as base-biography-no-photo

#let body-font = (
  "Palatino",
  "TeX Gyre Pagella",
  "URW Palladio L",
  "Palatino Linotype",
)
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

// IEEEtran.cls:826-828. Computer Society conferences use a 10bp body on 11.2bp
// rather than the journal's 9.5/11.54.
#let conf-sizes = (
  normal: (10pt, 11.2pt),
  small: (9pt, 10pt),
  footnote: (8pt, 9pt),
  sublarge: (11pt, 13.5pt),
  large: (12pt, 14pt),
  Large: (14pt, 17pt),
)
#let conf-line-advance = conf-sizes.normal.at(1)
// The class derives the text block from the sheet rather than fixing it, so
// both modes go through one calculation: a requested height, quantised to the
// nearest whole number of lines, with the error split between top and bottom
// (\IEEEquantizetextheight{c} and \IEEEsettopmargin{q}).
//
// Journal, IEEEtran.cls:1753-1776. 7in of text plus one 12bp gutter, so each
// column is 3.5in; the class notes the 6.875in in the CS spec disagrees with
// their proofs. The margins are 0.625in on US Letter and 24.675mm on A4, both
// of which leave 9.75in, quantised to 61 lines of 11.54bp.
//
// Conference, IEEEtran.cls:1785-1796. A 0.25in gutter inside 0.75in side
// margins, with 1in top and bottom, so the text block grows with the sheet:
// 58 lines on US Letter and 62 on A4.
#let geometry-for(paper, mode) = {
  let sheet = papers.at(paper)
  let conf = mode == "conference"
  let advance = if conf { conf-line-advance } else { line-advance }
  let margin = if conf { 1in } else if paper == "a4" { 24.675mm } else {
    0.625in
  }
  let requested = sheet.height - 2 * margin
  let height = calc.round(requested / advance) * advance
  let top = margin - (height - requested) / 2
  let gutter = if conf { 0.25in } else { 12pt }
  let width = if conf { sheet.width - 2 * 0.75in } else { 7in + gutter }
  (
    top: top,
    bottom: sheet.height - top - height,
    side: (sheet.width - width) / 2,
    width: width,
    gutter: gutter,
  )
}

#let page-setup(paper: "us-letter", mode: "journal", body) = {
  let conf = mode == "conference"
  let sz = if conf { conf-sizes } else { sizes }
  // Computer Society conferences are set in Times; only the journals use the
  // Palatino and Helvetica pairing.
  let family = if conf { times-font } else { body-font }
  let adv = if conf { conf-line-advance } else { line-advance }
  let g = geometry-for(paper, mode)
  set page(
    paper: paper,
    margin: (top: g.top, bottom: g.bottom, left: g.side, right: g.side),
    columns: 2,
  )
  set std.columns(gutter: g.gutter)
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

// Typst's smallcaps() uses the font's smcp feature and does not synthesise, so
// it silently does nothing in Helvetica clones: Nimbus Sans has no small caps.
// The class asks for \scshape on the sans face, and the reference renders it at
// 0.8 of the cap size, so it is emulated here rather than dropped.
#let sc-ratio = 0.8

#let small-caps(body) = {
  let s = plain(body)
  if s == "" { return body }
  for c in s.clusters() {
    if lower(c) == c and upper(c) != c {
      text(size: sc-ratio * 1em, upper(c))
    } else { c }
  }
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
    let in-appendix = appendix-state.at(it.location())
    let n = if it.numbering != none {
      if in-appendix and it.level == 1 {
        numbering("A", counter(heading).at(it.location()).first())
      } else { numbering-fn(..counter(heading).at(it.location())) }
    } else { none }

    let style = if it.level == 1 {
      (size: sizes.sublarge, weight: "bold", caps: true, style: "normal")
    } else if it.level == 2 {
      (size: sizes.normal, weight: "bold", caps: false, style: "normal")
    } else {
      (size: sizes.normal, weight: "regular", caps: false, style: "italic")
    }

    // IEEEtran.cls:5498-5507 gives 3.5ex above a section and subsection, 2.5ex
    // above a subsubsection, and 0.7ex / 0.7ex / 0.5ex below. Carried over
    // directly those leave every gap short against the reference, which
    // measures 29.1/27.1/22.7 above and 14.7/14.7/13.8 below, baseline to
    // baseline. These are calibrated to it, as the title-block constants
    // elsewhere are.
    let above = if it.level == 1 { 19.59pt } else if it.level == 2 {
      17.63pt
    } else { 13.18pt }
    //
    // bare_jrnl_compsoc.tex wraps its Introduction in \IEEEraisesectionheading
    // so the drop cap can sit beside it, which leaves more room below that one
    // heading. The first section gets the same treatment here.
    let first = (
      it.level == 1
        and not in-appendix
        and it.numbering != none
        and counter(heading).at(it.location()) == (1,)
    )
    let below = if it.level == 1 {
      (
        (if first { 11.05pt } else { 5.16pt })
          + heading-below-extra.at(it.location())
      )
    } else if it.level == 2 { 5.16pt } else { 4.27pt }

    block(above: above, below: below, width: 100%)[
      // The edges are pinned to the body's so the References heading, which
      // is emitted inside the footnotesize reference list, sits like the rest.
      // A heading of two lines advances at its own size's baselineskip.
      #set par(leading: style.size.at(1) - sizes.normal.at(0))
      #set text(
        font: heading-font,
        size: style.size.at(0),
        weight: style.weight,
        style: style.style,
        top-edge: 0.7 * sizes.normal.at(0),
        bottom-edge: -0.3 * sizes.normal.at(0),
      )
      #if in-appendix and n != none {
        // As in the Times modes: only numbered headings take the label, so a
        // starred Acknowledgment keeps its normal form (IEEEtran.cls:5745).
        let head = [#appendix-name~#n]
        if style.caps { small-caps(head) } else { head }
        if it.body != [] {
          linebreak()
          if style.caps { small-caps(it.body) } else { it.body }
        }
      } else {
        let label = [#if n != none [#n#h(0.5em)]#it.body]
        if style.caps { small-caps(label) } else { label }
      }
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

#let title-block(title, authors, abstract, index-terms) = {
  set align(center)
  v(title-top-space)
  with-size(sizes.huge, title)
  v(title-author-gap)
  with-size(sizes.sublarge, authors)
  set align(left)
  if abstract != none {
    v(abstract-above)
    // IEEEtran.cls:5269. compsoc sets the abstract and index terms at
    // footnotesize, and the label is bold italic as elsewhere.
    runin-section(abstract-label, abstract, size: sizes.footnote)
  }
  if index-terms != none {
    v(index-terms-above)
    runin-section(index-terms-label, index-terms, size: sizes.footnote)
  }
  v(diamond-above)
  diamond-line
}

#let header-ascent = 7.62pt

// How far the footnote block is raised off the bottom of the text area; see
// elements.typ. The journal value is calibrated to the reference, whose last
// footnote baseline is at 744.2pt. No conference reference carries a footnote,
// so that one is derived the same way as in the Times modes.
#let footnote-drop = 1.4pt
#let conf-footnote-drop = (
  0.3 * (conf-sizes.normal.at(0) - conf-sizes.footnote.at(0))
    + conf-line-advance
    - conf-sizes.normal.at(0)
)

// Unlike the other modes, the compsoc title block is not quantised to the body
// grid: no slot count reproduces the reference's first section position, and the
// diamond rule ends the block on its own terms. A fixed trailing gap does match.
#let title-below = 23pt

#let with-title-below(body) = block(width: 100%, body + v(title-below))

// Computer Society conferences are set in Times, not Palatino: only the
// journals use the Palatino and Helvetica pairing. Sizes are still big points.
// IEEEtran.cls:2573-2577 numbers them "1.", "1.1.", with trailing periods, and
// 5490-5496 sets the headings in bold roman, flush left.
// Space below the References heading, on top of the normal heading skip.
// Calibrated against the references, which measure 14pt from heading to first
// entry in the journal and 23pt in the conference.
#let refs-heading-gap = 1.21pt
#let conf-refs-heading-gap = 10.5pt

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
    let extra = heading-below-extra.at(it.location())
    block(above: conf-heading-above, below: 0.7 * own-ex + extra, width: 100%)[
      #set text(
        size: size.at(0),
        weight: "bold",
        top-edge: 0.7 * conf-sizes.normal.at(0),
        bottom-edge: -0.3 * conf-sizes.normal.at(0),
      )
      #if n != none [#n#h(0.5em)]#it.body
    ]
  }
  body
}

// IEEEtran.cls:4808. \Large bold under two baselineskips of space.
#let conf-title-top-space = 2 * conf-line-advance + 5pt
#let conf-title-author-gap = 26pt
#let conf-author-row-gap = 12pt
#let conf-title-below = 37pt

#let conf-author-cell(a) = align(center, {
  with-size(conf-sizes.sublarge, as-lines(a.name))
  let aff = a.at("affiliation", default: none)
  if aff != none { with-size(conf-sizes.normal, as-lines(aff)) }
})

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
  show: elements.rules.with(
    footnote-size: conf-sizes.footnote,
    footnote-drop: conf-footnote-drop,
  )
  show: bibliography-rules.with(
    size: conf-sizes.footnote,
    heading-extra: conf-refs-heading-gap,
    item-gap: 0.5 * conf-sizes.footnote.at(1),
  )

  place(top, scope: "parent", float: true, clearance: 0pt, block(width: 100%, {
    set align(center)
    v(conf-title-top-space)
    with-size(conf-sizes.Large, text(weight: "bold", title))
    v(conf-title-author-gap)
    author-rows(
      authors.map(conf-author-cell),
      width: geometry-for(paper, "conference").width,
      gap: conf-author-row-gap,
    )
    v(conf-title-below)
  }))

  elements.placed-thanks-note(thanks)

  if abstract != none {
    runin-section(abstract-label, abstract, size: conf-sizes.small)
  }
  if index-terms != none {
    runin-section(index-terms-label, index-terms, size: conf-sizes.small)
  }

  body

  if bibliography != none { bibliography }

  // Closes the last column the way LaTeX's final \vfil does, so biographies
  // spread down it. Without any, it has no effect.
  v(1fr)
}

// The shared helpers default to the 10pt Times ladder, so Computer Society
// papers pass their own metrics: 9.5bp body on 11.54bp.
#let parstart(body) = base-parstart(
  body,
  advance: line-advance,
  body-size: sizes.normal.at(0),
)
#let biography(name: [], photo: none, body) = base-biography(
  name: name,
  photo: photo,
  text-size: sizes.footnote,
  body: sizes.normal,
  body,
)
#let biography-no-photo(name: [], body) = base-biography-no-photo(
  name: name,
  text-size: sizes.footnote,
  body: sizes.normal,
  body,
)

#let ieee-compsoc(
  paper: "us-letter",
  title: [],
  authors: [],
  header-left: [],
  header-right: [],
  twoside: false,
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(paper: paper)
  show: heading-rules
  show: floats.rules
  show: elements.rules.with(
    footnote-size: sizes.footnote,
    footnote-drop: footnote-drop,
  )

  set page(
    header: running-head(header-left, header-right, twoside: twoside),
    header-ascent: header-ascent,
  )
  show: bibliography-rules.with(
    size: sizes.footnote,
    heading-extra: refs-heading-gap,
  )

  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, with-title-below(
      title-block(title, authors, abstract, index-terms),
    )),
  )

  elements.placed-thanks-note(thanks)

  body

  if bibliography != none { bibliography }

  // Closes the last column the way LaTeX's final \vfil does, so biographies
  // spread down it. Without any, it has no effect.
  v(1fr)
}
