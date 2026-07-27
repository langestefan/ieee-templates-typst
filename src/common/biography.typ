// Author biographies, ported from IEEEtran.cls:5982-6070.
//
// A biography is a photo box with the text set beside it, the author's name
// leading the first line in bold. Without a photo the text simply runs full
// width under a bold name.

#import "geometry.typ": line-advance, sizes, with-size
#import "textsplit.typ": as-text, split-at-height

// IEEEtran.cls:5982-5983 and 5989.
#let photo-width = 1.0in
#let photo-depth = 1.25in
#let bio-skip = 4 * line-advance

// IEEEtran.cls:6006. The placeholder shown when no photo is supplied.
#let photo-placeholder = align(center)[PLACE #linebreak() PHOTO #linebreak() HERE]

#let photo-gap = 1em

// IEEEtran.cls:6005-6011. The placeholder is drawn in a \framebox with
// \fboxsep set to 0pt, so the rule hugs the box with no padding. A supplied
// photo goes in a plain \mbox instead and gets no frame.
#let photo-box(photo) = if photo == none {
  rect(
    width: photo-width,
    height: photo-depth,
    inset: 0pt,
    stroke: 0.4pt,
    with-size(sizes.footnote, align(horizon + center, photo-placeholder)),
  )
} else {
  box(width: photo-width, height: photo-depth, photo)
}

#let biography(name: [], photo: none, body) = context {
  v(bio-skip)
  with-size(sizes.footnote, layout(size => {
    let lead = text(weight: "bold", name)
    let full = as-text(body)
    let indent-width = size.width - photo-width - photo-gap

    // The name leads the same paragraph, so it is measured with each candidate
    // split rather than after the fact.
    let (head, rest) = split-at-height(
      full,
      indent-width,
      photo-depth,
      prefix: lead,
    )

    // A grid rather than a placed box: the row takes the height of whichever is
    // taller, so a short biography still reserves the photo's full depth and
    // the next one does not run over the frame.
    grid(
      columns: (photo-width, 1fr),
      column-gutter: photo-gap,
      photo-box(photo),
      par(first-line-indent: 0pt, justify: true)[#lead #head],
    )
    if rest != "" { par(first-line-indent: 0pt, justify: true, rest) }
  }))
}

// IEEEtran.cls:6065. Same thing without the photo area.
#let biography-no-photo(name: [], body) = {
  v(bio-skip)
  with-size(
    sizes.footnote,
    par(
      first-line-indent: 0pt,
      justify: true,
    )[#text(weight: "bold", name) #body],
  )
}
