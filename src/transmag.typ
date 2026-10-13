// IEEE Transactions on Magnetics layout, ported from IEEEtran.cls V1.8b
// [journal,transmag].
//
// Shares the journal's page geometry, headings, floats and running head. The
// differences are all in the title area:
//
//   - the title is \LARGE bold rather than \Huge (IEEEtran.cls:4808)
//   - author marks are plain superscript numbers, not symbols (4540)
//   - each affiliation is its own centred line, keyed by mark, rather than
//     side-by-side author blocks
//   - the abstract and index terms sit full width inside the title block via
//     \IEEEtitleabstractindextext (5243), not in the first column
//   - the abstract carries no "Abstract—" label; the class comment at 5331
//     reads "no abstract name, use indentation" (1em, bold)

#import "common/geometry.typ": (
  ex, line-advance, page-setup, quantize, sizes, tpt, vspace, with-size,
)
#import "common/authorblocks.typ": as-lines
#import "common/headings.typ" as headings
#import "common/headings.typ": appendices
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements
#import "common/parstart.typ": parstart
#import "common/runninghead.typ": head-ascent, running-head
#import "common/biography.typ": biography, biography-no-photo

// IEEEtran.cls:4808. \LARGE bold, where plain journal uses \Huge.
#let title-size = (17 * tpt, 20 * tpt)

// Calibrated the same way as the other title-internal gaps, to put the title
// baseline at 72pt and the author names at 123pt.
#let title-top-space = 2.86pt
#let title-author-gap = 16.64pt

// IEEEtran.cls:4584. Affiliation lines advance 2.75ex, as in conference mode.
#let affiliation-advance = 2.75 * ex
// Calibrated, as in conference mode: the first affiliation line sits this much
// further below the author line than the paragraph spacing alone gives.
#let author-aff-gap = 0.23pt

// Space from the last affiliation to the abstract, and from the abstract to the
// index terms. Calibrated against the reference.
#let abstract-above = 18.77pt
#let index-terms-above = 16.49pt

#let index-terms-label = "Index Terms"
// Slack below the title block before quantising, as in geometry.typ's
// slack-lines. transmag carries the abstract and index terms inside the title block,
// so its natural height is larger and the journal's 3 advances overshoot by a
// slot. Valid range measured against the reference is (1.5, 3.0); 2.25 is the
// midpoint.
#let title-slack = 2.25 * line-advance

// The affiliation mark is a plain superscript number in transmag
// (IEEEtran.cls:4540-4541), unlike the symbol sequence used elsewhere.
// \textsuperscript{\footnotesize n}: raised, but still at footnotesize.
// Typst's super() shrinks whatever it is given, so size must be pinned to 1em
// of the surrounding footnote size or the mark comes out at 4.8pt instead of 8.
//
// TeX raises a superscript by an amount taken from the font around it, not
// from the mark's own, so a mark on the 11pt author line sits higher than one
// on a 10pt affiliation line. Measured at 0.363 of the surrounding size in
// both places.
#let mark-raise = 0.363
#let mark(n) = context {
  let raise = mark-raise * text.size
  text(
    size: sizes.footnote.at(0),
    super(typographic: false, size: 1em, baseline: -raise, [#n]),
  )
}

#let title-block(title, authors, affiliations, abstract, index-terms, note) = {
  set align(center)
  v(title-top-space)
  with-size(title-size, text(weight: "bold", title))
  v(title-author-gap)
  // \thanks lives inside \author in the class, so the marker rides with the
  // author line. Emitting it on its own would form an empty paragraph and push
  // the whole title block down a quantisation slot.
  with-size(sizes.sublarge, [#as-lines(authors)#note])

  // Affiliations are numbered lines, one per organisation.
  v(author-aff-gap)
  with-size((sizes.normal.at(0), affiliation-advance), {
    for (i, a) in affiliations.enumerate() {
      [#mark(i + 1)#a]
      if i + 1 < affiliations.len() { linebreak() }
    }
  })

  // Abstract and index terms belong to the title block here, set full width and
  // flush left rather than centred.
  set align(left)
  if abstract != none {
    v(vspace(abstract-above))
    with-size(sizes.small, {
      set par(first-line-indent: (amount: 1em, all: true))
      text(weight: "bold", abstract)
    })
  }
  if index-terms != none {
    v(vspace(index-terms-above))
    with-size(sizes.small, {
      set par(first-line-indent: (amount: 1em, all: true))
      text(weight: "bold")[#text(
          style: "italic",
        )[#index-terms-label]---#index-terms]
    })
  }
}


#let ieee-transmag(
  paper: "us-letter",
  title: [],
  authors: [],
  affiliations: (),
  header-left: [],
  header-right: [],
  twoside: false,
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(mode: "journal", paper: paper)
  show: headings.rules.with(mode: "transmag")
  show: floats.rules
  show: elements.rules
  show: headings.bibliography-rules

  set page(
    header: running-head(header-left, header-right, twoside: twoside),
    header-ascent: head-ascent,
  )
  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, quantize(title-slack, title-block(
      title,
      authors,
      affiliations,
      abstract,
      index-terms,
      [],
    ))),
  )

  // \thanks sits inside \author in the class, but it cannot ride with the
  // author line here because the title block is a float.
  elements.placed-thanks-note(thanks)

  body

  // A convenience for the common case. Documents that need the list elsewhere
  // write #bibliography(..) into the body instead; it is styled either way.
  if bibliography != none { bibliography }

  // Closes the last column the way LaTeX's final \vfil does, so biographies
  // spread down it. Without any, it has no effect.
  v(1fr)
}
