# MVP architecture

```text
Built-in/default microphone
        |
        v
AVAudioEngine input tap
        |
        v
RMS threshold gate (local Float32 processing)
        |
        v
AVAudioPlayerNode -> AVAudioEngine output
        |
        v
Hidden "NoNoise Mic Engine" CoreAudio device
        |
        v
Shared C ring buffer in NoNoiseMic.driver
        |
        v
Visible "NoNoise Mic" input device
        |
        v
Zoom / Meet / Discord / OBS
```

The app resolves the hidden engine by its CoreAudio UID and explicitly routes its output
unit there. It does not intentionally route processed microphone audio to the speakers.
The driver serves silence for samples not yet written to its ring buffer.

## Trust and privilege boundaries

- The app performs signal processing locally and has no updater or network client.
- The HAL driver is loaded by `coreaudiod`, a system audio service.
- Installing or removing the driver requires administrator privileges and restarts
  `coreaudiod`.
- The build scripts compile source locally and ad-hoc sign the app/driver; this is not
  Apple Developer ID signing or notarization.
- The virtual driver source is derived from the upstream MIT-licensed NoNoise Mic driver.
  See `THIRD_PARTY_NOTICES/NoNoise-MIT.txt`.

## Verification still required

1. Compile on macOS using the included scripts.
2. Install the driver and confirm both CoreAudio devices appear.
3. Start the menu-bar app and grant microphone permission.
4. Select NoNoise Mic in a recording/call app and confirm speech passes.
5. Confirm room noise falls below threshold and speech opens the gate without clipping.
6. Stop the app and confirm the virtual mic outputs silence.
