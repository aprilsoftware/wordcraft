#!/usr/bin/env bash
# Generate committed Linux hicolor icons from April Software's approved 1024 px badge master.
#
# Needs ImageMagick 7 (`magick`). Builds and package assembly use the committed outputs and do not
# need ImageMagick.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MASTER="$ROOT/assets/april/badge_logo.png"
OUT="$ROOT/assets/app-icon/hicolor"
ID=com.aprilsoftware.aprilwriter
EXPECTED=ccf2fadc8da0e3f6a52bde4e1895d45520cd269a7690e1ecd0c151cdd0d6bb81
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v magick >/dev/null || { echo "error: ImageMagick 7 (magick) is required" >&2; exit 1; }
printf '%s  %s\n' "$EXPECTED" "$MASTER" | sha256sum --check --status || {
  echo "error: $MASTER is not the approved April badge master" >&2
  exit 1
}

for size in 16 24 32 48 64 128 256 512; do
  dir="$TMP/hicolor/${size}x${size}/apps"
  dst="$dir/$ID.png"
  mkdir -p "$dir"
  magick "$MASTER" -filter Lanczos -resize "${size}x${size}" -strip \
    -define png:exclude-chunk=date,time "PNG32:$dst"
  dimensions="$(magick identify -format '%wx%h' "$dst")"
  [[ "$dimensions" = "${size}x${size}" ]] || {
    echo "error: generated $dst is $dimensions" >&2
    exit 1
  }
done

rm -rf "$OUT"
mv "$TMP/hicolor" "$OUT"
echo "April Writer Linux icons written to $OUT"
