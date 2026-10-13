// Double-blind peer review: the title block becomes a cover page carrying the
// authors, and the title is repeated overleaf at the head of the body.
//
// Matches bare_jrnl.tex compiled with the peerreview class option.

#import "/src/journal.typ": (
  appendices, biography, biography-no-photo, ieee-journal, parstart,
)

#show: ieee-journal.with(
  peerreview: true,
  title: [Bare Demo of IEEEtran.cls \ for IEEE Journals],
  authors: [
    Michael Shell, _Member, IEEE,_ John Doe, _Fellow, OSA,_
    and Jane Doe, _Life Fellow, IEEE_
  ],
  header-left: [Journal of LaTeX Class Files, Vol. 14, No. 8, August 2015],
  header-right: [Shell #emph[et al.]: Bare Demo of IEEEtran.cls for IEEE Journals],
  thanks: [
    M. Shell was with the Department of Electrical and Computer Engineering,
    Georgia Institute of Technology, Atlanta, GA, 30332 USA e-mail: (see
    http:\/\/www.michaelshell.org/contact.html).


    J. Doe and J. Doe are with Anonymous University.

    Manuscript received April 19, 2005; revised August 26, 2015.
  ],
  abstract: [The abstract goes here.],
  index-terms: [IEEE, IEEEtran, journal, LaTeX, paper, template.],
)

= Introduction
#parstart[This demo file is intended to serve as a "starter file" for IEEE journal papers produced under LaTeX using IEEEtran.cls version 1.8b and later. I wish you the best of success.]

#align(right)[mds]

#align(right)[August 26, 2015]

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

#heading(numbering: none)[Acknowledgment]
The authors would like to thank\.\.\.

// IEEE orders a journal paper acknowledgment, references, then biographies, so
// the reference list is placed here rather than passed as an argument.
#bibliography("refs.bib")

#biography(name: [Michael Shell])[Biography text here.]

#biography-no-photo(name: [John Doe])[Biography text here.]

#biography-no-photo(name: [Jane Doe])[Biography text here.]

