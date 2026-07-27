#!/bin/bash
# Print the text baselines of a PDF page, one line per baseline.
#
#   scripts/baselines.sh file.pdf [page] [max-x]
#
# Ghostscript's txtwrite device reports each span's baseline rather than an ink
# bounding box, which pdftotext cannot do. That matters for checking vertical
# spacing: ink extent shifts by up to 2pt depending on whether a line happens to
# contain descenders, which is the same magnitude as the spacing being measured.
#
# max-x restricts output to a single column; it defaults to 300 for the left
# column of a two-column IEEE page.

set -u
[ $# -lt 1 ] && { echo "usage: $0 <pdf> [page] [max-x]" >&2; exit 1; }
f="$1"; p="${2:-1}"; maxx="${3:-300}"

gs -q -dBATCH -dNOPAUSE -sDEVICE=txtwrite -dTextFormat=0 \
   -dFirstPage="$p" -dLastPage="$p" -sOutputFile=- "$f" 2>/dev/null \
| grep -oE '<span bbox="[0-9.-]+ [0-9.-]+ [0-9.-]+ [0-9.-]+" font="[^"]*" size="[0-9.]+">|c="[^"]*"' \
| awk -v maxx="$maxx" '
    /^<span/ {
      match($0, /bbox="[0-9.-]+ [0-9.-]+/); b=substr($0, RSTART+6, RLENGTH-6)
      split(b, xy, " "); x=xy[1]+0; y=xy[2]+0
      match($0, /size="[0-9.]+"/); s=substr($0, RSTART+6, RLENGTH-7)
      keep = (x < maxx)
      if (keep) { key=sprintf("%.2f", y); size[key]=s; txt[key]=txt[key] }
      next
    }
    keep {
      match($0, /c="[^"]*"/); ch=substr($0, RSTART+3, RLENGTH-4)
      if (ch=="&#32;") ch=" "
      txt[key]=txt[key] ch
    }
    END {
      n=0; for (k in txt) ys[n++]=k+0
      for (i=0;i<n;i++) for (j=i+1;j<n;j++) if (ys[j]<ys[i]) {t=ys[i];ys[i]=ys[j];ys[j]=t}
      prev=-1
      for (i=0;i<n;i++) {
        k=sprintf("%.2f", ys[i])
        gap = (prev<0) ? 0 : ys[i]-prev
        printf "%8.2f  %+6.2f  %5.2fpt  %s\n", ys[i], gap, size[k], substr(txt[k], 1, 52)
        prev=ys[i]
      }
    }'
