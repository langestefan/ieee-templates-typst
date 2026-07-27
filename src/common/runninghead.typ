// The journal running head, ported from IEEEtran.cls:4360-4361 and the
// IEEEtitlepagestyle / headings page styles.
//
// Two details that are easy to miss:
//
//   \markboth wraps both marks in \MakeUppercase (4360-4361), so the head is
//   uppercased whatever case the author writes.
//
//   The page number sits on the outer edge, not always the right: \@oddhead is
//   "mark \hfil \thepage" while \@evenhead is "\thepage \hfil mark".

#import "geometry.typ": tpt

#let head-size = 7 * tpt

#let running-head(left-text, right-text, size: head-size) = context {
  let n = counter(page).at(here()).first()
  let even = calc.even(n)

  // IEEE puts the journal line on page one and on versos, and the author line
  // on the remaining rectos.
  let mark = if n == 1 or even { left-text } else { right-text }

  set text(size: size)
  block(
    width: 100%,
    if even {
      grid(
        columns: (auto, 1fr),
        align(left)[#n], align(right, upper(mark)),
      )
    } else {
      grid(
        columns: (1fr, auto),
        align(left, upper(mark)), align(right)[#n],
      )
    },
  )
}
