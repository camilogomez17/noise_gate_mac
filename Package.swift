// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NoNoiseMac",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "NoNoiseMac", targets: ["NoNoiseMac"])],
    targets: [
        .executableTarget(
            name: "NoNoiseMac",
            path: "Sources/NoNoiseMac",
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("AudioToolbox")
            ]
        )
    ]
)
