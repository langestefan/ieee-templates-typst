// \IEEEauthorrefmark, the superscript symbols tying author names to
// affiliations. Ported from IEEEtran.cls:4543-4545.

#import "geometry.typ": sizes

// The class cycles through this sequence and falls back to a superscript roman
// numeral past the ninth mark.
#let marks = ("*", "†", "‡", "§", "¶", "‖", "**", "††", "‡‡")

#let author-mark(n) = {
  assert(n >= 1, message: "author mark index starts at 1")
  let glyph = if n <= marks.len() { marks.at(n - 1) } else {
    // \romannumeral is lowercase.
    lower(numbering("I", n - marks.len()))
  }
  // The class raises a \footnotesize mark. Typst's super() shrinks whatever it
  // is given, so size is pinned to 1em of the footnote size; leaving it to
  // shrink gives a 4.8pt mark where the reference has 8pt.
  //
  // \raisebox{0pt}[0pt][0pt] makes the mark contribute no height or depth, so a
  // marked name does not sit differently from an unmarked one on the same line.
  box(height: 0pt, text(
    size: sizes.footnote.at(0),
    super(typographic: false, size: 1em, baseline: -0.4em, glyph),
  ))
}
