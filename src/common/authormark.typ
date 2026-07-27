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
  // \raisebox{0pt}[0pt][0pt] makes the mark contribute no height or depth, so a
  // marked name does not sit differently from an unmarked one on the same line.
  box(height: 0pt, super(text(size: sizes.footnote.at(0), glyph)))
}
