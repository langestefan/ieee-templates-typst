#import "@preview/ieee-templates:0.1.0": ieee-conference

#show: ieee-conference.with(
  title: [Paper Title],
  authors: (
    (
      name: "First Author",
      affiliation: (
        "Department, Organisation",
        "City, Country",
        "email@example.org",
      ),
    ),
    (
      name: "Second Author",
      affiliation: ("Department, Organisation", "City, Country"),
    ),
  ),
  // Funding notes go here; they render as an unmarked footnote on page one.
  // thanks: [This work was supported by ...],
  abstract: [
    The abstract goes here. IEEE sets it bold at 9pt, run in after the label.
  ],
  index-terms: [component, formatting, style],
  bibliography: bibliography("refs.bib"),
)

= Introduction
Sections number themselves `I.`, `II.` in centred small caps.

== Subsection
Subsections are italic and lettered `A.`, `B.`

=== Subsubsection
Subsubsections run into the paragraph, as IEEE sets them.

= Method
Reference figures as @fig and tables as @tbl; equations as @eq.

#figure(caption: [A figure caption.], rect(width: 60pt, height: 30pt)) <fig>

#figure(
  caption: [A Table Caption],
  table(
    columns: 2,
    [Heading], [Heading],
    [Cell], [Cell],
  ),
) <tbl>

$ E = m c^2 $ <eq>

= Conclusion
The conclusion goes here @example.
