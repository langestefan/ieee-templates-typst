// IEEE Computer Society journal, matching bare_jrnl_compsoc.tex.
//
// compsoc is a different design rather than a variant: Palatino body text,
// Helvetica headings, arabic hierarchical section numbers and a diamond rule
// closing the title block.
//
// Needs a Palatino and a Helvetica clone. If they are not installed system
// wide:
//   typst compile --root . --font-path <dir> template/compsoc.typ

#import "/src/compsoc.typ": (
  appendices, biography, biography-no-photo, ieee-compsoc, parstart,
)

#show: ieee-compsoc.with(
  title: [Bare Demo of IEEEtran.cls for \ IEEE Computer Society Journals],
  authors: [
    Michael Shell, _Member, IEEE,_ John Doe, _Fellow, OSA,_
    and Jane Doe, _Life Fellow, IEEE_
  ],
  header-left: [Journal of LaTeX Class Files, Vol. 14, No. 8, August 2015],
  header-right: [Shell #emph[et al.]: Bare Demo of IEEEtran.cls for IEEE Computer Society Journals],
  thanks: [
    M. Shell was with the Department of Electrical and Computer Engineering,
    Georgia Institute of Technology, Atlanta, GA, 30332 USA.
    #linebreak() Manuscript received April 19, 2005; revised August 26, 2015.
  ],
  abstract: [The abstract goes here.],
  index-terms: [Computer Society, IEEE, IEEEtran, journal, LaTeX, paper, template.],
)

= Introduction
#parstart[This demo file is intended to serve as a "starter file" for IEEE Computer Society journal papers produced under LaTeX using IEEEtran.cls version 1.8b and later. I wish you the best of success.]

#align(right)[mds \ August 26, 2015]

== Subsection Heading Here
Subsection text here.

=== Subsubsection Heading Here
Subsubsection text here.

= Conclusion
The conclusion goes here @kopka1999.

#show: appendices
= Proof of the First Zonklar Equation
Appendix one text goes here.

=
Appendix two text goes here.

#heading(numbering: none)[Acknowledgments]
The authors would like to thank\u{2026}

#bibliography("refs.bib")

#biography(name: [Michael Shell])[Biography text here.]

#biography-no-photo(name: [John Doe])[Biography text here.]
