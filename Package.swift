// swift-tools-version:5.5
import PackageDescription

var executable:(products:[Product], targets:[Target]) 
executable.products = 
[
    .executable (name: "examples", targets: ["Examples"]),
]
executable.targets =
[
    .executableTarget(name: "Examples",
        dependencies: 
        [
            .target(name: "JSON"),
        ],
        path: "Examples/",
        exclude: 
        [
        ]),
]
#if os(Linux)
executable.products.append(.executable(name: "benchmarks", targets: ["Benchmarks"]))
executable.targets.append(.executableTarget(name: "Benchmarks",
    dependencies: 
    [
        .target(name: "JSON"),
    ]))
#endif

// cannot build the documentation plugin on these platforms due to 
// https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/1299#issuecomment-1089950219
// cannot build the documentation plugin on windows since apparently 
// the PackagePlugin module is not available
#if swift(>=5.6) && (os(Linux) || os(macOS))
let plugins:[Package.Dependency] = 
[
    .package(url: "https://github.com/kelvin13/swift-package-catalog", from: "0.2.1")
]
#else 
let plugins:[Package.Dependency] = []
#endif

let package:Package = .init(
    name: "swift-json",
    products: executable.products +
    [
        .library(name: "JSON", targets: ["JSON"]),
    ],
    dependencies: plugins +
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", from: "0.1.5"),
    ],
    targets: executable.targets +
    [
        .target(name: "JSON", 
            dependencies: 
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),
    ]
)
