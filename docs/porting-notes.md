# Notes on porting IEEEtran to Typst

Things that cost real time here and are not obvious from the class source.

Three things cost real time here and are not obvious from the class source.

**TeX's point is 1/72.27in; Typst's is 1/72in.** Every dimension and font size in `IEEEtran.cls` needs
scaling by 72/72.27. Skip it and the layout drifts 0.37%, roughly 2.5pt down a column — enough to lose a
line off the page. It shows up as the class's `12pt` rendering at 11.955pt.

**`\vspace` and `v()` are not the same.** LaTeX's `\vspace` adds to the baselineskip, which already
contains the interline gap. Typst's `v()` adds on top of `par.spacing`, so a class value carried over
directly overshoots by exactly that spacing.

**Typst cannot indent only the first N lines of a paragraph.** `par` offers first-line and
all-but-first, nothing between. Both the drop cap and the biography photo need it, so
`src/common/textsplit.typ` splits the paragraph explicitly, binary-searching word count against a
measured height.
