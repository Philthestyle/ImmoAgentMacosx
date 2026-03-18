// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ImmoAgent",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ImmoAgent",
            path: "ImmoAgent"
        ),
    ]
)
