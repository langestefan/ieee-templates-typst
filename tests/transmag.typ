// IEEE Transactions on Magnetics, matching bare_jrnl_transmag.tex.
//
// transmag differs from a plain journal in its title area: a smaller bold
// title, numeric affiliation marks, one affiliation per line, and the abstract
// and index terms carried full width inside the title block rather than in the
// first column. The abstract has no "Abstract—" label.

#import "/src/transmag.typ": (
  appendices, biography, biography-no-photo, ieee-transmag, mark, parstart,
)

#show: ieee-transmag.with(
  title: [Bare Demo of IEEEtran.cls for \ IEEE #smallcaps[Transactions on Magnetics]],
  authors: [
    Michael Shell#mark(1), Homer Simpson#mark(2), James Kirk#mark(3),
    Montgomery Scott#mark(3), and Eldon Tyrell#mark(4), _Fellow, IEEE_
  ],
  affiliations: (
    [School of Electrical and Computer Engineering, Georgia Institute of Technology, Atlanta, GA 30332 USA],
    [Twentieth Century Fox, Springfield, USA],
    [Starfleet Academy, San Francisco, CA 96678 USA],
    [Tyrell Inc., 123 Replicant Street, Los Angeles, CA 90210 USA],
  ),
  header-left: [Journal of LaTeX Class Files, Vol. 14, No. 8, August 2015],
  header-right: [Shell #emph[et al.]: Bare Demo of IEEEtran.cls for IEEE Transactions on Magnetics],
  thanks: [Manuscript received December 1, 2012; revised August 26, 2015.],
  abstract: [The abstract goes here.],
  index-terms: [IEEE, IEEEtran, IEEE Transactions on Magnetics, journal, LaTeX, magnetics, paper, template.],
)

= Introduction
#parstart[This demo file is intended to serve as a starter file for IEEE Transactions on Magnetics papers produced under LaTeX using IEEEtran.cls version 1.8b and later.]

= Conclusion
The conclusion goes here @kopka1999.

#show: appendices
= Proof of the First Zonklar Equation
Appendix one text goes here.

=
Appendix two text goes here.

#heading(numbering: none)[Acknowledgment]
The authors would like to thank\u{2026}

#bibliography("refs.bib")

#biography(name: [Michael Shell])[Biography text here.]

#biography-no-photo(name: [Homer Simpson])[Biography text here.]
