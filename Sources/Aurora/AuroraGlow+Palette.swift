import Foundation

extension AuroraGlow {
  /// The colours the metaball blend cycles through. `base` is the
  /// dark-side starting colour each pixel begins at before anchors
  /// pull it toward their tints; `anchors` is exactly four colours
  /// that the eleven anchor points cycle through in a fixed pattern.
  public struct Palette: Sendable, Equatable {
    public var base: SIMD3<Float>
    public var anchors: [SIMD3<Float>]

    public init(base: SIMD3<Float>, anchors: [SIMD3<Float>]) {
      precondition(anchors.count == 4, "Palette requires exactly 4 anchor colors")
      self.base = base
      self.anchors = anchors
    }

    /// The default — purple / pink / orange / cyan over a cyan base.
    /// Reproduces the visual feel of Apple's long-press intro.
    public static let appleIntelligence = Palette(
      base: SIMD3(0.000, 0.588, 1.000),
      anchors: [
        SIMD3(0.983, 0.392, 1.000),
        SIMD3(1.000, 0.145, 0.333),
        SIMD3(1.000, 0.577, 0.000),
        SIMD3(0.000, 0.588, 1.000),
      ]
    )

    /// Golden-hour warm — yellows, oranges, magentas.
    public static let sunset = Palette(
      base: SIMD3(0.95, 0.55, 0.25),
      anchors: [
        SIMD3(1.000, 0.450, 0.150),
        SIMD3(0.950, 0.250, 0.350),
        SIMD3(0.850, 0.200, 0.550),
        SIMD3(1.000, 0.700, 0.300),
      ]
    )

    /// Cool — teals, cyans, ocean blues.
    public static let ocean = Palette(
      base: SIMD3(0.10, 0.40, 0.60),
      anchors: [
        SIMD3(0.200, 0.800, 0.900),
        SIMD3(0.300, 0.900, 0.850),
        SIMD3(0.150, 0.500, 0.850),
        SIMD3(0.200, 0.750, 0.700),
      ]
    )

    /// Greens — forest, lime, mint, emerald.
    public static let forest = Palette(
      base: SIMD3(0.15, 0.50, 0.20),
      anchors: [
        SIMD3(0.600, 0.850, 0.250),
        SIMD3(0.400, 0.900, 0.550),
        SIMD3(0.550, 0.700, 0.300),
        SIMD3(0.150, 0.700, 0.400),
      ]
    )

    /// Grayscale — no colour, just luminance gradient.
    public static let monochrome = Palette(
      base: SIMD3(0.30, 0.30, 0.30),
      anchors: [
        SIMD3(1.000, 1.000, 1.000),
        SIMD3(0.750, 0.750, 0.750),
        SIMD3(0.500, 0.500, 0.500),
        SIMD3(0.900, 0.900, 0.900),
      ]
    )

    /// Neon — high-saturation pink, electric blue, lime, neon purple.
    public static let cyberpunk = Palette(
      base: SIMD3(0.20, 0.10, 0.40),
      anchors: [
        SIMD3(1.000, 0.200, 0.700),
        SIMD3(0.200, 0.700, 1.000),
        SIMD3(0.400, 1.000, 0.300),
        SIMD3(0.700, 0.200, 1.000),
      ]
    )
  }
}
