// swift-tools-version:5.5
import PackageDescription

// cannot build the documentation plugin on these platforms due to 
// https://github.com/SwiftPackageIndex/SwiftPackageIndex-Server/issues/1299#issuecomment-1089950219
// cannot build the documentation plugin on windows since apparently 
// the PackagePlugin module is not available

// because the 5.6 compiler can recognize snippets, but not ignore them (?!), 
// invoking the plugin on 5.6 will always fail, because the SPM does not know 
// how to exclude targets it does not know how to serialize.
// the snippets directory path is hard-coded in the compiler, and since we 
// don’t have another way to conditionally exclude snippets from compilation, 
// there is no way to work around this other than only enabling the plugin on 
// nightly toolchains.
#if swift(>=5.7) && (os(Linux) || os(macOS))
let plugins:[Package.Dependency] = 
[
    .package(url: "https://github.com/kelvin13/swift-package-catalog", from: "0.2.1")
]
#else 
let plugins:[Package.Dependency] = []
#endif

let package:Package = .init(
    name: "swift-json",
    products:
    [
        .library(name: "JSON", targets: ["JSON"]),
    ],
    dependencies: plugins +
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", from: "0.1.5"),
    ],
    targets:
    [
        .target(name: "JSON", 
            dependencies: 
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),
        
        .target(name: "_BSON", 
            dependencies: 
            [
                .product(name: "Grammar", package: "swift-grammar"),
            ]),
    ]
)
