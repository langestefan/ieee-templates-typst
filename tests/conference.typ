#import "/src/conference.typ": ieee-conference

#show: ieee-conference.with(
  title: [Bare Demo of IEEEtran.cls \ for IEEE Conferences],
  authors: (
    (
      name: "Michael Shell",
      affiliation: (
        "School of Electrical and",
        "Computer Engineering",
        "Georgia Institute of Technology",
        "Atlanta, Georgia 30332–0250",
        "Email: http://www.michaelshell.org/contact.html",
      ),
    ),
    (
      name: "Homer Simpson",
      affiliation: (
        "Twentieth Century Fox",
        "Springfield, USA",
        "Email: homer@thesimpsons.com",
      ),
    ),
    (
      name: ("James Kirk", "and Montgomery Scott"),
      affiliation: (
        "Starfleet Academy",
        "San Francisco, California 96678–2391",
        "Telephone: (800) 555–1212",
        "Fax: (888) 555–1212",
      ),
    ),
  ),
  abstract: [The abstract goes here.],
  bibliography: bibliography("refs.bib"),
)

= Introduction
This demo file is intended to serve as a "starter file" for IEEE conference
papers produced under LaTeX using IEEE-?tran.cls version 1.8b and later.
I wish you the best of success.

#align(right)[mds]

#align(right)[August 26, 2015]

== Subsection Heading Here
Subsection text here.

=== Subsubsection Heading Here
Subsubsection text here.

= Conclusion
The conclusion goes here @kopka1999.

#heading(numbering: none)[Acknowledgment]
The authors would like to thank\u{2026}

