// Splitting a paragraph so that its opening sits beside something.
//
// Typst can indent the first line of a paragraph or every line but the first,
// and nothing in between. IEEEtran needs "the first N lines", both for the
// \IEEEPARstart drop cap and for the photo box beside a biography. The only way
// to get it is to split the paragraph explicitly and lay the two parts out
// separately, which is what these helpers support.
//
// The cost is that the split portion is handled as plain text, so markup inside
// it is not preserved. Markup in the remainder is untouched.

// Markup spaces are their own element rather than part of the surrounding text
// runs, so they need handling explicitly; missing them welds words to their
// neighbours across a quote or emphasis boundary.
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

#let as-text(body) = alternate-quotes(plain(body).trim())

// Largest word prefix of `s` that still fits within `height` when set at
// `width`, returned as (head, rest). The fit is measured rather than estimated,
// since it depends on the font.
//
// `prefix` is content that will lead the same paragraph, such as a biography's
// bold author name. It is measured together with each candidate so the split
// accounts for the room it takes on the first line.
#let split-at-height(s, width, height, prefix: none) = {
  let words = s.split(" ").filter(w => w != "")
  if words.len() == 0 { return ("", "") }

  // Binary search for the largest lo with fits(lo). mid is always strictly
  // greater than lo and at most hi, so each iteration moves one bound.
  let lo = 0
  let hi = words.len()
  while lo < hi {
    let mid = calc.floor((lo + hi + 1) / 2)
    let probe = words.slice(0, mid).join(" ")
    let candidate = if prefix == none { [#probe] } else { [#prefix #probe] }
    if measure(block(width: width, candidate)).height <= height {
      lo = mid
    } else { hi = mid - 1 }
  }

  (words.slice(0, lo).join(" "), words.slice(lo).join(" "))
}
