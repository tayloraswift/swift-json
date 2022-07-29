// swift-tools-version:5.4
import PackageDescription
// note: this manifest is exactly the same as `Package@swift-5.3.swift`. it’s 
// needed because of the following SPM error:
// error: the package manifest at '/Package@swift-5.4.swift' cannot be accessed 
// (InternalError(description: "Internal error. Please file a bug at https://bugs.swift.org with this info. symlinks not supported"))

let package:Package = .init(
    name: "swift-json",
    products:
    [
        .library(name: "JSON", targets: ["JSON"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", from: "0.1.5")
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
