// swift-tools-version:6.2
import PackageDescription

let package: Package = .init(
    name: "swift-json",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
    products: [
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "JSONAST", targets: ["JSONAST"]),
        .library(name: "JSONLegacy", targets: ["JSONLegacy"]),
        .library(name: "JavaScriptPersistence", targets: ["JavaScriptPersistence"]),

        .library(name: "_JSON_SnippetsAnchor", targets: ["_JSON_SnippetsAnchor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-grammar", from: "0.5.0"),
        .package(url: "https://github.com/tayloraswift/dollup", from: "0.7.0"),
    ],
    targets: [
        .target(name: "JSONAST"),

        .target(
            name: "JSONDecoding",
            dependencies: [
                .target(name: "JSONAST"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]
        ),

        .target(
            name: "JSONEncoding",
            dependencies: [
                .target(name: "JSONAST"),
            ]
        ),

        .target(
            name: "JSONLegacy",
            dependencies: [
                .target(name: "JSONDecoding"),
            ]
        ),

        .target(
            name: "JSONParsing",
            dependencies: [
                .target(name: "JSONAST"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]
        ),

        .target(
            name: "JSON",
            dependencies: [
                .target(name: "JSONDecoding"),
                .target(name: "JSONEncoding"),
                .target(name: "JSONParsing"),
            ]
        ),

        .target(
            name: "JavaScriptPersistence",
            dependencies: [
                .target(name: "JSON"),
            ]
        ),

        .testTarget(
            name: "JSONTests",
            dependencies: [
                .target(name: "JSON"),
            ]
        ),


        .target(
            name: "_JSON_SnippetsAnchor",
            dependencies: [
                .target(name: "JSON"),
            ],
            path: "Snippets/_Anchor",
            linkerSettings: [
                .linkedLibrary("m"),
            ],
        ),
    ]
)
