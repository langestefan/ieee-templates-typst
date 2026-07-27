// Journal layout, ported from IEEEtran.cls V1.8b [journal].
//
// Shares geometry, headings and floats with the conference mode. The
// differences are the running head, a single centred author line instead of
// side-by-side author blocks, and 58 lines per column instead of 56.

#import "common/geometry.typ": (
  leading-for, line-advance, margin-side, page-setup, sizes, text-width,
  vertical, with-size,
)
#import "common/authormark.typ": author-mark
#import "common/headings.typ" as headings
#import "common/headings.typ": appendices, heading-below-extra
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements
#import "common/parstart.typ": parstart
#import "common/biography.typ": biography, biography-no-photo

// Calibrated against IEEE_Journal_Paper_Template.pdf the same way as the
// conference constants: these put the title baseline at 77pt and the author
// line at 128pt.
#let title-top-space = 2pt
#let title-author-gap = 7pt

// One column places the title without the float and quantisation the two-column
// path needs, and the reference sits it 8pt higher than the two-column title
// despite an identical top margin, verified from page two's body start. The
// cause is in LaTeX's \@maketitle path for single-column mode and is not
// pinned down, so this is calibrated like the other title-internal gaps.
#let title-top-space-onecolumn = -6pt

// IEEEtran.cls:4955-4959. One-column journal puts 2.5\baselineskip between the
// title block and the text, and \abstract adds a further 0.5 above its centred
// label (5279).
#let title-body-gap = 3 * line-advance
// Space above the centred Index Terms label in one-column mode. The class has
// \addvspace{0.5\baselineskip} here (IEEEtran.cls:5279) but that lands 8pt
// short against the reference, so this is calibrated like the other one-column
// title gaps.
#let index-terms-above = 8pt

// IEEEtran.cls:5277 and 5283. Both label and body are bold, and the journal
// branch adds 1.34ex below the abstract where conference adds nothing.
#let abstract-label = "Abstract"
#let index-terms-label = "Index Terms"
#let ex = 0.448 * sizes.normal.at(0)

// LaTeX's \vspace adds to the baselineskip, which already contains the inter-
// line gap. Typst's v() adds on top of par.spacing instead, so a class value
// carried over directly overshoots by exactly that spacing. Every one of these
// gaps measured 2pt long before this correction, and par.spacing is 1.99pt.
#let vspace(x) = x - leading-for(sizes.normal)

// IEEEtran.cls:5283. The journal branch of \endabstract adds 1.34ex; the
// conference branch adds nothing.
#let abstract-below = vspace(1.34 * ex)

// IEEEtran.cls:5292. \endIEEEkeywords adds 0.67ex below the index terms.
#let index-terms-below = vspace(0.67 * ex)

#let runin-section(label, body) = with-size(
  sizes.small,
  text(weight: "bold")[#text(style: "italic")[#label]---#body],
)

// IEEEtran.cls:5277-5281. In one-column mode the abstract is not run in: the
// label is centred and bold on its own line, and the text follows inside a
// \quotation, indented on both sides. Measured at 35pt in the reference.
#let quotation-indent = 35pt

#let block-section(label, body, above: 0pt) = with-size(sizes.small, {
  block(above: above, below: 0.5 * line-advance, width: 100%)[
    #set align(center)
    #text(weight: "bold", label)
  ]
  pad(left: quotation-indent, right: quotation-indent, body)
})

// The running head is set at 7pt on the text-block width, with the page number
// pushed to the outer edge. Measured at baseline 31pt in the reference.
#let head-size = 7 * (72pt / 72.27)

#let running-head(left-text, right-text) = context {
  let n = counter(page).at(here()).first()
  // IEEE puts the journal line on page one and on versos, and the author line
  // on the remaining rectos.
  let text-for-page = if n == 1 or calc.even(n) { left-text } else { right-text }
  set text(size: head-size)
  block(width: 100%, grid(
    columns: (1fr, auto),
    align(left, text-for-page),
    align(right, [#n]),
  ))
}

#let quantize(body) = context {
  let natural = measure(block(width: text-width, body)).height
  let slots = calc.ceil((natural + vertical.journal.slack) / line-advance)
  block(height: slots * line-advance, body)
}

#let title-block(title, authors) = quantize({
  set align(center)
  v(title-top-space)
  with-size(sizes.huge, title)
  v(title-author-gap)
  with-size(sizes.sublarge, authors)
})

#let ieee-journal(
  paper: "us-letter",
  columns: 2,
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
  show: page-setup.with(mode: "journal", paper: paper, columns: columns)
  show: headings.rules.with(mode: "journal")
  show: floats.rules
  show: elements.rules

  set page(header: running-head(header-left, header-right), header-ascent: 25pt)

  set std.bibliography(title: [References], style: "ieee")

  // With one column there is nothing to span, so the title flows normally and
  // the quantisation that puts two columns on the baseline grid is unnecessary.
  if columns == 1 {
    block(width: 100%, {
      set align(center)
      v(title-top-space-onecolumn)
      with-size(sizes.huge, title)
      v(title-author-gap)
      with-size(sizes.sublarge, authors)
    })
  } else {
    place(
      top,
      scope: "parent",
      float: true,
      clearance: 0pt,
      block(width: 100%, title-block(title, authors)),
    )
  }

  // \thanks notes are footnotes without a marker: IEEEtran.cls:4756-4758 kills
  // \thefootnote and \@makefnmark so the funding note carries no superscript.
  // It must ride inside the first paragraph rather than stand alone, or it forms
  // an empty paragraph of its own and pushes the columns a line down.
  let note = if thanks != none { footnote(numbering: _ => "", thanks) } else { [] }
  let placed = false

  let one-col = columns == 1
  let section-form(label, body, above: 0pt) = if one-col {
    block-section(label, body, above: above)
  } else { runin-section(label, body) }

  if abstract != none {
    section-form(abstract-label, [#note#abstract], above: vspace(title-body-gap))
    v(abstract-below)
    placed = true
  }
  if index-terms != none {
    let lead = if placed { [] } else { note }
    section-form(index-terms-label, [#lead#index-terms], above: index-terms-above)
    v(index-terms-below)
    placed = true
  }
  if not placed { note }

  body

  if bibliography != none {
    // IEEEtran.cls:4492 adds 0.3aselineskip between the References heading
    // and the list.
    heading-below-extra.update(0.3 * line-advance)
    with-size(sizes.footnote, {
      // \IEEEbibitemsep is 0pt (IEEEtran.cls:4484), so entries sit one line
      // apart like any other line. Paragraph spacing has to be dropped to the
      // footnotesize leading or each entry drifts a point from the enclosing
      // body-size spacing.
      set par(spacing: leading-for(sizes.footnote))
      bibliography
    })
    heading-below-extra.update(0pt)
  }
}
