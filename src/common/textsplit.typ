// Splitting a paragraph so that its opening sits beside something.
//
// Typst can indent the first line of a paragraph or every line but the first,
// and nothing in between. IEEEtran needs "the first N lines", both for the
// \IEEEPARstart drop cap and for the photo box beside a biography. The only way
// to get it is to split the paragraph explicitly and lay the two parts out
// separately, which is what these helpers support.
//
// The body is cut into words first, keeping whatever markup each one carries:
// emphasis and other styling are reapplied word by word, and anything that is
// not running text, such as a citation, an equation or a footnote, travels as
// one word.

// Markup spaces are their own element rather than part of the surrounding text
// runs, so they need handling explicitly; missing them welds words to their
// neighbours across a quote or emphasis boundary.
#let space-func = [ ].func()
#let linebreak-func = linebreak().func()
#let styled-func = text(size: 1em)[].func()

// Flattens content to a string. Only for callers that need the characters
// themselves, since everything but the text is lost.
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

// Wrappers that can be taken apart and put back around each word.
#let inline-wrappers = (
  emph,
  strong,
  underline,
  overline,
  strike,
  highlight,
  smallcaps,
)

// Applies `f` to every run of text in `c` and leaves the rest as it is, so an
// equation or raw text inside passes through untouched.
#let map-text(c, f) = {
  if type(c) == str {
    f(c)
  } else if type(c) != content {
    c
  } else if c.func() == text {
    f(c.text)
  } else if c.has("children") {
    c.children.map(x => map-text(x, f)).join()
  } else if c.func() == styled-func {
    styled-func(map-text(c.child, f), c.styles)
  } else if c.func() == smallcaps {
    map-text(c.body, f)
  } else if c.func() in inline-wrappers {
    (c.func())(map-text(c.body, f))
  } else { c }
}

#let is-break(c) = (
  type(c) == content and (c.func() == space-func or c.func() == parbreak)
)

// Content as a flat array of pieces: a markup space, a paragraph break, or
// something that must stay in one piece.
#let atoms(c) = {
  if type(c) == str {
    let out = ()
    for (i, w) in c.split(regex("\\s+")).enumerate() {
      if i > 0 { out.push([ ]) }
      if w != "" { out.push(w) }
    }
    out
  } else if type(c) != content {
    ()
  } else if c.func() == text {
    atoms(c.text)
  } else if is-break(c) {
    (c,)
  } else if c.has("children") {
    c.children.map(atoms).flatten()
  } else if c.func() == styled-func {
    atoms(c.child).map(a => if is-break(a) { a } else {
      styled-func(a, c.styles)
    })
  } else if c.func() in inline-wrappers {
    atoms(c.body).map(a => if is-break(a) { a } else { (c.func())(a) })
  } else { (c,) }
}

// Groups the pieces into words. Each is (sep, body), where sep says what came
// before it: nothing, a space, or a paragraph break.
#let words(c) = {
  let out = ()
  let sep = ""
  let glue = false
  for a in atoms(c) {
    if is-break(a) {
      if a.func() == parbreak { sep = "par" } else if sep == "" { sep = " " }
      glue = false
    } else if glue {
      out.last().body += a
    } else {
      out.push((sep: if out.len() == 0 { "" } else { sep }, body: [] + a))
      sep = ""
      glue = true
    }
  }
  out
}

// IEEEtran.cls:6033 redefines \par inside a biography as \hfil\break\indent,
// so a paragraph break there is a line break and an indent, and the whole body
// stays one paragraph. The same is done wherever a body is split.
#let join-words(ws, indent: 0pt) = {
  for (i, w) in ws.enumerate() {
    if i > 0 {
      if w.sep == "par" { linebreak() + h(indent) } else { w.sep }
    }
    w.body
  }
}

// Largest run of leading words that still fits within `height` when set at
// `width`, returned as (head, rest), each content or none. The fit is measured
// rather than estimated, since it depends on the font.
//
// `prefix` is content that will lead the same paragraph, such as a biography's
// bold author name. It is measured together with each candidate so the split
// accounts for the room it takes on the first line.
#let split-at-height(ws, width, height, prefix: none, indent: 0pt) = {
  if ws.len() == 0 { return (none, none) }
  let join = join-words.with(indent: indent)

  // Binary search for the largest lo with fits(lo). mid is always strictly
  // greater than lo and at most hi, so each iteration moves one bound.
  let lo = 0
  let hi = ws.len()
  while lo < hi {
    let mid = calc.floor((lo + hi + 1) / 2)
    let probe = join(ws.slice(0, mid))
    let candidate = if prefix == none { probe } else { [#prefix #probe] }
    let set-par = par(first-line-indent: 0pt, candidate)
    if measure(block(width: width, set-par)).height <= height {
      lo = mid
    } else { hi = mid - 1 }
  }

  if lo == ws.len() { return (join(ws), none) }
  if lo == 0 { return (none, join(ws)) }
  // The head stops mid-paragraph, so its last line is justified like the rest
  // unless a paragraph break falls exactly there.
  if ws.at(lo).sep == "par" {
    (join(ws.slice(0, lo)), h(indent) + join(ws.slice(lo)))
  } else {
    (join(ws.slice(0, lo)) + linebreak(justify: true), join(ws.slice(lo)))
  }
}
