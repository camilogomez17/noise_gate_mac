# NoNoise — macOS microphone noise gate

A native macOS menu-bar app and CoreAudio virtual microphone. This first MVP captures the
default microphone, applies an adjustable local threshold gate, and routes the processed signal
to **NoNoise Mic**. It has no cloud processing, telemetry, or auto-updater.

## Requirements
- macOS 13 or later
- Xcode Command Line Tools (Swift compiler, clang, codesign)
- Microphone permission
- Administrator access only to install/remove the CoreAudio virtual microphone driver

## Build from source
```sh
./build-driver.sh
./build-app.sh
``

## Install the virtual microphone
```sh
sudo ./install-driver.sh
``
This restarts `coreaudiod`, so audio briefly disconnects. The installer does not run automatically.

## Launch
```sh
open build/NoNoise.app
``
Open the microphone icon in the menu bar, adjust the gate threshold, and press **Start**.
Then select **NoNoise Mic** as the input in Zoom, Discord, Meet, OBS, or another app.

## Remove the virtual microphone
```sh
sudo ./uninstall-driver.sh
``

## MVP status
- [x] Native menu-bar app
- [x] Adjustable local noise gate
- [x] Dedicated CoreAudio virtual microphone
- [x] Build, install, and uninstall scripts
- [x] No updater or network dependency
- [ ] DeepFilterNet neural noise suppression (next milestone)
- [ ] Input-device selector, presets, metering, and packaging polish

The virtual microphone driver is derived from the MIT-licensed NoNoise Mic driver. See
`THIRD_PARTY_NOTICES/NoNoise-MIT.txt`. The app is a new minimal implementation, not a full
feature-for-feature reproduction of upstream NoNoise yet.
