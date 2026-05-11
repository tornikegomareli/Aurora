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

  public func washOriginX(
    _ value: Float
  ) -> Self {
    with(\.washOriginX, value)
  }

  public func washOriginY(
    _ value: Float
  ) -> Self {
    with(\.washOriginY, value)
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
