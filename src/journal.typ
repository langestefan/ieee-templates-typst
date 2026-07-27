// Journal layout, ported from IEEEtran.cls V1.8b [journal].
//
// Shares geometry, headings and floats with the conference mode. The
// differences are the running head, a single centred author line instead of
// side-by-side author blocks, and 58 lines per column instead of 56.

#import "common/geometry.typ": (
  line-advance, margin-side, page-setup, sizes, text-width, vertical, with-size,
)
#import "common/headings.typ" as headings
#import "common/floats.typ" as floats

// Calibrated against IEEE_Journal_Paper_Template.pdf the same way as the
// conference constants: these put the title baseline at 77pt and the author
// line at 128pt.
#let title-top-space = 2pt
#let title-author-gap = 8pt

// Slack below the author line before quantising. IEEEtran.cls:4969 specifies
// 2.5\baselineskip for journal mode; 3 is what actually lands the abstract on
// body grid slot 10 at 184pt, matching the reference. Same kind of shortfall as
// in the conference mode, where the class value is also a slot short.
#let title-slack = 3 * line-advance

// IEEEtran.cls:5277 and 5283. Both label and body are bold, and the journal
// branch adds 1.34ex below the abstract where conference adds nothing.
#let abstract-label = "Abstract"
#let index-terms-label = "Index Terms"
#let ex = 0.448 * sizes.normal.at(0)
#let abstract-below = 1.34 * ex
// IEEEtran.cls:5292. \endIEEEkeywords adds 0.67ex below the index terms.
#let index-terms-below = 0.67 * ex

#let runin-section(label, body) = with-size(
  sizes.small,
  text(weight: "bold")[#text(style: "italic")[#label]---#body],
)

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
  let slots = calc.ceil((natural + title-slack) / line-advance)
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
  title: [],
  authors: [],
  header-left: [],
  header-right: [],
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(mode: "journal")
  show: headings.rules
  show: floats.rules

  set page(header: running-head(header-left, header-right), header-ascent: 25pt)

  set std.bibliography(title: [References], style: "ieee")

  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, title-block(title, authors)),
  )

  if abstract != none {
    runin-section(abstract-label, abstract)
    v(abstract-below)
  }
  if index-terms != none {
    runin-section(index-terms-label, index-terms)
    v(index-terms-below)
  }

  body

  if bibliography != none { with-size(sizes.footnote, bibliography) }
}
