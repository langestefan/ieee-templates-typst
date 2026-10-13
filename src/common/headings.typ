// Section headings, ported from IEEEtran.cls V1.8b.
//
// Numbering (IEEEtran.cls:2585-2589) shows only the level's own counter, so a
// subsection reads "B." rather than "I-B". Styling and spacing come from
// IEEEtran.cls:5467-5482, and the run-in behaviour from 5387 and 5416.

#import "geometry.typ": (
  ex-ratio, leading-for, sizes as default-sizes, with-size, word-space,
)

// The ex-based skips below apply ex-ratio to the body size explicitly. Writing
// them in em does not work: inside a heading show rule Typst has already scaled
// the text to 1.4em or 1.2em, so an em there is not the body's.

// `body` is the ladder entry of the body text and defaults to the 10pt one.
// `indent` is \parindent, 1em of the body unless a mode says otherwise.

// LaTeX adds a heading skip to the baselineskip, so 1.5ex above a section is
// 11.955 + 6.69 = 18.65pt baseline to baseline. A Typst block's `above` and
// `below` replace the paragraph leading instead of adding to it, so the
// leading is put back in: with the heading's line box pinned to the body's,
// the distance comes out as the body advance plus the class skip.

// IEEEtran.cls:5397. Gap between the number and the title.
#let num-gap = 0.5em

// IEEEtran.cls:5387. A run-in heading closes with a colon, a word space and a
// thin space. The spacing is weak so the space the source has after the
// heading does not add to it.
#let runin-punct = [:#h(word-space.times.regular + 1em / 6, weak: true)]

#let numbering-fn(..nums) = {
  let n = nums.pos()
  let own = n.last()
  if n.len() == 1 { numbering("I.", own) } else if n.len() == 2 {
    numbering("A.", own)
  } else if n.len() == 3 { numbering("1)", own) } else { numbering("a)", own) }
}

// Levels 3 and 4 have a zero after-skip in the class, which is what marks them
// as run-in headings (IEEEtran.cls:5416 treats afterskip <= 0 that way).
#let is-runin(level) = level >= 3

// IEEEtran.cls:2611 and 5764-5773. After \appendices, top-level sections are
// lettered rather than numbered and are titled "Appendix A", with the section
// title on a second line. Note the letter carries no trailing period, unlike
// the "I." of the main body.
#let appendix-name = "Appendix"
#let appendix-state = state("ieee-appendix-mode", false)

// IEEEtran.cls:4492 puts 0.3\baselineskip between the References heading and
// the list. The heading is emitted by the bibliography element itself, so the
// space cannot be inserted around it from outside; callers raise this instead.
#let heading-below-extra = state("ieee-heading-below-extra", 0pt)

// The reference list is set at footnotesize under an unnumbered heading
// (IEEEtran.cls:4489-4492). A show rule rather than styling a trailing
// parameter, so the list can sit wherever the document puts it: journals need
// it before the author biographies.
//
// IEEEtran.cls:4492 puts 0.3\baselineskip, at the list's size, between the
// heading and the list. `heading-extra` is what that takes on top of the normal
// heading skip: the first entry's line box and leading are smaller than the
// body's, which the default accounts for. `item-gap` is \IEEEbibitemsep, 0pt
// outside Computer Society conferences (4484-4486), so entries sit one line
// apart like any other line.
#let bibliography-rules(
  size: default-sizes.footnote,
  body: default-sizes.normal,
  heading-extra: auto,
  item-gap: 0pt,
  doc,
) = {
  set bibliography(title: [References], style: "ieee")
  show bibliography: it => {
    heading-below-extra.update(if heading-extra != auto { heading-extra } else {
      (
        0.3 * size.at(1)
          + leading-for(size)
          - leading-for(body)
          - 0.3 * (body.at(0) - size.at(0))
      )
    })
    with-size(size, {
      set par(spacing: leading-for(size) + item-gap)
      it
    })
    heading-below-extra.update(0pt)
  }
  doc
}

#let appendices(body) = {
  appendix-state.update(true)
  counter(heading).update(0)
  body
  appendix-state.update(false)
}

