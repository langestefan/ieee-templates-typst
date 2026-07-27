// \IEEEPARstart, the two-line drop cap opening a journal paper.
// Ported from IEEEtran.cls:5815-5830.
//
// Typst cannot indent only the first two lines of a paragraph: par offers
// first-line-indent, which covers line one, and hanging-indent, which covers
// every line but the first. Neither describes "the first two". So the paragraph
// is split explicitly: the opening words are set in a narrow block beside the
// cap, and the remainder follows at full width.
//
// Splitting means the leading portion is handled as plain text, so markup in
// the first two lines is not preserved. Markup in the remainder is untouched.

#import "geometry.typ": line-advance, sizes, with-size

// IEEEtran.cls:5824. The letter is lowered this far below the first baseline,
// and its height is that depth plus the cap height of the body font.
#let drop-depth = 1.1 * line-advance
#let drop-lines = 2

// Cap-height as a fraction of em for Times. Used both to size the drop cap and
// to convert the target height back into a font size.
#let cap-ratio = 0.662

#let cap-size = (drop-depth + cap-ratio * sizes.normal.at(0)) / cap-ratio

// Gap between the drop cap and the text beside it.
#let cap-gap = 0.08 * cap-size

// Recover plain text from content so the opening can be split on words.
//
// Markup spaces are their own element rather than part of the surrounding text
// runs, so they have to be handled explicitly; missing them welds words to
// their neighbours across a quote or emphasis boundary.
#let space-func = [ ].func()
#let linebreak-func = linebreak().func()

#let plain(c) = {
  if type(c) == str {
    c
  } else if type(c) != content {
    ""
  } else if c.func() == space-func or c.func() == linebreak-func {
    " "
  } else if c.func() == smartquote {
    if c.at("double", default: true) { "\u{201C}" } else { "\u{2018}" }
  } else if c.has("text") {
    c.text
  } else if c.has("children") {
    c.children.map(plain).join("")
  } else if c.has("body") { plain(c.body) } else { "" }
}

// Typst decides whether a smartquote opens or closes during layout, so
// extraction cannot tell them apart. Alternating per quote character recovers
// the right pair for well-formed text.
#let alternate-quotes(s) = {
  let out = ""
  let open-double = true
  let open-single = true
  for ch in s.clusters() {
    if ch == "\u{201C}" {
      out += if open-double { "\u{201C}" } else { "\u{201D}" }
      open-double = not open-double
    } else if ch == "\u{2018}" {
      out += if open-single { "\u{2018}" } else { "\u{2019}" }
      open-single = not open-single
    } else { out += ch }
  }
  out
}

#let parstart(body) = context {
  let full = alternate-quotes(plain(body).trim())
  if full == "" { return body }

  let letter = full.first()
  let after = full.slice(letter.len())

  // IEEEtran renders the remainder of the first word in upper case.
  let space-at = after.position(" ")
  let word-rest = if space-at == none { after } else { after.slice(0, space-at) }
  let tail = if space-at == none { "" } else { after.slice(space-at + 1) }

  let cap = text(size: cap-size, letter)
  let cap-width = measure(cap).width

  // Width available beside the cap for the dropped lines.
  let avail = layout(size => size.width)
  layout(size => {
    let indent-width = size.width - cap-width - cap-gap
    let opening = upper(word-rest) + " " + tail

    // Largest word prefix that still fits in `drop-lines` lines at the reduced
    // width. Measured rather than estimated, since it depends on the font.
    let words = opening.split(" ")
    let line-h = measure(block(width: indent-width, "M")).height
    let limit = line-h + (drop-lines - 1) * line-advance + 0.5pt

    // Largest lo with fits(lo). mid is always strictly greater than lo and at
    // most hi, so each iteration moves one bound and the loop terminates.
    let lo = 0
    let hi = words.len()
    while lo < hi {
      let mid = calc.floor((lo + hi + 1) / 2)
      let probe = words.slice(0, mid).join(" ")
      if measure(block(width: indent-width, probe)).height <= limit {
        lo = mid
      } else { hi = mid - 1 }
    }

    let head = words.slice(0, lo).join(" ")
    let rest = words.slice(lo).join(" ")

    // The cap's baseline sits drop-depth below the first line's baseline, which
    // lands it on the second. place() measures from the top of the block rather
    // than from a baseline, so the offset has to convert between the two: down
    // by the body ascent to reach the first baseline, down again by drop-depth,
    // then back up by the cap's own ascent. A zero-height box keeps the cap from
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
