// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "swift-json",
    products: 
    [
        .library    (name: "swift-json", targets: ["JSON"]),
        .executable (name: "benchmarks", targets: ["JSONBenchmarks"]),
    ],
    dependencies: [],
    targets: 
    [
        .target(name: "JSON", 
            path: "sources/", 
            exclude: 
            [
                "grammar/README.md",
            ]),
        .executableTarget(name: "JSONBenchmarks",
            dependencies: 
            [
                .target(name: "JSON"),
            ],
            path: "benchmarks/",
            exclude: 
            [
            ]),
    ]
)
