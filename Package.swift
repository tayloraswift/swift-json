// swift-tools-version:5.5
import PackageDescription

var executable:(products:[Product], targets:[Target]) 
executable.products = 
[
    .executable (name: "examples",      targets: ["JSONExamples"]),
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
executable.products.append(.executable(name: "proportions", targets: ["Proportions"]))
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
executable.targets.append(.executableTarget(name: "Proportions",
    dependencies: 
    [
        .product(name: "Grammar", package: "swift-grammar"),
    ],
    path: "proportions/",
    exclude: 
    [
    ]))
#endif

let package:Package = .init(
    name: "swift-json",
    products: executable.products +
    [
        .library(name: "JSON", targets: ["JSON"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", from: "0.1.2")
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
