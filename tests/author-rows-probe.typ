// Nine author blocks, compiled to give a second measurement of the author-row
// gap. IEEE's 062824 wrapper is the only other reference with more than one
// row, and one document cannot distinguish a correct constant from one fitted
// to a single boundary. LaTeX breaks these five and four, as this does.

#import "/src/conference.typ": ieee-conference
#show: ieee-conference.with(
  title: [Author Row Spacing Probe],
  authors: (
    (
      name: "Alpha One",
      affiliation: (
        "Department Number 1",
        "Institute of Testing",
        "City 1, Country",
      ),
    ),
    (
      name: "Bravo Two",
      affiliation: (
        "Department Number 2",
        "Institute of Testing",
        "City 2, Country",
      ),
    ),
    (
      name: "Charlie Three",
      affiliation: (
        "Department Number 3",
        "Institute of Testing",
        "City 3, Country",
      ),
    ),
    (
      name: "Delta Four",
      affiliation: (
        "Department Number 4",
        "Institute of Testing",
        "City 4, Country",
      ),
    ),
    (
      name: "Echo Five",
      affiliation: (
        "Department Number 5",
        "Institute of Testing",
        "City 5, Country",
      ),
    ),
    (
      name: "Foxtrot Six",
      affiliation: (
        "Department Number 6",
        "Institute of Testing",
        "City 6, Country",
      ),
    ),
    (
      name: "Golf Seven",
      affiliation: (
        "Department Number 7",
        "Institute of Testing",
        "City 7, Country",
      ),
    ),
    (
      name: "Hotel Eight",
      affiliation: (
        "Department Number 8",
        "Institute of Testing",
        "City 8, Country",
      ),
    ),
    (
      name: "India Nine",
      affiliation: (
        "Department Number 9",
        "Institute of Testing",
        "City 9, Country",
      ),
    ),
  ),
  abstract: [The abstract goes here.],
)
= Introduction
Body text here.
