import Foundation

extension AuroraGlow {
  /// Semantic mood presets — a shortcut for setting both `palette`
  /// and `speed` together to communicate state (listening to user
  /// input, thinking, error, success). Apply via `.mood(_:)`.
  /// `.neutral` is a no-op.
  public enum Mood: String, CaseIterable, Hashable, Sendable {
    case neutral
    case listening
    case thinking
    case error
    case success

    internal var palette: Palette {
      switch self {
      case .neutral, .listening: return .appleIntelligence
      case .thinking: return .ocean
      case .error:
        return Palette(
          base: SIMD3(0.70, 0.15, 0.10),
          anchors: [
            SIMD3(1.00, 0.20, 0.15),
            SIMD3(1.00, 0.45, 0.25),
            SIMD3(0.85, 0.10, 0.35),
            SIMD3(1.00, 0.30, 0.20),
          ]
        )
      case .success:
        return Palette(
          base: SIMD3(0.15, 0.60, 0.30),
          anchors: [
            SIMD3(0.20, 0.90, 0.40),
            SIMD3(0.40, 0.85, 0.55),
            SIMD3(0.15, 0.75, 0.50),
            SIMD3(0.60, 0.95, 0.35),
          ]
        )
      }
    }

    internal var speedMultiplier: Double {
      switch self {
      case .listening: return 1.5
      case .thinking:  return 0.6
      default:         return 1.0
      }
    }
  }
}
