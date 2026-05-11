import Foundation
import Observation

extension AuroraGlow {
  /// Hold one as `@State`, attach via `.burster(_:)`, and call `fire()`
  /// from anywhere to re-run the intro animation.
  @Observable
  public final class Burster {
    public private(set) var lastFiredAt: Date?

    public init() {
      self.lastFiredAt = nil
    }

    public func fire() {
      lastFiredAt = Date()
    }
  }
}
