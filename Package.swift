// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "swift-json",
    products: 
    [
        .library    (name: "JSON",          targets: ["JSON"]),
    
        .executable (name: "examples",      targets: ["JSONExamples"]),
        .executable (name: "benchmarks",    targets: ["JSONBenchmarks"]),
        .executable (name: "proportions",   targets: ["Proportions"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", from: "0.1.0")
    ],
    targets: 
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
)
