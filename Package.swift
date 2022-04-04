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

#if swift(>=5.6)
let future:[Package.Dependency] = 
[
    .package(url: "https://github.com/swift-biome/swift-documentation-extract", from: "0.1.1")
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
        .package(url: "https://github.com/kelvin13/swift-grammar", from: "0.1.4"),
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
