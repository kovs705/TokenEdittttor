//
//  Package.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TokenEditttor",
    platforms: [
        .iOS(.v17),
        .macCatalyst(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TokenEditttor",
            targets: ["TokenEditttor"]
        )
    ],
    targets: [
        .target(
            name: "TokenEditttor",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TokenEditttorTests",
            dependencies: ["TokenEditttor"]
        )
    ]
)
