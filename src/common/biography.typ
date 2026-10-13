// Author biographies, ported from IEEEtran.cls:5982-6070.
//
// A biography is a photo box with the text set beside it, the author's name
// leading the first line in bold. Without a photo the text simply runs full
// width under a bold name.

#import "geometry.typ": ladder-state, leading-for, tpt, with-size
#import "textsplit.typ": split-at-height, words

// IEEEtran.cls:5982-5983 and 5989.
#let photo-width = 1.0in
#let photo-depth = 1.25in
#let bio-skip-lines = 4

// The skip above a biography is 4\baselineskip plus 1fil, taken at the
// biography's own size. The fil means biographies share out whatever is left of
// the column between them; the layouts end the document with a matching
// v(1fr), as LaTeX ends its last page with \vfil.
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
#let bio-skip-fixed(text-size, body) = (
  bio-skip-lines * text-size.at(1)
    + leading-for(text-size)
    - bio-rise(text-size, body)
    - bio-drop(text-size, body)
)

// The fixed part allows for the `drop` under a biography before it. The first
// one follows the reference list instead, which has no such padding and which
// \endlist closes with \topsep, 2pt in a first-level list (IEEEtran.cls:1978).
#let after-bio = state("ieee-after-biography", false)
#let list-topsep = 2 * tpt
// How far Times descends, as elsewhere in this file.
#let descent = 0.217

// TeX discards the skip when the biography opens a column. Typst keeps a v()
// there, and drops a weak one next to a fractional one, so the skip is left
// out by hand. An empty block as tall as the room the biography needs goes
// first and is then backed over: it moves to the next column when that much
// does not fit, and the biography follows it. A mark placed at the top of the
// column tells whether the block opens it.
//
// With a photo, `need` is what \@IEEEtranneedspace asks for at
// IEEEtran.cls:5997-6001, and the \newpage it issues leaves a \vfil behind
// (5957-5961), which the fractional space left in the old column stands for.
// TeX takes the room left from the depth of the line above, and from a page
// goal that counts the depth of the last footnote line, 0.3 of its advance.
// The block allows for that depth whether or not the page has notes, so on a
// page without them a biography moves on up to 2.7pt sooner than in TeX.
//
// Without a photo the class breaks where TeX would anyway and leaves nothing
// behind, so the fractional space is weak and goes with the break.
#let bio-skip(text-size, body, need: none) = {
  let (size, advance) = text-size
  let first = not after-bio.get()
  let fixed = (
    bio-skip-fixed(text-size, body)
      + if first { bio-drop(text-size, body) + list-topsep } else { 0pt }
  )
  let room = if need == none { fixed + advance } else {
    (
      need
        + 0.3 * advance
        + if first {
          bio-drop(text-size, body) + list-topsep + descent * size
        } else { 0pt }
    )
  }
  v(1fr, weak: need == none)
  block(height: room, spacing: 0pt, breakable: false)[#metadata(
    none,
  )<ieee-bio-probe>]
  place(top)[#metadata(none)<ieee-bio-top>]
  v(-room)
  context {
    let at(mark) = query(selector(mark).before(here()))
      .last()
      .location()
      .position()
    let (probe, top) = (at(<ieee-bio-probe>), at(<ieee-bio-top>))
    let opens = probe.page == top.page and calc.abs(probe.y - top.y) < 0.1pt
    if not opens { v(fixed) }
  }
  after-bio.update(true)
}

// IEEEtran.cls:6038-6042. The text runs beside the photo for one line more
// than the photo's depth holds.
#let hang-lines(text-size) = calc.floor(photo-depth / text-size.at(1)) + 1

// IEEEtran.cls:6057-6062. A biography shorter than that is padded with a
// strut to two lines short of it, set below the depth of the last line of
// text. Times descends 0.217em. The last 2.5pt is calibrated.
#let reserved-height(text-size) = (
  (0.7 + descent) * text-size.at(0)
    + (hang-lines(text-size) - 2) * text-size.at(1)
    + 2.5pt
)

// IEEEtran.cls:6006. The placeholder shown when no photo is supplied.
#let cap-height(size) = {
  measure(text(
    size: size,
    top-edge: "cap-height",
    bottom-edge: "baseline",
  )[T]).height
}

// The minipage centres the three lines from the top of the first capital to
// the last baseline. Typst centres their line boxes, which reach 0.7em above
// the first baseline and 0.3em below the last, so the text is moved down by
// the difference.
#let photo-placeholder = context {
  move(dy: cap-height(1em) / 2 - 0.2em, align(
    center,
  )[PLACE #linebreak() PHOTO #linebreak() HERE])
}

// IEEEtran.cls:5996. The text hangs 1.14in in, clear of the 1in photo.
#let photo-gap = 1.14in - photo-width

// IEEEtran.cls:6005-6011. The placeholder is drawn in a \framebox with
// \fboxsep set to 0pt, so the rule hugs the box with no padding. A supplied
// photo goes in a plain \mbox instead and gets no frame.
//
// IEEEtran.cls:6044-6048 hangs the photo from the top of a capital T on the
// first line, and gives it no height of its own: the space it needs comes from
// the text beside it, or the strut when that is short.
#let photo-box(photo, text-size) = context box(
  height: reserved-height(text-size),
  move(dy: 0.7 * text-size.at(0) - cap-height(text-size.at(0)), if photo
    == none {
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

// `text-size` and `body` default to the ladder the layout was given; Computer
// Society papers pass their own.
#let biography(
  name: [],
  photo: none,
  text-size: auto,
  body: auto,
  content,
) = context {
  let ladder = ladder-state.get()
  let text-size = if text-size == auto { ladder.footnote } else { text-size }
  let body = if body == auto { ladder.normal } else { body }
  bio-skip(
    text-size,
    body,
    need: photo-depth + (bio-skip-lines + 1) * text-size.at(1),
  )
  with-size(text-size, layout(size => {
    let lead = strong(name)
    let indent-width = size.width - photo-width - photo-gap

    // The name leads the same paragraph, so it is measured with each candidate
    // split rather than after the fact.
    let (head, rest) = split-at-height(
      words(content),
      indent-width,
      text-size.at(0) + (hang-lines(text-size) - 1) * text-size.at(1) + 0.5pt,
      prefix: lead,
      indent: par.first-line-indent.amount,
    )

    // A grid rather than a placed box: the row takes the height of whichever is
    // taller, so a short biography still reserves the photo's depth and the
    // next one does not run over the frame.
    pad(
      top: bio-rise(text-size, body),
      bottom: if rest == none { bio-drop(text-size, body) } else { 0pt },
      grid(
        columns: (photo-width, 1fr),
        column-gutter: photo-gap,
        photo-box(photo, text-size),
        par(first-line-indent: 0pt, justify: true)[#lead #head],
      ),
    )
    if rest != none {
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
  text-size: auto,
  body: auto,
  content,
) = context {
  let ladder = ladder-state.get()
  let text-size = if text-size == auto { ladder.footnote } else { text-size }
  let body = if body == auto { ladder.normal } else { body }
  bio-skip(text-size, body)
  with-size(text-size, pad(
    top: bio-rise(text-size, body),
    bottom: bio-drop(text-size, body),
    par(
      first-line-indent: 0pt,
      justify: true,
    )[#strong(name) #content],
  ))
}
