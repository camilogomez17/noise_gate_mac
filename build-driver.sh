#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
ARCH="$(uname -m)"
case "$ARCH" in arm64|x86_64) ;; *) echo "Unsupported architecture: $ARCH"; exit 1 ;; esac
DRIVER="NoNoiseMic.driver"
SRC="Driver/NoNoiseMic"
rm -rf "$DRIVER"
mkdir -p "$DRIVER/Contents/MacOS"
cp "$SRC/Info.plist" "$DRIVER/Contents/Info.plist"
clang -bundle -std=c11 -O2 -arch "$ARCH" \
  -framework CoreAudio -framework CoreFoundation -framework AudioToolbox \
  "$SRC/NoNoiseMic.c" "$SRC/nn_ring.c" "$SRC/nn_clock.c" \
  -o "$DRIVER/Contents/MacOS/NoNoiseMic"
codesign --force --sign - "$DRIVER"
codesign -dv --verbose=4 "$DRIVER" 2>&1 | sed -n '1,6p'
echo "Built $DRIVER for $ARCH"
