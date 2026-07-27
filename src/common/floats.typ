// Figure and table captions, ported from IEEEtran.cls V1.8b.
//
// The traditional (non-compsoc) \@makecaption at IEEEtran.cls:2774-2793 treats
// the two kinds quite differently, and the numbering differs too: figures are
// arabic (2814) while tables are uppercase Roman (2830).

#import "geometry.typ": line-advance, sizes, with-size

// IEEEtran.cls:2697. Space between a float and its caption.
#let caption-skip = 0.5 * line-advance

// IEEEtran.cls:2607-2608.
#let figure-supplement = "Fig."
#let table-supplement = "TABLE"

#let caption-text(body) = with-size(sizes.footnote, body)

#let rules(body) = {
  set figure(placement: auto, gap: caption-skip)

  show figure.where(kind: image): set figure(
    supplement: figure-supplement,
    numbering: "1",
  )
  show figure.where(kind: table): set figure(
    supplement: table-supplement,
    numbering: "I",
  )

  // Table captions sit above the table, figure captions below it.
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: it => {
    let num = context it.counter.display(it.numbering)

    if it.kind == table {
      // Label on its own line, caption text in small caps beneath it, both
      // centred (IEEEtran.cls:2777).
      caption-text(align(center, {
        [#it.supplement~#num]
        linebreak()
        smallcaps(it.body)
      }))
    } else {
      // "Fig. 1." then two non-breaking spaces, then the text. Centred when it
      // fits on one line, otherwise wrapped flush left (IEEEtran.cls:2784-2792).
      let head = [#it.supplement~#num.]
      let full = [#head\u{00A0}\u{00A0}#it.body]
      caption-text(layout(size => context {
        let fits = measure(full).width <= size.width
        align(if fits { center } else { left }, full)
      }))
    }
  }

  body
}
