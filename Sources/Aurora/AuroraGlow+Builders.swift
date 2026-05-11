import SwiftUI

extension AuroraGlow {
  public func cornerRadius(_ value: CGFloat) -> Self {
    var copy = self
    copy.cornerRadius = value
    return copy
  }

  public func borderWidth(_ value: CGFloat) -> Self {
    var copy = self
    copy.borderWidth = value
    return copy
  }

  public func glowSize(_ value: CGFloat) -> Self {
    var copy = self
    copy.glowSize = value
    return copy
  }

  public func speed(_ value: Double) -> Self {
    var copy = self
    copy.speed = value
    return copy
  }

  public func burstsOnAppear(_ value: Bool) -> Self {
    var copy = self
    copy.burstsOnAppear = value
    return copy
  }

  public func burster(_ value: Burster?) -> Self {
    var copy = self
    copy.burster = value
    return copy
  }
}
