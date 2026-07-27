#!/bin/bash
# Compare a compiled Typst page against an IEEEtran reference render.
#
#   scripts/verify-geometry.sh mine.pdf 2 reference/pdf/whatever.pdf 1
#
# Reports the text-block extent, the left-column baseline count and the modal
# line advance. Body text should show 56 lines per column for conference mode
# and an advance of 11.955pt, which is 12 TeX points.

set -u
[ $# -lt 2 ] && { echo "usage: $0 <pdf> <page> [ref-pdf ref-page]" >&2; exit 1; }

boxes() {
  pdftotext -bbox -f "$2" -l "$2" "$1" - 2>/dev/null \
  | grep -oE 'xMin="[0-9.]+" yMin="[0-9.]+" xMax="[0-9.]+" yMax="[0-9.]+"' \
  | sed -E 's/[a-zA-Z]+="//g; s/"//g'
}

report() {
  local f="$1" p="$2"
  echo "$f page $p"
  boxes "$f" "$p" | awk '
    NR==1 {xmin=$1; xmax=$3}
    {if($1<xmin)xmin=$1; if($3>xmax)xmax=$3}
    END {printf "  x %.1f..%.1f  width %.1f\n", xmin, xmax, xmax-xmin}'
  boxes "$f" "$p" | awk '$1 < 300 {printf "%.3f\n", $4}' | sort -n | uniq | awk '
    {v[NR]=$1}
    END {
      printf "  left column: %d baselines, y %.1f..%.1f, span %.1f\n", NR, v[1], v[NR], v[NR]-v[1]
      for (i=2; i<=NR; i++) { d=sprintf("%.2f", v[i]-v[i-1]); c[d]++ }
      best=""; n=0
      for (k in c) if (c[k]>n) { n=c[k]; best=k }
      printf "  modal advance: %s (x%d)\n", best, n
    }'
}

report "$1" "$2"
[ $# -ge 4 ] && { echo; report "$3" "$4"; }
