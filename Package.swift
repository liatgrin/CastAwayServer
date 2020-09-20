// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScreenMirrorServer",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PerfectHTTPServer", url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
        .package(name: "PerfectWebSockets", url: "https://github.com/PerfectlySoft/Perfect-WebSockets.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ScreenMirrorServer",
            dependencies: ["PerfectHTTPServer", "PerfectWebSockets"]),
        .testTarget(
            name: "ScreenMirrorServerTests",
            dependencies: ["ScreenMirrorServer"]),
    ]
)
