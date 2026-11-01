#!/usr/bin/env bash
# Generate the committed macOS icon from April Software's approved 1024 px badge master.
#
# Needs ImageMagick 7 (`magick`) and Python 3. Builds and package assembly use the committed ICNS
# and do not need either tool.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MASTER="$ROOT/assets/april/badge_logo.png"
OUT="$ROOT/assets/app-icon/aprilwriter.icns"
EXPECTED=ccf2fadc8da0e3f6a52bde4e1895d45520cd269a7690e1ecd0c151cdd0d6bb81
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v magick >/dev/null || { echo "error: ImageMagick 7 (magick) is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "error: Python 3 is required" >&2; exit 1; }
printf '%s  %s\n' "$EXPECTED" "$MASTER" | sha256sum --check --status || {
  echo "error: $MASTER is not the approved April badge master" >&2
  exit 1
}

for size in 16 32 64 128 256 512 1024; do
  png="$TMP/aprilwriter-$size.png"
  magick "$MASTER" -filter Lanczos -resize "${size}x${size}" -strip \
    -define png:exclude-chunk=date,time "PNG32:$png"
  dimensions="$(magick identify -format '%wx%h' "$png")"
  [[ "$dimensions" = "${size}x${size}" ]] || {
    echo "error: generated $png is $dimensions" >&2
    exit 1
  }
done

python3 - "$TMP" "$OUT" <<'PY'
import struct
import sys
from pathlib import Path

source = Path(sys.argv[1])
out = Path(sys.argv[2])
frames = [
    (b"icp4", 16),
    (b"ic11", 32),   # 16 pt @2x
    (b"icp5", 32),
    (b"ic12", 64),   # 32 pt @2x
    (b"icp6", 64),
    (b"ic07", 128),
    (b"ic13", 256),  # 128 pt @2x
    (b"ic08", 256),
    (b"ic14", 512),  # 256 pt @2x
    (b"ic09", 512),
    (b"ic10", 1024),
]
chunks = []
for kind, size in frames:
    png = (source / f"aprilwriter-{size}.png").read_bytes()
    if png[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"error: {size} px frame is not PNG")
    width, height = struct.unpack(">II", png[16:24])
    if (width, height) != (size, size):
        raise SystemExit(f"error: {kind.decode()} is {width}x{height}, expected {size}x{size}")
    chunks.append(kind + struct.pack(">I", len(png) + 8) + png)
payload = b"".join(chunks)
out.write_bytes(b"icns" + struct.pack(">I", len(payload) + 8) + payload)
PY

echo "April Writer macOS icon written to $OUT"
