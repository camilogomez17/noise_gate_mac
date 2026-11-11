# NoNoise Mic — CoreAudio HAL driver

This AudioServerPlugIn driver is derived from the NoNoise Mic driver in
https://github.com/ivalsaraj/NoNoise-Mac and is redistributed under its MIT license.
The upstream copyright and license notice are retained in
`THIRD_PARTY_NOTICES/NoNoise-MIT.txt`.

It exposes an input-only device named **NoNoise Mic** and a hidden output-only device named
**NoNoise Mic Engine**. The app renders processed microphone audio to the hidden engine;
calling apps select the visible input device.

The driver runs inside macOS `coreaudiod`. Review the C source before installing it.
Installation requires administrator privileges and restarts `coreaudiod`, briefly interrupting
system audio.

Build and install:
```sh
./build-driver.sh
sudo ./install-driver.sh
``

Uninstall:
```sh
sudo ./uninstall-driver.sh
``
