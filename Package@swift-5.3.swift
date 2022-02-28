// swift-tools-version:5.3
import PackageDescription

let executable:(products:[Product], targets:[Target]) 

executable.products = []
executable.targets  = []

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
