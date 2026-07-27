# Known gaps

What this port does not do, and why. Every entry was established by measurement
against IEEE's own compiled PDFs in `reference/pdf/`, not by inspection.

## Not reproducible in Typst

**Last-page column balancing.** Typst fills page-level columns sequentially and
offers no balancing; neither `set page(columns:)` nor the `columns()` function
balances a final page, which was verified rather than assumed. `#colbreak()` is
the manual remedy.

## Unverified

**`peerreview` and `technote`.** Built from the class alone. No reference render
exists for either, so unlike the six verified modes there is nothing to check
them against. They are the only layouts here in that position.

**A4** is verified, against renders compiled specifically for it.

## Measured differences that remain

**Computer Society body headings run about 3pt tight per heading**, and the
first body line sits 8pt above the reference. The reference's source calls
`\IEEEraisesectionheading` on its opening section and this port does not
implement it, but that command raises content while the reference sits *lower*
than this port, so it does not explain the gap. Unresolved.

**The journal drop cap is 1pt above the reference**, 265 against 266. The only
landmark in any mode that is not exact.

## Deliberately not done

**Point sizes other than 10pt.** All four ladders are in `geometry.typ` and the
vertical geometry derives from them: `vertical-for(mode, pt)` reproduces every
line count the class documents. Wiring them through the layouts is mechanical
but unverifiable, since no reference render exists at any other size, and IEEE
papers are 10pt in practice. `parstart` and `biography` are already
parameterised; `headings` is not.

**`comsoc`.** Per the class changelog, V1.8b's Communications Society option
only swaps in the newtxmath math fonts, leaving it geometrically identical to a
plain journal. There is nothing to port.

**`IEEEeqnarray`.** Typst's native math aligns on `&` and breaks on `\`, which
is what that environment exists to work around in LaTeX. Only its sub-numbering
was missing, and `subequations` supplies that.

## Verification debt

**`author-row-gap` rests on two documents**, IEEE's 062824 wrapper and a
nine-author probe compiled for the purpose. 26pt satisfies the first and leaves
the probe 1pt short; 27pt the reverse; 26.5 satisfies both. A third document
would test it further.

**The title quantisation slack is calibrated, not derived.** The class's
`\@IEEENORMtitlevspace` sits below every valid range, short by roughly one line
advance, which matches the `[-\topskip]` offset `\IEEEquantizevspace` applies.
Adding exactly one advance fixes journal but leaves the bare conference demo
0.66pt short, so the cause is narrowed rather than settled. Measured bounds for
all three references are recorded in `geometry.typ`.
