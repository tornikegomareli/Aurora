import Foundation

extension AuroraGlow {
  public enum Direction: String, CaseIterable, Hashable, Sendable {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop

    /// Unit vector in screen-space (Metal/SwiftUI y-down) pointing in
    /// the direction the wave/fill travels.
    internal var vector: SIMD2<Float> {
      switch self {
      case .leftToRight: return SIMD2(1, 0)
      case .rightToLeft: return SIMD2(-1, 0)
      case .topToBottom: return SIMD2(0, 1)
      case .bottomToTop: return SIMD2(0, -1)
      }
    }
  }
}
