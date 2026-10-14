// The journal running head, ported from IEEEtran.cls:4243-4281 and the
// IEEEtitlepagestyle / headings page styles.
//
// Three details that are easy to miss:
//
//   \markboth wraps both marks in \MakeUppercase (4360-4361), so the head is
//   uppercased whatever case the author writes.
//
//   The class is oneside by default (374), and the oneside head is the left
//   mark with the page number on the right, on every page (4261-4264). The
//   right mark only ever appears under the twoside option.
//
//   Under twoside the page number sits on the outer edge (4246-4247):
//   \@oddhead is "mark \hfil \thepage", \@evenhead "\thepage \hfil mark".

#import "geometry.typ": tpt

#let head-size = 7 * tpt

// Distance from the text block up to the head, for `page.header-ascent`.
// Calibrated to put the head's baseline at 31.2pt, as the references have it.
#let head-ascent = 24.09pt

#let running-head(
  left-text,
  right-text,
  size: head-size,
  twoside: false,
) = context {
  let n = counter(page).get().first()
  let even = twoside and calc.even(n)

  // Two-sided, the journal line goes on page one and on versos, and the author
  // line on the remaining rectos.
  let mark = if not twoside or n == 1 or even { left-text } else { right-text }

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
