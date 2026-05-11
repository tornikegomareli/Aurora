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
    )
  ]
)
