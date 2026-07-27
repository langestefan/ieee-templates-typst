// Section headings, ported from IEEEtran.cls V1.8b.
//
// Numbering (IEEEtran.cls:2585-2589) shows only the level's own counter, so a
// subsection reads "B." rather than "I-B". Styling and spacing come from
// IEEEtran.cls:5467-5482, and the run-in behaviour from 5387 and 5416.

#import "geometry.typ": par-indent, sizes

// Times has no ex unit in Typst; its x-height is 0.448em.
#let ex = 0.448em

// Both engines add heading separation on top of the line advance, so the class
// values carry over directly: a gap of 1.5ex renders as 11.955 + 6.69 = 18.65pt
// baseline to baseline, which is what the reference measures.

// IEEEtran.cls:5397. Gap between the number and the title.
#let num-gap = 0.5em

// IEEEtran.cls:5387. Punctuation closing a run-in heading.
#let runin-punct = ": "

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

#let rules(body) = {
  set heading(numbering: numbering-fn)

  show heading: it => {
    let n = if it.numbering != none {
      numbering-fn(..counter(heading).at(it.location()))
    } else { none }

    // Level 1: centred small caps, 1.5ex above and 0.7ex below.
    if it.level == 1 {
      block(above: 1.5 * ex, below: 0.7 * ex, width: 100%)[
        #set align(center)
        #set text(size: sizes.normal.at(0), weight: "regular")
        #smallcaps[#if n != none [#n#h(num-gap)]#it.body]
      ]
    } else if it.level == 2 {
      // Level 2: flush-left italic, same spacing.
      block(above: 1.5 * ex, below: 0.7 * ex, width: 100%)[
        #set text(size: sizes.normal.at(0), style: "italic", weight: "regular")
        #if n != none [#n#h(num-gap)]#it.body
      ]
    } else {
      // Levels 3 and 4 run into the paragraph that follows. Returning inline
      // content rather than a block is what lets Typst merge them; a block
      // would break the line no matter how its spacing is set.
      //
      // The class indents these by \parindent and 2\parindent respectively.
      // The first of those is already supplied by par.first-line-indent, so
      // only level 4 needs to make up the difference.
      let extra = if it.level == 3 { 0pt } else { par-indent }
      let head = text(size: sizes.normal.at(0), style: "italic", weight: "regular")[
        #if n != none [#n#h(num-gap)]#it.body#runin-punct
      ]
      // The parbreak closes the preceding paragraph. Without it the heading
      // would run into the text above as well as the text below.
      [#parbreak()#h(extra)#head]
    }
  }

  body
}
