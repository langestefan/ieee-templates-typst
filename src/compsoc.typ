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

#import "common/geometry.typ": (
  body-font as times-font, papers, tex-small-caps, with-size, word-space,
  word-spacing,
)
#import "common/authorblocks.typ": as-lines, author-rows
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements
#import "common/elements.typ": runin-depth, runin-section
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

// IEEEtran.cls:1709-1711. Computer Society paragraphs indent by 1.5em.
#let par-indent-em = 1.5

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

#let page-setup(paper: "us-letter", mode: "journal", font: auto, body) = {
  let conf = mode == "conference"
  let sz = if conf { conf-sizes } else { sizes }
  // Computer Society conferences are set in Times; only the journals use the
  // Palatino and Helvetica pairing.
  let family = if font != auto { font } else if conf { times-font } else {
    body-font
  }
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
    // The journal's headings take a negative skip above, which is how LaTeX is
    // told not to indent the paragraph after one (IEEEtran.cls:5498-5499).
    first-line-indent: (amount: par-indent-em * sz.normal.at(0), all: conf),
  )
  show: word-spacing.with(face: if conf { "times" } else { "palatino" })
  body
}

// The class asks for \scshape on the sans face. Nimbus Sans has no small caps,
// and LaTeX's Helvetica has none drawn either: it sets the capitals at 0.8 of
// the size and spaces the letters out, as it does for Times.
#let small-caps = tex-small-caps

// Helvetica keeps its own word space: the class only retunes the roman family
// (IEEEtran.cls:1070-1072).
//
// The face is held in a state so that `biography`, which the document calls
// itself, follows the layout's `sans-font` argument.
#let sans-family = state("ieee-compsoc-sans", heading-font)
#let sans(body) = context text(font: sans-family.get(), spacing: 100%, body)

// IEEEtran.cls:2548-2551 and 2579-2582. Arabic and hierarchical: 1, 1.1, 1.1.1.
#let numbering-fn(..nums) = numbering("1.1.1.1", ..nums.pos())

// The class's ex-based skips are relative to the font in force for that
// heading, not the body. A level-one compsoc heading is set at sublargesize, so
// its 3.5ex is 17.3pt rather than the 14.9pt the body size would give.
#let ex-of(entry) = 0.448 * entry.at(0)

// IEEEtran.cls:5498-5507. Sans-serif throughout, bold small caps at the top
// level. The negative before-skips in the class mark the following paragraph as
// unindented, which `page-setup` does through the paragraph indent.
//
// `column-top` is where the columns begin under the title block on page one,
// for the raised first heading below.
#let column-top = state("ieee-compsoc-column-top", none)

// IEEEtran.cls:5525. bare_jrnl_compsoc.tex wraps its Introduction in
// \IEEEraisesectionheading, which lifts the heading into the space under the
// title block and gives it no height, so that the drop cap opens the column.
// The lift is 1.5\baselineskip plus what the heading leaves beneath it;
// measured, the heading's baseline is this far above the first line's.
#let heading-raise = 20.61pt

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
    let below = if it.level == 1 {
      5.16pt + heading-below-extra.at(it.location())
    } else if it.level == 2 { 5.16pt } else { 4.27pt }

    // The class leaves the raising to the author. Here the first section is
    // raised when it opens the columns on page one, which is where the class's
    // own demo uses it, and set as any other heading otherwise.
    let first = (
      it.level == 1
        and not in-appendix
        and it.numbering != none
        and counter(heading).at(it.location()) == (1,)
    )
    let frame(content) = context {
      let top = column-top.get()
      let pos = here().position()
      if (
        first and top != none and pos.page == 1 and calc.abs(pos.y - top) < 1pt
      ) {
        place(dy: -heading-raise, block(width: 100%, content))
      } else {
        block(above: above, below: below, width: 100%, content)
      }
    }

    frame[
      // The edges are pinned to the body's so the References heading, which
      // is emitted inside the footnotesize reference list, sits like the rest.
      // A heading of two lines advances at its own size's baselineskip.
      #set par(leading: style.size.at(1) - sizes.normal.at(0))
      #set text(
        font: sans-family.get(),
        size: style.size.at(0),
        weight: style.weight,
        style: style.style,
        spacing: 100%,
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
        // IEEEtran.cls:5402. The journal follows the number with 1em, not
        // the 0.5em of the other layouts.
        let label = [#if n != none [#n#h(1em)]#it.body]
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
// The class takes the glyph from ZapfDingbats (pzd). It is U+2726, which
// DejaVu Sans carries; naming the URW clone D050000L first would make Typst
// warn "unknown font family" on every compile where it is absent, typst.app
// included, even for layouts that never draw this rule.
#let diamond-rule-width = 4cm
#let diamond-gap = 7.5pt

// A filled box rather than line(), which is block level and would break the row.
#let diamond-rule = box(width: diamond-rule-width, height: 0.5pt, fill: black)

#let diamond-line = align(center, box({
  diamond-rule
  h(diamond-gap)
  text(font: "DejaVu Sans", size: 11pt, baseline: 3.5pt)[\u{2726}]
  h(diamond-gap)
  diamond-rule
}))

