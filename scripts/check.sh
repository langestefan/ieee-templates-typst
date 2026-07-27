#!/bin/bash
# Regression check: compile every template and assert that landmark baselines
# still match the IEEEtran reference renders.
#
#   scripts/check.sh
#
# Expected values come from reference/pdf/ and reference/conference-template-*/,
# measured with scripts/baselines.sh. A change to geometry.typ affects all three
# templates at once, so this exists to catch drift that is invisible by eye.
#
# Tolerance is 1pt because Ghostscript's txtwrite reports integer baselines.

set -u
cd "$(dirname "$0")/.." || exit 1

TOL=1
pass=0
fail=0
# Output goes inside the repo: tmp/ is gitignored, and writing outside the
# project directory is not always permitted.
out=tmp/check
rm -rf "$out"; mkdir -p "$out"

# baseline <pdf> <page> <regex> -> first matching baseline, or empty
baseline() {
  ./scripts/baselines.sh "$1" "$2" 9999 | awk -v re="$3" '$0 ~ re {print $1; exit}'
}

check() {
  local label="$1" got="$2" want="$3"
  if [ -z "$got" ]; then
    printf '  FAIL  %-34s not found\n' "$label"; fail=$((fail + 1)); return
  fi
  local d
  d=$(awk -v a="$got" -v b="$want" 'BEGIN{d=a-b; print (d<0?-d:d)}')
  if awk -v d="$d" -v t="$TOL" 'BEGIN{exit !(d <= t)}'; then
    printf '  ok    %-34s %s\n' "$label" "$got"; pass=$((pass + 1))
  else
    printf '  FAIL  %-34s got %s want %s\n' "$label" "$got" "$want"; fail=$((fail + 1))
  fi
}

build() {
  if ! typst compile --root . "$1" "$out/$2.pdf" 2>"$out/$2.err"; then
    printf '  FAIL  %-34s did not compile\n' "$2"
    grep -v "unknown font family" "$out/$2.err" | sed 's/^/          /' | head -5
    fail=$((fail + 1)); return 1
  fi
  printf '  ok    %-34s compiled (%s pages)\n' "$2" \
    "$(pdfinfo "$out/$2.pdf" | awk '/^Pages/{print $2}')"
  pass=$((pass + 1))
}

echo "conference: bare demo"
if build template/main.typ conf; then
  check "title"        "$(baseline "$out/conf.pdf" 1 'Bare Demo')"    71
  check "author names" "$(baseline "$out/conf.pdf" 1 'Michael')"     131
  check "abstract"     "$(baseline "$out/conf.pdf" 1 'Abstract')"    238
  check "section 1"    "$(baseline "$out/conf.pdf" 1 'Introduction')" 257
  # IEEEtran.cls:4492 puts 0.3\baselineskip between the References heading and
  # the list, and \IEEEbibitemsep is effectively zero so entries are one line
  # apart. The reference measures 15 then 9.
  refh=$(baseline "$out/conf.pdf" 1 'References')
  ref1=$(./scripts/baselines.sh "$out/conf.pdf" 1 300 | grep -A1 'References' | tail -1 | awk '{print $1}')
  check "refs heading to entry 1" "$(awk -v a="$ref1" -v b="$refh" 'BEGIN{print a-b}')" 15
fi

echo "conference: IEEE 062824 wrapper, two author rows"
if build template/conference-062824.typ c62; then
  check "title"          "$(baseline "$out/c62.pdf" 1 'Conference Paper')" 71
  check "subtitle"       "$(baseline "$out/c62.pdf" 1 'Note: Sub-titles')" 99
  check "author row 1"   "$(baseline "$out/c62.pdf" 1 '1 Given')"         131
  check "author row 2"   "$(baseline "$out/c62.pdf" 1 '4 Given')"         205
  check "abstract"       "$(baseline "$out/c62.pdf" 1 'Abstract')"        298
fi

