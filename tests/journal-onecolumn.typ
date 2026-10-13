// Single-column journal, matching bare_jrnl.tex compiled with the onecolumn
// class option. In this mode the abstract and index terms are not run in: each
// gets a centred bold label with the text indented beneath it.

#import "/src/journal.typ": (
  appendices, biography, biography-no-photo, ieee-journal, parstart,
)

#show: ieee-journal.with(
  columns: 1,
  title: [Bare Demo of IEEEtran.cls \ for IEEE Journals],
  authors: [
    Michael Shell, _Member, IEEE,_ John Doe, _Fellow, OSA,_
    and Jane Doe, _Life Fellow, IEEE_
  ],
  header-left: [Journal of LaTeX Class Files, Vol. 14, No. 8, August 2015],
  header-right: [Shell #emph[et al.]: Bare Demo of IEEEtran.cls for IEEE Journals],
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
The authors would like to thank\u{2026}

// IEEE orders a journal paper acknowledgment, references, then biographies, so
// the reference list is placed here rather than passed as an argument.
#bibliography("refs.bib")

#biography(name: [Michael Shell])[Biography text here.]

#biography-no-photo(name: [John Doe])[Biography text here.]

#biography-no-photo(name: [Jane Doe])[Biography text here.]

