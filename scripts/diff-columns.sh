#!/bin/bash
# Compare every text baseline in a column of two PDFs, line by line.
#
#   scripts/diff-columns.sh mine.pdf reference.pdf [page] [max-x] [tolerance] [min-x]
#
# Prints both baselines and their difference for each line, and exits non-zero
# if the columns have different line counts or any line differs by more than
# the tolerance, 0.25pt by default.
#
# Ghostscript's txtwrite reports whole device pixels, which at its default 72dpi
# are whole points. Half-point errors hide behind that, so this runs it at
# 7200dpi for baselines to a hundredth of a point.
#
# The two documents must carry the same text in the column for the pairing to
# mean anything. max-x defaults to 300, the left column of a two-column page;
# give 9999 and a min-x of 300 for the right one.

set -u
[ $# -lt 2 ] && { echo "usage: $0 <pdf> <ref-pdf> [page] [max-x] [tolerance] [min-x]" >&2; exit 1; }
page="${3:-1}"; maxx="${4:-300}"; tol="${5:-0.25}"; minx="${6:-0}"

# lines <pdf> -> "baseline text" per line, top to bottom
lines() {
  gs -q -dBATCH -dNOPAUSE -sDEVICE=txtwrite -dTextFormat=0 -r7200 \
     -dFirstPage="$page" -dLastPage="$page" -sOutputFile=- "$1" 2>/dev/null \
  | grep -oE '<span bbox="[0-9-]+ [0-9-]+ [0-9-]+ [0-9-]+" font="[^"]*" size="[0-9.]+">|c="[^"]*"' \
  | awk -v maxx="$maxx" -v minx="$minx" '
      /^<span/ {
        match($0, /bbox="[0-9-]+ [0-9-]+/); b=substr($0, RSTART+6, RLENGTH-6)
        split(b, xy, " ")
        match($0, /size="[0-9.]+"/); s=substr($0, RSTART+6, RLENGTH-7)
        # Below 7.5pt are superscripts and the raised A of the LaTeX logo,
        # which sit on baselines of their own.
        keep = (xy[1] / 100 < maxx && xy[1] / 100 >= minx && s + 0 >= 7.5)
        key = sprintf("%09.2f", xy[2] / 100)
        if (keep && !(key in txt)) txt[key] = ""
        next
      }
      keep {
        match($0, /c="[^"]*"/); ch=substr($0, RSTART+3, RLENGTH-4)
        if (ch != "&#32;") txt[key] = txt[key] ch
      }
      END { for (k in txt) print k, txt[k] }' \
  | sort \
  | awk '
      # The lowered E of the LaTeX logo is a line of its own; drop it. Cells
      # set side by side can differ by a hundredth; merge them.
      $2 == "E" || $2 == "" { next }
      n > 0 && $1 - y[n] < 0.05 { t[n] = t[n] $2; next }
      { n++; y[n] = $1 + 0; t[n] = $2 }
      END { for (i = 1; i <= n; i++) printf "%.2f %s\n", y[i], substr(t[i], 1, 30) }'
}

paste -d'|' <(lines "$1") <(lines "$2") | awk -F'|' -v tol="$tol" '
  {
    split($1, a, " "); split($2, b, " ")
    if ($1 == "" || $2 == "") { printf "%8s %8s %7s  %s\n", a[1], b[1], "", a[2] b[2]; bad++; next }
    d = a[1] - b[1]
    printf "%8.2f %8.2f %+7.2f  %s\n", a[1], b[1], d, a[2]
    if (d > tol || d < -tol) bad++
  }
  END { exit bad > 0 }'
