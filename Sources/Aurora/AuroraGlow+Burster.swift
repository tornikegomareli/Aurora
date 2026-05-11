import Foundation
import Observation

extension AuroraGlow {
  /// Hold one as `@State`, attach via `.burster(_:)`, and call `fire()`
  /// to re-run the intro animation. Main-actor-isolated — from off-main
  /// callers (TCA effects, detached tasks, NotificationCenter handlers)
  /// hop first: `Task { @MainActor in burster.fire() }`.
  @Observable
  @MainActor
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
