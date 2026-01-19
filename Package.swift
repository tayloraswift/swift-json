// swift-tools-version:6.2
import PackageDescription

let package: Package = .init(
    name: "swift-json",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "JSON", targets: ["JSON"]),
        .library(name: "JSONAST", targets: ["JSONAST"]),
        .library(name: "JSONLegacy", targets: ["JSONLegacy"]),
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

        .testTarget(
            name: "JSONTests",
            dependencies: [
                .target(name: "JSON"),
            ]
        ),
    ]
)
package.targets = package.targets.map {
    switch $0.type {
    case .plugin: return $0
    case .binary: return $0
    default: break
    }
    {
        var settings: [SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.treatWarning("ExistentialAny", as: .error))
        settings.append(.treatWarning("MutableGlobalVariable", as: .error))

        $0 = settings
    } (&$0.swiftSettings)
    return $0
}
