// swift-tools-version:5.5
import PackageDescription

let package:Package = .init(
    name: "swift-json-benchmarks",
    products: 
    [
        .executable(name: "benchmark", targets: ["GeneralDecoding"]),
        .executable(name: "benchmark-aws-ipam", targets: ["AmazonIPAddressManager"]),
    ],
    dependencies: 
    [
        .package(name: "swift-json", path: ".."),

        .package(url: "https://github.com/kelvin13/swift-system-extras", from: "0.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser",  from: "1.1.3"),
    ],
    targets: 
    [
        .executableTarget(name: "GeneralDecoding",
            dependencies: 
            [
                .product(name: "JSON", package: "swift-json"),
                .product(name: "SystemExtras", package: "swift-system-extras"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .executableTarget(name: "AmazonIPAddressManager",
            dependencies: 
            [
                .product(name: "JSON", package: "swift-json"),
                .product(name: "SystemExtras", package: "swift-system-extras"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ]
)
