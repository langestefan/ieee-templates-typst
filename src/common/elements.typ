// Equations and footnotes, ported from IEEEtran.cls V1.8b.

#import "geometry.typ": leading-for, par-indent, sizes, with-size

// TeX sets the last footnote line on the baseline of the column's last body
// line. Typst sets the footnote's line box against the bottom of the text
// area, which leaves it lower by the difference in depth between a body line
// and a footnote line plus the body leading. Each entry is padded by that much
// and the gap between entries taken in by the same, so consecutive notes still
// advance one footnote line.
#let default-footnote-drop = (
  0.3 * (sizes.normal.at(0) - sizes.footnote.at(0)) + leading-for(sizes.normal)
)

// IEEEtran.cls:2544 and 2592. Equations are numbered in arabic and displayed
// parenthesised, set flush right, which is Typst's default position.
#let equation-numbering = "(1)"

#let rules(footnote-drop: default-footnote-drop, body) = {
  set math.equation(numbering: equation-numbering)

  // IEEEtran.cls:2498, with the comment "The IEEE does not use footnote rules".
  // Typst draws a separator line by default, so it has to be turned off. Only
  // compsoc uses a rule, and then only for \thanks.
  //
  // Footnote text is footnotesize and indented by \parindent
  // (IEEEtran.cls:2490).
  set footnote.entry(
    separator: none,
    indent: par-indent,
    gap: leading-for(sizes.footnote) - footnote-drop,
  )
  show footnote.entry: it => pad(bottom: footnote-drop, with-size(
    sizes.footnote,
    it,
  ))

  // IEEE refers to an equation by its bare parenthesised number, as in "as
  // shown in (1)", never "Equation 1".
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      // Use the element's own numbering, not the module default, so an
      // equation inside a subequations group references as (2a) rather than (2).
      link(el.location(), numbering(
        el.numbering,
        ..counter(math.equation).at(el.location()),
      ))
    } else { it }
  }

  body
}

// IEEEtran.cls:5277. The abstract label is bold italic, but \bfseries is not
// scoped, so the dash and the whole body are bold as well. The reference render
// confirms it: NimbusRomNo9L-Medi throughout.
#let runin-section(label, body, size: sizes.small) = with-size(
  size,
  text(weight: "bold")[#text(style: "italic")[#label]---#body],
)

// A line set at `size` reaches less far below its baseline than a body line
// does, so whatever follows a run-in section sits that much too close. Adding
// this after the last one keeps the next line a full body advance away.
#let runin-depth(size: sizes.small) = 0.3 * (sizes.normal.at(0) - size.at(0))

// The same above the baseline. TeX puts the first baseline of a column on the
// body grid whatever the size of the line, where Typst places the line box, so
// a run-in section opening a column needs this much above it.
#let runin-height(size: sizes.small) = 0.7 * (sizes.normal.at(0) - size.at(0))

// \thanks notes are footnotes without a marker: IEEEtran.cls:4756-4758 kills
// \thefootnote and \@makefnmark so the funding note carries no superscript,
// and 4784 resets the counter afterwards so the note does not use up number 1.
#let thanks-note(thanks) = if thanks == none { [] } else {
  footnote(numbering: _ => "", thanks)
  counter(footnote).update(0)
}

// For layouts whose title block is a float. A footnote inside
// place(float: true) never registers, and emitting it in the column flow forms
// an empty paragraph that pushes the first section down. A non-floating place()
// registers the footnote while taking no flow space.
#let placed-thanks-note(thanks) = if thanks != none {
  place(top + left, box(thanks-note(thanks)))
}

// IEEEtran's IEEEeqnarray family exists because LaTeX's own multi-line equation
// support is poor. Typst's native math already aligns on & and breaks on \\, so
// there is nothing to port there: write the equation normally.
//
// What IEEE also uses and Typst does not provide is sub-numbering, (1a), (1b),
// for equations that belong together. This groups them: the group takes one
// equation number and its members are lettered, after which numbering resumes
// where it would have.
#let subequations(body) = context {
  let start = counter(math.equation).get().first()
  set math.equation(numbering: n => numbering("(1a)", start + 1, n - start))
  body
  counter(math.equation).update(start + 1)
}
