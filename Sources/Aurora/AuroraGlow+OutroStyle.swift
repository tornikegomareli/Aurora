import Foundation

extension AuroraGlow {
  /// How the glow should disappear when `isVisible` flips to `false`.
  public enum OutroStyle: String, CaseIterable, Hashable, Sendable {
    /// Alpha fades to zero across `outroDuration`.
    case dissolve

    /// Band shrinks back to zero thickness — the reverse of the
    /// `.thicknessGrow` intro.
    case shrinkInward

    internal var shaderValue: Float {
      switch self {
      case .dissolve:     return 0.0
      case .shrinkInward: return 1.0
      }
    }
  }
}
