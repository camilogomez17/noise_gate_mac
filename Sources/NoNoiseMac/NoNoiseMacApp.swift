import SwiftUI
import AVFoundation
import AudioToolbox
import CoreAudio
import Combine

@main
struct NoNoiseMacApp: App {
    @StateObject private var audio = AudioPipeline()

    var body: some Scene {
        MenuBarExtra("NoNoise", systemImage: "mic.fill") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("NoNoise Mic").font(.headline)
                    Spacer()
                    Circle().fill(audio.isRunning ? .green : .secondary).frame(width: 8, height: 8)
                }
                Text(audio.status).font(.caption).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Divider()
                HStack {
                    Text("Gate threshold")
                    Spacer()
                    Text("\(Int(audio.thresholdDB)) dB").monospacedDigit()
                }
                Slider(value: $audio.thresholdDB, in: -60.0 ... -20.0, step: 1.0)
                HStack {
                    Button(audio.isRunning ? "Stop" : "Start") {
                        if audio.isRunning { audio.stop() } else { audio.start() }
                    }
                    .keyboardShortcut(.defaultAction)
                    Spacer()
                    Button("Quit") { NSApplication.shared.terminate(nil) }
                }
                Text("Processing is local. Select “NoNoise Mic” as the microphone in your calling app.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(width: 300)
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
final class AudioPipeline: ObservableObject {
    @Published private(set) var isRunning = false
    @Published var thresholdDB: Double = -42
    @Published private(set) var status = "Install the NoNoise Mic driver to begin."

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var gain: Float = 0
    private var tapInstalled = false
    private var playerAttached = false

    func start() {
        guard !isRunning else { return }
        do {
            guard let outputDevice = Self.deviceID(forUID: "NoNoiseMic:engine:48k2ch") else {
                throw PipelineError.driverMissing
            }
            let input = engine.inputNode
            let inputFormat = input.outputFormat(forBus: 0)
            guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
                throw PipelineError.noInput
            }
            if !playerAttached {
                engine.attach(player)
                engine.connect(player, to: engine.mainMixerNode, format: inputFormat)
                playerAttached = true
            }
            guard let outputUnit = engine.outputNode.audioUnit else {
                throw PipelineError.outputUnavailable
            }
            var selectedDevice = outputDevice
            let routeStatus = AudioUnitSetProperty(
                outputUnit, kAudioOutputUnitProperty_CurrentDevice,
                kAudioUnitScope_Global, 0, &selectedDevice,
                UInt32(MemoryLayout<AudioDeviceID>.size)
            )
            guard routeStatus == noErr else { throw PipelineError.routeFailed(routeStatus) }

            input.installTap(onBus: 0, bufferSize: 512, format: inputFormat) { [weak self] buffer, _ in
                guard let self, let channels = buffer.floatChannelData else { return }
                let frames = Int(buffer.frameLength)
                let channelCount = Int(buffer.format.channelCount)
                guard frames > 0, channelCount > 0 else { return }
                var sum: Float = 0
                for channel in 0..<channelCount {
                    for frame in 0..<frames {
                        let sample = channels[channel][frame]
                        sum += sample * sample
                    }
                }
                let rms = sqrtf(sum / Float(frames * channelCount))
                let threshold = powf(10, Float(self.thresholdDB) / 20)
                let target: Float = rms >= threshold ? 1.0 : 0.015
                for frame in 0..<frames {
                    self.gain += (target - self.gain) * (target > self.gain ? 0.0025 : 0.00035)
                    for channel in 0..<channelCount {
                        channels[channel][frame] *= self.gain
                    }
                }
                self.player.scheduleBuffer(buffer, completionHandler: nil)
            }
            tapInstalled = true
            engine.prepare()
            try engine.start()
            player.play()
            isRunning = true
            status = "Live — choose “NoNoise Mic” in your calling app."
        } catch {
            stop()
            status = error.localizedDescription
        }
    }

    func stop() {
        if tapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        player.stop()
        engine.stop()
        isRunning = false
        status = "Stopped."
    }

    private static func deviceID(forUID uid: String) -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyTranslateUIDToDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var uidString = uid as CFString
        var deviceID = AudioDeviceID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        let result = withUnsafePointer(to: &uidString) { pointer in
            AudioObjectGetPropertyData(
                AudioObjectID(kAudioObjectSystemObject), &address,
                UInt32(MemoryLayout<CFString>.size), pointer, &size, &deviceID
            )
        }
        return result == noErr && deviceID != kAudioObjectUnknown ? deviceID : nil
    }
}

private enum PipelineError: LocalizedError {
    case driverMissing, noInput, outputUnavailable, routeFailed(OSStatus)
    var errorDescription: String? {
        switch self {
        case .driverMissing: return "NoNoise Mic driver is not installed. Build and install it with the included scripts."
        case .noInput: return "macOS did not provide a usable microphone input."
        case .outputUnavailable: return "Could not access the audio output unit."
        case .routeFailed(let status): return "Could not route audio to the virtual microphone (Core Audio error \(status))."
        }
    }
}
