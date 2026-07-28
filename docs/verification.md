# Verification

The point of this port is that it is checked, not eyeballed.

```bash
scripts/check.sh
```

Compiles every template and asserts 83 landmark baselines against IEEE's compiled reference PDFs in
`reference/pdf/`. Every asserted landmark matches its reference exactly.

`tests/` holds a Typst port of each `bare_*.tex`, one per mode, which is what `check.sh` measures. They
are verification fixtures rather than things to start a paper from; `template/main.typ` is that.

## What is checked

| Mode | Reference |
|---|---|
| `ieee-conference` | `bare_conf.tex`, and IEEE's 2024-06-28 wrapper |
| `ieee-journal` | `bare_jrnl.tex`, two columns and one |
| `ieee-journal` with `technote` | `bare_jrnl.tex` compiled with the option |
| `ieee-journal` with `peerreview` | `bare_jrnl.tex` compiled with the option |
| `ieee-transmag` | `bare_jrnl_transmag.tex` |
| `ieee-compsoc` | `bare_jrnl_compsoc.tex` |
| `ieee-compsoc-conference` | `bare_conf_compsoc.tex` |

All on US Letter and A4. The landmarks are title, author block, abstract, index terms, first section
heading, the first body line after it, drop cap, running head, and column extent and line count.

`check.sh` also verifies that the preview images in `assets/` are current, by comparing a signature of
the rendered pages against `assets/previews.txt`. Regenerate both with `scripts/update-previews.sh`.

CI runs the same script on every push and pull request, on a runner with the Nimbus and TeX Gyre fonts
installed; a missing font fails the job rather than silently skipping the checks that need it.

## Measurement tools

- `scripts/baselines.sh <pdf> [page] [max-x]` prints true text baselines via Ghostscript's `txtwrite`.
  Use this rather than `pdftotext`, which only exposes ink bounding boxes; those shift by up to 2pt
  depending on whether a line happens to contain descenders, which is the same magnitude as the spacing
  being measured. Early measurements taken that way were wrong.
- `scripts/verify-geometry.sh <pdf> <page> [ref] [page]` reports text-block extent, line count and modal
  advance.

## Reference PDFs

`reference/pdf/` holds IEEE's compiled output, rendered with pdfTeX 1.40.27 from the `bare_*.tex`
skeletons in `reference/IEEEtran-1.8b/`, plus IEEE's own 2024-06-28 conference wrapper. They were
compiled by hand and are not reproducible by any command in this repo.

Upstream IEEEtran is frozen at V1.8b (2015/08/26), so these will not go stale.
