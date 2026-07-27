// A brief technical note: the title sits in the first column rather than
// spanning both, set \large bold.
//
// Matches bare_jrnl.tex compiled with the technote class option.

#import "/src/journal.typ": ieee-journal

#show: ieee-journal.with(
  technote: true,
  title: [Bare Demo of IEEEtran.cls \ for IEEE Journals],
  authors: [
    Michael Shell, _Member, IEEE,_ John Doe, _Fellow, OSA,_
    and Jane Doe, _Life Fellow, IEEE_
  ],
  header-left: [Journal of LaTeX Class Files, Vol. 14, No. 8, August 2015],
  header-right: [Shell #emph[et al.]: Bare Demo of IEEEtran.cls for IEEE Journals],
  thanks: [
    M. Shell was with the Department of Electrical and Computer Engineering,
    Georgia Institute of Technology, Atlanta, GA, 30332 USA.
    #linebreak() J. Doe and J. Doe are with Anonymous University.
    #linebreak() Manuscript received April 19, 2005; revised August 26, 2015.
  ],
  abstract: [The abstract goes here.],
  index-terms: [IEEE, IEEEtran, journal, LaTeX, paper, template.],
)

= Introduction
This demo file is intended to serve as a "starter file" for IEEE journal papers
produced under LaTeX using IEEEtran.cls version 1.8b and later.

== Subsection Heading Here
Subsection text here.

= Conclusion
The conclusion goes here @kopka1999.

#heading(numbering: none)[Acknowledgment]
The authors would like to thank\u{2026}

#bibliography("refs.bib")
