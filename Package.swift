// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Aurora",
  platforms: [
    .iOS(.v17),
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "Aurora",
      targets: ["Aurora"]
    ),
  ],
  targets: [
    .target(
      name: "Aurora",
      // Compiled into Metallibs/ by Scripts/build_metallibs.sh: command-line SwiftPM can't compile Metal.
      exclude: ["AuroraGlow.metal"],
      resources: [.copy("Metallibs")]
    ),
    .testTarget(
      name: "AuroraTests",
      dependencies: ["Aurora"]
    ),
  ]
)
