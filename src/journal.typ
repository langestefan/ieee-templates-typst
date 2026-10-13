// Journal layout, ported from IEEEtran.cls V1.8b [journal].
//
// Shares geometry, headings and floats with the conference mode. The
// differences are the running head, a single centred author line instead of
// side-by-side author blocks, and 58 lines per column instead of 56.

#import "common/geometry.typ": (
  leading-for, line-advance, page-setup, quantize, sizes, vertical, with-size,
)
#import "common/authormark.typ": author-mark
#import "common/headings.typ" as headings
#import "common/headings.typ": appendices
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements
#import "common/elements.typ": runin-depth, runin-height, runin-section
#import "common/parstart.typ": parstart
#import "common/runninghead.typ": head-ascent, running-head
#import "common/biography.typ": biography, biography-no-photo

// Calibrated against IEEE_Journal_Paper_Template.pdf the same way as the
// conference constants: these put the title baseline at 77pt and the author
// line at 128pt.
#let title-top-space = 2.62pt
#let title-author-gap = 6.48pt

// One column places the title without the float and quantisation the two-column
// path needs, and the reference sits it 8pt higher than the two-column title
// despite an identical top margin, verified from page two's body start. The
// cause is in LaTeX's \@maketitle path for single-column mode and is not
// pinned down, so this is calibrated like the other title-internal gaps.
#let title-top-space-onecolumn = -5.35pt

// Calibrated to put the technote title baseline at 78pt, as the reference does.
#let technote-title-top = -1.33pt
// IEEEtran.cls:4804-4806 has \vskip 1.3em under the title and nothing explicit
// under the authors; both are calibrated to the reference.
#let technote-title-author-gap = 11.65pt
#let technote-body-gap = 16.34pt

// The peerreview cover sets its abstract closer to the author line than the
// one-column journal does. Calibrated to the reference's 146pt.
#let peerreview-body-gap = 1.5 * line-advance + 0.38pt

// IEEEtran.cls:4955-4959. One-column journal puts 2.5\baselineskip between the
// title block and the text, and \abstract adds a further 0.5 above its centred
// label (5279).
#let title-body-gap = 3 * line-advance + 0.38pt
// Space above the centred Index Terms label in one-column mode. The class has
// \addvspace{0.5\baselineskip} here (IEEEtran.cls:5279) but that lands 8pt
// short against the reference, so this is calibrated like the other one-column
// title gaps.
#let index-terms-above = 7.84pt

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

// The skips around the abstract are taken in the font in force there, 9pt
// Times Bold, whose x-height is 0.461em.
#let ex-abstract = 0.461 * sizes.small.at(0)

// IEEEtran.cls:5283. The journal branch of \endabstract adds 1.34ex; the
// conference branch adds nothing. The index terms that follow are set on the
// 9pt advance, so the leading that vspace() takes out is put back at that size.
#let abstract-below = vspace(1.34 * ex-abstract) + leading-for(sizes.small)

// IEEEtran.cls:5292. \endIEEEkeywords adds 0.67ex below the index terms, or
// 1.34ex in a technote, in the 9pt font still in force there. Not passed through vspace(): what follows
// is normally a heading, whose own space above already stands in for the
// paragraph spacing.
#let index-terms-below(technote) = (
  (if technote { 1.34 } else { 0.67 }) * ex-abstract + runin-depth()
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

#let title-block(title, authors) = quantize(vertical.journal.slack, {
  set align(center)
  v(title-top-space)
  with-size(sizes.huge, title)
  v(title-author-gap)
  with-size(sizes.sublarge, authors)
})

// IEEEtran.cls:4922-4926. Under peerreview the title block becomes a cover
// page of its own and \IEEEpeerreviewmaketitle then repeats the title, without
// the authors, at the head of the body. The point is double-blind review: the
// cover carries the identifying material and can be removed.
//
// IEEEtran.cls:4941 sets the repeated title in \Huge, like a journal title.
#let peerreview-title(title) = {
  set align(center)
  v(title-top-space)
  with-size(sizes.huge, title)
  v(title-author-gap)
}

