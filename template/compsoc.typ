// IEEE Computer Society journal, matching bare_jrnl_compsoc.tex.
//
// compsoc is a different design rather than a variant: Palatino body text,
// Helvetica headings, arabic hierarchical section numbers and a diamond rule
// closing the title block.
//
// Needs a Palatino and a Helvetica clone. If they are not installed system
// wide:
//   typst compile --root . --font-path <dir> template/compsoc.typ

#import "/src/compsoc.typ": ieee-compsoc

#show: ieee-compsoc.with(
  title: [Bare Demo of IEEEtran.cls for \ IEEE Computer Society Journals],
  authors: [
    Michael Shell, _Member, IEEE,_ John Doe, _Fellow, OSA,_
    and Jane Doe, _Life Fellow, IEEE_
  ],
  header-left: [Journal of LaTeX Class Files, Vol. 14, No. 8, August 2015],
  header-right: [Shell #emph[et al.]: Bare Demo of IEEEtran.cls for IEEE Computer Society Journals],
  abstract: [The abstract goes here.],
  index-terms: [Computer Society, IEEE, IEEEtran, journal, LaTeX, paper, template.],
)

= Introduction
This demo file is intended to serve as a "starter file" for IEEE Computer
Society journal papers produced under LaTeX using IEEEtran.cls version 1.8b and
later. I wish you the best of success.

#align(right)[mds \ August 26, 2015]

== Subsection Heading Here
Subsection text here.

=== Subsubsection Heading Here
Subsubsection text here.

= Conclusion
The conclusion goes here.
