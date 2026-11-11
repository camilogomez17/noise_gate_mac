#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release
APP="build/NoNoise.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/NoNoiseMac "$APP/Contents/MacOS/NoNoiseMac"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "Built $APP"
