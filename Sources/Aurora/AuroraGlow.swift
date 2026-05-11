import SwiftUI

public struct AuroraGlow: View {
  public var profile: Profile
  public var cornerRadius: CGFloat = 55
  public var borderWidth: CGFloat = 6
  public var glowSize: CGFloat = 28
  public var speed: Double = 0.12
  public var burstsOnAppear: Bool = true
  public var introOnAppear: Bool = true
  public var washSweepDuration: Float = 0.32
  public var washPulseWidth: Float = 0.22
  public var washPeak: Float = 0.28
  public var burster: Burster?

  @State private var startDate = Date()
  @State private var burstStartDate: Date? = nil
  @State private var introStartDate: Date? = nil

  public init(_ style: Style = .standard) {
    self.profile = style.profile
  }

  public init(profile: Profile) {
    self.profile = profile
  }

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
      let now = Date()
      if introOnAppear { introStartDate = now }
      if burstsOnAppear { burstStartDate = now }
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
    let introElapsed: Double = introStartDate.map {
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
          .float(introElapsed),
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
          ),
          .float3(
            CGFloat(washSweepDuration),
            CGFloat(washPulseWidth),
            CGFloat(washPeak)
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
