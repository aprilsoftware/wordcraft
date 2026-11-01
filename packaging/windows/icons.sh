#!/usr/bin/env bash
# Generate the committed Windows icon from April Software's approved 1024 px badge master.
#
# Needs ImageMagick 7 (`magick`) and the repository's existing xtask. Builds and package assembly
# use the committed ICO and do not need either tool.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MASTER="$ROOT/assets/april/badge_logo.png"
OUT="$ROOT/assets/app-icon/aprilwriter.ico"
EXPECTED=ccf2fadc8da0e3f6a52bde4e1895d45520cd269a7690e1ecd0c151cdd0d6bb81
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v magick >/dev/null || { echo "error: ImageMagick 7 (magick) is required" >&2; exit 1; }
printf '%s  %s\n' "$EXPECTED" "$MASTER" | sha256sum --check --status || {
  echo "error: $MASTER is not the approved April badge master" >&2
  exit 1
}

pngs=()
for size in 16 20 24 32 40 48 64 128 256; do
  png="$TMP/aprilwriter-$size.png"
  magick "$MASTER" -filter Lanczos -resize "${size}x${size}" -strip \
    -define png:exclude-chunk=date,time "PNG32:$png"
  dimensions="$(magick identify -format '%wx%h' "$png")"
  [[ "$dimensions" = "${size}x${size}" ]] || {
    echo "error: generated $png is $dimensions" >&2
    exit 1
  }
  pngs+=("$png")
done

(cd "$ROOT" && cargo run --quiet --locked -p xtask -- ico "$OUT" "${pngs[@]}")
expected_dimensions=$'16x16\n20x20\n24x24\n32x32\n40x40\n48x48\n64x64\n128x128\n256x256'
actual_dimensions="$(magick identify -format '%wx%h\n' "$OUT")"
[[ "$actual_dimensions" = "$expected_dimensions" ]] || {
  printf 'error: unexpected ICO frames:\n%s\n' "$actual_dimensions" >&2
  exit 1
}
echo "April Writer Windows icon written to $OUT"