// IEEEtran.cls:5466-5476. The class comment reads "The IEEE wants section
// heading spacing to decrease for conference mode": conference uses 1.5ex above
// both sections and subsections, journal uses 3.0ex and 3.5ex. The space below
// is 0.7ex in both. Applying the conference values to journal put its first
// section heading 5pt high. In ex.
#let above-skip = (
  conference: (1.5, 1.5),
  journal: (3.0, 3.5),
  transmag: (3.0, 3.5),
)
#let below-skip = 0.7

// IEEEtran.cls:5503-5508. Transactions on Magnetics indents its subsections by
// 0.75\parindent, and sets subsubsections on a line of their own, indented
// 1.25\parindent with 0.1ex above and below, rather than running them in.
#let transmag-indent = (0.75, 1.25)
#let transmag-subsub-skip = 0.1

#let rules(
  mode: "conference",
  body: default-sizes.normal,
  indent: auto,
  doc,
) = {
  let text-size = body.at(0)
  let par-indent = if indent == auto { text-size } else { indent }
  let ex = ex-ratio * text-size
  let leading = leading-for(body)
  let above = above-skip.at(mode).map(x => x * ex + leading)
  let below = below-skip * ex + leading
  let transmag = mode == "transmag"
  // Pinned to the body's line box, so a heading sits the same wherever it is
  // emitted. The References heading comes from inside the footnotesize
  // reference list and would otherwise inherit its smaller edges.
  let heading-text = text.with(
    size: text-size,
    weight: "regular",
    top-edge: 0.7 * text-size,
    bottom-edge: -0.3 * text-size,
  )
  set heading(numbering: numbering-fn)

  show heading: it => {
    let in-appendix = appendix-state.at(it.location())
    let n = if it.numbering != none {
      if in-appendix and it.level == 1 {
        numbering("A", counter(heading).at(it.location()).first())
      } else {
        numbering-fn(..counter(heading).at(it.location()))
      }
    } else { none }

    // Level 1: centred small caps.
    if it.level == 1 {
      let extra = heading-below-extra.at(it.location())
      block(
        above: above.at(0),
        below: below + extra,
        width: 100%,
        sticky: true,
        heading-text({
          set align(center)
          if in-appendix and n != none {
            // "Appendix A" on one line, the title beneath it. An empty title
            // leaves just the label, as \@IEEEprocessthesectionargument does.
            //
            // Only numbered headings get the label: the class leaves \section*
            // alone in appendix mode (IEEEtran.cls:5745), which is how the
            // Acknowledgment and References headings keep their normal form.
            smallcaps[#appendix-name~#n]
            if it.body != [] {
              linebreak()
              smallcaps(it.body)
            }
          } else {
            smallcaps[#if n != none [#n#h(num-gap)]#it.body]
          }
        }),
      )
    } else if it.level == 2 {
      // Level 2: flush-left italic, same spacing.
      block(
        above: above.at(1),
        below: below,
        width: 100%,
        sticky: true,
        inset: (
          left: if transmag { transmag-indent.at(0) * par-indent } else {
            0pt
          },
        ),
        heading-text(style: "italic")[#if n != none [#n#h(num-gap)]#it.body],
      )
    } else if transmag and it.level == 3 {
      let skip = transmag-subsub-skip * ex + leading
      block(
        above: skip,
        below: skip,
        width: 100%,
        sticky: true,
        inset: (left: transmag-indent.at(1) * par-indent),
        heading-text(style: "italic")[#if n != none [#n#h(num-gap)]#it.body],
      )
    } else {
      // Levels 3 and 4 run into the paragraph that follows. Returning inline
      // content rather than a block is what lets Typst merge them; a block
      // would break the line no matter how its spacing is set.
      //
      // The class indents these by \parindent and 2\parindent respectively.
      // The first of those is already supplied by par.first-line-indent, so
      // only level 4 needs to make up the difference.
      let extra = if it.level == 3 { 0pt } else { par-indent }
      let head = text(size: text-size, style: "italic", weight: "regular")[
        #if n != none [#n#h(num-gap)]#it.body#runin-punct
      ]
      // The parbreak closes the preceding paragraph. Without it the heading
      // would run into the text above as well as the text below.
      [#parbreak()#h(extra)#head]
    }
  }

  doc
}
