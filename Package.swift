// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OrderedDictionary",
    products: [
        .library(name: "OrderedDictionary", targets: ["OrderedDictionary"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "OrderedDictionary", dependencies: []),
        .testTarget(name: "OrderedDictionaryTests", dependencies: ["OrderedDictionary"]),
    ]
)
