import SwiftUI

/// Apple-Intelligence-inspired glow ring rendered by a single Metal
/// fragment shader.
///
/// ## Use
/// ```swift
/// AuroraGlow(style: .standard).ignoresSafeArea()
/// ```
///
/// ## Style
///
/// `Style` picks one of three pre-tuned looks; each maps to a different
/// set of shader uniforms covering burst amplitude, anchor speed, flame
/// strength, decay rate, and steady-state baseline. Pick by feel:
///
/// - `.subtle`    — gentle steady-state, soft intro, minimal flames
/// - `.standard`  — recommended default; moderate burst, restrained flames
/// - `.dramatic`  — energetic intro, big flames lapping inward; closest to
///                  the Apple Intelligence first-launch animation
///
/// ## Burst
///
/// `burstTrigger` is an opaque `Hashable`. Whenever its value changes the
/// shader's burst envelope re-fires from `t = 0`. The first burst happens
/// on appear unless `burstsOnAppear` is `false`.
///
/// ```swift
/// @State private var burst = 0
/// AuroraGlow(burstTrigger: burst)
/// Button("Burst") { burst &+= 1 }
/// ```
///
/// ## Parameters
/// - `style`: a `Style` preset selecting the burst feel.
/// - `cornerRadius`: outer rounded-rect radius. Default `55`.
/// - `borderWidth`: width of the sharp inner ring. Default `6`.
/// - `glowSize`: outer aura extent in points. Default `28`.
/// - `speed`: baseline anchor animation rate. Default `0.12`. The burst
///   envelope scales this on top.
/// - `burstsOnAppear`: trigger an initial burst when mounted. Default `true`.
/// - `burstTrigger`: change to re-fire the burst.
///
/// ## Platform
/// iOS 17+.
public struct AuroraGlow: View {

  // MARK: - Style

  /// Pre-tuned variant of the animation. Each style maps to a fixed
  /// `Profile` that gets handed to the shader. Pick by feel — see the
  /// component-level doc comment for guidance.
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

  /// The numeric knobs that drive the shader. A `Style` is a named
  /// preset; a `Profile` is the actual values that get sent to the
  /// shader's two `float4` uniforms. Build one by hand to dial in a
  /// custom feel without picking one of the presets.
  public struct Profile: Sendable, Equatable {
    /// Damped-cosine amplitude added to anchor amplitude at burst start.
    /// Anchors visibly bounce outward and back. Higher = bigger bounce.
    public var anchorAmpBoost: Float

    /// Exponential boost added to anchor animation speed at burst start.
    /// Higher = faster colour churn during the intro.
    public var anchorSpeedBoost: Float

    /// Exponential boost added to the flame overlay's amplitude. Higher
    /// = bigger inward-reaching flame tongues during burst.
    public var flameAmpBoost: Float

    /// Exponential brightness pop applied uniformly at burst start.
    public var brightnessPop: Float

    /// Decay rate of all envelopes (1 / seconds). Higher = settles faster.
    public var decayRate: Float

    /// Flame overlay amplitude in steady state. Even at rest, flames
    /// remain at this fraction so the boundary has organic life.
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

  // MARK: - Public API

  public var style: Style
  public var cornerRadius: CGFloat
  public var borderWidth: CGFloat
  public var glowSize: CGFloat
  public var speed: Double
  public var burstsOnAppear: Bool
  public var burstTrigger: AnyHashable?

  public init(
    style: Style = .standard,
    cornerRadius: CGFloat = 55,
    borderWidth: CGFloat = 6,
    glowSize: CGFloat = 28,
    speed: Double = 0.12,
    burstsOnAppear: Bool = true,
    burstTrigger: AnyHashable? = nil
  ) {
    self.style = style
    self.cornerRadius = cornerRadius
    self.borderWidth = borderWidth
    self.glowSize = glowSize
    self.speed = speed
    self.burstsOnAppear = burstsOnAppear
    self.burstTrigger = burstTrigger
  }

  // MARK: - Internal state

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
    .onChange(of: burstTrigger) { _, _ in
      burstStartDate = Date()
    }
  }

  private func glowRect(in size: CGSize, at now: Date) -> some View {
    let elapsed = now.timeIntervalSince(startDate)
    let burstElapsed: Double = burstStartDate.map {
      now.timeIntervalSince($0)
    } ?? -1.0
    let t: Profile = style.profile
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
    AuroraGlow(style: .subtle).ignoresSafeArea()
  }
}

#Preview("Standard") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(style: .standard).ignoresSafeArea()
  }
}

#Preview("Dramatic") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(style: .dramatic).ignoresSafeArea()
  }
}

#Preview("Inset card · standard") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(
      style: .standard,
      cornerRadius: 24,
      borderWidth: 4,
      glowSize: 18
    )
    .frame(width: 280, height: 360)
  }
}
