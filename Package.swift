// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Aurora",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "Aurora",
      targets: ["Aurora"]
    ),
  ],
  targets: [
    .target(
      name: "Aurora"
    ),
    // Demo views that exercise the public API. Not part of the
    // shipped `Aurora` product, so consumers of the library don't
    // pull this in. Useful for in-package Xcode previews and for
    // example apps that depend on the package directly.
    .target(
      name: "AuroraExamples",
      dependencies: ["Aurora"],
      path: "Examples/AuroraExamples"
    ),
    .testTarget(
      name: "AuroraTests",
      dependencies: ["Aurora"]
    ),
  ]
)