// IEEEtran.cls:4809 adds \vskip 0.75\baselineskip before the title in compsoc
// non-conference mode, on top of \IEEEtitletopspace. Calibrated to put the
// title baseline at 74pt as the reference does.
#let title-top-space = 13.26pt
#let title-author-gap = 11.83pt
#let abstract-above = 17.71pt
#let index-terms-above = 11.09pt
#let diamond-above = 3pt

#let abstract-label = "Abstract"
#let index-terms-label = "Index Terms"

// IEEEtran.cls:4796. The abstract and index terms sit in a box 0.922 of the
// text width, centred, and are set ragged right.
#let abstract-width = 0.922

// IEEEtran.cls:5313-5318. Sans at footnotesize with a bold upright label, not
// indented, on a baselineskip stretched by 1.15.
#let abstract-stretch = 1.15
#let abstract-section(label, body) = {
  let (size, advance) = sizes.footnote
  set par(first-line-indent: 0pt, justify: false)
  with-size((size, abstract-stretch * advance), sans[*#label*---#body])
}

// IEEEtran.cls:4808 and 4832 set the title and the author line in sans.
#let title-block(title, authors, abstract, index-terms) = {
  set align(center)
  v(title-top-space)
  with-size(sizes.huge, sans(title))
  v(title-author-gap)
  with-size(sizes.sublarge, sans(authors))
  set align(left)
  let inset = (1 - abstract-width) / 2 * 100%
  if abstract != none {
    v(abstract-above)
    pad(x: inset, abstract-section(abstract-label, abstract))
  }
  if index-terms != none {
    v(index-terms-above)
    pad(x: inset, abstract-section(index-terms-label, index-terms))
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
// grid. The reference's columns start a tenth of a line off the grid as this
// layout computes it, so no slot count lands on them; a fixed gap under the
// diamond rule does. A title block of another height will therefore not be
// rounded as the class would round it.
#let title-below = 43.72pt

#let with-title-below(body) = block(width: 100%, body + v(title-below))

// Computer Society conferences are set in Times, not Palatino: only the
// journals use the Palatino and Helvetica pairing. Sizes are still big points.
// IEEEtran.cls:2573-2577 numbers them "1.", "1.1.", with trailing periods, and
// 5490-5496 sets the headings in bold roman, flush left.
// Space below the References heading, on top of the normal heading skip.
// Calibrated against the references, which measure 14pt from heading to first
// entry in the journal and 23pt in the conference.
#let refs-heading-gap = 1.21pt
#let conf-refs-heading-gap = 1.9pt

#let conf-numbering(..nums) = numbering("1.1.1.", ..nums.pos())

// IEEEtran.cls:5490-5496. A section, subsection and subsubsection each take
// 1\baselineskip above. The first two take 1\baselineskip below as well; the
// third takes none and so runs into its paragraph, closed with a full stop
// and a space (5391-5393). All three are bold, and none is indented.
//
// TeX reaches a heading's baseline by the heading size's own baselineskip, so
// a section sits 14 + 11.2bp below the text above it and a subsection 13.5 +
// 11.2bp. Blocks here are spaced edge to edge, with the line box pinned to
// the body's 10bp, which is what the last term takes off.
#let conf-heading-size(level) = if level == 1 { conf-sizes.large } else if (
  level == 2
) { conf-sizes.sublarge } else { conf-sizes.normal }
#let conf-heading-above(level) = (
  conf-heading-size(level).at(1) + conf-line-advance - conf-sizes.normal.at(0)
)
#let conf-heading-below = 2 * conf-line-advance - conf-sizes.normal.at(0)
#let conf-runin-punct = [.#h(word-space.times.bold, weak: true)]

