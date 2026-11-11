#!/bin/bash
set -euo pipefail
sudo rm -rf "/Library/Audio/Plug-Ins/HAL/NoNoiseMic.driver"
sudo killall coreaudiod 2>/dev/null || true
echo "NoNoise Mic driver removed."
