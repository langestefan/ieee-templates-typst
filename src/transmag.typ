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
  leading-for, line-advance, page-setup, sizes, text-width, tpt, vertical,
  with-size,
)
#import "common/headings.typ" as headings
#import "common/headings.typ": appendices, heading-below-extra
#import "common/floats.typ" as floats
#import "common/elements.typ" as elements
#import "common/parstart.typ": parstart
#import "common/runninghead.typ": running-head
#import "common/biography.typ": biography, biography-no-photo

#let ex = 0.448 * sizes.normal.at(0)
#let vspace(x) = x - leading-for(sizes.normal)

// IEEEtran.cls:4808. \LARGE bold, where plain journal uses \Huge.
#let title-size = (17 * tpt, 20 * tpt)

// Calibrated the same way as the other title-internal gaps, to put the title
// baseline at 72pt and the author names at 123pt.
#let title-top-space = 2pt
#let title-author-gap = 17pt

// IEEEtran.cls:4584. Affiliation lines advance 2.75ex, as in conference mode.
#let affiliation-advance = 2.75 * ex

// Space from the last affiliation to the abstract, and from the abstract to the
// index terms. Calibrated against the reference.
#let abstract-above = 19pt
#let index-terms-above = 16pt

#let index-terms-label = "Index Terms"
// Slack below the title block before quantising, as in geometry.typ's vertical
// table. transmag carries the abstract and index terms inside the title block,
// so its natural height is larger and the journal's 3 advances overshoot by a
// slot. Valid range measured against the reference is (1.5, 3.0); 2.25 is the
// midpoint.
#let title-slack = 2.25 * line-advance

// The affiliation mark is a plain superscript number in transmag
// (IEEEtran.cls:4540-4541), unlike the symbol sequence used elsewhere.
// \textsuperscript{\footnotesize n}: raised, but still at footnotesize.
// Typst's super() shrinks whatever it is given, so size must be pinned to 1em
// of the surrounding footnote size or the mark comes out at 4.8pt instead of 8.
#let mark(n) = text(
  size: sizes.footnote.at(0),
  super(typographic: false, size: 1em, baseline: -0.4em, [#n]),
)

#let as-lines(x) = {
  if type(x) == array { x.map(l => [#l]).join(linebreak()) } else { x }
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


#let quantize(body) = context {
  let natural = measure(block(width: text-width, body)).height
  let slots = calc.ceil((natural + title-slack) / line-advance)
  // width must be explicit: without it the block shrinks to its content and
  // `set align(center)` inside then centres against that narrower box rather
  // than the full text width.
  block(height: slots * line-advance, width: 100%, body)
}

#let ieee-transmag(
  paper: "us-letter",
  title: [],
  authors: [],
  affiliations: (),
  header-left: [],
  header-right: [],
  thanks: none,
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(mode: "journal", paper: paper)
  show: headings.rules.with(mode: "journal")
  show: floats.rules
  show: elements.rules

  set page(header: running-head(header-left, header-right), header-ascent: 25pt)
  set std.bibliography(title: [References], style: "ieee")

  // A show rule rather than styling a trailing parameter, so the reference list
  // can sit wherever the document puts it. Journals need it before the author
  // biographies, which the old "emit it last" arrangement made impossible.
  show std.bibliography: it => {
    heading-below-extra.update(0.25 * line-advance)
    with-size(sizes.footnote, {
      // \IEEEbibitemsep is 0pt (IEEEtran.cls:4484), so entries sit one line
      // apart like any other line.
      set par(spacing: leading-for(sizes.footnote))
      it
    })
    heading-below-extra.update(0pt)
  }

  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, quantize(title-block(
      title,
      authors,
      affiliations,
      abstract,
      index-terms,
      [],
    ))),
  )

  // \thanks sits inside \author in the class, but a footnote inside
  // place(float: true) never registers, so it cannot ride with the author line
  // here. Emitting it in the column flow instead registers it but forms an empty
  // paragraph that pushes the first section down 29pt. Wrapping it in a
  // non-floating place() registers the footnote while taking no flow space.
  if thanks != none {
    place(top + left, box(footnote(numbering: _ => "", thanks)))
  }

  body

  // Emitting it here is a convenience for the common case. Documents that need
  // it elsewhere, such as a journal placing it before the biographies, can drop
  // the argument and write #bibliography(..) into the body instead; the show
  // rule above styles it either way.
  if bibliography != none { bibliography }
}