// IEEEtran.cls:4804-4806. A technote puts its title in the first column rather
// than spanning both, and sets it \large bold rather than \Huge, with the
// author line following at body size after 1.3em.
#let technote-title(title, authors) = {
  set align(center)
  v(technote-title-top)
  with-size(sizes.large, text(weight: "bold", title))
  v(technote-title-author-gap)
  // \@IEEEauthordefaulttextstyle is \normalfont\sublargesize
  // (IEEEtran.cls:4555), so the author line is 11pt. Its advance stays at the
  // body's 12 TeX pt though, not sublargesize's 13.4: the reference measures
  // 12 between the two author lines.
  with-size((sizes.sublarge.at(0), sizes.normal.at(1)), authors)
  v(technote-body-gap)
}

#let ieee-journal(
  paper: "us-letter",
  pt: "10pt",
  columns: 2,
  peerreview: false,
  technote: false,
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
  show: page-setup.with(mode: "journal", paper: paper, columns: columns, pt: pt)
  show: headings.rules.with(mode: "journal")
  show: floats.rules
  show: elements.rules
  show: headings.bibliography-rules

  set page(
    header: running-head(header-left, header-right, twoside: twoside),
    header-ascent: head-ascent,
  )

  // A technote keeps its title inside the first column, so like the one-column
  // case it needs neither the float nor the quantisation.
  if technote {
    technote-title(title, authors)
  } else if peerreview {
    // IEEEtran.cls:4766 does not wrap the peerreview title in \twocolumn, so
    // the cover page is single column, and it carries no running head. The
    // abstract and index terms therefore take their block form, label centred
    // above indented text, and sit on the cover rather than in the body.
    page(columns: 1, header: none, {
      // The cover is page 0, so the paper proper starts on page 1
      // (IEEEtran.cls:5639-5643).
      counter(page).update(0)
      set align(center)
      v(title-top-space-onecolumn)
      with-size(sizes.huge, title)
      v(title-author-gap)
      with-size(sizes.sublarge, authors)
      set align(left)
      if abstract != none {
        block-section(
          abstract-label,
          abstract,
          above: vspace(peerreview-body-gap),
        )
        v(abstract-below)
      }
      if index-terms != none {
        block-section(index-terms-label, index-terms, above: index-terms-above)
      }
      elements.placed-thanks-note(thanks)
    })
    block(width: 100%, peerreview-title(title))
  } else if columns == 1 {
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

  // Already emitted on the cover page.
  let (abstract, index-terms, thanks) = if peerreview { (none,) * 3 } else {
    (abstract, index-terms, thanks)
  }

  // The note must ride inside the first paragraph rather than stand alone, or
  // it forms an empty paragraph of its own and pushes the columns a line down.
  let note = elements.thanks-note(thanks)
  let placed = false

  let one-col = columns == 1
  // Only where the run-in sections open a column, under the spanning title.
  if (
    not one-col and not technote and (abstract != none or index-terms != none)
  ) {
    v(runin-height())
  }
  let section-form(label, body, above: 0pt) = if one-col {
    block-section(label, body, above: above)
  } else { runin-section(label, body) }

  if abstract != none {
    section-form(
      abstract-label,
      [#note#abstract],
      above: vspace(title-body-gap),
    )
    v(abstract-below)
    placed = true
  }
  if index-terms != none {
    let lead = if placed { [] } else { note }
    section-form(
      index-terms-label,
      [#lead#index-terms],
      above: index-terms-above,
    )
    v(index-terms-below(technote))
    placed = true
  }
  if not placed { note }

  body

  // A convenience for the common case. Documents that need the list elsewhere
  // write #bibliography(..) into the body instead; it is styled either way.
  if bibliography != none { bibliography }
}
