// swift-tools-version:5.3
import PackageDescription

let package:Package = .init(
    name: "swift-json",
    products:
    [
        .library(name: "JSON", targets: ["JSON"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", .upToNextMinor(from: "0.2.0"))
    ],
    targets:
    [
        .target(name: "JSON", 
            dependencies: 
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),
    ]
)
