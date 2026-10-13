// Side-by-side author blocks, as conference papers set them.

// Author fields accept either content or an array of lines. The array form
// mirrors the \\ separators in \IEEEauthorblockA and avoids escaping trouble,
// since an unescaped @ in markup would parse as a reference and a bare URL
// would autolink.
#let as-lines(x) = {
  if type(x) == array { x.map(l => [#l]).join(linebreak()) } else { x }
}

// Author blocks sit in naturally sized cells separated by equal glue, not in
// equal-width columns: an even three-way split would centre the first block at
// x=134.7 where the reference has it at 154.
//
// \and is \hfill between separate halign groups (IEEEtran.cls:4731), so the
// blocks form one horizontal list that TeX line-breaks when it overruns. Six
// authors therefore wrap to two rows of three. Typst grids do not wrap, so the
// packing is done explicitly here.
#let author-rows(cells, width: none, gap: 0pt) = context {
  let rows = ()
  let current = ()
  let used = 0pt
  for c in cells {
    // \and is \hfill, which has zero natural width, so no gap is reserved: the
    // blocks only have to fit the text width between them. Verified against the
    // nine-author probe, where LaTeX also breaks five and four.
    let needed = measure(c).width
    if current.len() > 0 and used + needed > width {
      rows.push(current)
      current = (c,)
      used = needed
    } else {
      current.push(c)
      used += needed
    }
  }
  if current.len() > 0 { rows.push(current) }

  stack(
    dir: ttb,
    spacing: gap,
    ..rows.map(r => block(width: 100%, grid(
      columns: (auto,) * r.len(),
      column-gutter: 1fr,
      ..r,
    ))),
  )
}
