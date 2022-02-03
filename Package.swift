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
    ],
    targets: 
    [
        .target(name: "JSON", 
            path: "sources/", 
            exclude: 
            [
                "grammar/README.md",
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
            ],
            path: "proportions/",
            exclude: 
            [
                "grammar/README.md",
            ]),
    ]
)
