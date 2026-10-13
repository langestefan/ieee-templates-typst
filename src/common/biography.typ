// Author biographies, ported from IEEEtran.cls:5982-6070.
//
// A biography is a photo box with the text set beside it, the author's name
// leading the first line in bold. Without a photo the text simply runs full
// width under a bold name.

#import "geometry.typ": leading-for, sizes as default-sizes, with-size
#import "textsplit.typ": as-text, split-at-height

// IEEEtran.cls:5982-5983 and 5989.
#let photo-width = 1.0in
#let photo-depth = 1.25in
#let bio-skip-lines = 4

// The skip above a biography is 4\baselineskip plus 1fil, taken at the
// biography's own size. The fil means biographies share out whatever is left of
// the column between them; the layouts end the document with a matching
// v(1fr), as LaTeX ends its last page with \vfil.
//
// A biography that does not fit moves to the next column and leaves the skip
// behind, which matches TeX discarding glue at a break. Weak spacing would do
// that more directly, but Typst drops a weak v() next to a fractional one.
//
// Two corrections make a biography line stand in for a body line at the ends
// of a column, where TeX works from baselines and Typst from line boxes.
// `rise` goes above: a column's first baseline is on the body grid whatever
// the size of the line. `drop` goes below: its last baseline is the last body
// baseline, which Typst leaves a leading short of the bottom.
#let bio-rise(text-size, body) = 0.7 * (body.at(0) - text-size.at(0))
#let bio-drop(text-size, body) = (
  0.3 * (body.at(0) - text-size.at(0)) + leading-for(body)
)
#let bio-skip(text-size, body) = {
  v(
    bio-skip-lines * text-size.at(1)
      + leading-for(text-size)
      - bio-rise(text-size, body)
      - bio-drop(text-size, body),
  )
  v(1fr)
}

// IEEEtran.cls:6038-6042. The text runs beside the photo for one line more
// than the photo's depth holds.
#let hang-lines(text-size) = calc.floor(photo-depth / text-size.at(1)) + 1

// IEEEtran.cls:6057-6062. A biography shorter than that is padded with a
// strut to two lines short of it, set below the depth of the last line of
// text. Times descends 0.217em. The last 2.5pt is calibrated.
#let reserved-height(text-size) = (
  (0.7 + 0.217) * text-size.at(0)
    + (hang-lines(text-size) - 2) * text-size.at(1)
    + 2.5pt
)

// IEEEtran.cls:6006. The placeholder shown when no photo is supplied.
#let photo-placeholder = align(
  center,
)[PLACE #linebreak() PHOTO #linebreak() HERE]

#let photo-gap = 1em

// IEEEtran.cls:6005-6011. The placeholder is drawn in a \framebox with
// \fboxsep set to 0pt, so the rule hugs the box with no padding. A supplied
// photo goes in a plain \mbox instead and gets no frame.
//
// IEEEtran.cls:6044-6048 hangs the photo from the top of a capital T on the
// first line, and gives it no height of its own: the space it needs comes from
// the text beside it, or the strut when that is short.
#let photo-box(photo, text-size) = box(
  height: reserved-height(text-size),
  move(dy: (0.7 - 0.662) * text-size.at(0), if photo == none {
    rect(
      width: photo-width,
      height: photo-depth,
      inset: 0pt,
      stroke: 0.4pt,
      with-size(text-size, align(horizon + center, photo-placeholder)),
    )
  } else {
    box(width: photo-width, height: photo-depth, photo)
  }),
)

// `text-size` and `body` default to the 10pt Times ladder; Computer Society
// papers pass their own.
#let biography(
  name: [],
  photo: none,
  text-size: default-sizes.footnote,
  body: default-sizes.normal,
  content,
) = {
  bio-skip(text-size, body)
  with-size(text-size, layout(size => {
    let lead = text(weight: "bold", name)
    let full = as-text(content)
    let indent-width = size.width - photo-width - photo-gap

    // The name leads the same paragraph, so it is measured with each candidate
    // split rather than after the fact.
    let (head, rest) = split-at-height(
      full,
      indent-width,
      text-size.at(0) + (hang-lines(text-size) - 1) * text-size.at(1) + 0.5pt,
      prefix: lead,
    )

    // A grid rather than a placed box: the row takes the height of whichever is
    // taller, so a short biography still reserves the photo's depth and the
    // next one does not run over the frame.
    pad(
      top: bio-rise(text-size, body),
      bottom: if rest == "" { bio-drop(text-size, body) } else { 0pt },
      grid(
        columns: (photo-width, 1fr),
        column-gutter: photo-gap,
        photo-box(photo, text-size),
        par(first-line-indent: 0pt, justify: true)[#lead #head],
      ),
    )
    if rest != "" {
      pad(bottom: bio-drop(text-size, body), par(
        first-line-indent: 0pt,
        justify: true,
        rest,
      ))
    }
  }))
}

// IEEEtran.cls:6065. Same thing without the photo area.
#let biography-no-photo(
  name: [],
  text-size: default-sizes.footnote,
  body: default-sizes.normal,
  content,
) = {
  bio-skip(text-size, body)
  with-size(text-size, pad(
    top: bio-rise(text-size, body),
    bottom: bio-drop(text-size, body),
    par(
      first-line-indent: 0pt,
      justify: true,
    )[#text(weight: "bold", name) #content],
  ))
}
