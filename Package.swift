// swift-tools-version:5.5
import PackageDescription

let executable:(products:[Product], targets:[Target]) 
executable.products = 
[
    .executable (name: "examples",      targets: ["JSONExamples"]),
    .executable (name: "benchmarks",    targets: ["JSONBenchmarks"]),
    .executable (name: "proportions",   targets: ["Proportions"]),
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
    .executableTarget(name: "JSONBenchmarks",
        dependencies: 
        [
            .target(name: "JSON"),
        ],
        path: "benchmarks/",
        exclude: 
        [
            "script",
        ]),
    .executableTarget(name: "Proportions",
        dependencies: 
        [
            .product(name: "Grammar", package: "swift-grammar"),
        ],
        path: "proportions/",
        exclude: 
        [
        ]),
]

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
