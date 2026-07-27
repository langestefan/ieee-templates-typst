// IEEE Computer Society conference, matching bare_conf_compsoc.tex.
//
// Unlike Computer Society journals, these are set in Times, so no extra fonts
// are needed. Sections are numbered 1., 1.1. with trailing periods and set in
// bold roman flush left.

#import "/src/compsoc.typ": ieee-compsoc-conference

#show: ieee-compsoc-conference.with(
  title: [Bare Demo of IEEEtran.cls for \ IEEE Computer Society Conferences],
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
      affiliation: ("Twentieth Century Fox", "Springfield, USA", "Email: homer@thesimpsons.com"),
    ),
    (
      name: ("James Kirk", "and Montgomery Scott"),
      affiliation: (
        "Starfleet Academy",
        "San Francisco, California 96678-2391",
        "Telephone: (800) 555–1212",
        "Fax: (888) 555–1212",
      ),
    ),
  ),
  abstract: [The abstract goes here.],
)

= Introduction
This demo file is intended to serve as a "starter file" for IEEE Computer
Society conference papers produced under LaTeX using IEEEtran.cls version 1.8b
and later. I wish you the best of success.

#align(right)[mds \ August 26, 2015]

== Subsection Heading Here
Subsection text here.

= Conclusion
The conclusion goes here.
