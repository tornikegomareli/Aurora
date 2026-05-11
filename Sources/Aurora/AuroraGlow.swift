import SwiftUI

public struct AuroraGlow: View {
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
  
  public var profile: Profile
  public var cornerRadius: CGFloat = 55
  public var borderWidth: CGFloat = 6
  public var glowSize: CGFloat = 28
  public var speed: Double = 0.12
  public var burstsOnAppear: Bool = true
  public var burster: Burster?
  
  public init(_ style: Style = .standard) {
    self.profile = style.profile
  }
  
  public init(profile: Profile) {
    self.profile = profile
  }
  
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
  
  @State private var startDate = Date()
  @State private var burstStartDate: Date? = nil
  
  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation) { context in
        glowRect(in: proxy.size, at: context.date)
      }
    }
    .compositingGroup()
    .allowsHitTesting(false)
    .accessibilityHidden(true)
    .onAppear {
      if burstsOnAppear { burstStartDate = Date() }
    }
    .onChange(of: burster?.lastFiredAt) { _, newValue in
      if let newValue { burstStartDate = newValue }
    }
  }
  
  private func glowRect(in size: CGSize, at now: Date) -> some View {
    let elapsed = now.timeIntervalSince(startDate)
    let burstElapsed: Double = burstStartDate.map {
      now.timeIntervalSince($0)
    } ?? -1.0
    let t = profile
    return Rectangle()
      .colorEffect(
        ShaderLibrary.bundle(.module).auroraGlow(
          .float2(size),
          .float(elapsed * speed),
          .float(cornerRadius),
          .float(borderWidth),
          .float(glowSize),
          .float(burstElapsed),
          .float4(
            CGFloat(t.anchorAmpBoost),
            CGFloat(t.anchorSpeedBoost),
            CGFloat(t.flameAmpBoost),
            CGFloat(t.brightnessPop)
          ),
          .float4(
            CGFloat(t.decayRate),
            CGFloat(t.flameBaseline),
            0.0,
            0.0
          )
        )
      )
  }
}

#Preview("Subtle") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.subtle).ignoresSafeArea()
  }
}

#Preview("Standard") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.standard).ignoresSafeArea()
  }
}

#Preview("Dramatic") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.dramatic).ignoresSafeArea()
  }
}

#Preview("Inset card") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.standard)
      .cornerRadius(24)
      .borderWidth(4)
      .glowSize(18)
      .frame(width: 280, height: 360)
  }
}
