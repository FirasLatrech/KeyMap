// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KeyMap",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "KeyMap", targets: ["KeyMap"])
    ],
    targets: [
        .executableTarget(
            name: "KeyMap",
            path: "KeyMap",
            exclude: ["Resources/Info.plist"]
        ),
        .testTarget(
            name: "KeyMapTests",
            dependencies: ["KeyMap"],
            path: "KeyMapTests"
        )
    ]
)
