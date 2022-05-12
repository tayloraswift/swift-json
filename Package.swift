// swift-tools-version:5.5
import PackageDescription

var executable:(products:[Product], targets:[Target]) 
executable.products = 
[
    .executable (name: "examples", targets: ["JSONExamples"]),
]
executable.targets =
[
    .executableTarget(name: "JSONExamples",
        dependencies: 
        [
            .target(name: "JSON"),
        ],
        path: "examples/",
        exclude: 
        [
        ]),
]
#if os(Linux)
executable.products.append(.executable(name: "benchmarks", targets: ["JSONBenchmarks"]))
executable.targets.append(.executableTarget(name: "JSONBenchmarks",
    dependencies: 
    [
        .target(name: "JSON"),
    ],
    path: "benchmarks/",
    exclude: 
    [
        "script",
    ]))
#endif

// cannot build the documentation plugin on these platforms due to 
// https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/1299#issuecomment-1089950219
// cannot build the documentation plugin on windows since apparently 
// the PackagePlugin module is not available
#if swift(>=5.6) && !os(iOS) && !os(tvOS) && !os(watchOS) && !os(Windows)
let future:[Package.Dependency] = 
[
    .package(url: "https://github.com/swift-biome/swift-documentation-extract", from: "0.2.0")
]
#else 
let future:[Package.Dependency] = []
#endif

let package:Package = .init(
    name: "swift-json",
    products: executable.products +
    [
        .library(name: "JSON", targets: ["JSON"]),
    ],
    dependencies: future +
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", from: "0.1.5"),
    ],
    targets: executable.targets +
    [
        .target(name: "JSON", 
            dependencies: 
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ],
            path: "sources/", 
            exclude: 
            [
            ]),
    ]
)
