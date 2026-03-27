// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MGLinker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(name: "MGLinker", targets: ["MGLinker"])
    ],
    targets: [
        .executableTarget(
            name: "MGLinker",
            path: "Sources"
        )
    ]
)