// The LaTeX logo as latex.ltx draws it, for the fixtures only. It is 5.7pt
// narrower at 10pt than the word in plain letters, which is enough to move a
// line break: the technote fixture's first paragraph ran a line longer than
// its reference without it.
//
//   L\kern-.36em{raised script-size A}\kern-.15em T\kern-.1667em
//   \lower.5ex\hbox{E}\kern-.125em X
//
// The A is \sf@size, 7pt at 10pt, with its top level with the T's.
#let latex = context {
  let cap = measure(text(
    top-edge: "cap-height",
    bottom-edge: "baseline",
  )[T]).height
  let ex = measure(text(
    top-edge: "x-height",
    bottom-edge: "baseline",
  )[x]).height
  box({
    [L]
    h(-0.36em)
    text(size: 0.7em, baseline: -0.3 * cap)[A]
    h(-0.15em)
    [T]
    h(-0.1667em)
    text(baseline: 0.5 * ex)[E]
    h(-0.125em)
    [X]
  })
}
