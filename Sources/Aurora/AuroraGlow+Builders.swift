import SwiftUI

extension AuroraGlow {
  public func cornerRadius(
    _ value: CGFloat
  ) -> Self {
    with(\.cornerRadius,value)
  }
  
  public func borderWidth(
    _ value: CGFloat
  ) -> Self  {
    with(\.borderWidth, value)
  }
  
  public func glowSize(
    _ value: CGFloat
  ) -> Self {
    with(\.glowSize,value)
  }
  
  public func speed(
    _ value: Double
  ) -> Self {
    with(\.speed,value)
  }
  
  public func burstsOnAppear(
    _ value: Bool
  ) -> Self {
    with(\.burstsOnAppear, value)
  }

  public func introOnAppear(
    _ value: Bool
  ) -> Self {
    with(\.introOnAppear, value)
  }

  public func washSweepDuration(
    _ value: Float
  ) -> Self {
    with(\.washSweepDuration, value)
  }

  public func washPulseWidth(
    _ value: Float
  ) -> Self {
    with(\.washPulseWidth, value)
  }

  public func washPeak(
    _ value: Float
  ) -> Self {
    with(\.washPeak, value)
  }

  public func direction(
    _ value: Direction
  ) -> Self {
    with(\.direction, value)
  }

  public func introStyle(
    _ value: IntroStyle
  ) -> Self {
    with(\.introStyle, value)
  }

  public func introDuration(
    _ value: Float
  ) -> Self {
    with(\.introDuration, value)
  }

  public func palette(
    _ value: Palette
  ) -> Self {
    with(\.palette, value)
  }

  public func mood(
    _ value: Mood
  ) -> Self {
    guard value != .neutral else { return self }
    var copy = self
    copy.palette = value.palette
    copy.speed = self.speed * value.speedMultiplier
    return copy
  }

  public func isVisible(
    _ value: Bool
  ) -> Self {
    with(\.isVisible, value)
  }

  public func outroStyle(
    _ value: OutroStyle
  ) -> Self {
    with(\.outroStyle, value)
  }

  public func outroDuration(
    _ value: Float
  ) -> Self {
    with(\.outroDuration, value)
  }

  public func burster(
    _ value: Burster?
  ) -> Self {
    with(\.burster, value)
  }
  
  private func with<T>(
    _ keyPath: WritableKeyPath<Self,T>,
    _ value: T
  ) -> Self {
    var copy = self
    copy[keyPath: keyPath] = value
    return copy
  }
}