#let conf-heading-rules(body) = {
  set heading(numbering: conf-numbering)
  show heading: it => {
    let n = if it.numbering != none {
      conf-numbering(..counter(heading).at(it.location()))
    } else { none }
    let size = conf-heading-size(it.level)
    let label = [#if n != none [#n#h(0.5em)]#it.body]
    if it.level >= 3 {
      // The parbreak closes the paragraph above. The paragraph this opens
      // takes the indent like any other, which a subsubsection gives back and
      // a paragraph heading doubles.
      let indent = par-indent-em * conf-sizes.normal.at(0)
      let head = if it.level == 3 { h(-indent) + strong(label) } else {
        h(indent) + label
      }
      let above = if it.level == 3 { conf-line-advance } else { 0pt }
      return [#parbreak()#v(above)#head#conf-runin-punct]
    }
    let extra = heading-below-extra.at(it.location())
    block(
      above: conf-heading-above(it.level),
      below: conf-heading-below + extra,
      width: 100%,
    )[
      #set text(
        size: size.at(0),
        weight: "bold",
        spacing: word-space.times.bold,
        top-edge: 0.7 * conf-sizes.normal.at(0),
        bottom-edge: -0.3 * conf-sizes.normal.at(0),
      )
      #label
    ]
  }
  body
}

// IEEEtran.cls:4808. \Large bold under two baselineskips of space.
#let conf-title-top-space = 2 * conf-line-advance + 4.1pt
#let conf-title-author-gap = 27.7pt
#let conf-author-row-gap = 12pt
#let conf-title-below = 33.25pt

// IEEEtran.cls:4583-4584 spaces name lines by 2.6ex and affiliation lines by
// 2.75ex, each in ex of its own font. For the 11bp names that is 12.87pt. The
// reference measures 12.13pt between affiliation lines, a little under the
// 12.38pt that gives, and 12.35pt from the name down to the first of them.
#let conf-name-advance = 2.6 * 0.45 * conf-sizes.sublarge.at(0)
#let conf-aff-advance = 12.13pt
#let conf-name-aff-gap = 0.85pt

#let conf-author-cell(a) = align(center, {
  with-size((conf-sizes.sublarge.at(0), conf-name-advance), as-lines(a.name))
  let aff = a.at("affiliation", default: none)
  if aff != none {
    v(conf-name-aff-gap)
    with-size((conf-sizes.normal.at(0), conf-aff-advance), as-lines(aff))
  }
})

#let ieee-compsoc-conference(
  paper: "us-letter",
  font: times-font,
  title: [],
  authors: (),
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(paper: paper, mode: "conference", font: font)
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
    // \Large is the one size the class leaves out when it widens the word
    // space (IEEEtran.cls:1071-1084), so this title keeps the font's own.
    with-size(conf-sizes.Large, text(weight: "bold", spacing: 100%, title))
    v(conf-title-author-gap)
    author-rows(
      authors.map(conf-author-cell),
      width: geometry-for(paper, "conference").width,
      gap: conf-author-row-gap,
    )
    v(conf-title-below)
  }))

  elements.placed-thanks-note(thanks)

  // IEEEtran.cls:5301 and 5307. Neither the abstract nor the index terms is
  // indented here, unlike the other Times layouts.
  let runin = (size: conf-sizes.small, body: conf-sizes.normal)
  let section(label, body) = {
    set par(first-line-indent: 0pt)
    runin-section(label, body, size: conf-sizes.small)
  }
  if abstract != none { section(abstract-label, abstract) }
  // IEEEtran.cls:5307 puts half a line above the index terms and 5292 adds
  // 0.67ex below them, in the bold then in force, whose x-height is 0.461em.
  // bare_conf_compsoc.tex has no index terms, so neither is checked against a
  // render.
  if index-terms != none {
    if abstract != none { v(0.5 * conf-sizes.small.at(1)) }
    section(index-terms-label, index-terms)
    v(0.67 * 0.461 * conf-sizes.small.at(0))
  }
  if abstract != none or index-terms != none { v(runin-depth(..runin)) }

  body

  if bibliography != none { bibliography }

  // Closes the last column the way LaTeX's final \vfil does, so biographies
  // spread down it. Without any, it has no effect.
  v(1fr)
}

