// Conference layout, ported from IEEEtran.cls V1.8b [conference].

#import "common/geometry.typ": (
  em-box, line-advance, page-setup, par-indent, sizes, text-width, tpc, tpt,
  with-size,
)
#import "common/headings.typ" as headings

// Space above the title and between the title and the author blocks. The class
// specifies 0.5\baselineskip (IEEEtran.cls:4748) and \vskip1.0em (4809), but
// those are measured against TeX's \topskip rule for the first line of a box,
// which Typst has no equivalent of. These are calibrated to put the title
// baseline at 71pt and the author names at 131pt, matching the reference.
#let title-top-space = 2pt
#let title-author-gap = 15pt

// IEEEtran.cls:5277. The abstract label is bold italic, but \bfseries is not
// scoped, so the dash and the whole abstract body are bold as well. The
// reference render confirms it: NimbusRomNo9L-Medi throughout.
#let abstract-label = "Abstract"
#let index-terms-label = "Index Terms"

#let runin-section(label, body) = with-size(
  sizes.small,
  text(weight: "bold")[#text(style: "italic")[#label]---#body],
)

// Author fields accept either content or an array of lines. The array form
// mirrors the \\ separators in \IEEEauthorblockA and avoids escaping trouble,
// since an unescaped @ in markup would parse as a reference and a bare URL
// would autolink.
#let as-lines(x) = {
  if type(x) == array { x.map(l => [#l]).join(linebreak()) } else { x }
}

// Author blocks sit in a row of naturally sized cells separated by equal glue,
// which is what \IEEEauthorblock produces. Equal-width columns would place them
// differently: the reference centres block one at x=154, not at the 134.7 an
// even three-way split would give.
#let author-row(authors) = block(width: 100%, grid(
  columns: (auto,) * authors.len(),
  column-gutter: 1fr,
  ..authors.map(a => align(
    center,
    {
      with-size(sizes.sublarge, as-lines(a.at("name", default: [])))
      let aff = a.at("affiliation", default: none)
      if aff != none { with-size(sizes.normal, as-lines(aff)) }
    },
  ))
))

// Slack added below the author blocks before quantising. IEEEtran.cls:4969-4974
// specifies 1\baselineskip for conference mode, but that lands the columns two
// lines high against the reference. The shortfall is internal author-block
// spacing that IEEEtran adds and this port does not yet model, so the value is
// calibrated rather than derived: 2.5 reproduces the reference exactly.
#let title-slack = 2.5 * line-advance

// IEEEtran.cls:4772 wraps the title in \IEEEquantizevspace, which rounds the
// whole block to a whole number of body lines so the columns below start on the
// baseline grid. Without this the abstract sits off-grid and every following
// line inherits the error.
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
  author-row(authors)
})

#let ieee-conference(
  title: [],
  authors: (),
  abstract: none,
  index-terms: none,
  bibliography: none,
  body,
) = {
  show: page-setup.with(mode: "conference")
  show: headings.rules

  // The title spans both columns; everything after it flows in the columns.
  // clearance must be zero: the quantised block height is what puts the columns
  // on the baseline grid, and any float clearance on top of it breaks that.
  place(
    top,
    scope: "parent",
    float: true,
    clearance: 0pt,
    block(width: 100%, title-block(title, authors)),
  )

  if abstract != none { runin-section(abstract-label, abstract) }
  if index-terms != none { runin-section(index-terms-label, index-terms) }

  body

  if bibliography != none { bibliography }
}
