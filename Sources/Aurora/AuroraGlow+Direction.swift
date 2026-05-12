import Foundation

extension AuroraGlow {
  public enum Direction: String, CaseIterable, Hashable, Sendable {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop

    /// Unit vector pointing in the direction the wave/fill travels.
    /// The Y sign is the *visual* one — `.topToBottom` produces a
    /// downward sweep on screen (positive Y in our atan2-based
    /// perimeter map corresponds to the bottom edge of the rect).
    internal var vector: SIMD2<Float> {
      switch self {
      case .leftToRight: return SIMD2(1, 0)
      case .rightToLeft: return SIMD2(-1, 0)
      case .topToBottom: return SIMD2(0, -1)
      case .bottomToTop: return SIMD2(0, 1)
      }
    }
  }
}
