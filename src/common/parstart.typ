// \IEEEPARstart, the two-line drop cap opening a journal paper.
// Ported from IEEEtran.cls:5815-5830.

#import "geometry.typ": line-advance as default-advance, sizes as default-sizes
#import "textsplit.typ": as-text, split-at-height

// IEEEtran.cls:5824. The letter is lowered this far below the first baseline,
// and its height is that depth plus the cap height of the body font.
#let drop-lines = 2

// Cap height as a fraction of em for Times. Used both to size the drop cap and
// to convert the target height back into a font size.
#let cap-ratio = 0.662

// Gap between the drop cap and the text beside it, as a fraction of its size.
#let cap-gap-ratio = 0.08

// `advance` and `body-size` default to the 10pt Times ladder the Times-based
// modes share. Computer Society papers pass their own: 9.5bp Palatino on
// 11.54bp, where the defaults would size the cap for the wrong body.
#let parstart(body, advance: default-advance, body-size: none) = context {
  let base = if body-size == none { default-sizes.normal.at(0) } else {
    body-size
  }
  let drop-depth = 1.1 * advance
  let cap-size = (drop-depth + cap-ratio * base) / cap-ratio
  let cap-gap = cap-gap-ratio * cap-size
  let full = as-text(body)
  if full == "" { return body }

  let letter = full.first()
  let after = full.slice(letter.len())

  // IEEEtran renders the remainder of the first word in upper case.
  let space-at = after.position(" ")
  let word-rest = if space-at == none { after } else {
    after.slice(0, space-at)
  }
  let tail = if space-at == none { "" } else { after.slice(space-at + 1) }

  // The cap must carry its own edges. Modes that pin top-edge as an absolute
  // length, as the Computer Society layouts do, would otherwise give this 28pt
  // letter the body's 6.65pt edge and place it on the first line instead of the
  // second.
  let cap = text(
    size: cap-size,
    top-edge: 0.7 * cap-size,
    bottom-edge: -0.3 * cap-size,
    letter,
  )
  let cap-width = measure(cap).width

  layout(size => {
    let indent-width = size.width - cap-width - cap-gap
    let opening = upper(word-rest) + " " + tail

    let line-h = measure(block(width: indent-width, "M")).height
    let limit = line-h + (drop-lines - 1) * advance + 0.5pt
    let (head, rest) = split-at-height(opening, indent-width, limit)

    // The cap's baseline sits drop-depth below the first line's baseline, which
    // lands it on the second. place() measures from the top of the block rather
    // than from a baseline, so the offset converts between the two: down by the
    // body ascent to reach the first baseline, down again by drop-depth, then
    // back up by the cap's own ascent. A zero-height box keeps the cap from
    // contributing to the line height.
    let ascent = 0.7 * base
    let dy = ascent + drop-depth - 0.7 * cap-size
    block(width: 100%, {
      place(top + left, box(height: 0pt, move(dy: dy, cap)))
      pad(left: cap-width + cap-gap, par(first-line-indent: 0pt, head))
    })
    if rest != "" { par(first-line-indent: 0pt, rest) }
  })
}
