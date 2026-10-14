// \IEEEPARstart, the two-line drop cap opening a journal paper.
// Ported from IEEEtran.cls:5815-5830.

#import "geometry.typ": ladder-state
#import "textsplit.typ": plain, split-at-height, words

// IEEEtran.cls:5824. The letter is lowered this far below the first baseline,
// and its height is that depth plus the cap height of the body font.
#let drop-lines = 2

// IEEEtran.cls:5873-5874. The letter is to be as tall as a capital of the body
// font plus the drop depth. This is that capital's height in em, for Times.
#let cap-ratio = 0.662

// IEEEtran.cls:5833 sets the letter in bold, and 5882-5905 scales it until the
// bold letter reaches the height above. The class reads that letter's height
// from the font metrics TeX carries, where Times Bold capitals come to 0.671em
// by the size of the reference's letter; the outline itself is 0.676em.
#let bold-cap-ratio = 0.671

// IEEEtran.cls:5846. \IEEEPARstartSEP, the gap between the letter and the text
// beside it, in em of the body font.
#let cap-gap-em = 0.15

// `advance` and `body-size` default to the ladder the layout was given.
// Computer Society papers pass their own: 9.5bp Palatino on 11.54bp, where the
// Times ladder would size the cap for the wrong body.
//
// `weight` is the letter's, `cap` the height of a body capital in em, and
// `letter-cap` that of the letter in its own weight.
#let parstart(
  body,
  advance: auto,
  body-size: auto,
  weight: "bold",
  cap: cap-ratio,
  letter-cap: bold-cap-ratio,
) = context {
  let normal = ladder-state.get().normal
  let base = if body-size == auto { normal.at(0) } else { body-size }
  let advance = if advance == auto { normal.at(1) } else { advance }
  let drop-depth = 1.1 * advance
  let cap-size = (drop-depth + cap * base) / letter-cap
  let cap-gap = cap-gap-em * base
  let ws = words(body)
  // Only the first word is reduced to plain text, to take its first letter.
  let first = if ws.len() == 0 { "" } else { plain(ws.first().body) }
  if first == "" { return body }

  let letter = first.clusters().first()
  // IEEEtran renders the remainder of the first word in upper case.
  let word-rest = upper(first.slice(letter.len()))
  let opening = if word-rest == "" { ws.slice(1) } else {
    ((sep: "", body: word-rest),) + ws.slice(1)
  }

  // The cap must carry its own edges. Modes that pin top-edge as an absolute
  // length, as the Computer Society layouts do, would otherwise give this 28pt
  // letter the body's 6.65pt edge and place it on the first line instead of the
  // second.
  let cap = text(
    size: cap-size,
    weight: weight,
    top-edge: 0.7 * cap-size,
    bottom-edge: -0.3 * cap-size,
    letter,
  )
  let cap-width = measure(cap).width

  layout(size => {
    let indent-width = size.width - cap-width - cap-gap
    let line-h = measure(block(width: indent-width, "M")).height
    let limit = line-h + (drop-lines - 1) * advance + 0.5pt
    let (head, rest) = split-at-height(
      opening,
      indent-width,
      limit,
      indent: par.first-line-indent.amount,
    )

    // The cap's baseline sits drop-depth below the first line's baseline, which
    // lands it on the second. place() measures from the top of the block rather
    // than from a baseline, so the offset converts between the two: down by the
    // body ascent to reach the first baseline, down again by drop-depth, then
    // back up by the cap's own ascent. A zero-height box keeps the cap from
    // contributing to the line height.
    let ascent = 0.7 * base
    let dy = ascent + drop-depth - 0.7 * cap-size
    // Spaced like the paragraph it is, not like a block.
    block(width: 100%, spacing: par.spacing, {
      place(top + left, box(height: 0pt, move(dy: dy, cap)))
      pad(left: cap-width + cap-gap, par(first-line-indent: 0pt, head))
    })
    if rest != none { par(first-line-indent: 0pt, rest) }
  })
}
