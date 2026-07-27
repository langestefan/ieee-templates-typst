// Port of IEEE's official conference wrapper, IEEE-conference-template-062824.tex.
// Kept alongside the bare demo because it exercises author-row wrapping: six
// author blocks do not fit on one line and must break into two rows of three.

#import "/src/conference.typ": ieee-conference

#let ordinal(n, suffix) = [#n#super[#suffix]]

#let author(n, suffix) = (
  name: [#ordinal(n, suffix) Given Name Surname],
  affiliation: (
    [_dept. name of organization (of Aff.)_],
    [_name of organization (of Aff.)_],
    "City, Country",
    "email address or ORCID",
  ),
)

#show: ieee-conference.with(
  title: [
    Conference Paper Title\*
    #linebreak()
    #text(size: 8pt)[
      #super[\*]Note: Sub-titles are not captured for
      https\://ieeexplore.ieee.org and should not be used
    ]
  ],
  authors: (
    author(1, "st"),
    author(2, "nd"),
    author(3, "rd"),
    author(4, "th"),
    author(5, "th"),
    author(6, "th"),
  ),
  abstract: [
    This document is a model and instructions for LaTeX. This and the
    IEEEtran.cls file define the components of your paper [title, text, heads,
    etc.]. \*CRITICAL: Do Not Use Symbols, Special Characters, Footnotes, or
    Math in Paper Title or Abstract.
  ],
  index-terms: [component, formatting, style, styling, insert.],
)

= Introduction
This document is a model and instructions for LaTeX. Please observe the
conference page limits.

= Ease of Use

== Maintaining the Integrity of the Specifications
The IEEEtran class file is used to format your paper and style the text. All
margins, column widths, line spaces, and text fonts are prescribed; please do
not alter them.

= Prepare Your Paper Before Styling
Before you begin to format your paper, first write and save the content as a
separate text file.

== Abbreviations and Acronyms
Define abbreviations and acronyms the first time they are used in the text,
even after they have been defined in the abstract.

== Units
Use either SI (MKS) or CGS as primary units.

= Conclusion
The conclusion goes here.
