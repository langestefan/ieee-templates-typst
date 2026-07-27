// Section headings, ported from IEEEtran.cls V1.8b.
//
// Numbering (IEEEtran.cls:2585-2589) shows only the level's own counter, so a
// subsection reads "B." rather than "I-B". Styling and spacing come from
// IEEEtran.cls:5467-5482, and the run-in behaviour from 5387 and 5416.

#import "geometry.typ": par-indent as default-indent, sizes as default-sizes

// Times has no ex unit in Typst; its x-height is 0.448em.
#let ex = 0.448em

// The Times-based modes all share the 10pt ladder, so `body-size` and `indent`
// default to it. They are arguments rather than fixed so a mode on a different
// ladder can pass its own; this is what stops the module being tied to 10pt.

// Both engines add heading separation on top of the line advance, so the class
// values carry over directly: a gap of 1.5ex renders as 11.955 + 6.69 = 18.65pt
// baseline to baseline, which is what the reference measures.
//
// The space below is the exception. The class says 0.7ex, which puts the first
// body line 1pt above the reference in both Times modes; 0.8ex lands both. The
// checks did not catch this for a long time because they assert where headings
// sit, not where the text after them starts.

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
// section heading 5pt high.
#let above-skip = (
  conference: (1.5 * ex, 1.5 * ex),
  journal: (3.0 * ex, 3.5 * ex),
)

#let rules(mode: "conference", body-size: none, indent: none, body) = {
  let text-size = if body-size == none { default-sizes.normal.at(0) } else {
    body-size
  }
  let par-indent = if indent == none { default-indent } else { indent }
  let above = above-skip.at(mode)
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

    // Level 1: centred small caps, 1.5ex above and 0.7ex below.
    if it.level == 1 {
      let extra = heading-below-extra.at(it.location())
      block(above: above.at(0), below: 0.8 * ex + extra, width: 100%)[
        #set align(center)
        #set text(size: text-size, weight: "regular")
        #if in-appendix and n != none {
          // "Appendix A" on one line, the title beneath it. An empty title
          // leaves just the label, as \@IEEEprocessthesectionargument does.
          //
          // Only numbered headings get the label: the class leaves \section*
          // alone in appendix mode (IEEEtran.cls:5745), which is how the
          // Acknowledgment and References headings keep their normal form.
          smallcaps[#appendix-name#if n != none [~#n]]
          if it.body != [] {
            linebreak()
            smallcaps(it.body)
          }
        } else {
          smallcaps[#if n != none [#n#h(num-gap)]#it.body]
        }
      ]
    } else if it.level == 2 {
      // Level 2: flush-left italic, same spacing.
      block(above: above.at(1), below: 0.7 * ex, width: 100%)[
        #set text(size: text-size, style: "italic", weight: "regular")
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
      let head = text(
        size: text-size,
        style: "italic",
        weight: "regular",
      )[
        #if n != none [#n#h(num-gap)]#it.body#runin-punct
      ]
      // The parbreak closes the preceding paragraph. Without it the heading
      // would run into the text above as well as the text below.
      [#parbreak()#h(extra)#head]
    }
  }

  body
}
