// \IEEEPARstart, the two-line drop cap opening a journal paper.
// Ported from IEEEtran.cls:5815-5830.

#import "geometry.typ": line-advance, sizes
#import "textsplit.typ": as-text, split-at-height

// IEEEtran.cls:5824. The letter is lowered this far below the first baseline,
// and its height is that depth plus the cap height of the body font.
#let drop-depth = 1.1 * line-advance
#let drop-lines = 2

// Cap height as a fraction of em for Times. Used both to size the drop cap and
// to convert the target height back into a font size.
#let cap-ratio = 0.662

#let cap-size = (drop-depth + cap-ratio * sizes.normal.at(0)) / cap-ratio

// Gap between the drop cap and the text beside it.
#let cap-gap = 0.08 * cap-size

#let parstart(body) = context {
  let full = as-text(body)
  if full == "" { return body }

  let letter = full.first()
  let after = full.slice(letter.len())

  // IEEEtran renders the remainder of the first word in upper case.
  let space-at = after.position(" ")
  let word-rest = if space-at == none { after } else { after.slice(0, space-at) }
  let tail = if space-at == none { "" } else { after.slice(space-at + 1) }

  let cap = text(size: cap-size, letter)
  let cap-width = measure(cap).width

  layout(size => {
    let indent-width = size.width - cap-width - cap-gap
    let opening = upper(word-rest) + " " + tail

    let line-h = measure(block(width: indent-width, "M")).height
    let limit = line-h + (drop-lines - 1) * line-advance + 0.5pt
    let (head, rest) = split-at-height(opening, indent-width, limit)

    // The cap's baseline sits drop-depth below the first line's baseline, which
    // lands it on the second. place() measures from the top of the block rather
    // than from a baseline, so the offset converts between the two: down by the
    // body ascent to reach the first baseline, down again by drop-depth, then
    // back up by the cap's own ascent. A zero-height box keeps the cap from
    // contributing to the line height.
    let ascent = 0.7 * sizes.normal.at(0)
    let dy = ascent + drop-depth - 0.7 * cap-size
    block(width: 100%, {
      place(top + left, box(height: 0pt, move(dy: dy, cap)))
      pad(left: cap-width + cap-gap, par(first-line-indent: 0pt, head))
    })
    if rest != "" { par(first-line-indent: 0pt, rest) }
  })
}
