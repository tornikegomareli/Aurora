import Foundation

extension AuroraGlow {
  public enum Style: String, CaseIterable, Hashable, Sendable {
    case subtle
    case standard
    case dramatic

    public var profile: Profile {
      switch self {
      case .subtle:
        return Profile(
          anchorAmpBoost: 0.22,
          anchorSpeedBoost: 1.4,
          flameAmpBoost: 1.2,
          brightnessPop: 0.18,
          decayRate: 1.4,
          flameBaseline: 0.30
        )
      case .standard:
        return Profile(
          anchorAmpBoost: 0.38,
          anchorSpeedBoost: 2.2,
          flameAmpBoost: 2.0,
          brightnessPop: 0.32,
          decayRate: 1.6,
          flameBaseline: 0.45
        )
      case .dramatic:
        return Profile(
          anchorAmpBoost: 0.55,
          anchorSpeedBoost: 3.5,
          flameAmpBoost: 4.0,
          brightnessPop: 0.45,
          decayRate: 1.5,
          flameBaseline: 0.55
        )
      }
    }
  }

  public struct Profile: Sendable, Equatable {
    public var anchorAmpBoost: Float
    public var anchorSpeedBoost: Float
    public var flameAmpBoost: Float
    public var brightnessPop: Float
    public var decayRate: Float
    public var flameBaseline: Float

    public init(
      anchorAmpBoost: Float,
      anchorSpeedBoost: Float,
      flameAmpBoost: Float,
      brightnessPop: Float,
      decayRate: Float,
      flameBaseline: Float
    ) {
      self.anchorAmpBoost = anchorAmpBoost
      self.anchorSpeedBoost = anchorSpeedBoost
      self.flameAmpBoost = flameAmpBoost
      self.brightnessPop = brightnessPop
      self.decayRate = decayRate
      self.flameBaseline = flameBaseline
    }
  }
}
