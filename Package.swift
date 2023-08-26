// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacSwiftUI",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MacSwiftUI",
            targets: ["MacSwiftUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ChimeHQ/Neon.git", from: "0.5.1"),
        .package(url: "https://github.com/alex-pinkus/tree-sitter-swift.git", branch: "with-generated-files")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MacSwiftUI",
            dependencies: [
                .product(name: "Neon", package: "Neon"),
                .product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
            ]),
        .testTarget(
            name: "MacSwiftUITests",
            dependencies: ["MacSwiftUI"]),
    ]
)
