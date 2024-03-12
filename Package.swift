// swift-tools-version:5.10
import PackageDescription

let package:Package = .init(
    name: "swift-json",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "JSONAST", targets: ["JSONAST"]),
        .library(name: "JSONLegacy", targets: ["JSONLegacy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.3.4")),
        .package(url: "https://github.com/apple/swift-testing", .upToNextMinor(
            from: "0.5.1")),
    ],
    targets: [
        .target(name: "JSONAST"),

        .target(name: "JSONDecoding",
            dependencies: [
                .target(name: "JSONAST"),
                .product(name: "Grammar",
                    package: "swift-grammar",
                    moduleAliases: ["Testing": "_Testing"]),
            ]),

        .target(name: "JSONEncoding",
            dependencies: [
                .target(name: "JSONAST"),
            ]),

        .target(name: "JSONLegacy",
            dependencies: [
                .target(name: "JSONDecoding"),
            ]),

        .target(name: "JSONParsing",
            dependencies: [
                .target(name: "JSONAST"),
                .product(name: "Grammar",
                    package: "swift-grammar",
                    moduleAliases: ["Testing": "_Testing"]),
            ]),

        .target(name: "JSON",
            dependencies: [
                .target(name: "JSONDecoding"),
                .target(name: "JSONEncoding"),
                .target(name: "JSONParsing"),
            ]),

        .testTarget(name: "JSONTests",
            dependencies: [
                .target(name: "JSON"),
                .product(name: "Testing", package: "swift-testing"),
            ]),
    ]
)
