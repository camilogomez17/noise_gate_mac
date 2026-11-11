#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
DRIVER="NoNoiseMic.driver"
DEST="/Library/Audio/Plug-Ins/HAL"
[ -d "$DRIVER" ] || { echo "Run ./build-driver.sh first."; exit 1; }
echo "This installs a CoreAudio HAL driver and restarts coreaudiod; audio will briefly stop."
sudo rm -rf "$DEST/$DRIVER"
sudo cp -R "$DRIVER" "$DEST/"
sudo killall coreaudiod 2>/dev/null || true
sleep 3
if system_profiler SPAudioDataType 2>/dev/null | grep -q "NoNoise Mic"; then
  echo "NoNoise Mic is installed."
else
  echo "Driver did not appear. Inspect Console.app for coreaudiod errors."
  exit 1
fi
