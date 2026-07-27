#!/bin/bash
# Regenerate the README preview images and the signature that check.sh uses to
# tell whether they have gone stale.
#
#   scripts/update-previews.sh
#
# Run this after any change that moves the layout of the conference or journal
# templates, then commit assets/ along with the change.

set -eu
cd "$(dirname "$0")/.."

# --signature-only recomputes the signature without touching assets/, which is
# how check.sh asks whether the committed images are still current.
SIGNATURE_ONLY=0
[ "${1:-}" = "--signature-only" ] && SIGNATURE_ONLY=1

RES=110

# Which template each preview is rendered from.
# Rendered from the reference ports in tests/, which exercise every feature,
# rather than from the starter, which is deliberately sparse.
PREVIEWS="preview-conference:tests/conference.typ preview-journal:tests/journal.typ"

mkdir -p tmp/previews assets

# The signature is a baseline dump rather than an image hash. Pixels depend on
# the font build and the renderer version, so a hash would differ between
# machines and make the check useless in CI; baselines are integers produced by
# the same ghostscript path the reference checks already rely on.
sig() {
  ./scripts/baselines.sh "$1" 1 9999 | awk '{printf "%s %s %s\n", $1, $3, $4}'
}

: > tmp/previews/signature.new

for entry in $PREVIEWS; do
  name=${entry%%:*}
  src=${entry##*:}

  typst compile --root . "$src" "tmp/previews/$name.pdf"
  if [ "$SIGNATURE_ONLY" -eq 0 ]; then
    pdftoppm -r "$RES" -f 1 -l 1 -png "tmp/previews/$name.pdf" "tmp/previews/$name"
    mv "tmp/previews/$name-1.png" "assets/$name.png"
  fi

  {
    echo "# $name <- $src"
    sig "tmp/previews/$name.pdf"
  } >> tmp/previews/signature.new
done

if [ "$SIGNATURE_ONLY" -eq 1 ]; then exit 0; fi

cp tmp/previews/signature.new assets/previews.txt

echo "Regenerated:"
for entry in $PREVIEWS; do echo "  assets/${entry%%:*}.png"; done
echo "  assets/previews.txt"
