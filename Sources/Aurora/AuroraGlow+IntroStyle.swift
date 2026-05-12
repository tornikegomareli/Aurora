import Foundation

extension AuroraGlow {
  /// How the edge ring should appear on first mount.
  public enum IntroStyle: String, CaseIterable, Hashable, Sendable {
    /// Band scales from invisible to full thickness, growing inward
    /// on all four sides simultaneously. The original default.
    case thicknessGrow

    /// Band stays at full thickness but is masked so it appears to
    /// "fill" the perimeter starting from the `direction`'s start
    /// edge, sweeping around the rounded rect and meeting itself on
    /// the opposite side. Reads like a frame drawing itself.
    case borderFill

    internal var shaderValue: Float {
      switch self {
      case .thicknessGrow: return 0.0
      case .borderFill:    return 1.0
      }
    }
  }
}