// The shared helpers default to the 10pt Times ladder, so Computer Society
// papers pass their own metrics: 9.5bp body on 11.54bp.
//
// IEEEtran.cls:5789. The letter is regular weight here, not bold. 0.699em is
// the height of a Palatino capital that gives the reference's 27.66pt letter.
#let palatino-cap = 0.699
#let parstart(body) = base-parstart(
  body,
  advance: line-advance,
  body-size: sizes.normal.at(0),
  weight: "regular",
  cap: palatino-cap,
  letter-cap: palatino-cap,
)
// IEEEtran.cls:5991 and 6079. Biographies are sans here.
#let biography(name: [], photo: none, body) = sans(base-biography(
  name: name,
  photo: photo,
  text-size: sizes.footnote,
  body: sizes.normal,
  drop: footnote-drop,
  body,
))
#let biography-no-photo(name: [], body) = sans(base-biography-no-photo(
  name: name,
  text-size: sizes.footnote,
  body: sizes.normal,
  drop: footnote-drop,
  body,
))

// \IEEEcompsocitemizethanks and \thanks, IEEEtran.cls:4873-4906. Both are
// italic and neither is indented (4762). The items hang behind a bullet, 1.2em
// plus the bullet's width in (4891-4892). A rule half a column wide sits above
// the note, the only footnote rule the class draws (2500-2512).
//
// The reference render sets the plain note over the last item, half a line
// below it. That is the class's \vspace{-1\baselineskip} going wrong, so the
// note goes on the next line here.
#let thanks-hang = 13.42pt
#let thanks-rule-above = 1pt
#let thanks-body(items, thanks) = {
  set text(style: "italic")
  set par(first-line-indent: 0pt)
  place(top + center, dy: -thanks-rule-above, line(
    length: 50%,
    stroke: 0.4pt,
  ))
  for item in items {
    grid(
      columns: (thanks-hang, 1fr),
      text(style: "normal")[•], item,
    )
  }
  thanks
}

#let ieee-compsoc(
  paper: "us-letter",
  font: body-font,
  sans-font: heading-font,
  title: [],
  authors: [],
  header-left: [],
  header-right: [],
  twoside: false,
  thanks: none,
  thanks-items: (),
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  sans-family.update(sans-font)
  show: page-setup.with(paper: paper, font: font)
  show: heading-rules
  show: floats.rules
  show: elements.rules.with(
    footnote-size: sizes.footnote,
    footnote-drop: footnote-drop,
  )

  set page(
    header: sans(running-head(header-left, header-right, twoside: twoside)),
    header-ascent: header-ascent,
  )
  show: bibliography-rules.with(
    size: sizes.footnote,
    heading-extra: refs-heading-gap,
  )

  let head = block(width: 100%, with-title-below(
    title-block(title, authors, abstract, index-terms),
  ))
  place(top, scope: "parent", float: true, clearance: 0pt, head)
  context {
    let g = geometry-for(paper, "journal")
    let height = measure(block(width: g.width, head)).height
    column-top.update(g.top + height)
  }

  if thanks != none or thanks-items.len() > 0 {
    elements.placed-thanks-note(thanks-body(thanks-items, thanks))
  }

  body

  if bibliography != none { bibliography }

  // Closes the last column the way LaTeX's final \vfil does, so biographies
  // spread down it. Without any, it has no effect.
  v(1fr)
}