echo "journal"
if build template/journal.typ jrnl; then
  check "running head" "$(baseline "$out/jrnl.pdf" 1 'Journal of')"  31
  check "title"        "$(baseline "$out/jrnl.pdf" 1 'Bare Demo')"   77
  check "author line"  "$(baseline "$out/jrnl.pdf" 1 'Michael')"    128
  check "abstract"     "$(baseline "$out/jrnl.pdf" 1 'Abstract')"   184
  # The drop cap's baseline sits on the second body line, one line below the
  # first. Catches the offset conversion in parstart.typ silently breaking.
  check "drop cap"     "$(baseline "$out/jrnl.pdf" 1 '29\\.[0-9]+pt  T')" 260
  # Appendices letter their sections and title them "Appendix A" on a line of
  # their own. Presence is what matters here, not the exact baseline.
  if ./scripts/baselines.sh "$out/jrnl.pdf" 1 9999 | grep -q 'Appendix.*B'; then
    printf '  ok    %-34s present\n' "appendix lettering"; pass=$((pass + 1))
  else
    printf '  FAIL  %-34s missing\n' "appendix lettering"; fail=$((fail + 1))
  fi
  # The biography placeholder box, drawn when no photo is supplied.
  if ./scripts/baselines.sh "$out/jrnl.pdf" 1 9999 | grep -q 'PHOTO'; then
    printf '  ok    %-34s present\n' "biography photo box"; pass=$((pass + 1))
  else
    printf '  FAIL  %-34s missing\n' "biography photo box"; fail=$((fail + 1))
  fi
fi

echo "A4"
# Verified against real IEEE A4 renders. a4paper changes only the sheet
# dimensions for conference and journal mode: \if@IEEEusingAfourpaper is
# referenced once outside the option declaration and that is inside the compsoc
# branch (IEEEtran.cls:1773). So every vertical landmark matches US Letter and
# only the side margins move, from 48.96pt to 40.60pt.
for pair in "template/main.typ:conf-a4:ieee-conference" \
            "template/journal.typ:jrnl-a4:ieee-journal"; do
  src=${pair%%:*}; rest=${pair#*:}; tag=${rest%%:*}; fn=${rest##*:}
  sed "s|^#show: $fn.with(|#show: $fn.with(\n  paper: \"a4\",|" "$src" > "$out/$tag.typ"
  cp template/refs.bib "$out/refs.bib" 2>/dev/null
  build "$out/$tag.typ" "$tag" || continue
done

if [ -f "$out/conf-a4.pdf" ]; then
  ref=reference/pdf/IEEE_Bare_Demo_Template_for_Conferences_A4.pdf
  check "A4 conf title"    "$(baseline "$out/conf-a4.pdf" 1 'Bare Demo')"    "$(baseline "$ref" 1 'BareDemo')"
  check "A4 conf authors"  "$(baseline "$out/conf-a4.pdf" 1 'Michael')"      "$(baseline "$ref" 1 'Michael')"
  check "A4 conf abstract" "$(baseline "$out/conf-a4.pdf" 1 'Abstract')"     "$(baseline "$ref" 1 'Abstract')"
  left=$(pdftotext -bbox -f 1 -l 1 "$out/conf-a4.pdf" - 2>/dev/null \
         | grep -oE 'xMin="[0-9.]+"' | sed -E 's/[^0-9.]//g' | sort -n | head -1)
  check "A4 left edge"     "$left" 40.6
fi
if [ -f "$out/jrnl-a4.pdf" ]; then
  ref=reference/pdf/IEEE_Journal_Paper_Template_A4.pdf
  check "A4 jrnl head"     "$(baseline "$out/jrnl-a4.pdf" 1 'Journal of')"   "$(baseline "$ref" 1 'JOURNAL')"
  check "A4 jrnl title"    "$(baseline "$out/jrnl-a4.pdf" 1 'Bare Demo')"    "$(baseline "$ref" 1 'BareDemo')"
  check "A4 jrnl abstract" "$(baseline "$out/jrnl-a4.pdf" 1 'Abstract')"     "$(baseline "$ref" 1 'Abstract')"
fi

echo "geometry invariants"
cols=$(./scripts/baselines.sh "$out/conf.pdf" 1 300 | wc -l)
printf '  info  %-34s %s baselines in left column\n' "conference column" "$cols"

echo
if [ "$fail" -eq 0 ]; then
  echo "$pass checks passed"
else
  echo "$pass passed, $fail FAILED"
fi
exit $((fail > 0))
