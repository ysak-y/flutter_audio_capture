// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_audio_capture",
    platforms: [
        .iOS("13.6")
    ],
    products: [
        .library(name: "flutter-audio-capture", targets: ["flutter_audio_capture"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_audio_capture",
            dependencies: []
        )
    ]
)
