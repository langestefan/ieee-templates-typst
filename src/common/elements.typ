// Equations and footnotes, ported from IEEEtran.cls V1.8b.

#import "geometry.typ": par-indent, sizes, with-size

// IEEEtran.cls:2544 and 2592. Equations are numbered in arabic and displayed
// parenthesised, set flush right, which is Typst's default position.
#let equation-numbering = "(1)"

#let rules(body) = {
  set math.equation(numbering: equation-numbering)

  // IEEEtran.cls:2498, with the comment "The IEEE does not use footnote rules".
  // Typst draws a separator line by default, so it has to be turned off. Only
  // compsoc uses a rule, and then only for \thanks.
  //
  // Footnote text is footnotesize and indented by \parindent
  // (IEEEtran.cls:2490).
  set footnote.entry(separator: none, indent: par-indent)
  show footnote.entry: it => with-size(sizes.footnote, it)

  // IEEE refers to an equation by its bare parenthesised number, as in "as
  // shown in (1)", never "Equation 1".
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      link(el.location(), numbering(
        equation-numbering,
        ..counter(math.equation).at(el.location()),
      ))
    } else { it }
  }

  body
}
